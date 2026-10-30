@echo off
setlocal EnableExtensions DisableDelayedExpansion
REM AXMART PC CARE v0.1 - run manually from a Windows Recovery command prompt.
REM This script does not change boot configuration, partitions, or BitLocker state.
echo.
echo ===== AXMART PC CARE - WINDOWS RECOVERY REVIEW =====
echo Read-only inventory. Not a bootable USB image or automatic repair.
echo If storage is physically failing, prioritize professional data recovery.
echo.
set "LOGDIR=%~dp0..\REPORTS"
if not exist "%LOGDIR%" mkdir "%LOGDIR%" 2>nul
if not exist "%LOGDIR%" (
  echo USB report folder not writable. Logging only to the screen.
  goto VIEWONLY
)
set "LOG=%LOGDIR%\recovery-review-%RANDOM%-%RANDOM%.txt"
>"%LOG%" echo AXMART PC CARE recovery review - No repairs performed.
if errorlevel 1 goto VIEWONLY
>>"%LOG%" echo Note: WinRE drive letters can differ from normal Windows.
>>"%LOG%" echo PRIVACY: BitLocker status and BCD entries may contain machine identifiers; review before sharing.
echo Candidate Windows installations:
>>"%LOG%" echo Candidate Windows installations:
for %%D in (C D E F G H I J K L M N O P Q R S T U V W Y Z) do if exist "%%D:\Windows\System32\Config\SYSTEM" (
 echo %%D:\Windows
 >>"%LOG%" echo %%D:\Windows
 if exist "%%D:\Windows\MEMORY.DMP" (
   echo   Potential blue-screen artifact: MEMORY.DMP found ^(cause not verified^)
   >>"%LOG%" echo %%D: MEMORY.DMP found - crash artifact, NOT root cause
 )
 if exist "%%D:\Windows\Minidump\*.dmp" (
   echo   Potential blue-screen artifact: Minidump files found ^(cause not verified^)
   >>"%LOG%" echo %%D: Minidump files found - crash artifact, NOT root cause
 )
 if exist "%%D:\Windows\System32\LogFiles\Srt\SrtTrail.txt" (
   echo   Startup Repair history found ^(not necessarily current incident^)
   >>"%LOG%" echo %%D: Startup Repair log exists - age/cause NOT verified
 )
 if exist "%%D:\Windows\System32\winevt\Logs\System.evtx" (
   >>"%LOG%" echo %%D: offline System.evtx present; manual analysis may be needed
 )
)
echo.
echo BitLocker status (NO KEYS REQUESTED):
manage-bde -status >>"%LOG%" 2>&1
echo.
echo Boot entries (read only):
bcdedit /enum >>"%LOG%" 2>&1
echo.
echo Saved review: "%LOG%"
echo PRIVACY: BCD entries may contain machine identifiers. Do not share this report without review.
goto END
:VIEWONLY
for %%D in (C D E F G H I J K L M N O P Q R S T U V W Y Z) do if exist "%%D:\Windows\System32\Config\SYSTEM" echo Candidate: %%D:\Windows
manage-bde -status
bcdedit /enum
:END
echo.
echo For Microsoft Startup Repair: exit Command Prompt, then select
 echo Troubleshoot ^> Advanced options ^> Startup Repair.
echo Encrypted volumes may require a BitLocker recovery key obtained
 echo by the PC owner outside this utility.
echo Never use format, diskpart clean, chkdsk /r, or bootrec blindly.
echo.
pause
endlocal
