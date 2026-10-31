# AXMART PC CARE: isolated Windows PowerShell 5.1 report-writer fixture.
# Writes and deletes only a dedicated throwaway directory under the OS temp folder.
$ErrorActionPreference = 'Stop'
. (Join-Path (Split-Path -Parent $PSScriptRoot) 'tools/report_io.ps1')
function Assert-Report([bool]$Condition, [string]$Reason) {
    if (-not $Condition) { throw ('REPORT IO FIXTURE FAIL: ' + $Reason) }
}
$sandbox = Join-Path ([System.IO.Path]::GetTempPath()) ('axmart-pc-care-fixture-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $sandbox -ErrorAction Stop | Out-Null
try {

    # Network-mapped drive letters do not start with UNC, so gate the actual DriveType.
    Assert-Report (-not (Test-PcCareLocalDriveType -DriveType ([System.IO.DriveType]::Network))) 'Mapped network shares must not count as private drives'
    Assert-Report (-not (Test-PcCareLocalDriveType -DriveType ([System.IO.DriveType]::NoRootDirectory))) 'Unresolved drive types are blocked'
    Assert-Report (-not (Test-PcCareLocalDriveType -DriveType ([System.IO.DriveType]::CDRom))) 'Read-only optical drives are not report destinations'
    Assert-Report (Test-PcCareLocalDriveType -DriveType ([System.IO.DriveType]::Fixed)) 'Fixed local drive remains an allowed type'
    Assert-Report (Test-PcCareLocalDriveType -DriveType ([System.IO.DriveType]::Removable)) 'USB removable drive remains an allowed type'
    # Define the target before exercising its privacy gate; an unbound $normal
    # makes the synthetic QA fail before it reaches any report I/O assertion.
    $normal = Join-Path $sandbox 'normal'
    Assert-Report (Test-PcCarePrivateReportFolder -Folder $normal) 'Local synthetic sandbox is accepted'
    # No arbitrary path from FileBase may escape the nominated report directory.
    foreach ($badBase in @('../escaped', '..\escaped', '/absolute', 'C:\outside', '.hidden', 'nested/name', '', ('x' * 81))) {
        $blocked = $false
        try {
            Save-PcCareReportPair -JsonText 'X' -HtmlText 'Y' -Candidates @($normal) -FileBase $badBase | Out-Null
        } catch { $blocked = ([string]$_.Exception.Message -match 'Invalid report file base') }
        Assert-Report $blocked ('Unsafe report file base accepted: ' + $badBase)
    }
    Assert-Report (-not (Test-Path -LiteralPath (Join-Path $sandbox 'escaped.json'))) 'Traversal wrote a JSON file outside REPORTS'
    Assert-Report (-not (Test-Path -LiteralPath (Join-Path $sandbox 'escaped.html'))) 'Traversal wrote an HTML file outside REPORTS'
    $first = Save-PcCareReportPair -JsonText '{"mode":"read-only"}' -HtmlText '<html>local only</html>' -Candidates @($normal) -FileBase 'fixture-one'
    Assert-Report ((Test-Path -LiteralPath $first.json) -and (Test-Path -LiteralPath $first.html)) 'Both outputs must exist'
    Assert-Report (([System.IO.File]::ReadAllText($first.json)) -eq '{"mode":"read-only"}') 'JSON bytes do not match'
    Assert-Report (([System.IO.File]::ReadAllText($first.html)) -eq '<html>local only</html>') 'HTML bytes do not match'
    $collision = $false
    try {
        Save-PcCareReportPair -JsonText 'new' -HtmlText 'new' -Candidates @($normal) -FileBase 'fixture-one' | Out-Null
    } catch { $collision = ([string]$_.Exception.Message -match 'filename collision') }
    Assert-Report $collision 'Existing report name must be rejected'
    Assert-Report (([System.IO.File]::ReadAllText($first.json)) -eq '{"mode":"read-only"}') 'Collision modified previous JSON'
    Assert-Report (([System.IO.File]::ReadAllText($first.html)) -eq '<html>local only</html>') 'Collision modified previous HTML'
    # A stale or other process-owned temp file must never be rewritten or deleted.
    $stale = Join-Path $sandbox 'stale-temp'
    New-Item -ItemType Directory -Path $stale -ErrorAction Stop | Out-Null
    $stalePath = Join-Path $stale 'fixture-stale.json.partial'
    [System.IO.File]::WriteAllText($stalePath, 'SENTINEL-DO-NOT-DELETE')
    $staleRejected = $false
    try {
        Save-PcCareReportPair -JsonText 'new-data' -HtmlText 'new-html' -Candidates @($stale) -FileBase 'fixture-stale' | Out-Null
    } catch { $staleRejected = ([string]$_.Exception.Message -match 'filename collision') }
    Assert-Report $staleRejected 'Existing partial name must be rejected'
    Assert-Report (([System.IO.File]::ReadAllText($stalePath)) -eq 'SENTINEL-DO-NOT-DELETE') 'Existing partial data changed'
    Assert-Report (-not (Test-Path -LiteralPath (Join-Path $stale 'fixture-stale.json'))) 'Partial collision wrote a final JSON'
    Assert-Report (-not (Test-Path -LiteralPath (Join-Path $stale 'fixture-stale.html'))) 'Partial collision wrote a final HTML'
    # An existing final file still blocks publishing and must remain byte-for-byte intact.
    $oneSided = Join-Path $sandbox 'one-sided'
    New-Item -ItemType Directory -Path $oneSided -ErrorAction Stop | Out-Null
    $existingHtml = Join-Path $oneSided 'fixture-existing.html'
    [System.IO.File]::WriteAllText($existingHtml, 'EXISTING-HTML')
    $existingRejected = $false
    try {
        Save-PcCareReportPair -JsonText 'fresh' -HtmlText 'fresh' -Candidates @($oneSided) -FileBase 'fixture-existing' | Out-Null
    } catch { $existingRejected = ([string]$_.Exception.Message -match 'filename collision') }
    Assert-Report $existingRejected 'Existing one-sided HTML must block overwrite'
    Assert-Report (([System.IO.File]::ReadAllText($existingHtml)) -eq 'EXISTING-HTML') 'Existing final HTML was altered'
    Assert-Report (-not (Test-Path -LiteralPath (Join-Path $oneSided 'fixture-existing.json'))) 'Partial final pair was unexpectedly published'
    $blocker = Join-Path $sandbox 'blocked-parent-is-file'
    [System.IO.File]::WriteAllText($blocker, 'not a directory')
    $fallback = Join-Path $sandbox 'fallback'
    $pair = Save-PcCareReportPair -JsonText 'fallback-json' -HtmlText 'fallback-html' -Candidates @($blocker,$fallback) -FileBase 'fixture-two'
    Assert-Report ((Test-Path -LiteralPath $pair.json) -and (Test-Path -LiteralPath $pair.html)) 'Fallback failed to produce report pair'
    Assert-Report ($pair.json.StartsWith($fallback, [System.StringComparison]::OrdinalIgnoreCase)) 'Wrong fallback destination'
    Assert-Report (([System.IO.File]::ReadAllText($blocker)) -eq 'not a directory') 'Source blocker file changed'
    $allFailed = $false
    try {
        Save-PcCareReportPair -JsonText 'X' -HtmlText 'Y' -Candidates @($blocker) -FileBase 'fixture-three' | Out-Null
    } catch { $allFailed = ([string]$_.Exception.Message -match '저장에 실패') }
    Assert-Report $allFailed 'Exhausted candidate destinations must fail explicitly'

    # Cloud-synced paths must never receive sensitive local reports, even if writable.
    $cloud = Join-Path $sandbox 'OneDrive - Synthetic Organization'
    $cloudReports = Join-Path $cloud 'REPORTS'
    Assert-Report (-not (Test-PcCarePrivateReportFolder -Folder $cloudReports)) 'Known OneDrive-style sync folder is blocked'
    $offline = Join-Path $sandbox 'private-fallback'
    $local = Save-PcCareReportPair -JsonText 'private-json' -HtmlText 'private-html' -Candidates @($cloudReports,$offline) -FileBase 'fixture-private'
    Assert-Report ((Test-Path -LiteralPath $local.json) -and ($local.json.StartsWith($offline, [System.StringComparison]::OrdinalIgnoreCase))) 'Cloud folder skipped in favor of local fallback'
    Assert-Report (-not (Test-Path -LiteralPath $cloudReports)) 'Cloud folder must not be created as a report destination'
    $onlyCloudRejected = $false
    try {
        Save-PcCareReportPair -JsonText 'must-not-sync' -HtmlText 'must-not-sync' -Candidates @($cloudReports) -FileBase 'fixture-cloud-only' | Out-Null
    } catch { $onlyCloudRejected = ([string]$_.Exception.Message -match '저장에 실패') }
    Assert-Report $onlyCloudRejected 'Only cloud destinations must fail closed'
    Assert-Report (-not (Test-Path -LiteralPath (Join-Path $cloudReports 'fixture-cloud-only.json'))) 'Cloud-only failure must not write personal JSON'
    Assert-Report (-not (Test-PcCarePrivateReportFolder -Folder '\\example-server\public\reports')) 'UNC network shares are not private report folders'
    Write-Host 'REPORT IO FIXTURE PASS: paired output, existing-file preservation, fallback and failure.' -ForegroundColor Green
} finally {
    # This path is created from a fresh GUID beneath the OS temp folder by this fixture.
    if (Test-Path -LiteralPath $sandbox) {
        Remove-Item -LiteralPath $sandbox -Recurse -Force -ErrorAction Stop
    }
}
