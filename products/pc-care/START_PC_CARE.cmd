@echo off
setlocal EnableExtensions DisableDelayedExpansion
REM AXMART PC CARE: non-admin, offline entrypoint for a normally booted Windows PC.
REM This menu NEVER starts repair, elevates privileges, or enters WinRE.
set "PC_CARE_ROOT=%~dp0"
if not defined SystemRoot goto NO_CHOICE
set "PC_CARE_CHOICE=%SystemRoot%\System32\choice.exe"
if not exist "%PC_CARE_CHOICE%" goto NO_CHOICE

:MENU
echo.
echo ==========================================================
echo AXMART PC CARE  [ALPHA - NOT RELEASE APPROVED]
echo ==========================================================
echo 1. Read-only health check (creates local reports)
echo 2. Read-only Windows self-test (creates local reports)
echo 3. Where to find reports / privacy guidance
echo 4. Recovery safety guidance (no repairs executed)
echo 5. Compare saved JSON reports (local/offline)
echo 0. Exit
echo.
"%PC_CARE_CHOICE%" /C 123450 /N /M "Select 1, 2, 3, 4, 5 or 0: "
set "PC_CARE_PICK=%ERRORLEVEL%"
if "%PC_CARE_PICK%"=="1" goto HEALTH
if "%PC_CARE_PICK%"=="2" goto SELFTEST
if "%PC_CARE_PICK%"=="3" goto REPORTS
if "%PC_CARE_PICK%"=="4" goto GUIDANCE
if "%PC_CARE_PICK%"=="5" goto HISTORY
if "%PC_CARE_PICK%"=="6" exit /b 0
echo Invalid or canceled selection. No action taken.
goto MENU

:HEALTH
if not exist "%PC_CARE_ROOT%RUN_HEALTH_CHECK.cmd" goto MISSING
call "%PC_CARE_ROOT%RUN_HEALTH_CHECK.cmd"
echo Health-check launcher exit code: %ERRORLEVEL%
goto MENU

:SELFTEST
if not exist "%PC_CARE_ROOT%RUN_SELF_TEST.cmd" goto MISSING
call "%PC_CARE_ROOT%RUN_SELF_TEST.cmd"
echo Self-test launcher exit code: %ERRORLEVEL%
goto MENU

:REPORTS
echo Reports are stored locally under:
echo   "%PC_CARE_ROOT%REPORTS"
echo If that folder is not writable, diagnostics may use Documents.
echo Reports may contain private device information. Review before sharing.
echo Nothing here uploads or deletes reports.
pause
goto MENU

:GUIDANCE
echo.
echo This menu does not run DISM, SFC, WinRE, or any repair command.
echo Do not repair a possibly failing drive before protecting personal data.
echo For a non-booting PC, use Microsoft's official recovery environment
echo and the separate recovery\WINRE_READ_ONLY.cmd only after reviewing docs.
echo The ZIP is NOT a bootable Windows recovery image.
echo System-changing repair requires a separate administrator launcher,
echo confirmed backup, two explicit approvals, and isolated VM verification.
pause
goto MENU

:HISTORY
if not exist "%PC_CARE_ROOT%ui\history_compare.html" goto MISSING
if not exist "%PC_CARE_ROOT%ui\history_compare.js" goto MISSING
start "" "%PC_CARE_ROOT%ui\history_compare.html"
if errorlevel 1 echo ERROR: Could not open local history page.
goto MENU

:MISSING
echo ERROR: Required read-only launcher is missing. No action executed.
pause
goto MENU

:NO_CHOICE
echo ERROR: Trusted Windows choice.exe unavailable. No action executed.
exit /b 2
