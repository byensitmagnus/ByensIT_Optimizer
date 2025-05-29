#Requires -RunAsAdministrator
<#
.SYNOPSIS
    ByensIT Optimizer - Part 1: Safe Repair
.DESCRIPTION
    System reparation og grundlæggende cleanup. Inkluderer DISM, SFC og temp cleanup.
.AUTHOR
    Byens IT - magnususmo@hotmail.dk
.VERSION
    1.0.0
#>

param(
    [switch]$Silent = $false,
    [string]$LogPath = "$PSScriptRoot\Logs",
    [switch]$SkipRestorePoint = $false
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
    
    # Opret logs mappe hvis den ikke eksisterer
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

function Test-AdminRights {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function New-SystemRestorePoint {
    param([string]$Description = "ByensIT Optimizer - Before Optimization")
    
    try {
        Write-ByensLog "Opretter system restore point..."
        
        # Aktiver System Restore hvis deaktiveret
        Enable-ComputerRestore -Drive "C:\"
        
        # Opret restore point
        Checkpoint-Computer -Description $Description -RestorePointType "MODIFY_SETTINGS"
        Write-ByensLog "System restore point oprettet succesfuldt"
        return $true
    }
    catch {
        Write-ByensLog "Fejl ved oprettelse af restore point: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

function Invoke-DISMRepair {
    try {
        Write-ByensLog "Starter DISM system image repair..."
        
        # Check system image health
        $dismCheck = & dism /online /cleanup-image /checkhealth 2>&1
        Write-ByensLog "DISM CheckHealth completed"
        
        # Scan system image health
        $dismScan = & dism /online /cleanup-image /scanhealth 2>&1
        Write-ByensLog "DISM ScanHealth completed"
        
        # Restore system image health hvis nødvendigt
        $dismRestore = & dism /online /cleanup-image /restorehealth 2>&1
        Write-ByensLog "DISM RestoreHealth completed"
        
        return $true
    }
    catch {
        Write-ByensLog "Fejl under DISM repair: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

function Invoke-SFCScan {
    try {
        Write-ByensLog "Starter SFC system file scan..."
        
        $sfcResult = & sfc /scannow 2>&1
        Write-ByensLog "SFC scan completed"
        
        return $true
    }
    catch {
        Write-ByensLog "Fejl under SFC scan: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

function Clear-TempFiles {
    try {
        Write-ByensLog "Starter cleanup af temp filer..."
        
        $tempPaths = @(
            "$env:TEMP\*",
            "$env:WINDIR\Temp\*",
            "$env:LOCALAPPDATA\Temp\*",
            "$env:USERPROFILE\AppData\Local\Temp\*"
        )
        
        $totalCleaned = 0
        
        foreach ($path in $tempPaths) {
            try {
                $items = Get-ChildItem -Path $path -Recurse -Force -ErrorAction SilentlyContinue
                $size = ($items | Measure-Object -Property Length -Sum).Sum
                $totalCleaned += $size
                
                Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
                Write-ByensLog "Cleaned: $path"
            }
            catch {
                Write-ByensLog "Kunne ikke rydde: $path - $($_.Exception.Message)" -Level "WARN"
            }
        }
        
        $cleanedMB = [Math]::Round($totalCleaned / 1MB, 2)
        Write-ByensLog "Temp cleanup completed - ${cleanedMB}MB frigjort"
        
        return $true
    }
    catch {
        Write-ByensLog "Fejl under temp cleanup: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

function Clear-WindowsUpdateCache {
    try {
        Write-ByensLog "Rydder Windows Update cache..."
        
        # Stop Windows Update services
        $services = @("wuauserv", "cryptSvc", "bits", "msiserver")
        foreach ($service in $services) {
            Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
            Write-ByensLog "Stopped service: $service"
        }
        
        # Clear update cache
        $updatePaths = @(
            "$env:WINDIR\SoftwareDistribution\Download\*",
            "$env:WINDIR\System32\catroot2\*"
        )
        
        foreach ($path in $updatePaths) {
            Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
            Write-ByensLog "Cleared: $path"
        }
        
        # Start services again
        foreach ($service in $services) {
            Start-Service -Name $service -ErrorAction SilentlyContinue
            Write-ByensLog "Started service: $service"
        }
        
        Write-ByensLog "Windows Update cache cleared"
        return $true
    }
    catch {
        Write-ByensLog "Fejl ved clearing af Windows Update cache: $($_.Exception.Message)" -Level "ERROR"
        return $false
    }
}

function Start-SafeRepair {
    Write-ByensLog "=== ByensIT Optimizer - Safe Repair Started ===" 
    
    # Check admin rights
    if (!(Test-AdminRights)) {
        Write-ByensLog "Script skal køres som administrator!" -Level "ERROR"
        return $false
    }
    
    $success = $true
    
    # Opret restore point
    if (!$SkipRestorePoint) {
        $success = $success -and (New-SystemRestorePoint)
    }
    
    # DISM repair
    $success = $success -and (Invoke-DISMRepair)
    
    # SFC scan
    $success = $success -and (Invoke-SFCScan)
    
    # Temp cleanup
    $success = $success -and (Clear-TempFiles)
    
    # Windows Update cache cleanup
    $success = $success -and (Clear-WindowsUpdateCache)
    
    if ($success) {
        Write-ByensLog "=== Safe Repair completed successfully ===" 
    } else {
        Write-ByensLog "=== Safe Repair completed with errors ===" -Level "WARN"
    }
    
    return $success
}

# Main execution
if ($MyInvocation.InvocationName -ne '.') {
    Start-SafeRepair
} 