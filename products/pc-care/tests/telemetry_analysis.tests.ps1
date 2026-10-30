# Offline-only telemetry regression fixtures. No Windows queries or modifications.
$ErrorActionPreference = 'Stop'
. (Join-Path (Split-Path -Parent $PSScriptRoot) 'tools/telemetry_analysis.ps1')
function Assert-Telemetry([bool]$Ok, [string]$Reason) {
    if (-not $Ok) { throw ('TELEMETRY FIXTURE FAIL: ' + $Reason) }
}
$unavailable = ConvertTo-PcCareBatterySnapshot -QueryStatus 'unavailable'
Assert-Telemetry ($unavailable.status -eq 'unavailable' -and $null -eq $unavailable.batteryCount) 'Query denial != no battery'
$absent = ConvertTo-PcCareBatterySnapshot -QueryStatus 'empty'
Assert-Telemetry ($absent.status -eq 'not_present' -and $absent.batteryCount -eq 0) 'No battery is separate from failure'
$invalid = [pscustomobject]@{
    EstimatedChargeRemaining = 255
    BatteryStatus = 999
    DesignCapacity = 0
    FullChargeCapacity = -1
    DeviceID = 'MUST-NOT-LEAK'
    Name = '<script>MUST-NOT-LEAK</script>'
}
$bad = ConvertTo-PcCareBatterySnapshot -Batteries @($invalid) -QueryStatus 'collected'
Assert-Telemetry ($bad.batteryCount -eq 1 -and $bad.status -eq 'collected') 'Count should reflect reported devices'
Assert-Telemetry ($null -eq $bad.samples[0].chargeRemainingPercent) '255 must not represent charge'
Assert-Telemetry ($null -eq $bad.samples[0].designCapacityMWh -and $null -eq $bad.samples[0].fullChargeCapacityMWh) 'Unsupported capacity stays unknown'
Assert-Telemetry (($bad | ConvertTo-Json -Depth 6) -notmatch 'MUST-NOT-LEAK') 'Personal device identifiers must not be copied'
$valid = ConvertTo-PcCareBatterySnapshot -Batteries @([pscustomobject]@{
    EstimatedChargeRemaining = 42; BatteryStatus = 2; DesignCapacity = 60000; FullChargeCapacity = 52000
}) -QueryStatus 'collected'
Assert-Telemetry ($valid.samples[0].chargeRemainingPercent -eq 42) 'Charge is not battery health'
Assert-Telemetry ($valid.samples[0].designCapacityMWh -eq 60000 -and $valid.samples[0].fullChargeCapacityMWh -eq 52000) 'Optional capacities in mWh'
Assert-Telemetry (($valid | ConvertTo-Json -Depth 6) -notmatch 'healthPercent|lifeRemainingPercent') 'Never infer SSD-style remaining battery life'
$time = [datetime]::SpecifyKind(([datetime]::Parse('2026-10-30T01:00:00')), [DateTimeKind]::Utc)
$updates = @(
    [pscustomobject]@{ Id=20; ProviderName='Microsoft-Windows-WindowsUpdateClient'; RecordId=110; TimeCreated=$time; Message='PRIVATE UPDATE NAME' },
    [pscustomobject]@{ Id=20; ProviderName='Microsoft-Windows-WindowsUpdateClient'; RecordId=110; TimeCreated=$time; Message='duplicate entry' },
    [pscustomobject]@{ Id=19; ProviderName='Microsoft-Windows-WindowsUpdateClient'; RecordId=111; TimeCreated=$time.AddMinutes(10); Message='install success' },
    [pscustomobject]@{ Id=20; ProviderName='Other-Provider'; RecordId=112; TimeCreated=$time; Message='false update event' },
    [pscustomobject]@{ Id=999; ProviderName='Microsoft-Windows-WindowsUpdateClient'; RecordId=113; TimeCreated=$time; Message='unrelated' }
)
$evidence = @(ConvertTo-PcCareUpdateEvidence -Events $updates)
Assert-Telemetry ($evidence.Count -eq 2) 'Only approved provider/IDs with record dedup'
Assert-Telemetry (@($evidence | Where-Object { $_.kind -eq 'update_installation_failure_record' }).Count -eq 1) 'Event 20 is installation failure record'
Assert-Telemetry (@($evidence | Where-Object { $_.kind -eq 'update_installation_success_record' }).Count -eq 1) 'Event 19 is installation success record'
Assert-Telemetry ($evidence[0].timeBasis -eq 'event_recorded_time') 'No inferred update date'
Assert-Telemetry (($evidence | ConvertTo-Json -Depth 6) -notmatch 'PRIVATE UPDATE NAME') 'Raw update messages must never be serialized'
# Pure storage metrics tests share the existing packaged telemetry fixture.
$normal = ConvertTo-PcCareStorageMetrics -Counter ([pscustomobject]@{ Wear=17; Temperature=39; SerialNumber='PRIVATE-SERIAL' })
Assert-Telemetry ($normal.reliabilityStatus -eq 'collected') 'Counter presence'
Assert-Telemetry ($normal.wearPercent -eq 17 -and $normal.temperatureC -eq 39) 'Valid observed metrics'
Assert-Telemetry (($normal | ConvertTo-Json -Compress) -notmatch 'PRIVATE') 'Never expose device identifiers'
$missing = ConvertTo-PcCareStorageMetrics -Counter $null
Assert-Telemetry ($missing.reliabilityStatus -eq 'unavailable' -and $null -eq $missing.wearPercent -and $null -eq $missing.temperatureC) 'Missing telemetry does not imply healthy'
$zero = ConvertTo-PcCareStorageMetrics -Counter ([pscustomobject]@{ Wear=0; Temperature=0 })
Assert-Telemetry ($null -eq $zero.wearPercent -and $null -eq $zero.temperatureC) 'Ambiguous zeros are not valid readings'
$sentinel = ConvertTo-PcCareStorageMetrics -Counter ([pscustomobject]@{ Wear=255; Temperature=65535 })
Assert-Telemetry ($null -eq $sentinel.wearPercent -and $null -eq $sentinel.temperatureC) 'Sentinel readings rejected'
$negative = ConvertTo-PcCareStorageMetrics -Counter ([pscustomobject]@{ Wear=-2; Temperature=-99 })
Assert-Telemetry ($null -eq $negative.wearPercent -and $null -eq $negative.temperatureC) 'Invalid negative values rejected'
$boundary = ConvertTo-PcCareStorageMetrics -Counter ([pscustomobject]@{ Wear=100; Temperature=125 })
Assert-Telemetry ($boundary.wearPercent -eq 100 -and $boundary.temperatureC -eq 125) 'Bounded values retained'
$fraction = ConvertTo-PcCareStorageMetrics -Counter ([pscustomobject]@{ Wear=10.5; Temperature=36.8 })
Assert-Telemetry ($null -eq $fraction.wearPercent -and $null -eq $fraction.temperatureC) 'Do not round uncertain measurements'
$spoof = ConvertTo-PcCareStorageMetrics -Counter ([pscustomobject]@{ Wear='PRIVATE-SECRET'; Temperature='S/N:private' })
Assert-Telemetry ($null -eq $spoof.wearPercent -and $null -eq $spoof.temperatureC) 'Non-numeric fields never displayed'
Assert-Telemetry (($spoof | ConvertTo-Json -Compress) -notmatch 'PRIVATE|S/N') 'Raw names not reflected'
Write-Host 'TELEMETRY STORAGE METRICS FIXTURE PASS: bounded noncausal wear/temperature; unsupported and private values rejected.' -ForegroundColor Green
Write-Host 'TELEMETRY FIXTURE PASS: absent/denied/invalid battery and scoped Windows update evidence.' -ForegroundColor Green
