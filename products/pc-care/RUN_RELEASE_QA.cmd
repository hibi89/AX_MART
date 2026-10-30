@echo off
setlocal EnableExtensions DisableDelayedExpansion
REM Development-only PC CARE release QA. This file is NOT shipped in customer ZIP.
REM Runs synthetic tests and internal ZIP packaging; never runs live diagnosis or repair.
set "PC_CARE_DEV_ROOT=%~dp0"
if not exist "%PC_CARE_DEV_ROOT%tools\preflight.py" goto MISSING
if not exist "%PC_CARE_DEV_ROOT%tools\release.py" goto MISSING
if not exist "%PC_CARE_DEV_ROOT%tests\windows_smoke.ps1" goto MISSING
pushd "%PC_CARE_DEV_ROOT%"
if errorlevel 1 goto ROOT_FAILURE
set "PYTHONDONTWRITEBYTECODE=1"
set "PYTHONNOUSERSITE=1"
echo ============================================================
echo AXMART PC CARE - INTERNAL OFFLINE RELEASE QA (NOT DISTRIBUTION)
echo ============================================================
echo Python unittest, Node synthetic tests, temporary internal ZIP,
echo SHA256 verification, Windows PowerShell 5.1 synthetic tests.
echo This does NOT run live diagnosis, repairs, BitLocker or WinRE.
echo All package files remain local. ZIP is discarded after testing.
echo.
REM Prefer the official installed Python launcher; validate minimum version.
set "QA_PY=python"
where py >nul 2>nul
if not errorlevel 1 (
  py -3 -c "import sys; sys.exit(0 if sys.version_info >= (3,11) else 1)" >nul 2>nul
  if not errorlevel 1 set "QA_PY=py -3"
)
if "%QA_PY%"=="python" (
  python -c "import sys; sys.exit(0 if sys.version_info >= (3,11) else 1)" >nul 2>nul
  if errorlevel 1 goto NO_PYTHON
)
REM No -RunReadOnly flag is ever supplied; preflight itself only invokes synthetic PS.
%QA_PY% "tools\preflight.py" --root "."
set "QA_EXIT=%ERRORLEVEL%"
echo.
if "%QA_EXIT%"=="0" (
  echo QA PASSED: offline source and synthetic checks only.
  echo REAL Windows runtime, USB, QR camera, A4 PDF and WinRE remain separate.
) else (
  echo QA FAILED or BLOCKED. Review above. No public release approved.
)
popd
exit /b %QA_EXIT%
:NO_PYTHON
echo BLOCKED: Python 3.11 or newer not found. No QA executed.
popd
exit /b 2
:MISSING
echo BLOCKED: Internal QA sources missing. No QA executed.
exit /b 3
:ROOT_FAILURE
echo BLOCKED: Could not enter the PC CARE source folder.
exit /b 3
