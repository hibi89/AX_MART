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
$fractionalBattery = ConvertTo-PcCareBatterySnapshot -Batteries @([pscustomobject]@{
    EstimatedChargeRemaining=42.5; BatteryStatus=2.5; DesignCapacity=60000.5; FullChargeCapacity=$true
}) -QueryStatus 'collected'
Assert-Telemetry ($null -eq $fractionalBattery.samples[0].chargeRemainingPercent -and
    $null -eq $fractionalBattery.samples[0].batteryStatusCode -and
    $null -eq $fractionalBattery.samples[0].designCapacityMWh -and
    $null -eq $fractionalBattery.samples[0].fullChargeCapacityMWh) 'Fractional and boolean battery values stay unknown'
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
Assert-Telemetry (@($evidence | Where-Object { $_.provider -cne 'Microsoft-Windows-WindowsUpdateClient' }).Count -eq 0) 'Only canonical update providers can be normalized'
Assert-Telemetry ($evidence.Count -eq 2) 'Only approved provider/IDs with record dedup'
Assert-Telemetry (@($evidence | Where-Object { $_.kind -eq 'update_installation_failure_record' }).Count -eq 1) 'Event 20 is installation failure record'
Assert-Telemetry (@($evidence | Where-Object { $_.kind -eq 'update_installation_success_record' }).Count -eq 1) 'Event 19 is installation success record'
Assert-Telemetry ($evidence[0].timeBasis -eq 'event_recorded_time') 'No inferred update date'
Assert-Telemetry (($evidence | ConvertTo-Json -Depth 6) -notmatch 'PRIVATE UPDATE NAME') 'Raw update messages must never be serialized'
$badUpdateIds = @(
    [pscustomobject]@{ Id=20.5; ProviderName='Microsoft-Windows-WindowsUpdateClient'; TimeCreated=$time; RecordId=121 },
    [pscustomobject]@{ Id=$true; ProviderName='Microsoft-Windows-WindowsUpdateClient'; TimeCreated=$time; RecordId=122 },
    [pscustomobject]@{ Id='20.5'; ProviderName='Microsoft-Windows-WindowsUpdateClient'; TimeCreated=$time; RecordId=123 }
)
Assert-Telemetry (@(ConvertTo-PcCareUpdateEvidence -Events $badUpdateIds).Count -eq 0) 'Fractional and boolean event IDs cannot create update evidence'

# Synthetic disk names must never appear in private reports.
$fakeDisk = [pscustomobject]@{
    FriendlyName='PRIVATE-OWNER-SERIAL-1234'
    SerialNumber='PRIVATE-SERIAL'
    UniqueId='PRIVATE-UNIQUE'
    HealthStatus='Warning'
    OperationalStatus=@('OK','PRIVATE-COMPUTER-ALIAS')
}
$privateDisk = ConvertTo-PcCarePrivateDiskObservation -Disk $fakeDisk -Ordinal 1
Assert-Telemetry ($privateDisk.model -eq '물리 저장장치 1' -and $privateDisk.status -eq 'Warning') 'Private disk observation retains health without device identity'
Assert-Telemetry ($privateDisk.operationalStatus -eq 'OK') 'Only recognized disk operational states may be recorded'
Assert-Telemetry (($privateDisk | ConvertTo-Json -Depth 5) -notmatch 'PRIVATE|SERIAL|UNIQUE|OWNER') 'Raw device identity must never appear in report observation'
$privateDisk2 = ConvertTo-PcCarePrivateDiskObservation -Disk ([pscustomobject]@{
    FriendlyName='SECOND-PRIVATE-NAME'; HealthStatus='Unhealthy'; OperationalStatus=@('Degraded','Lost Communication')
}) -Ordinal 2
Assert-Telemetry ($privateDisk2.model -eq '물리 저장장치 2' -and $privateDisk2.status -eq 'Unhealthy') 'Second disk remains distinct without raw names'
Assert-Telemetry ($privateDisk2.operationalStatus -eq 'Degraded,Lost Communication') 'Legitimate operational warnings remain visible'
$unknownDisk = ConvertTo-PcCarePrivateDiskObservation -Disk ([pscustomobject]@{
    FriendlyName='PRIVATE-NAME'; HealthStatus='PRIVATE-HEALTH'; OperationalStatus='PRIVATE-OP'
}) -Ordinal 3
Assert-Telemetry ($unknownDisk.status -eq 'Unknown' -and $unknownDisk.operationalStatus -eq 'unavailable') 'Untrusted storage strings cannot masquerade as health'
Assert-Telemetry (($unknownDisk | ConvertTo-Json -Depth 5) -notmatch 'PRIVATE') 'Untrusted storage text does not escape to JSON'
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
$booleanStorage = ConvertTo-PcCareStorageMetrics -Counter ([pscustomobject]@{ Wear=$true; Temperature=$true })
Assert-Telemetry ($null -eq $booleanStorage.wearPercent -and $null -eq $booleanStorage.temperatureC) 'Boolean sensor values stay unknown'
$independentStorage = ConvertTo-PcCareStorageMetrics -Counter ([pscustomobject]@{ Wear='PRIVATE-SERIAL'; Temperature=37 })
Assert-Telemetry ($null -eq $independentStorage.wearPercent -and $independentStorage.temperatureC -eq 37) 'Invalid wear must not hide valid temperature'
Assert-Telemetry (($independentStorage | ConvertTo-Json -Compress) -notmatch 'PRIVATE') 'Reject raw private readings'
$validWear = ConvertTo-PcCareStorageMetrics -Counter ([pscustomobject]@{ Wear=100; Temperature='not-a-number' })
Assert-Telemetry ($validWear.wearPercent -eq 100 -and $null -eq $validWear.temperatureC) 'Invalid temperature must not hide valid wear'
# Logical disk fixtures are pure. A single malformed CIM sample cannot abort the scan.
$validVolume = ConvertTo-PcCareVolumeSample -Volume ([pscustomobject]@{ DeviceID='C:'; Size=(100 * 1GB); FreeSpace=(4 * 1GB); VolumeName='PRIVATE-NAME' })
Assert-Telemetry ($validVolume.drive -eq 'C:' -and $validVolume.remainingGB -eq 4 -and $validVolume.sizeGB -eq 100 -and $validVolume.freePercent -eq 4) 'Valid disk sample and percentage'
Assert-Telemetry (($validVolume | ConvertTo-Json -Compress) -notmatch 'PRIVATE') 'Do not serialize volume labels'
$lowerVolume = ConvertTo-PcCareVolumeSample -Volume ([pscustomobject]@{ DeviceID='c:'; Size=(10 * 1GB); FreeSpace=(3 * 1GB) })
Assert-Telemetry ($lowerVolume.drive -eq 'C:' -and $lowerVolume.freePercent -eq 30) 'Lowercase drive letter is normalized'
$fullVolume = ConvertTo-PcCareVolumeSample -Volume ([pscustomobject]@{ DeviceID='D:'; Size=(20 * 1GB); FreeSpace=0 })
Assert-Telemetry ($fullVolume.drive -eq 'D:' -and $fullVolume.remainingGB -eq 0 -and $fullVolume.freePercent -eq 0) 'A full disk must not be rejected as an invalid sensor'
$invalidVolumes = @(
    [pscustomobject]@{ DeviceID='C:\\Private'; Size=(100 * 1GB); FreeSpace=(5 * 1GB) },
    [pscustomobject]@{ DeviceID='PRIVATE'; Size=(100 * 1GB); FreeSpace=(5 * 1GB) },
    [pscustomobject]@{ DeviceID='C:'; Size=0; FreeSpace=0 },
    [pscustomobject]@{ DeviceID='C:'; Size='NaN'; FreeSpace=1 },
    [pscustomobject]@{ DeviceID='C:'; Size='Infinity'; FreeSpace=1 },
    [pscustomobject]@{ DeviceID='C:'; Size=(100 * 1GB) + 0.5; FreeSpace=(5 * 1GB) },
    [pscustomobject]@{ DeviceID='C:'; Size=(100 * 1GB); FreeSpace=(5 * 1GB) + 0.5 },
    [pscustomobject]@{ DeviceID='C:'; Size=$true; FreeSpace=1 },
    [pscustomobject]@{ DeviceID='C:'; Size=(10 * 1GB); FreeSpace=$true },
    [pscustomobject]@{ DeviceID='C:'; Size='PRIVATE-VALUE'; FreeSpace=1 },
    [pscustomobject]@{ DeviceID='C:'; Size=(10 * 1GB); FreeSpace=-1 },
    [pscustomobject]@{ DeviceID='C:'; Size=(10 * 1GB); FreeSpace=(11 * 1GB) },
    [pscustomobject]@{ DeviceID='C:'; Size=(10 * 1GB); FreeSpace='NaN' },
    [pscustomobject]@{ DeviceID='C:'; Size=$null; FreeSpace=1 }
)
foreach ($invalidVolume in $invalidVolumes) {
    $badVolume = ConvertTo-PcCareVolumeSample -Volume $invalidVolume
    Assert-Telemetry ($null -eq $badVolume) 'Invalid logical disk data must return unknown, not throw or leak raw fields'
}
Assert-Telemetry ($null -eq (ConvertTo-PcCareVolumeSample -Volume $null)) 'Missing volume remains unknown'
# Regression: rounded display (5.0 GB / 5.0%) cannot conceal raw-byte critical space.
$roundedCritical = ConvertTo-PcCareVolumeSample -Volume ([pscustomobject]@{
    DeviceID='F:'; Size=(100 * 1GB); FreeSpace=([math]::Round(4.96 * 1GB))
})
Assert-Telemetry ($roundedCritical.remainingGB -eq 5.0 -and $roundedCritical.freePercent -eq 5.0) 'Critical raw reading has threshold-rounded display'
Assert-Telemetry ((Get-PcCareVolumeRisk -Sample $roundedCritical) -eq 'high') 'Critical warning must use raw bytes, not rounded display'
$roundedMedium = ConvertTo-PcCareVolumeSample -Volume ([pscustomobject]@{
    DeviceID='G:'; Size=(50 * 1GB); FreeSpace=([math]::Round(7.49 * 1GB))
})
Assert-Telemetry ($roundedMedium.freePercent -eq 15.0) 'Medium raw reading has threshold-rounded percent'
Assert-Telemetry ((Get-PcCareVolumeRisk -Sample $roundedMedium) -eq 'medium') 'Medium warning must use raw percentage'
$preciselyFive = ConvertTo-PcCareVolumeSample -Volume ([pscustomobject]@{
    DeviceID='H:'; Size=(100 * 1GB); FreeSpace=(5 * 1GB)
})
Assert-Telemetry ((Get-PcCareVolumeRisk -Sample $preciselyFive) -eq 'medium') 'Exact 5 percent boundary is medium, not critical'
$healthyFree = ConvertTo-PcCareVolumeSample -Volume ([pscustomobject]@{
    DeviceID='I:'; Size=(100 * 1GB); FreeSpace=(15 * 1GB)
})
Assert-Telemetry ((Get-PcCareVolumeRisk -Sample $healthyFree) -eq 'none') 'Exact 15 percent boundary must not be a warning'
$smallDrive = ConvertTo-PcCareVolumeSample -Volume ([pscustomobject]@{
    DeviceID='J:'; Size=([math]::Round(19.9 * 1GB)); FreeSpace=([math]::Round(0.1 * 1GB))
})
Assert-Telemetry ((Get-PcCareVolumeRisk -Sample $smallDrive) -eq 'none') 'Small drives stay outside the established >=20GiB policy'
Assert-Telemetry ((Get-PcCareVolumeRisk -Sample $null) -eq 'unavailable') 'Missing volume must never be judged healthy'
Assert-Telemetry ((Get-PcCareVolumeRisk -Sample ([pscustomobject]@{
    capacityBytes=[double]::NaN; remainingBytes=1
})) -eq 'unavailable') 'Invalid raw bytes do not produce a health verdict'
Assert-Telemetry ($roundedCritical.remainingBytes -gt 0 -and $roundedCritical.capacityBytes -gt 0) 'Raw byte fields survive normalization'
Assert-Telemetry (($roundedCritical | ConvertTo-Json -Compress) -notmatch 'PRIVATE') 'Raw byte evaluation does not emit device names'

$followupVolume = ConvertTo-PcCareVolumeSample -Volume ([pscustomobject]@{ DeviceID='E:'; Size=(40 * 1GB); FreeSpace=(24 * 1GB) })
Assert-Telemetry ($followupVolume.freePercent -eq 60) 'Good disk after malformed disk still evaluates'

Write-Host 'TELEMETRY FIXTURE PASS: absent/denied/invalid battery and scoped Windows update evidence.' -ForegroundColor Green
