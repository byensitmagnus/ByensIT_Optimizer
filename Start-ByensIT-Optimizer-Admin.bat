@echo off
REM ByensIT Optimizer - Administrator Startup Script
REM Dette script starter ByensIT Optimizer med administrator rettigheder

echo Starting ByensIT Optimizer...
echo Checking administrator rights...

REM Check if running as admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process cmd -ArgumentList '/c %~dp0Start-ByensIT-Optimizer-Admin.bat' -Verb RunAs"
    exit /b
)

echo Running as administrator - starting ByensIT Optimizer...

REM Change to script directory
cd /d "%~dp0"

REM Start the PowerShell GUI
powershell -ExecutionPolicy Bypass -File "ByensIT-Optimizer-Part4_GUI.ps1"

echo ByensIT Optimizer finished.
pause 