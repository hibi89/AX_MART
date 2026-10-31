# Full diagnosis orchestration using synthetic API shims only.
# Writes only one unique report pair into this temporary source copy's REPORTS folder.
$ErrorActionPreference = 'Stop'
$productRoot = Split-Path -Parent $PSScriptRoot
$repoRoot = Split-Path -Parent $productRoot
$diagnose = Join-Path $productRoot 'tools/diagnose.ps1'
$startedAt = [datetime]::Now.AddMinutes(-10)
$privateMarker = 'PRIVATE-SYNTHETIC-DO-NOT-EXPORT-91C3'

function Get-CimInstance {
    param([string]$ClassName, [string]$Filter, [string[]]$Property, [string]$ErrorAction)
    switch ($ClassName) {
        'Win32_OperatingSystem' {
            return [pscustomobject]@{ Caption='Microsoft Windows 11 Pro'; Version='10.0'; BuildNumber='26100'; LastBootUpTime='20261031190000.000000+540' }
        }
        'Win32_LogicalDisk' {
            return @([pscustomobject]@{ DeviceID='C:'; Size=(100 * 1GB); FreeSpace=([math]::Round(4.96 * 1GB)); VolumeName=$privateMarker })
        }
        'Win32_Battery' {
            return @([pscustomobject]@{ EstimatedChargeRemaining=$true; BatteryStatus=$true; DesignCapacity=60000.5; FullChargeCapacity=60000 })
        }
        'Win32_PnPEntity' {
            return @([pscustomobject]@{ ConfigManagerErrorCode=28.5; PNPClass='Display'; Name=$privateMarker; DeviceID=$privateMarker })
        }
        default { throw ('Unexpected synthetic CIM class: ' + $ClassName) }
    }
}
function Get-PhysicalDisk {
    param([string]$ErrorAction)
    return [pscustomobject]@{ HealthStatus='Warning'; OperationalStatus=@('OK'); FriendlyName=$privateMarker; SerialNumber=$privateMarker; UniqueId=$privateMarker }
}
function Get-StorageReliabilityCounter {
    param([Parameter(ValueFromPipeline=$true)][object]$PhysicalDisk, [string]$ErrorAction)
    process { return [pscustomobject]@{ Wear=$true; Temperature=$true; SerialNumber=$privateMarker } }
}
function Get-WinEvent {
    param([hashtable]$FilterHashtable, [int]$MaxEvents, [string]$ErrorAction)
    if ($FilterHashtable.ContainsKey('ProviderName')) {
        return [pscustomobject]@{ Id=20; ProviderName='Microsoft-Windows-WindowsUpdateClient'; RecordId=701; TimeCreated=$startedAt.AddMinutes(4); Message=('<script>' + $privateMarker + '</script>') }
    }
    return @(
        [pscustomobject]@{ Id=41; ProviderName='Microsoft-Windows-Kernel-Power'; RecordId=500.5; TimeCreated=$startedAt; Message=$privateMarker },
        [pscustomobject]@{ Id=41; ProviderName='Microsoft-Windows-Kernel-Power'; RecordId=$true; TimeCreated=$startedAt.AddSeconds(1); Message=$privateMarker },
        [pscustomobject]@{ Id=6008; ProviderName='EventLog'; RecordId=702; TimeCreated=$startedAt.AddMinutes(1); Message=$privateMarker },
        [pscustomobject]@{ Id=7; ProviderName='disk'; RecordId=703; TimeCreated=$startedAt.AddMinutes(2); Message=$privateMarker },
        [pscustomobject]@{ Id=1001; ProviderName='Microsoft-Windows-WER-SystemErrorReporting'; RecordId=704; TimeCreated=$startedAt.AddMinutes(3); Message=('<script>' + $privateMarker + '</script>') }
    )
}
function Get-MpComputerStatus {
    param([string]$ErrorAction)
    return [pscustomobject]@{ AntivirusEnabled=$true; RealTimeProtectionEnabled=$true }
}

$savedJson = $null
$savedHtml = $null
try {
    # These command names shadow Windows APIs for the child diagnosis script.
    $result = @(& $diagnose -Days 30 -PassThru -NoOpenReport)
    if ($result.Count -ne 1 -or $null -eq $result[0]) { throw 'Mocked diagnosis did not return one report receipt.' }
    $savedJson = [System.IO.Path]::GetFullPath([string]$result[0].json)
    $savedHtml = [System.IO.Path]::GetFullPath([string]$result[0].html)
    $reportsRoot = [System.IO.Path]::GetFullPath((Join-Path $productRoot 'REPORTS')).TrimEnd('\') + '\'
    if (-not $savedJson.StartsWith($reportsRoot, [StringComparison]::OrdinalIgnoreCase) -or
        -not $savedHtml.StartsWith($reportsRoot, [StringComparison]::OrdinalIgnoreCase)) {
        throw 'Mocked report pair escaped the temporary package REPORTS folder.'
    }
    if (-not (Test-Path -LiteralPath $savedJson -PathType Leaf) -or -not (Test-Path -LiteralPath $savedHtml -PathType Leaf)) {
        throw 'Mocked diagnosis did not persist both output formats.'
    }
    $jsonText = [System.IO.File]::ReadAllText($savedJson, [System.Text.Encoding]::UTF8)
    $htmlText = [System.IO.File]::ReadAllText($savedHtml, [System.Text.Encoding]::UTF8)
    $report = $jsonText | ConvertFrom-Json
    $criticalIssues = @($report.issues | Where-Object { $_.code -eq 'DISK_SPACE_CRITICAL' })
    if ($report.assessment -ne '위험 신호' -or $criticalIssues.Count -ne 1) {
        $codes = @($report.issues | ForEach-Object { [string]$_.code }) -join ','
        throw ('Exact raw-byte disk boundary did not produce a visible critical issue: assessment={0}; codes={1}' -f $report.assessment,$codes)
    }
    if (@($report.issues | Where-Object { $_.code -eq 'DISK_HEALTH' }).Count -ne 1) {
        throw 'Synthetic storage Warning was not retained as a diagnostic warning.'
    }
    if ($report.observations.physicalDisks[0].wearPercent -ne $null -or $report.observations.physicalDisks[0].temperatureC -ne $null) {
        throw 'Boolean SMART sensor values became numeric measurements.'
    }
    if ($report.observations.battery.samples[0].chargeRemainingPercent -ne $null -or
        $report.observations.battery.samples[0].batteryStatusCode -ne $null -or
        $report.observations.battery.samples[0].designCapacityMWh -ne $null) {
        throw 'Malformed battery readings became numeric observations.'
    }
    if (@($report.observations.eventEvidence | Where-Object { $_.kind -eq 'shutdown_signal' }).Count -ne 3) {
        throw 'Separate malformed RecordId observations were lost or provider filtering changed.'
    }
    if ($report.observations.windowsUpdate.installationFailureRecords -ne 1) {
        throw 'Scoped Windows Update failure record was lost.'
    }
    if ($report.consultation.assessment -ne $report.assessment -or
        $htmlText -notmatch [regex]::Escape([string]$report.assessment) -or
        $htmlText -notmatch 'consultation-print') {
        throw 'JSON and HTML did not preserve the same assessment/consultation result.'
    }
    if (($jsonText + $htmlText) -match [regex]::Escape($privateMarker)) {
        throw 'Synthetic device names or raw event message escaped into a report.'
    }
    if ($report.consultation.timeBasis -notmatch '실제 장애 발생 시각 확정 아님' -or
        $htmlText -notmatch '실제 장애 발생 시각 확정 아님') {
        throw 'Report overclaimed event recorded time as incident time.'
    }
    Write-Host 'DIAGNOSE MOCK E2E PASS: API shims, exact disk boundary, warning provenance, invalid sensor and RecordIds, JSON/HTML agreement, privacy.' -ForegroundColor Green
} finally {
    # Delete only the unique files returned by this invocation and only within the temp REPORTS folder.
    $reportsRoot = [System.IO.Path]::GetFullPath((Join-Path $productRoot 'REPORTS')).TrimEnd('\') + '\'
    foreach ($path in @($savedJson,$savedHtml)) {
        if ([string]::IsNullOrWhiteSpace($path)) { continue }
        $full = [System.IO.Path]::GetFullPath($path)
        if ($full.StartsWith($reportsRoot, [StringComparison]::OrdinalIgnoreCase) -and
            [System.IO.File]::Exists($full)) {
            [System.IO.File]::Delete($full)
        }
    }
}
