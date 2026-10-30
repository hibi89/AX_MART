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
    $normal = Join-Path $sandbox 'normal'
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
    Write-Host 'REPORT IO FIXTURE PASS: paired output, existing-file preservation, fallback and failure.' -ForegroundColor Green
} finally {
    # This path is created from a fresh GUID beneath the OS temp folder by this fixture.
    if (Test-Path -LiteralPath $sandbox) {
        Remove-Item -LiteralPath $sandbox -Recurse -Force -ErrorAction Stop
    }
}
