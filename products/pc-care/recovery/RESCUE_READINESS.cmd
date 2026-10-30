@echo off
setlocal EnableExtensions DisableDelayedExpansion
REM AXMART PC CARE - WinRE Rescue readiness PREVIEW ONLY (Release B unapproved).
REM No copying, file content reads, unlocks, logs, writes, repair, or external tools.
REM Run manually from Microsoft's genuine WinRE Command Prompt, not by autorun.
echo.
echo ===== AXMART PC CARE - RESCUE READINESS PREVIEW =====
echo This tool lists candidate Windows drive LETTERS, not user files.
echo It NEVER copies, deletes, repairs, unlocks, or backs up anything.
echo If a disk is failing, avoid repeated access and consult data recovery.
echo.
if not defined SystemRoot goto NO_RUNTIME
if not exist "%SystemRoot%\System32\cmd.exe" goto NO_RUNTIME

echo STEP 1 - AVAILABLE RECOVERY TOOLS ONLY - NOT EXECUTED
if exist "%SystemRoot%\System32\robocopy.exe" echo INFO: robocopy.exe is present. This does NOT authorize copying.
if not exist "%SystemRoot%\System32\robocopy.exe" echo BLOCK: robocopy.exe not found in this environment.
if exist "%SystemRoot%\System32\manage-bde.exe" echo INFO: manage-bde.exe is present. BitLocker status is NOT checked here.
if not exist "%SystemRoot%\System32\manage-bde.exe" echo BLOCK: BitLocker status tool unavailable.
echo.
echo STEP 2 - POSSIBLE WINDOWS VOLUMES - READ-ONLY PATH CHECK
set "PC_CARE_FOUND=0"
REM X: is commonly the temporary WinRE RAM environment; it is NOT a backup destination.
for %%D in (C D E F G H I J K L M N O P Q R S T U V W Y Z) do (
  if exist "%%D:\Windows\System32\Config\SYSTEM" (
    echo CANDIDATE: %%D:\Windows
    set "PC_CARE_FOUND=1"
    if exist "%%D:\Users" echo INFO: %%D:\Users folder exists. Profile contents NOT scanned.
  )
)
if "%PC_CARE_FOUND%"=="0" echo BLOCK: No accessible Windows folder found. Volume may be locked or unavailable.
echo.
echo STEP 3 - MANDATORY SAFETY GATES - NOT VERIFIED
 echo BLOCK: Source and target physical disk identity NOT proven.
 echo BLOCK: BitLocker lock state and ownership NOT verified.
 echo BLOCK: Destination free space, file system and 4GiB limit NOT verified.
 echo BLOCK: EFS, cloud-only files, links and source damage NOT verified.
 echo BLOCK: New empty destination and independent copy/hash checks NOT verified.
echo.
echo DO NOT treat a different drive letter as a different physical disk.
echo Do NOT enter recovery keys or passwords into AXMART PC CARE.
echo Current preview cannot copy any data; consult the recovery guide.
echo RESULT: BLOCKED - THIS IS NOT A BACKUP OR A SUCCESS REPORT.
endlocal & exit /b 3
:NO_RUNTIME
echo BLOCK: Trusted WinRE command environment is unavailable.
echo RESULT: BLOCKED - NO ACTION WAS TAKEN.
endlocal & exit /b 3
