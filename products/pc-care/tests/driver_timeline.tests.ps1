# Synthetic tests only: no OS queries, installation or repair.
$ErrorActionPreference = 'Stop'
. (Join-Path (Split-Path -Parent $PSScriptRoot) 'tools/pnp_analysis.ps1')
. (Join-Path (Split-Path -Parent $PSScriptRoot) 'tools/recorded_timeline.ps1')
function Assert-PcCareDriverTimeline([bool]$Yes, [string]$Why) {
    if (-not $Yes) { throw ('DRIVER/TIMELINE FIXTURE FAIL: ' + $Why) }
}
$denied = ConvertTo-PcCarePnPSummary -Devices @() -QueryStatus 'unavailable'
Assert-PcCareDriverTimeline ($denied.status -eq 'unavailable' -and $null -eq $denied.observedCount) 'Denied PnP query must not equal zero errors'
$absent = ConvertTo-PcCarePnPSummary -Devices @() -QueryStatus 'no matching devices'
Assert-PcCareDriverTimeline ($absent.status -eq 'no matching devices' -and $absent.observedCount -eq 0) 'No matching reported devices'
$devices = @(
    [pscustomobject]@{ ConfigManagerErrorCode=0; PNPClass='Net'; Name='PRIVATE-NAME' },
    [pscustomobject]@{ ConfigManagerErrorCode=28; PNPClass='Display'; DeviceID='PRIVATE-ID'; Name='PRIVATE-NAME' },
    [pscustomobject]@{ ConfigManagerErrorCode=22; PNPClass='Unknown PRIVATE-NAME'; SerialNumber='PRIVATE-SERIAL' },
    [pscustomobject]@{ ConfigManagerErrorCode=999; PNPClass='USB'; Name='PRIVATE-NAME' }
)
$pnp = ConvertTo-PcCarePnPSummary -Devices $devices -QueryStatus 'collected'
Assert-PcCareDriverTimeline ($pnp.observedCount -eq 2 -and $pnp.samples.Count -eq 2) 'Only valid nonzero codes counted'
Assert-PcCareDriverTimeline ($pnp.samples[0].interpretation -eq 'driver_not_installed_record') 'Code 28 meaning'
Assert-PcCareDriverTimeline ($pnp.samples[1].interpretation -eq 'device_disabled') 'Code 22 can be intentionally disabled'
Assert-PcCareDriverTimeline ($pnp.samples[1].category -eq 'other') 'No free-text class or identifiers'
Assert-PcCareDriverTimeline (($pnp | ConvertTo-Json -Depth 6) -notmatch 'PRIVATE-') 'Device identifiers must not be serialized'
$cap = ConvertTo-PcCarePnPSummary -Devices $devices -QueryStatus 'collected' -MaxSamples 1
Assert-PcCareDriverTimeline ($cap.status -eq 'truncated' -and $cap.samples.Count -eq 1) 'Bounded PnP samples'
$evidence = @(
    [pscustomobject]@{ kind='bugcheck_record'; recordedUtc='2026-10-30T01:01:00.0000000+00:00'; Message='PRIVATE-LOG' },
    [pscustomobject]@{ kind='shutdown_signal'; recordedUtc='2026-10-30T10:04:00+09:00'; id='PRIVATE-LOG' },
    [pscustomobject]@{ kind='storage_signal'; recordedUtc='2026-10-30T01:40:00.0000000Z' },
    [pscustomobject]@{ kind='not_from_normalizer'; recordedUtc='2026-10-30T01:05:00.0000000Z' }
)
$updates = @([pscustomobject]@{ kind='update_installation_failure_record'; recordedUtc='2026-10-30T01:03:00.0000000Z'; Message='PRIVATE-LOG' })
$timeline = Get-PcCareRecordedTimeline -SystemEvidence $evidence -UpdateEvidence $updates -WindowMinutes 15
Assert-PcCareDriverTimeline ($timeline.acceptedCount -eq 4 -and $timeline.windows.Count -eq 2) 'Only allowed kinds and separate distant window'
Assert-PcCareDriverTimeline ($timeline.windows[0].evidenceCount -eq 3) 'Same instant zone offsets should group by UTC'
Assert-PcCareDriverTimeline ($timeline.windows[0].interpretation -eq 'recorded_timestamp_proximity_only') 'Never infer cause'
Assert-PcCareDriverTimeline (@($timeline.windows | Where-Object { $_.causeConfirmed }).Count -eq 0) 'No causal conclusion'
Assert-PcCareDriverTimeline (($timeline | ConvertTo-Json -Depth 8) -notmatch 'PRIVATE-') 'No raw event messages or identifiers'
$bounded = Get-PcCareRecordedTimeline -SystemEvidence $evidence -UpdateEvidence $updates -MaxEntries 2
Assert-PcCareDriverTimeline ($bounded.status -eq 'truncated' -and $bounded.returnedCount -eq 2) 'Enforced timeline limit'
$invalidTime = Get-PcCareRecordedTimeline -SystemEvidence @([pscustomobject]@{ kind='shutdown_signal'; recordedUtc='not-a-date' })
Assert-PcCareDriverTimeline ($invalidTime.acceptedCount -eq 0) 'Reject invalid timestamp'
Write-Host 'DRIVER/TIMELINE FIXTURE PASS: scoped PnP codes, privacy, UTC grouping, bounded and noncausal history.' -ForegroundColor Green
