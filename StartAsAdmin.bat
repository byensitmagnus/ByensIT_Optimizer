@echo off
echo ============================================
echo      ByensIT Complete PC Suite v2.0
echo         Administrator Start Script
echo ============================================
echo.
echo KRITISK: Registry tweaks KRAEVER Administrator!
echo.
echo VIGTIGT: Hoejreklik paa denne .bat fil og vaelg "Koer som administrator"
echo.
echo Hvis du ser "Access denied" fejl, har du IKKE admin rettigheder!
echo.
pause
echo.
echo Starter ByensIT Optimizer med Administrator rettigheder...
echo.

:: Check if running as admin
net session >nul 2>&1
if %errorLevel% == 0 (
    echo [SUCCESS] Koerer som Administrator! Registry tweaks vil virke! ✅
) else (
    echo [ERROR] IKKE Administrator! Registry tweaks vil fejle! ❌
    echo.
    echo LOESUNG: Hoejreklik paa StartAsAdmin.bat og vaelg "Koer som administrator"
    echo.
    pause
    exit /b 1
)

echo.
cd /d "%~dp0"
"C:\Program Files\dotnet\dotnet.exe" run
pause 