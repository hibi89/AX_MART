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
    if (@($disks | Where-Object { $_.HealthStatus -in @('Warning','Unhealthy') }).Count -gt 0) {
        Write-Host 'STORAGE HEALTH WARNING DETECTED. Repair blocked. Back up data and seek hardware assistance.' -ForegroundColor Red
        exit 3
    }
} catch {
    Write-Host 'Disk health cannot be confirmed. Repair should be performed only after independent backup.' -ForegroundColor Yellow
}
$backup = Read-Host 'Type BACKUP only if important files are safely backed up'
if ($backup -cne 'BACKUP') { Write-Host 'Canceled: no changes made.'; exit 1 }
$confirm = Read-Host 'Type REPAIR to run Windows DISM and SFC (can take a long time)'
if ($confirm -cne 'REPAIR') { Write-Host 'Canceled: no changes made.'; exit 1 }
$root = Split-Path -Parent $PSScriptRoot
$outDir = Join-Path $root 'REPORTS'
try { New-Item -ItemType Directory -Path $outDir -Force -ErrorAction Stop | Out-Null }
catch { $outDir = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'AXMART-PC-CARE-Reports'; New-Item -ItemType Directory -Path $outDir -Force | Out-Null }
$logPath = Join-Path $outDir ('approved-repair-' + (Get-Date -Format 'yyyyMMdd-HHmmss') + '.log')
'AXMART PC CARE - Explicitly approved repair run. Commands: DISM /RestoreHealth then SFC /scannow.' | Out-File -LiteralPath $logPath -Encoding UTF8
Write-Host 'Running DISM /Online /Cleanup-Image /RestoreHealth ...'
& "$env:SystemRoot\System32\dism.exe" /Online /Cleanup-Image /RestoreHealth 2>&1 | Out-File -LiteralPath $logPath -Append -Encoding UTF8
$dismExit = $LASTEXITCODE
('DISM_EXIT_CODE={0}' -f $dismExit) | Out-File -LiteralPath $logPath -Append -Encoding UTF8
if ($dismExit -ne 0) {
    Write-Host "DISM returned $dismExit. SFC not started. Review the log." -ForegroundColor Red
    Write-Host $logPath
    exit 4
}
Write-Host 'Running SFC /scannow ...'
& "$env:SystemRoot\System32\sfc.exe" /scannow 2>&1 | Out-File -LiteralPath $logPath -Append -Encoding UTF8
$sfcExit = $LASTEXITCODE
('SFC_EXIT_CODE={0}' -f $sfcExit) | Out-File -LiteralPath $logPath -Append -Encoding UTF8
Write-Host "Repair sequence ended. SFC exit: $sfcExit. Restart only if required by Windows."
Write-Host ('Repair log: ' + $logPath)
if ($sfcExit -ne 0) { exit 5 }
