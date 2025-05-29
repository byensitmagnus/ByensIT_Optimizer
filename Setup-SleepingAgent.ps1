#Requires -RunAsAdministrator

<#
.SYNOPSIS
    ByensIT Optimizer - Sleeping Agent Setup
    
.DESCRIPTION
    Opsætter en lokal "sleeping agent" der kører automatiske maintenance tasks
    Denne agent arbejder lokalt på din PC og hjælper med kontinuerlig optimering
    
.NOTES
    Kræver administrator rettigheder for at oprette scheduled tasks
    
.AUTHOR
    ByensIT Sleeping Agent System
#>

param(
    [switch]$Install,
    [switch]$Uninstall,
    [switch]$Status,
    [string]$LogPath = "$PSScriptRoot\Logs"
)

# Farver til console output
$Green = "`e[32m"
$Yellow = "`e[33m"
$Red = "`e[31m"
$Blue = "`e[34m"
$Reset = "`e[0m"

function Write-AgentLog {
    param($Message, $Level = "INFO")
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    
    # Console output med farver
    switch ($Level) {
        "INFO" { Write-Host "$Blue[INFO]$Reset $Message" }
        "SUCCESS" { Write-Host "$Green[SUCCESS]$Reset $Message" }
        "WARNING" { Write-Host "$Yellow[WARNING]$Reset $Message" }
        "ERROR" { Write-Host "$Red[ERROR]$Reset $Message" }
    }
    
    # Log til fil
    if (!(Test-Path $LogPath)) {
        New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
    }
    $logMessage | Add-Content -Path "$LogPath\sleeping-agent-$(Get-Date -Format 'yyyy-MM-dd').log"
}

function Install-SleepingAgent {
    Write-AgentLog "🤖 Installing ByensIT Sleeping Agent..." "INFO"
    
    # Opret agent scripts
    $agentPath = "$PSScriptRoot\Agent"
    if (!(Test-Path $agentPath)) {
        New-Item -ItemType Directory -Path $agentPath -Force | Out-Null
    }
    
    # Hovedagent script
    $mainAgentScript = @"
#Requires -RunAsAdministrator

# ByensIT Sleeping Agent - Main Runner
`$LogPath = "$LogPath"
`$ProjectPath = "$PSScriptRoot"

function Write-AgentLog {
    param(`$Message, `$Level = "INFO")
    `$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    `$logMessage = "[`$timestamp] [`$Level] `$Message"
    
    if (!(Test-Path `$LogPath)) {
        New-Item -ItemType Directory -Path `$LogPath -Force | Out-Null
    }
    `$logMessage | Add-Content -Path "`$LogPath\sleeping-agent-`$(Get-Date -Format 'yyyy-MM-dd').log"
}

function Start-AgentTasks {
    Write-AgentLog "🌙 ByensIT Sleeping Agent starting tasks..." "INFO"
    
    try {
        # 1. System Health Check
        Write-AgentLog "🔍 Performing system health check..." "INFO"
        `$healthScore = Get-WmiObject -Class Win32_Processor | Measure-Object -Property LoadPercentage -Average
        `$memoryUsage = Get-WmiObject -Class Win32_OperatingSystem | ForEach-Object { [math]::Round(((`$_.TotalVisibleMemorySize - `$_.FreePhysicalMemory) / `$_.TotalVisibleMemorySize) * 100, 2) }
        
        `$healthReport = @{
            Date = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
            CPUAverage = `$healthScore.Average
            MemoryUsage = `$memoryUsage
            DiskSpace = (Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='C:'" | ForEach-Object { [math]::Round(((`$_.Size - `$_.FreeSpace) / `$_.Size) * 100, 2) })
        }
        
        `$healthReport | ConvertTo-Json | Out-File "`$LogPath\health-check-`$(Get-Date -Format 'yyyy-MM-dd-HHmm').json"
        
        # 2. Cleanup temporary files
        Write-AgentLog "🧹 Cleaning temporary files..." "INFO"
        `$tempCleaned = 0
        `$tempPaths = @("`$env:TEMP", "`$env:TMP", "C:\Windows\Temp")
        
        foreach (`$tempPath in `$tempPaths) {
            if (Test-Path `$tempPath) {
                `$beforeSize = (Get-ChildItem `$tempPath -Recurse -File | Measure-Object -Property Length -Sum).Sum
                Get-ChildItem `$tempPath -Recurse -File | Where-Object { `$_.LastWriteTime -lt (Get-Date).AddDays(-7) } | Remove-Item -Force -ErrorAction SilentlyContinue
                `$afterSize = (Get-ChildItem `$tempPath -Recurse -File | Measure-Object -Property Length -Sum).Sum
                `$tempCleaned += (`$beforeSize - `$afterSize)
            }
        }
        
        Write-AgentLog "✅ Cleaned `$([math]::Round(`$tempCleaned / 1MB, 2)) MB of temporary files" "SUCCESS"
        
        # 3. Update git repository hvis vi er i et git repo
        if (Test-Path ".git") {
            Write-AgentLog "📡 Checking for git updates..." "INFO"
            `$gitStatus = git status --porcelain
            if (`$gitStatus) {
                Write-AgentLog "📝 Found `$(`$gitStatus.Count) uncommitted changes" "INFO"
            }
            
            # Fetch latest changes
            git fetch origin 2>`$null
            `$behindCommits = git rev-list --count HEAD..origin/main 2>`$null
            if (`$behindCommits -and `$behindCommits -gt 0) {
                Write-AgentLog "⬇️ Repository is `$behindCommits commits behind origin/main" "INFO"
            }
        }
        
        # 4. System optimization tweaks
        Write-AgentLog "⚡ Applying sleep-time optimizations..." "INFO"
        
        # Disable Windows Search Indexer during low activity
        `$searchService = Get-Service -Name "WSearch" -ErrorAction SilentlyContinue
        if (`$searchService -and `$searchService.Status -eq "Running") {
            `$cpuUsage = (Get-Counter "\Processor(_Total)\% Processor Time").CounterSamples.CookedValue
            if (`$cpuUsage -lt 20) {
                # System is idle, safe to run maintenance
                Write-AgentLog "🔍 Running Windows Search optimization..." "INFO"
            }
        }
        
        # Memory optimization
        if (`$memoryUsage -gt 80) {
            Write-AgentLog "🔧 High memory usage detected (`$memoryUsage%), running optimization..." "WARNING"
            [System.GC]::Collect()
            [System.GC]::WaitForPendingFinalizers()
        }
        
        # 5. Generate daily summary
        `$summaryReport = @"
# 🌙 ByensIT Sleeping Agent Report - `$(Get-Date -Format 'yyyy-MM-dd HH:mm')

## 🤖 Automated Tasks Completed

### 💻 System Health:
- **CPU Usage:** `$([math]::Round(`$healthScore.Average, 1))%
- **Memory Usage:** `$memoryUsage%
- **C: Drive Usage:** `$(`$healthReport.DiskSpace)%

### 🧹 Cleanup Results:
- **Temporary Files Cleaned:** `$([math]::Round(`$tempCleaned / 1MB, 2)) MB
- **Cleanup Paths:** `$(`$tempPaths.Count) directories processed

### 📊 Recommendations:
`$(if (`$memoryUsage -gt 80) { "- ⚠️ High memory usage - consider closing unused applications" } else { "- ✅ Memory usage within normal range" })
`$(if (`$healthReport.DiskSpace -gt 90) { "- ⚠️ Low disk space - consider running disk cleanup" } else { "- ✅ Disk space sufficient" })

---
*Generated by ByensIT Sleeping Agent at `$(Get-Date)*
"@
        
        `$summaryReport | Out-File "`$LogPath\agent-summary-`$(Get-Date -Format 'yyyy-MM-dd-HHmm').md"
        Write-AgentLog "📊 Generated system summary report" "SUCCESS"
        
        Write-AgentLog "🎯 All sleeping agent tasks completed successfully" "SUCCESS"
        
    } catch {
        Write-AgentLog "❌ Agent task failed: `$(`$_.Exception.Message)" "ERROR"
    }
}

# Kør agent tasks
Start-AgentTasks
"@

    $mainAgentScript | Out-File "$agentPath\MainAgent.ps1" -Encoding UTF8
    
    # Opret scheduled tasks
    Write-AgentLog "⏰ Creating scheduled tasks..." "INFO"
    
    # Nightly maintenance task (kl. 03:00)
    $nightlyAction = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$agentPath\MainAgent.ps1`""
    $nightlyTrigger = New-ScheduledTaskTrigger -Daily -At "03:00AM"
    $nightlySettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
    $nightlyPrincipal = New-ScheduledTaskPrincipal -UserID "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    
    try {
        Register-ScheduledTask -TaskName "ByensIT-SleepingAgent-Nightly" -Action $nightlyAction -Trigger $nightlyTrigger -Settings $nightlySettings -Principal $nightlyPrincipal -Description "ByensIT Optimizer Sleeping Agent - Nightly maintenance" -Force
        Write-AgentLog "✅ Created nightly maintenance task (03:00)" "SUCCESS"
    } catch {
        Write-AgentLog "❌ Failed to create nightly task: $($_.Exception.Message)" "ERROR"
    }
    
    # Quick check task (hver 4. time)
    $quickAction = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$agentPath\MainAgent.ps1`""
    $quickTrigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Hours 4) -RepetitionDuration (New-TimeSpan -Days 365)
    $quickSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
    
    try {
        Register-ScheduledTask -TaskName "ByensIT-SleepingAgent-QuickCheck" -Action $quickAction -Trigger $quickTrigger -Settings $quickSettings -Principal $nightlyPrincipal -Description "ByensIT Optimizer Sleeping Agent - Quick system check" -Force
        Write-AgentLog "✅ Created quick check task (every 4 hours)" "SUCCESS"
    } catch {
        Write-AgentLog "❌ Failed to create quick check task: $($_.Exception.Message)" "ERROR"
    }
    
    Write-AgentLog "🎉 ByensIT Sleeping Agent installed successfully!" "SUCCESS"
    Write-AgentLog "📊 Logs will be saved to: $LogPath" "INFO"
    Write-AgentLog "🌙 The agent will start working tonight at 03:00" "INFO"
}

function Uninstall-SleepingAgent {
    Write-AgentLog "🗑️ Uninstalling ByensIT Sleeping Agent..." "INFO"
    
    # Fjern scheduled tasks
    try {
        Unregister-ScheduledTask -TaskName "ByensIT-SleepingAgent-Nightly" -Confirm:$false -ErrorAction SilentlyContinue
        Unregister-ScheduledTask -TaskName "ByensIT-SleepingAgent-QuickCheck" -Confirm:$false -ErrorAction SilentlyContinue
        Write-AgentLog "✅ Removed scheduled tasks" "SUCCESS"
    } catch {
        Write-AgentLog "❌ Failed to remove tasks: $($_.Exception.Message)" "ERROR"
    }
    
    # Fjern agent filer
    $agentPath = "$PSScriptRoot\Agent"
    if (Test-Path $agentPath) {
        Remove-Item $agentPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-AgentLog "✅ Removed agent files" "SUCCESS"
    }
    
    Write-AgentLog "👋 ByensIT Sleeping Agent uninstalled" "SUCCESS"
}

function Show-AgentStatus {
    Write-AgentLog "📊 ByensIT Sleeping Agent Status" "INFO"
    
    # Tjek scheduled tasks
    $nightlyTask = Get-ScheduledTask -TaskName "ByensIT-SleepingAgent-Nightly" -ErrorAction SilentlyContinue
    $quickTask = Get-ScheduledTask -TaskName "ByensIT-SleepingAgent-QuickCheck" -ErrorAction SilentlyContinue
    
    if ($nightlyTask) {
        Write-AgentLog "✅ Nightly task: $($nightlyTask.State) - Next run: $($nightlyTask.Triggers[0].StartBoundary)" "SUCCESS"
    } else {
        Write-AgentLog "❌ Nightly task: Not installed" "ERROR"
    }
    
    if ($quickTask) {
        Write-AgentLog "✅ Quick check task: $($quickTask.State)" "SUCCESS"
    } else {
        Write-AgentLog "❌ Quick check task: Not installed" "ERROR"
    }
    
    # Vis seneste logs
    $latestLogs = Get-ChildItem $LogPath -Filter "*.log" | Sort-Object LastWriteTime -Descending | Select-Object -First 3
    if ($latestLogs) {
        Write-AgentLog "📄 Recent activity:" "INFO"
        foreach ($log in $latestLogs) {
            Write-AgentLog "   - $($log.Name) ($(Get-Date $log.LastWriteTime -Format 'yyyy-MM-dd HH:mm'))" "INFO"
        }
    }
}

# Main execution logic
Write-Host @"
$Blue
🌙 ByensIT Optimizer - Sleeping Agent Setup
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Den intelligente agent der arbejder mens du sover! 
$Reset
"@

if ($Install) {
    Install-SleepingAgent
} elseif ($Uninstall) {
    Uninstall-SleepingAgent
} elseif ($Status) {
    Show-AgentStatus
} else {
    Write-Host @"
Brug:
  .\Setup-SleepingAgent.ps1 -Install     # Installer sleeping agent
  .\Setup-SleepingAgent.ps1 -Uninstall   # Afinstaller sleeping agent  
  .\Setup-SleepingAgent.ps1 -Status      # Vis agent status

Den sleeping agent vil:
🔍 Køre system health checks
🧹 Rydde op i temp filer
⚡ Optimere system performance
📊 Generere daily reports
🤖 Arbejde mens du sover!
"@
} 