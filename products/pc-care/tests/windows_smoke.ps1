# AXMART PC CARE Windows PowerShell 5.1 verification (never starts repair).
# Default performs parsing only; -RunReadOnly explicitly executes diagnostics.
[CmdletBinding()]
param([switch]$RunReadOnly)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
foreach ($rel in @('tools/diagnose.ps1','tools/repair.ps1','tools/event_analysis.ps1','tools/incident_analysis.ps1','tools/telemetry_analysis.ps1','tools/pnp_analysis.ps1','tools/recorded_timeline.ps1','tools/consultation_report.ps1','tools/consultation_render.ps1','tools/report_io.ps1','tests/event_analysis.tests.ps1','tests/incident_analysis.tests.ps1','tests/telemetry_analysis.tests.ps1','tests/driver_timeline.tests.ps1','tests/consultation_report.tests.ps1','tests/report_io.tests.ps1')) {
    $path = Join-Path $root $rel
    $tokens = $null
    $parseErrors = $null
    [System.Management.Automation.Language.Parser]::ParseFile($path, [ref]$tokens, [ref]$parseErrors) | Out-Null
    if ($parseErrors.Count -gt 0) {
        foreach ($parseError in $parseErrors) { Write-Error ($rel + ': ' + $parseError.Message) }
        throw ('PowerShell syntax failed: ' + $rel)
    }
    Write-Host ('PARSE PASS: ' + $rel) -ForegroundColor Green
}
# Synthetic fixtures are safe even without elevated privileges.
& (Join-Path $root 'tests/event_analysis.tests.ps1')
& (Join-Path $root 'tests/incident_analysis.tests.ps1')
& (Join-Path $root 'tests/telemetry_analysis.tests.ps1')
& (Join-Path $root 'tests/driver_timeline.tests.ps1')
& (Join-Path $root 'tests/consultation_report.tests.ps1')
& (Join-Path $root 'tests/report_io.tests.ps1')
if (-not $RunReadOnly) {
    Write-Host 'Syntax checked only. No diagnostics or repairs were executed.'
    exit 0
}
$begin = Get-Date
& (Join-Path $root 'tools/diagnose.ps1') -Days 1
$locations = @((Join-Path $root 'REPORTS'), (Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'AXMART-PC-CARE-Reports'))
$recent = @()
foreach ($dir in $locations) {
    if (Test-Path -LiteralPath $dir) {
        $recent += @(Get-ChildItem -LiteralPath $dir -Filter 'pc-care-*.json' -File -ErrorAction Stop | Where-Object { $_.LastWriteTime -ge $begin.AddSeconds(-2) })
    }
}
if ($recent.Count -eq 0) { throw 'No new diagnostic JSON found after read-only test.' }
$jsonFile = ($recent | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName
$htmlFile = [System.IO.Path]::ChangeExtension($jsonFile, '.html')
if (-not (Test-Path -LiteralPath $htmlFile -PathType Leaf)) {
    throw 'Incomplete report pair: JSON exists but matching HTML is missing.'
}
$json = Get-Content -LiteralPath $jsonFile -Raw -Encoding UTF8 | ConvertFrom-Json
if ($json.mode -ne 'read-only' -or $json.version -notmatch 'alpha' -or $null -eq $json.observations.eventCollection -or $null -eq $json.observations.collectionStatus -or $null -eq $json.analysis -or $null -eq $json.observations.battery -or $null -eq $json.observations.windowsUpdate -or $null -eq $json.observations.driverDevices -or $null -eq $json.observations.recordedTimeline -or $null -eq $json.consultation) {
    throw 'Diagnostic output schema mismatch.'
}
Write-Host ('READ-ONLY TEST PASS: ' + $json.assessment)
Write-Host ('Report pair: ' + $jsonFile + ' / ' + $htmlFile) -ForegroundColor Green
Write-Host 'No disk repair or boot configuration changes were initiated. Local HTML/JSON report files WERE written.'
