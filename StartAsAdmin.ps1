# ByensIT Complete PC Suite v2.0 - Auto-Administrator Starter
# Dette script starter automatisk som Administrator

Write-Host "============================================" -ForegroundColor Green
Write-Host "     ByensIT Complete PC Suite v2.0" -ForegroundColor Green  
Write-Host "        Auto-Administrator Starter" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
Write-Host ""

# Check if running as Administrator
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "❌ IKKE Administrator! Genstarting med admin rettigheder..." -ForegroundColor Red
    Write-Host ""
    
    # Get current script path  
    $scriptPath = $MyInvocation.MyCommand.Path
    
    # Start PowerShell as Administrator
    Start-Process powershell.exe -Verb RunAs -ArgumentList "-NoExit", "-File", "`"$scriptPath`""
    exit
}

Write-Host "✅ SUCCESS: Kører som Administrator!" -ForegroundColor Green
Write-Host "🔧 Registry tweaks vil nu virke korrekt!" -ForegroundColor Green
Write-Host ""

# Navigate to project directory
$projectPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectPath

Write-Host "📂 Project Path: $projectPath" -ForegroundColor Cyan
Write-Host "🚀 Starter ByensIT Optimizer..." -ForegroundColor Yellow
Write-Host ""

# Start the application
try {
    & "C:\Program Files\dotnet\dotnet.exe" run
    Write-Host ""
    Write-Host "✅ ByensIT Optimizer afsluttet normalt" -ForegroundColor Green
} catch {
    Write-Host "❌ Fejl ved start af ByensIT Optimizer: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Tryk på en tast for at lukke..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 