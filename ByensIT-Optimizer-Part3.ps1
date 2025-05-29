#Requires -RunAsAdministrator
<#
.SYNOPSIS
    ByensIT Optimizer - Part 3: Gaming Tweaks
.DESCRIPTION
    Gaming optimering inkluderer driver updates, HAGS, Ultimate Performance og gaming tweaks.
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

function Enable-UltimatePowerPlan {
    try {
        Write-ByensLog "Aktiverer Ultimate Performance power plan..."
        
        # Check if Ultimate Performance exists
        $ultimatePlan = powercfg /list | Select-String "Ultimate Performance"
        
        if (!$ultimatePlan) {
            # Enable Ultimate Performance plan
            powercfg /duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
            Write-ByensLog "Ultimate Performance plan oprettet"
        }
        
        # Get Ultimate Performance GUID
        $planGuid = (powercfg /list | Select-String "Ultimate Performance").ToString().Split()[3]
        
        # Set as active
        powercfg /setactive $planGuid
        Write-ByensLog "Ultimate Performance plan aktiveret: $planGuid"
        
        return $true
    }
    catch {
        Write-ByensLog "Fejl ved aktivering af Ultimate Performance: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

function Set-HighPerformanceSettings {
    try {
        Write-ByensLog "Konfigurerer high performance indstillinger..."
        
        # Deaktiver power throttling
        $powerSettings = @{
            "HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerThrottling" = @{
                "PowerThrottlingOff" = 1
            }
            # Gaming optimering registry tweaks
            "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" = @{
                "SystemResponsiveness" = 10
                "NetworkThrottlingIndex" = 4294967295
            }
            "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" = @{
                "GPU Priority" = 8
                "Priority" = 6
                "Scheduling Category" = "High"
                "SFIO Priority" = "High"
            }
        }
        
        foreach ($regPath in $powerSettings.Keys) {
            try {
                if (!(Test-Path $regPath)) {
                    New-Item -Path $regPath -Force | Out-Null
                }
                
                foreach ($setting in $powerSettings[$regPath].Keys) {
                    $value = $powerSettings[$regPath][$setting]
                    if ($value -is [string]) {
                        Set-ItemProperty -Path $regPath -Name $setting -Value $value -Type String -Force
                    } else {
                        Set-ItemProperty -Path $regPath -Name $setting -Value $value -Type DWord -Force
                    }
                    Write-ByensLog "Set performance setting: $regPath\$setting = $value"
                }
            }
            catch {
                Write-ByensLog "Kunne ikke sætte performance setting $regPath : $($_.Exception.Message)" -Level "WARN"
            }
        }
        
        return $true
    }
    catch {
        Write-ByensLog "Fejl ved konfiguration af performance settings: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

function Configure-HAGS {
    try {
        Write-ByensLog "Konfigurerer Hardware Accelerated GPU Scheduling (HAGS)..."
        
        # Check if system supports HAGS
        $gpuInfo = Get-WmiObject -Class Win32_VideoController | Where-Object { $_.Name -notlike "*Basic*" }
        
        if ($gpuInfo) {
            Write-ByensLog "GPU fundet: $($gpuInfo.Name)"
            
            # Enable HAGS globally
            $hagsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
            if (!(Test-Path $hagsPath)) {
                New-Item -Path $hagsPath -Force | Out-Null
            }
            
            Set-ItemProperty -Path $hagsPath -Name "HwSchMode" -Value 2 -Type DWord -Force
            Write-ByensLog "HAGS aktiveret globalt"
            
            # Configure per-application HAGS for common games/apps
            $appsToOptimize = @(
                "FortniteClient-Win64-Shipping.exe",
                "cs2.exe",
                "League of Legends.exe",
                "RocketLeague.exe",
                "r5apex.exe",
                "Warzone.exe"
            )
            
            foreach ($app in $appsToOptimize) {
                try {
                    $appPath = "HKLM:\SOFTWARE\Microsoft\DirectX\UserGpuPreferences"
                    if (!(Test-Path $appPath)) {
                        New-Item -Path $appPath -Force | Out-Null
                    }
                    
                    Set-ItemProperty -Path $appPath -Name $app -Value "GpuPreference=2;" -Type String -Force
                    Write-ByensLog "HAGS konfigureret for: $app"
                }
                catch {
                    Write-ByensLog "Kunne ikke konfigurere HAGS for $app : $($_.Exception.Message)" -Level "WARN"
                }
            }
        } else {
            Write-ByensLog "Ingen kompatible GPU'er fundet for HAGS" -Level "WARN"
        }
        
        return $true
    }
    catch {
        Write-ByensLog "Fejl ved konfiguration af HAGS: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

function Update-GraphicsDrivers {
    try {
        Write-ByensLog "Checker for graphics driver updates..."
        
        # Check if winget is available
        $wingetPath = Get-Command winget -ErrorAction SilentlyContinue
        if (!$wingetPath) {
            Write-ByensLog "Winget ikke fundet - springer driver update over" -Level "WARN"
            return $true
        }
        
        # Update NVIDIA drivers if applicable
        $nvidiaGpu = Get-WmiObject -Class Win32_VideoController | Where-Object { $_.Name -like "*NVIDIA*" }
        if ($nvidiaGpu) {
            Write-ByensLog "NVIDIA GPU fundet - opdaterer drivers..."
            try {
                & winget install --id=Nvidia.GeForceExperience --silent --accept-source-agreements --accept-package-agreements
                Write-ByensLog "NVIDIA drivers opdateret"
            }
            catch {
                Write-ByensLog "Kunne ikke opdatere NVIDIA drivers: $($_.Exception.Message)" -Level "WARN"
            }
        }
        
        # Update AMD drivers if applicable
        $amdGpu = Get-WmiObject -Class Win32_VideoController | Where-Object { $_.Name -like "*AMD*" -or $_.Name -like "*Radeon*" }
        if ($amdGpu) {
            Write-ByensLog "AMD GPU fundet - opdaterer drivers..."
            try {
                & winget install --id=AdvancedMicroDevices.AMDSoftwareAdrenalinEdition --silent --accept-source-agreements --accept-package-agreements
                Write-ByensLog "AMD drivers opdateret"
            }
            catch {
                Write-ByensLog "Kunne ikke opdatere AMD drivers: $($_.Exception.Message)" -Level "WARN"
            }
        }
        
        return $true
    }
    catch {
        Write-ByensLog "Fejl ved driver update: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

function Set-HighResolutionTimer {
    try {
        Write-ByensLog "Aktiverer high resolution timer..."
        
        # Enable high resolution timer
        $timerPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel"
        if (!(Test-Path $timerPath)) {
            New-Item -Path $timerPath -Force | Out-Null
        }
        
        Set-ItemProperty -Path $timerPath -Name "GlobalTimerResolutionRequests" -Value 1 -Type DWord -Force
        Write-ByensLog "High resolution timer aktiveret"
        
        return $true
    }
    catch {
        Write-ByensLog "Fejl ved aktivering af high resolution timer: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

function Optimize-GameMode {
    try {
        Write-ByensLog "Optimerer Windows Game Mode..."
        
        $gameModeSettings = @{
            "HKCU:\SOFTWARE\Microsoft\GameBar" = @{
                "AutoGameModeEnabled" = 1
                "AllowAutoGameMode" = 1
            }
            "HKLM:\SOFTWARE\Microsoft\PolicyManager\default\ApplicationManagement\AllowGameDVR" = @{
                "value" = 0
            }
        }
        
        foreach ($regPath in $gameModeSettings.Keys) {
            try {
                if (!(Test-Path $regPath)) {
                    New-Item -Path $regPath -Force | Out-Null
                }
                
                foreach ($setting in $gameModeSettings[$regPath].Keys) {
                    $value = $gameModeSettings[$regPath][$setting]
                    Set-ItemProperty -Path $regPath -Name $setting -Value $value -Type DWord -Force
                    Write-ByensLog "Game Mode setting: $regPath\$setting = $value"
                }
            }
            catch {
                Write-ByensLog "Kunne ikke sætte Game Mode setting $regPath : $($_.Exception.Message)" -Level "WARN"
            }
        }
        
        return $true
    }
    catch {
        Write-ByensLog "Fejl ved optimering af Game Mode: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

function Start-GamingTweaks {
    Write-ByensLog "=== ByensIT Optimizer - Gaming Tweaks Started ==="
    
    $success = $true
    
    # Aktiver Ultimate Performance
    $success = $success -and (Enable-UltimatePowerPlan)
    
    # High performance settings
    $success = $success -and (Set-HighPerformanceSettings)
    
    # Konfigurer HAGS
    $success = $success -and (Configure-HAGS)
    
    # Opdater graphics drivers
    $success = $success -and (Update-GraphicsDrivers)
    
    # High resolution timer
    $success = $success -and (Set-HighResolutionTimer)
    
    # Optimer Game Mode
    $success = $success -and (Optimize-GameMode)
    
    if ($success) {
        Write-ByensLog "=== Gaming Tweaks completed successfully ==="
        Write-ByensLog "BEMÆRK: Genstart er påkrævet for alle ændringer træder i kraft" -Level "WARN"
    } else {
        Write-ByensLog "=== Gaming Tweaks completed with errors ===" -Level "WARN"
    }
    
    return $success
}

# Main execution
if ($MyInvocation.InvocationName -ne '.') {
    Start-GamingTweaks
} 