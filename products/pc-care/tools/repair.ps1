# AXMART PC CARE v0.1 | OPTIONAL APPROVAL-ONLY ONLINE REPAIR
# No disk format / bootloader rewrite / BitLocker changes / automatic reboot.
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host 'Administrator privileges are required. Right-click RUN_SAFE_REPAIR.cmd and Run as administrator.' -ForegroundColor Yellow
    exit 2
}
Write-Host 'AXMART PC CARE: SAFE REPAIR (BETA)' -ForegroundColor Yellow
Write-Host 'This step changes Windows system components; it is NOT read-only.'
Write-Host 'Back up important personal files to another disk before repair.'
Write-Host 'Do not proceed if the disk is failing, makes abnormal noises, or BitLocker access is uncertain.'
try {
    $disks = @(Get-PhysicalDisk -ErrorAction Stop)
    if ($disks.Count -eq 0 -or @($disks | Where-Object { $_.HealthStatus -ne 'Healthy' }).Count -gt 0) {
        Write-Host 'Storage health is warning, unknown, or unavailable. Automatic repair path blocked. Back up data and obtain independent hardware assessment.' -ForegroundColor Red
        exit 3
    }
} catch {
    Write-Host 'Storage health check failed. Repair blocked (fail-closed); use official Windows support after verifying backups and hardware.' -ForegroundColor Red
    exit 3
}
$backup = Read-Host 'Type BACKUP only if important files are safely backed up'
if ($backup -cne 'BACKUP') { Write-Host 'Canceled: no changes made.'; exit 1 }
$confirm = Read-Host 'Type REPAIR to run Windows DISM and SFC (can take a long time)'
if ($confirm -cne 'REPAIR') { Write-Host 'Canceled: no changes made.'; exit 1 }
$root = Split-Path -Parent $PSScriptRoot
# The repair log is potentially sensitive. Use the same cloud/network/reparse
# restrictions as read-only diagnostic reports, without a Documents fallback.
. (Join-Path $PSScriptRoot 'report_io.ps1')
$reportCandidates = @(Join-Path $root 'REPORTS')
$localData = [Environment]::GetFolderPath('LocalApplicationData')
if (-not [string]::IsNullOrWhiteSpace($localData)) {
    $reportCandidates += (Join-Path $localData 'AXMART-PC-CARE-Reports')
}
$logHandle = $null
try {
    $logHandle = New-PcCarePrivateRepairLogStream -Candidates $reportCandidates
} catch {
    Write-Host 'Repair blocked: no safe private local log destination. No repair command was started.' -ForegroundColor Red
    exit 6
}
$logPath = [string]$logHandle.path
$writer = $null
$repairExit = 6
try {
    $writer = [System.IO.StreamWriter]::new($logHandle.stream, [System.Text.UTF8Encoding]::new($false))
    $writer.WriteLine('AXMART PC CARE - Explicitly approved repair run. Commands: DISM /RestoreHealth then SFC /scannow.')
    $writer.Flush()
    Write-Host 'Running DISM /Online /Cleanup-Image /RestoreHealth ...'
    & "$env:SystemRoot\System32\dism.exe" /Online /Cleanup-Image /RestoreHealth 2>&1 |
        ForEach-Object { $writer.WriteLine([string]$_) }
    $dismExit = $LASTEXITCODE
    $writer.WriteLine(('DISM_EXIT_CODE={0}' -f $dismExit))
    $writer.Flush()
    if ($dismExit -ne 0) {
        $repairExit = 4
        Write-Host "DISM returned $dismExit. SFC not started. Review the log." -ForegroundColor Red
    } else {
        Write-Host 'Running SFC /scannow ...'
        & "$env:SystemRoot\System32\sfc.exe" /scannow 2>&1 |
            ForEach-Object { $writer.WriteLine([string]$_) }
        $sfcExit = $LASTEXITCODE
        $writer.WriteLine(('SFC_EXIT_CODE={0}' -f $sfcExit))
        $writer.Flush()
        $repairExit = if ($sfcExit -eq 0) { 0 } else { 5 }
        Write-Host "Repair sequence ended. SFC exit: $sfcExit. Restart only if required by Windows."
    }
} catch {
    # Any inability to record the approved operation is an error, not a PASS.
    $repairExit = 6
    Write-Host ('Repair stopped or log failed (' + $_.Exception.GetType().Name +
        '). A command may have partially executed; inspect Windows logs before retrying.') -ForegroundColor Red
} finally {
    try {
        if ($null -ne $writer) { $writer.Dispose() }
        elseif ($null -ne $logHandle) { $logHandle.stream.Dispose() }
    } catch {
        $repairExit = 6
        Write-Host 'Repair log flush/close failed. Completion cannot be confirmed.' -ForegroundColor Red
    }
}
Write-Host ('Repair log (private local): ' + $logPath)
exit $repairExit
