@echo off
setlocal EnableExtensions DisableDelayedExpansion
cd /d "%~dp0"
echo ============================================================
echo AXMART PC CARE - WINDOWS READ-ONLY SELF TEST (ALPHA)
echo ============================================================
echo 1. Parse-checks Windows PowerShell scripts.
echo 2. Runs a one-day read-only diagnostic and creates local reports.
echo 3. NEVER launches the DISM/SFC repair script.
echo 4. Do not share generated reports before reviewing private data.
echo.
where powershell.exe >nul 2>&1
if errorlevel 1 (
  echo ERROR: Windows PowerShell was not found.
  pause
  exit /b 2
)
if not exist "%~dp0tests\windows_smoke.ps1" (
  echo ERROR: Missing tests\windows_smoke.ps1 file.
  pause
  exit /b 3
)
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0tests\windows_smoke.ps1" -RunReadOnly
set "RC=%ERRORLEVEL%"
echo.
if "%RC%"=="0" (
  echo SELF TEST PASS - parser and report creation checks passed.
  echo This does NOT certify WinRE or repair safety.
) else (
  echo SELF TEST FAILED - exit code %RC%. Do not attempt repair.
)
echo.
pause
exit /b %RC%
