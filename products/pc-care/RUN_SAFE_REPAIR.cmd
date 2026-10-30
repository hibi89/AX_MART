@echo off
setlocal EnableExtensions DisableDelayedExpansion
cd /d "%~dp0"
echo WARNING: This optional tool can change Windows system files.
echo Run this only after backing up personal data and reading docs\SAFETY.md.
echo You need administrator privileges; the tool does not elevate itself.
set "AXMART_PS51=%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe"
if not exist "%AXMART_PS51%" (
  echo Windows PowerShell 5.1 was not found; no repair executed.
  pause
  exit /b 2
)
"%AXMART_PS51%" -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\repair.ps1"
set "RC=%ERRORLEVEL%"
echo.
echo Exit code: %RC%
pause
exit /b %RC%
