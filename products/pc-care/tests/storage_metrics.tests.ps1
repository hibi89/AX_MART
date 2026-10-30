# Synthetic-only storage reliability source validation. Never queries Windows devices.
$ErrorActionPreference = 'Stop'
. (Join-Path (Split-Path -Parent $PSScriptRoot) 'tools/storage_metrics.ps1')
function Assert-StorageMetric([bool]$Condition, [string]$Detail) {
    if (-not $Condition) { throw ('STORAGE METRICS FAIL: ' + $Detail) }
}
$normal = ConvertTo-PcCareStorageMetrics -Counter ([pscustomobject]@{ Wear=17; Temperature=39; SerialNumber='PRIVATE-SERIAL' })
Assert-StorageMetric ($normal.reliabilityStatus -eq 'collected') 'Counter presence'
Assert-StorageMetric ($normal.wearPercent -eq 17 -and $normal.temperatureC -eq 39) 'Valid observed metrics'
Assert-StorageMetric (($normal | ConvertTo-Json -Compress) -notmatch 'PRIVATE') 'Never expose device identifiers'
$missing = ConvertTo-PcCareStorageMetrics -Counter $null
Assert-StorageMetric ($missing.reliabilityStatus -eq 'unavailable' -and $null -eq $missing.wearPercent -and $null -eq $missing.temperatureC) 'Missing telemetry does not imply healthy'
$zero = ConvertTo-PcCareStorageMetrics -Counter ([pscustomobject]@{ Wear=0; Temperature=0 })
Assert-StorageMetric ($null -eq $zero.wearPercent -and $null -eq $zero.temperatureC) 'Ambiguous zeros are not valid readings'
$sentinel = ConvertTo-PcCareStorageMetrics -Counter ([pscustomobject]@{ Wear=255; Temperature=65535 })
Assert-StorageMetric ($null -eq $sentinel.wearPercent -and $null -eq $sentinel.temperatureC) 'Sentinel readings rejected'
$negative = ConvertTo-PcCareStorageMetrics -Counter ([pscustomobject]@{ Wear=-2; Temperature=-99 })
Assert-StorageMetric ($null -eq $negative.wearPercent -and $null -eq $negative.temperatureC) 'Invalid negative values rejected'
$boundary = ConvertTo-PcCareStorageMetrics -Counter ([pscustomobject]@{ Wear=100; Temperature=125 })
Assert-StorageMetric ($boundary.wearPercent -eq 100 -and $boundary.temperatureC -eq 125) 'Bounded values retained'
$fraction = ConvertTo-PcCareStorageMetrics -Counter ([pscustomobject]@{ Wear=10.5; Temperature=36.8 })
Assert-StorageMetric ($null -eq $fraction.wearPercent -and $null -eq $fraction.temperatureC) 'Do not round uncertain measurements'
$spoof = ConvertTo-PcCareStorageMetrics -Counter ([pscustomobject]@{ Wear='PRIVATE-SECRET'; Temperature='S/N:private' })
Assert-StorageMetric ($null -eq $spoof.wearPercent -and $null -eq $spoof.temperatureC) 'Non-numeric fields never displayed'
Assert-StorageMetric (($spoof | ConvertTo-Json -Compress) -notmatch 'PRIVATE|S/N') 'Raw names not reflected'
Write-Host 'STORAGE METRICS FIXTURE PASS: bounded noncausal wear/temperature; unsupported and private values rejected.' -ForegroundColor Green
