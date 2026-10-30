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
    [pscustomobject]@{ Id=20; ProviderName='Private-WindowsUpdateClient'; RecordId=114; TimeCreated=$time; Message='PRIVATE FAKE UPDATE' },
    [pscustomobject]@{ Id=19; ProviderName='WindowsUpdateClient'; RecordId=115; TimeCreated=$time; Message='PRIVATE FAKE UPDATE' },
    [pscustomobject]@{ Id=999; ProviderName='Microsoft-Windows-WindowsUpdateClient'; RecordId=113; TimeCreated=$time; Message='unrelated' }
)
$evidence = @(ConvertTo-PcCareUpdateEvidence -Events $updates)
Assert-Telemetry ($evidence.Count -eq 2) 'Only approved provider/IDs with record dedup'
Assert-Telemetry (@($evidence | Where-Object { $_.kind -eq 'update_installation_failure_record' }).Count -eq 1) 'Event 20 is installation failure record'
Assert-Telemetry (@($evidence | Where-Object { $_.kind -eq 'update_installation_success_record' }).Count -eq 1) 'Event 19 is installation success record'
Assert-Telemetry ($evidence[0].timeBasis -eq 'event_recorded_time') 'No inferred update date'
Assert-Telemetry (($evidence | ConvertTo-Json -Depth 6) -notmatch 'PRIVATE UPDATE NAME') 'Raw update messages must never be serialized'
# Pure SMART fixture: no Get-PhysicalDisk or OS query is executed here.
$validStorage = ConvertTo-PcCareStorageMetrics -Counter ([pscustomobject]@{ Wear=18; Temperature=43; SerialNumber='PRIVATE-UNIT' })
Assert-Telemetry ($validStorage.wearPercent -eq 18 -and $validStorage.temperatureC -eq 43) 'Valid bounded device readings'
Assert-Telemetry (($validStorage | ConvertTo-Json -Compress) -notmatch 'PRIVATE') 'Serial identifier never reflected'
$missingStorage = ConvertTo-PcCareStorageMetrics -Counter $null
Assert-Telemetry ($null -eq $missingStorage.wearPercent -and $null -eq $missingStorage.temperatureC) 'Missing sensor does not imply healthy'
$zeroStorage = ConvertTo-PcCareStorageMetrics -Counter ([pscustomobject]@{ Wear=0; Temperature=0 })
Assert-Telemetry ($null -eq $zeroStorage.wearPercent -and $null -eq $zeroStorage.temperatureC) 'Ambiguous zero means unknown'
$sentinelStorage = ConvertTo-PcCareStorageMetrics -Counter ([pscustomobject]@{ Wear=255; Temperature=65535 })
Assert-Telemetry ($null -eq $sentinelStorage.wearPercent -and $null -eq $sentinelStorage.temperatureC) 'Reject sentinel and out-of-range readings'
$negativeStorage = ConvertTo-PcCareStorageMetrics -Counter ([pscustomobject]@{ Wear=-1; Temperature=-120 })
Assert-Telemetry ($null -eq $negativeStorage.wearPercent -and $null -eq $negativeStorage.temperatureC) 'Reject invalid negative readings'
$fractionalStorage = ConvertTo-PcCareStorageMetrics -Counter ([pscustomobject]@{ Wear=12.5; Temperature=36.5 })
Assert-Telemetry ($null -eq $fractionalStorage.wearPercent -and $null -eq $fractionalStorage.temperatureC) 'Reject uncertain decimal rounding'
$independentStorage = ConvertTo-PcCareStorageMetrics -Counter ([pscustomobject]@{ Wear='PRIVATE-SERIAL'; Temperature=37 })
Assert-Telemetry ($null -eq $independentStorage.wearPercent -and $independentStorage.temperatureC -eq 37) 'Invalid wear must not hide valid temperature'
Assert-Telemetry (($independentStorage | ConvertTo-Json -Compress) -notmatch 'PRIVATE') 'Reject raw private readings'
$validWear = ConvertTo-PcCareStorageMetrics -Counter ([pscustomobject]@{ Wear=100; Temperature='not-a-number' })
Assert-Telemetry ($validWear.wearPercent -eq 100 -and $null -eq $validWear.temperatureC) 'Invalid temperature must not hide valid wear'
Write-Host 'TELEMETRY FIXTURE PASS: absent/denied/invalid battery and scoped Windows update evidence.' -ForegroundColor Green
