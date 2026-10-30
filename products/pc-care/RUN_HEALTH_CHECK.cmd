@echo off
setlocal
cd /d "%~dp0"
where powershell.exe >nul 2>&1
if errorlevel 1 (
  echo Windows PowerShell was not found. This mode requires running Windows 10/11.
  pause
  exit /b 2
)
echo AXMART PC CARE - Read-only PC diagnostic.
echo No files will be deleted and no system repair will be performed.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\diagnose.ps1"
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" echo Diagnostic encountered an error. Exit code: %RC%
echo.
echo Review the local REPORTS folder for the report.
pause
exit /b %RC%
