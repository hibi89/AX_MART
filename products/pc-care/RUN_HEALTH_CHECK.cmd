@echo off
setlocal EnableExtensions DisableDelayedExpansion
cd /d "%~dp0"
set "AXMART_PS51=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if not exist "%AXMART_PS51%" (
  echo Windows PowerShell 5.1 not found at the trusted OS path. No code was executed.
  pause
  exit /b 2
)
echo AXMART PC CARE - Read-only PC diagnostic.
echo No files will be deleted and no system repair will be performed.
"%AXMART_PS51%" -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\diagnose.ps1"
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" echo Diagnostic encountered an error. Exit code: %RC%
echo.
echo Review the report location printed above. If USB is read-only, it may be in Documents.
pause
exit /b %RC%
