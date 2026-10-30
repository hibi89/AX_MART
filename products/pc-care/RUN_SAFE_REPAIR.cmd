@echo off
setlocal
cd /d "%~dp0"
echo WARNING: This optional tool can change Windows system files.
echo Run this only after backing up personal data and reading docs\SAFETY.md.
echo You need administrator privileges; the tool does not elevate itself.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\repair.ps1"
set "RC=%ERRORLEVEL%"
echo.
echo Exit code: %RC%
pause
exit /b %RC%
