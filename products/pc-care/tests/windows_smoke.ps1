# AXMART PC CARE Windows PowerShell 5.1 verification (never starts repair).
# Default performs parsing only; -RunReadOnly explicitly executes diagnostics.
[CmdletBinding()]
param([switch]$RunReadOnly)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
foreach ($rel in @('tools/diagnose.ps1','tools/repair.ps1','tools/event_analysis.ps1','tools/incident_analysis.ps1','tools/telemetry_analysis.ps1','tools/pnp_analysis.ps1','tools/recorded_timeline.ps1','tools/consultation_report.ps1','tools/consultation_render.ps1','tools/share_payload.ps1','tools/share_preview.ps1','tools/report_io.ps1','tests/event_analysis.tests.ps1','tests/incident_analysis.tests.ps1','tests/telemetry_analysis.tests.ps1','tests/driver_timeline.tests.ps1','tests/consultation_report.tests.ps1','tests/share_payload.tests.ps1','tests/report_io.tests.ps1','tests/diagnose_mock_e2e.tests.ps1')) {
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
& (Join-Path $root 'tests/share_payload.tests.ps1')
& (Join-Path $root 'tests/report_io.tests.ps1')
& (Join-Path $root 'tests/diagnose_mock_e2e.tests.ps1')
if (-not $RunReadOnly) {
    Write-Host 'Syntax checked only. No diagnostics or repairs were executed.'
    exit 0
}
# Validate only this run's saved files; never select latest by timestamp.
$savedPair = @(& (Join-Path $root 'tools/diagnose.ps1') -Days 1 -PassThru -NoOpenReport)
if ($savedPair.Count -ne 1 -or $null -eq $savedPair[0]) { throw 'Expected one receipt.' }
$jsonFile = [string]$savedPair[0].json
$htmlFile = [string]$savedPair[0].html
if ([string]::IsNullOrWhiteSpace($jsonFile) -or [string]::IsNullOrWhiteSpace($htmlFile)) { throw 'Missing receipt path.' }
if (-not [System.IO.Path]::IsPathRooted($jsonFile) -or -not [System.IO.Path]::IsPathRooted($htmlFile)) { throw 'Relative receipt path.' }
$jsonFile = [System.IO.Path]::GetFullPath($jsonFile)
$htmlFile = [System.IO.Path]::GetFullPath($htmlFile)
$name = [System.IO.Path]::GetFileName($jsonFile)
if ($name -notmatch '^pc-care-[0-9]{8}-[0-9]{6}-[0-9a-f]{8}[.]json$') { throw 'Unexpected report name.' }
if (-not [string]::Equals([System.IO.Path]::ChangeExtension($jsonFile, '.html'), $htmlFile, [System.StringComparison]::OrdinalIgnoreCase)) { throw 'Report names mismatch.' }
$jsonFolder = [System.IO.Path]::GetDirectoryName($jsonFile)
$allowedFolders = @((Join-Path $root 'REPORTS'))
$localData = [Environment]::GetFolderPath('LocalApplicationData')
if (-not [string]::IsNullOrWhiteSpace($localData)) { $allowedFolders += (Join-Path $localData 'AXMART-PC-CARE-Reports') }
$documents = [Environment]::GetFolderPath('MyDocuments')
if (-not [string]::IsNullOrWhiteSpace($documents)) { $allowedFolders += (Join-Path $documents 'AXMART-PC-CARE-Reports') }
$allowed = $false
foreach ($folder in $allowedFolders) {
    if ([string]::Equals($jsonFolder, [System.IO.Path]::GetFullPath($folder), [System.StringComparison]::OrdinalIgnoreCase)) { $allowed = $true; break }
}
. (Join-Path $root 'tools/report_io.ps1')
if (-not $allowed -or -not (Test-PcCarePrivateReportFolder -Folder $jsonFolder)) { throw 'Diagnostic receipt points outside safe private local report folders.' }
if (-not (Test-Path -LiteralPath $jsonFile -PathType Leaf) -or -not (Test-Path -LiteralPath $htmlFile -PathType Leaf)) { throw 'Diagnostic receipt JSON or HTML is missing.' }
$json = Get-Content -LiteralPath $jsonFile -Raw -Encoding UTF8 | ConvertFrom-Json
if ($json.schemaVersion -ne 1 -or $json.mode -ne 'read-only' -or $json.version -notmatch 'alpha' -or $null -eq $json.observations.eventCollection -or $null -eq $json.observations.collectionStatus -or $null -eq $json.analysis -or $null -eq $json.observations.battery -or $null -eq $json.observations.windowsUpdate -or $null -eq $json.observations.driverDevices -or $null -eq $json.observations.recordedTimeline -or $null -eq $json.consultation -or $null -eq $json.sharePreview -or $null -eq $json.sharePreview.qrImageSupported) {
    throw 'Diagnostic output schema mismatch.'
}
# The diagnostic JSON uses only per-run disk ordinals and bounded health names.
$diskIndex = 0
foreach ($device in @($json.observations.physicalDisks)) {
    $diskIndex++
    if ([string]$device.model -cne ('물리 저장장치 {0}' -f $diskIndex)) {
        throw 'Saved disk observation contains a raw or unexpected device label.'
    }
    if ([string]$device.status -notin @('Healthy','Warning','Unhealthy','Unknown')) {
        throw 'Saved disk observation has an untrusted health status.'
    }
}
Write-Host 'DISK PRIVACY CONTRACT PASS: per-run ordinals and bounded health states.' -ForegroundColor Green
# Validate the end-to-end timeline evidence contract in THIS run's local report.
$timeReport = $json.observations.recordedTimeline
if ($null -eq $timeReport -or $timeReport.status -notin @('collected','no matching events','truncated','incomplete','unavailable') -or
    $null -eq $timeReport.coverageComplete -or $null -eq $timeReport.sourceCollection) {
    throw 'Recorded timeline coverage schema missing.'
}
if ($timeReport.sourceCollection.system -ne $json.observations.eventCollection -or
    $timeReport.sourceCollection.update -ne $json.observations.windowsUpdate.status) {
    throw 'Recorded timeline input provenance differs from collectors.'
}
if ($null -eq $timeReport.rejectedCount -or
    $timeReport.rejectedCount -isnot [int] -or $timeReport.rejectedCount -lt 0) {
    throw 'Timeline input rejection count is missing or invalid.'
}
if ($timeReport.rejectedCount -gt 0 -and
    ($timeReport.coverageComplete -or $timeReport.status -in @('collected','no matching events'))) {
    throw 'Timeline discarded raw records but claims complete event coverage.'
}
if ($timeReport.coverageComplete -and
    ($timeReport.status -notin @('collected','no matching events') -or
     $timeReport.sourceCollection.system -in @('unavailable','truncated') -or
     $timeReport.sourceCollection.update -in @('unavailable','truncated'))) {
    throw 'Timeline claims complete coverage despite missing or capped input.'
}
$allowedProximity = @('bugcheck_storage_proximity','shutdown_storage_proximity','bugcheck_update_proximity')
foreach ($window in @($timeReport.windows)) {
    if ($null -eq $window -or $window.causeConfirmed -ne $false -or
        $window.interpretation -ne 'recorded_timestamp_proximity_only') {
        throw 'Timeline reports causality instead of recorded-time grouping.'
    }
    foreach ($kind in @($window.coObserved)) {
        if ([string]$kind -notin $allowedProximity) {
            throw 'Unexpected or unfiltered timeline proximity code.'
        }
    }
}
# A full report with incomplete evidence must never present a clean assessment.
if ($json.analysis.status -eq 'incomplete' -and
    $json.assessment -eq '관찰 범위 내 특이사항 없음') {
    throw 'Report claims a clean assessment while incident evidence is incomplete.'
}
if ($json.assessment -eq '관찰 범위 내 특이사항 없음' -and
    @($json.limitations).Count -gt 0) {
    throw 'Clean assessment contradicts explicit report limitations.'
}
Write-Host 'ASSESSMENT CONTRACT PASS: incomplete evidence cannot appear as clean.' -ForegroundColor Green
Write-Host 'TIMELINE CONTRACT PASS: local collector provenance, coverage and no causal claims.' -ForegroundColor Green
# Validate the saved static consultation report without executing JavaScript or initiating repair.
$savedHtml = [System.IO.File]::ReadAllText($htmlFile, [System.Text.Encoding]::UTF8)
if ($savedHtml -notmatch 'id="consultation-print"' -or
    $savedHtml -notmatch '@page\{size:A4 portrait' -or
    $savedHtml -notmatch 'main>:not\(#consultation-print\)' -or
    $savedHtml -notmatch 'aria-label="진단 보고서 바로가기"' -or
    $savedHtml -notmatch 'share-panel' -or
    $savedHtml -notmatch '근접 신호\(원인 확정 아님\)') {
    throw 'Saved HTML missing the private consultation/print/share sections.'
}
if ($json.sharePreview.payloadStoredInJson -ne $false -or
    @($json.sharePreview.PSObject.Properties.Name | Where-Object { $_ -in @('payloadText','rawMessage','serialNumber') }).Count -ne 0) {
    throw 'Share preview JSON unexpectedly contains share text or raw identifiers.'
}
if ($json.sharePreview.qrImageSupported -eq $true) {
    if ($savedHtml -notmatch 'id="pc-care-generate-qr"' -or
        $savedHtml -notmatch 'id="pc-care-qr-canvas"' -or
        $savedHtml -notmatch 'Copyright \(c\) 2012 davidshimjs' -or
        $savedHtml -notmatch 'QRCode.CorrectLevel') {
        throw 'QR reported supported, but offline image generator or its license is missing.'
    }
} else {
    if ($savedHtml -match 'id="pc-care-generate-qr"') {
        throw 'QR generation button present despite unsupported local vendor.'
    }
}
if ($savedHtml -match '(?i)<script\s+[^>]*src\s*=\s*["'']?https?://' -or
    $savedHtml -match '(?i)<link\s+[^>]*href\s*=\s*["'']?https?://') {
    throw 'Saved report depends on a remote script or stylesheet.'
}
Write-Host 'REPORT HTML CONTRACT PASS: consultation A4, QR local fallback, no remote asset tags.' -ForegroundColor Green
Write-Host ('READ-ONLY TEST PASS: ' + $json.assessment)
Write-Host ('Report pair: ' + $jsonFile + ' / ' + $htmlFile) -ForegroundColor Green
Write-Host 'No disk repair or boot configuration changes were initiated. Local HTML/JSON report files WERE written.'
