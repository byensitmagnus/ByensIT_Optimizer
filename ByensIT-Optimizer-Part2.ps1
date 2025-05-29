#Requires -RunAsAdministrator
<#
.SYNOPSIS
    ByensIT Optimizer - Part 2: Debloat & Privacy
.DESCRIPTION
    Fjerner bloatware, UWP apps og forbedrer privatliv ved at deaktivere telemetri.
.AUTHOR
    Byens IT - magnususmo@hotmail.dk
.VERSION
    1.0.0
#>

param(
    [switch]$Silent = $false,
    [string]$LogPath = "$PSScriptRoot\Logs"
)

# Import fælles funktioner
. "$PSScriptRoot\Common-Functions.ps1" -ErrorAction SilentlyContinue

function Write-ByensLog {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    if (!(Test-Path $LogPath)) {
        New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
    }
    
    $logFile = Join-Path $LogPath "ByensIT-Optimizer-$(Get-Date -Format 'yyyy-MM-dd').log"
    Add-Content -Path $logFile -Value $logMessage
    
    if (!$Silent) {
        switch ($Level) {
            "ERROR" { Write-Host $logMessage -ForegroundColor Red }
            "WARN" { Write-Host $logMessage -ForegroundColor Yellow }
            default { Write-Host $logMessage -ForegroundColor Green }
        }
    }
}

function Remove-BloatwareApps {
    try {
        Write-ByensLog "Starter fjernelse af bloatware apps..."
        
        # Liste over apps der skal fjernes
        $bloatwareApps = @(
            "Microsoft.3DBuilder",
            "Microsoft.BingWeather",
            "Microsoft.GetHelp",
            "Microsoft.Getstarted",
            "Microsoft.Messaging",
            "Microsoft.Microsoft3DViewer",
            "Microsoft.MicrosoftOfficeHub",
            "Microsoft.MicrosoftSolitaireCollection",
            "Microsoft.MixedReality.Portal",
            "Microsoft.OneConnect",
            "Microsoft.People",
            "Microsoft.Print3D",
            "Microsoft.SkypeApp",
            "Microsoft.Wallet",
            "Microsoft.WindowsCamera",
            "Microsoft.WindowsFeedbackHub",
            "Microsoft.WindowsMaps",
            "Microsoft.WindowsSoundRecorder",
            "Microsoft.Xbox.TCUI",
            "Microsoft.XboxApp",
            "Microsoft.XboxGameOverlay",
            "Microsoft.XboxGamingOverlay",
            "Microsoft.XboxIdentityProvider",
            "Microsoft.XboxSpeechToTextOverlay",
            "Microsoft.YourPhone",
            "Microsoft.ZuneMusic",
            "Microsoft.ZuneVideo",
            "*Disney*",
            "*Netflix*",
            "*Spotify*",
            "*Twitter*",
            "*Facebook*",
            "*Candy*",
            "*March*",
            "*Solitaire*"
        )
        
        $removedCount = 0
        
        foreach ($app in $bloatwareApps) {
            try {
                $packages = Get-AppxPackage -Name $app -AllUsers -ErrorAction SilentlyContinue
                foreach ($package in $packages) {
                    Remove-AppxPackage -Package $package.PackageFullName -ErrorAction SilentlyContinue
                    Write-ByensLog "Fjernet: $($package.Name)"
                    $removedCount++
                }
                
                # Fjern provisioned packages (for nye brugere)
                $provisionedPackages = Get-AppxProvisionedPackage -Online | Where-Object { $_.DisplayName -like $app }
                foreach ($package in $provisionedPackages) {
                    Remove-AppxProvisionedPackage -Online -PackageName $package.PackageName -ErrorAction SilentlyContinue
                    Write-ByensLog "Fjernet provisioned: $($package.DisplayName)"
                }
            }
            catch {
                Write-ByensLog "Kunne ikke fjerne $app : $($_.Exception.Message)" -Level "WARN"
            }
        }
        
        Write-ByensLog "Bloatware removal completed - $removedCount apps fjernet"
        return $true
    }
    catch {
        Write-ByensLog "Fejl under bloatware fjernelse: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

function Disable-TelemetryServices {
    try {
        Write-ByensLog "Deaktiverer telemetri services..."
        
        $telemetryServices = @(
            "DiagTrack",
            "dmwappushservice",
            "RemoteRegistry",
            "TrkWks",
            "WMPNetworkSvc",
            "WSearch"
        )
        
        foreach ($service in $telemetryServices) {
            try {
                $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
                if ($svc) {
                    Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
                    Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
                    Write-ByensLog "Deaktiveret service: $service"
                }
            }
            catch {
                Write-ByensLog "Kunne ikke deaktivere service $service : $($_.Exception.Message)" -Level "WARN"
            }
        }
        
        return $true
    }
    catch {
        Write-ByensLog "Fejl ved deaktivering af telemetri services: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

function Disable-ScheduledTasks {
    try {
        Write-ByensLog "Deaktiverer unødvendige scheduled tasks..."
        
        $tasksToDisable = @(
            "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
            "Microsoft\Windows\Application Experience\ProgramDataUpdater",
            "Microsoft\Windows\Autochk\Proxy",
            "Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
            "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
            "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector",
            "Microsoft\Windows\Feedback\Siuf\DmClient",
            "Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload",
            "Microsoft\Windows\Windows Error Reporting\QueueReporting",
            "Microsoft\Windows\Application Experience\AitAgent",
            "Microsoft\Windows\Windows Error Reporting\QueueReporting"
        )
        
        foreach ($task in $tasksToDisable) {
            try {
                $schedTask = Get-ScheduledTask -TaskPath "*" -TaskName "*" -ErrorAction SilentlyContinue | Where-Object { $_.TaskPath -like "*$($task.Split('\')[-2])*" -and $_.TaskName -eq $task.Split('\')[-1] }
                if ($schedTask) {
                    Disable-ScheduledTask -TaskName $schedTask.TaskName -TaskPath $schedTask.TaskPath -ErrorAction SilentlyContinue
                    Write-ByensLog "Deaktiveret task: $task"
                }
            }
            catch {
                Write-ByensLog "Kunne ikke deaktivere task $task : $($_.Exception.Message)" -Level "WARN"
            }
        }
        
        return $true
    }
    catch {
        Write-ByensLog "Fejl ved deaktivering af scheduled tasks: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

function Set-PrivacySettings {
    try {
        Write-ByensLog "Konfigurerer privacy indstillinger..."
        
        # Registry paths for privacy settings
        $privacySettings = @{
            # Deaktiver advertising ID
            "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo" = @{
                "Enabled" = 0
            }
            # Deaktiver location tracking
            "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Sensor\Overrides\{BFA794E4-F964-4FDB-90F6-51056BFE4B44}" = @{
                "SensorPermissionState" = 0
            }
            # Deaktiver feedback requests
            "HKLM:\SOFTWARE\Microsoft\Siuf\Rules" = @{
                "NumberOfSIUFInPeriod" = 0
            }
            # Deaktiver telemetri
            "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" = @{
                "AllowTelemetry" = 0
            }
            # Deaktiver Windows tips
            "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" = @{
                "DisableWindowsConsumerFeatures" = 1
            }
        }
        
        foreach ($regPath in $privacySettings.Keys) {
            try {
                if (!(Test-Path $regPath)) {
                    New-Item -Path $regPath -Force | Out-Null
                }
                
                foreach ($setting in $privacySettings[$regPath].Keys) {
                    $value = $privacySettings[$regPath][$setting]
                    Set-ItemProperty -Path $regPath -Name $setting -Value $value -Type DWord -Force
                    Write-ByensLog "Set registry: $regPath\$setting = $value"
                }
            }
            catch {
                Write-ByensLog "Kunne ikke sætte registry $regPath : $($_.Exception.Message)" -Level "WARN"
            }
        }
        
        return $true
    }
    catch {
        Write-ByensLog "Fejl ved konfiguration af privacy settings: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

function Disable-CortanaAndSearch {
    try {
        Write-ByensLog "Deaktiverer Cortana og web search..."
        
        $cortanaSettings = @{
            "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" = @{
                "AllowCortana" = 0
                "AllowSearchToUseLocation" = 0
                "DisableWebSearch" = 1
                "ConnectedSearchUseWeb" = 0
            }
        }
        
        foreach ($regPath in $cortanaSettings.Keys) {
            try {
                if (!(Test-Path $regPath)) {
                    New-Item -Path $regPath -Force | Out-Null
                }
                
                foreach ($setting in $cortanaSettings[$regPath].Keys) {
                    $value = $cortanaSettings[$regPath][$setting]
                    Set-ItemProperty -Path $regPath -Name $setting -Value $value -Type DWord -Force
                    Write-ByensLog "Deaktiveret: $setting"
                }
            }
            catch {
                Write-ByensLog "Kunne ikke deaktivere Cortana setting: $($_.Exception.Message)" -Level "WARN"
            }
        }
        
        return $true
    }
    catch {
        Write-ByensLog "Fejl ved deaktivering af Cortana: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

function Start-DebloatAndPrivacy {
    Write-ByensLog "=== ByensIT Optimizer - Debloat & Privacy Started ==="
    
    $success = $true
    
    # Fjern bloatware apps
    $success = $success -and (Remove-BloatwareApps)
    
    # Deaktiver telemetri services
    $success = $success -and (Disable-TelemetryServices)
    
    # Deaktiver scheduled tasks
    $success = $success -and (Disable-ScheduledTasks)
    
    # Konfigurer privacy settings
    $success = $success -and (Set-PrivacySettings)
    
    # Deaktiver Cortana
    $success = $success -and (Disable-CortanaAndSearch)
    
    if ($success) {
        Write-ByensLog "=== Debloat & Privacy completed successfully ==="
    } else {
        Write-ByensLog "=== Debloat & Privacy completed with errors ===" -Level "WARN"
    }
    
    return $success
}

# Main execution
if ($MyInvocation.InvocationName -ne '.') {
    Start-DebloatAndPrivacy
} 