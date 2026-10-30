# Synthetic tests only: no OS queries, installation or repair.
$ErrorActionPreference = 'Stop'
. (Join-Path (Split-Path -Parent $PSScriptRoot) 'tools/pnp_analysis.ps1')
. (Join-Path (Split-Path -Parent $PSScriptRoot) 'tools/recorded_timeline.ps1')
. (Join-Path (Split-Path -Parent $PSScriptRoot) 'tools/incident_analysis.ps1')
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
# Query result status must beat stale raw samples, even if the CIM array survives.
$noMatchStale = ConvertTo-PcCarePnPSummary -Devices $devices -QueryStatus 'no matching devices'
Assert-PcCareDriverTimeline ($noMatchStale.status -eq 'no matching devices' -and $noMatchStale.observedCount -eq 0) 'Stale PnP records cannot override no-match status'
Assert-PcCareDriverTimeline ($noMatchStale.samples.Count -eq 0) 'No-match PnP samples remain empty despite stale input'
$unavailableStale = ConvertTo-PcCarePnPSummary -Devices $devices -QueryStatus 'unavailable'
Assert-PcCareDriverTimeline ($unavailableStale.status -eq 'unavailable' -and $null -eq $unavailableStale.observedCount) 'Failed PnP lookup cannot invent observed code count'
Assert-PcCareDriverTimeline ($unavailableStale.samples.Count -eq 0) 'Unavailable PnP input never leaks code samples'
$pnp = ConvertTo-PcCarePnPSummary -Devices $devices -QueryStatus 'collected'
Assert-PcCareDriverTimeline ($pnp.observedCount -eq 2 -and $pnp.samples.Count -eq 2) 'Only valid nonzero codes counted'
Assert-PcCareDriverTimeline ($pnp.samples[0].interpretation -eq 'driver_not_installed_record') 'Code 28 meaning'
Assert-PcCareDriverTimeline ($pnp.samples[1].interpretation -eq 'device_disabled') 'Code 22 can be intentionally disabled'
Assert-PcCareDriverTimeline ($pnp.samples[1].category -eq 'other') 'No free-text class or identifiers'
Assert-PcCareDriverTimeline (($pnp | ConvertTo-Json -Depth 6) -notmatch 'PRIVATE-') 'Device identifiers must not be serialized'
$cap = ConvertTo-PcCarePnPSummary -Devices $devices -QueryStatus 'collected' -MaxSamples 1
Assert-PcCareDriverTimeline ($cap.status -eq 'truncated' -and $cap.samples.Count -eq 1) 'Bounded PnP samples'
$evidence = @(
    [pscustomobject]@{ kind='bugcheck_record'; timeBasis='event_recorded_time'; eventId=1001; recordedUtc='2026-10-30T01:01:00.0000000+00:00'; Message='PRIVATE-LOG' },
    [pscustomobject]@{ kind='shutdown_signal'; timeBasis='event_recorded_time'; eventId=41; recordedUtc='2026-10-30T10:04:00+09:00'; id='PRIVATE-LOG' },
    [pscustomobject]@{ kind='storage_signal'; timeBasis='event_recorded_time'; eventId=7; recordedUtc='2026-10-30T01:40:00.0000000Z' },
    [pscustomobject]@{ kind='not_from_normalizer'; timeBasis='event_recorded_time'; recordedUtc='2026-10-30T01:05:00.0000000Z' }
)
$updates = @([pscustomobject]@{ kind='update_installation_failure_record'; timeBasis='event_recorded_time'; eventId=20; recordedUtc='2026-10-30T01:03:00.0000000Z'; Message='PRIVATE-LOG' })
$timeline = Get-PcCareRecordedTimeline -SystemEvidence $evidence -UpdateEvidence $updates -WindowMinutes 15 -SystemCollectionStatus 'collected' -UpdateCollectionStatus 'collected'
Assert-PcCareDriverTimeline ($timeline.acceptedCount -eq 4 -and $timeline.windows.Count -eq 2) 'Only allowed kinds and separate distant window'
Assert-PcCareDriverTimeline ($timeline.windows[0].evidenceCount -eq 3) 'Same instant zone offsets should group by UTC'
Assert-PcCareDriverTimeline ($timeline.windows[0].interpretation -eq 'recorded_timestamp_proximity_only') 'Never infer cause'
Assert-PcCareDriverTimeline ($timeline.status -eq 'incomplete' -and -not $timeline.coverageComplete -and $timeline.rejectedCount -eq 1) 'Rejected normalized inputs must never claim complete collection'
Assert-PcCareDriverTimeline (@($timeline.windows[0].coObserved | Where-Object { $_ -eq 'bugcheck_update_proximity' }).Count -eq 1) 'BugCheck and update failure share a recording-time window'
Assert-PcCareDriverTimeline (@($timeline.windows[0].coObserved | Where-Object { $_ -eq 'bugcheck_storage_proximity' }).Count -eq 0) 'Distant storage events cannot become near-term correlations'
Assert-PcCareDriverTimeline (@($timeline.windows[1].coObserved).Count -eq 0) 'Isolated storage record carries no inferred pair'
Assert-PcCareDriverTimeline (@($timeline.windows | Where-Object { $_.causeConfirmed }).Count -eq 0) 'No causal conclusion'
Assert-PcCareDriverTimeline (($timeline | ConvertTo-Json -Depth 8) -notmatch 'PRIVATE-') 'No raw event messages or identifiers'
# Valid normalizer output still gives a complete and reproducible time window.
$cleanEvidence = @($evidence | Where-Object { $_.kind -ne 'not_from_normalizer' })
$cleanTimeline = Get-PcCareRecordedTimeline -SystemEvidence $cleanEvidence -UpdateEvidence $updates -SystemCollectionStatus 'collected' -UpdateCollectionStatus 'collected'
Assert-PcCareDriverTimeline ($cleanTimeline.status -eq 'collected' -and $cleanTimeline.coverageComplete -and $cleanTimeline.rejectedCount -eq 0) 'All accepted timestamped records preserve complete status'
Assert-PcCareDriverTimeline ($cleanTimeline.acceptedCount -eq 4) 'Complete timeline retains observed normalizer records'
$unmarked = Get-PcCareRecordedTimeline -SystemEvidence @([pscustomobject]@{kind='shutdown_signal'; eventId=41; recordedUtc='2026-10-30T01:00:00Z'}) -SystemCollectionStatus 'collected' -UpdateCollectionStatus 'no matching events'
Assert-PcCareDriverTimeline ($unmarked.acceptedCount -eq 0 -and $unmarked.rejectedCount -eq 1) 'Missing time basis cannot masquerade as normalized Windows log'
Assert-PcCareDriverTimeline ($unmarked.status -eq 'incomplete' -and -not $unmarked.coverageComplete) 'Unverified input is not a genuine empty log'
$forgedTimeBasis = Get-PcCareRecordedTimeline -SystemEvidence @([pscustomobject]@{kind='shutdown_signal'; eventId=41; timeBasis='estimated_crash_time'; recordedUtc='2026-10-30T01:00:00Z'}) -SystemCollectionStatus 'collected' -UpdateCollectionStatus 'no matching events'
Assert-PcCareDriverTimeline ($forgedTimeBasis.rejectedCount -eq 1 -and $forgedTimeBasis.status -eq 'incomplete') 'Estimated incident time cannot become verified recorded time'
$bounded = Get-PcCareRecordedTimeline -SystemEvidence $evidence -UpdateEvidence $updates -MaxEntries 2 -SystemCollectionStatus 'collected' -UpdateCollectionStatus 'collected'
Assert-PcCareDriverTimeline ($bounded.status -eq 'truncated' -and $bounded.returnedCount -eq 2) 'Enforced timeline limit'
$invalidTime = Get-PcCareRecordedTimeline -SystemEvidence @([pscustomobject]@{ kind='shutdown_signal'; timeBasis='event_recorded_time'; eventId=41; recordedUtc='not-a-date' }) -SystemCollectionStatus 'collected'
Assert-PcCareDriverTimeline ($invalidTime.acceptedCount -eq 0) 'Reject invalid timestamp'
# The same arrays may survive a failed/no-match event query: status wins.
$staleTimeline = Get-PcCareRecordedTimeline -SystemEvidence $evidence -UpdateEvidence $updates -SystemCollectionStatus 'unavailable' -UpdateCollectionStatus 'no matching events'
Assert-PcCareDriverTimeline ($staleTimeline.acceptedCount -eq 0 -and $staleTimeline.windows.Count -eq 0) 'Failed/no-match collectors cannot generate timeline windows'
Assert-PcCareDriverTimeline ($staleTimeline.sourceCollection.system -eq 'unavailable') 'Collection provenance exposed without raw identifiers'
Assert-PcCareDriverTimeline ($staleTimeline.status -eq 'unavailable' -and -not $staleTimeline.coverageComplete) 'Failed source never gets collected status'
$partiallyDenied = Get-PcCareRecordedTimeline -SystemEvidence $evidence -UpdateEvidence $updates -SystemCollectionStatus 'unavailable' -UpdateCollectionStatus 'collected'
Assert-PcCareDriverTimeline ($partiallyDenied.status -eq 'incomplete' -and $partiallyDenied.acceptedCount -eq 1) 'Mixed success and query failure marked incomplete'
$trulyEmpty = Get-PcCareRecordedTimeline -SystemEvidence @() -UpdateEvidence @() -SystemCollectionStatus 'no matching events' -UpdateCollectionStatus 'no matching events'
Assert-PcCareDriverTimeline ($trulyEmpty.status -eq 'no matching events' -and $trulyEmpty.coverageComplete) 'Successful empty queries distinguished from unavailable'
$nearStorage = @(
    [pscustomobject]@{ kind='bugcheck_record'; timeBasis='event_recorded_time'; eventId=1001; recordedUtc='2026-10-30T01:01:00Z' },
    [pscustomobject]@{ kind='storage_signal'; timeBasis='event_recorded_time'; eventId=7; recordedUtc='2026-10-30T01:04:00Z' },
    [pscustomobject]@{ kind='shutdown_signal'; timeBasis='event_recorded_time'; eventId=6008; recordedUtc='2026-10-30T01:06:00Z' }
)
$near = Get-PcCareRecordedTimeline -SystemEvidence $nearStorage -UpdateEvidence $updates -SystemCollectionStatus 'collected' -UpdateCollectionStatus 'collected'
Assert-PcCareDriverTimeline (@($near.windows[0].coObserved).Count -eq 3) 'Three bounded proximity combinations are emitted'
Assert-PcCareDriverTimeline ($near.windows[0].causeConfirmed -eq $false) 'Near-recording co-observation never confirms causation'
Assert-PcCareDriverTimeline (($near | ConvertTo-Json -Depth 8) -notmatch 'PRIVATE-') 'No raw identity in proximity output'
$partialTimeline = Get-PcCareRecordedTimeline -SystemEvidence $evidence -UpdateEvidence $updates -SystemCollectionStatus 'truncated' -UpdateCollectionStatus 'collected'
Assert-PcCareDriverTimeline ($partialTimeline.status -eq 'truncated' -and $partialTimeline.acceptedCount -eq 4) 'Collector cap preserved even below timeline display cap'
$crossOrigin = Get-PcCareRecordedTimeline -SystemEvidence $updates -UpdateEvidence $evidence -SystemCollectionStatus 'collected' -UpdateCollectionStatus 'collected'
Assert-PcCareDriverTimeline ($crossOrigin.acceptedCount -eq 0) 'Update and System evidence cannot cross collector boundaries'
$wrongId = Get-PcCareRecordedTimeline -SystemEvidence @([pscustomobject]@{ kind='bugcheck_record'; timeBasis='event_recorded_time'; eventId=41; recordedUtc='2026-10-30T01:00:00Z' }) -SystemCollectionStatus 'collected'
Assert-PcCareDriverTimeline ($wrongId.acceptedCount -eq 0) 'BugCheck kind requires event 1001'
$unknownId = Get-PcCareRecordedTimeline -SystemEvidence @([pscustomobject]@{ kind='storage_signal'; timeBasis='event_recorded_time'; eventId=999; recordedUtc='2026-10-30T01:00:00Z' }) -SystemCollectionStatus 'collected'
Assert-PcCareDriverTimeline ($unknownId.acceptedCount -eq 0) 'Only allowlisted storage IDs are accepted'
$noOffset = Get-PcCareRecordedTimeline -SystemEvidence @([pscustomobject]@{ kind='shutdown_signal'; timeBasis='event_recorded_time'; eventId=41; recordedUtc='2026-10-30T01:00:00' }) -SystemCollectionStatus 'collected'
Assert-PcCareDriverTimeline ($noOffset.acceptedCount -eq 0) 'Ambiguous local timezone is not an evidence time'
$fakeDate = Get-PcCareRecordedTimeline -SystemEvidence @([pscustomobject]@{ kind='shutdown_signal'; timeBasis='event_recorded_time'; eventId=41; recordedUtc='2026-02-30T01:00:00Z' }) -SystemCollectionStatus 'collected'
Assert-PcCareDriverTimeline ($fakeDate.acceptedCount -eq 0) 'Invalid calendar day never becomes an event'
$validOffset = Get-PcCareRecordedTimeline -SystemEvidence @([pscustomobject]@{ kind='shutdown_signal'; timeBasis='event_recorded_time'; eventId=6008; recordedUtc='2026-10-30T10:00:00+09:00' }) -SystemCollectionStatus 'collected'
Assert-PcCareDriverTimeline ($validOffset.acceptedCount -eq 1 -and $validOffset.windows.Count -eq 1) 'Explicit offsets accepted and normalized'
$pnpFinding = Get-PcCareIncidentAssessment -EventEvidence @() -DiskObservations @([pscustomobject]@{ status='Healthy' }) -EventCollectionStatus 'collected' -UpdateCollectionStatus 'collected' -PnPSummary $pnp
Assert-PcCareDriverTimeline (@($pnpFinding.findings | Where-Object { $_.code -eq 'PNP_CONFIG_REVIEW' }).Count -eq 1) 'PnP error gets conservative review'
Assert-PcCareDriverTimeline ($pnpFinding.observedCounts.pnpIssueSamples -eq 1) 'Disabled code 22 is excluded from active issue count'
Assert-PcCareDriverTimeline (@($pnpFinding.findings | Where-Object { $_.causeConfirmed }).Count -eq 0) 'No root cause asserted'
$disabledOnly = ConvertTo-PcCarePnPSummary -Devices @([pscustomobject]@{ ConfigManagerErrorCode=22 }) -QueryStatus 'collected'
$disabledFinding = Get-PcCareIncidentAssessment -EventEvidence @() -DiskObservations @([pscustomobject]@{ status='Healthy' }) -EventCollectionStatus 'collected' -UpdateCollectionStatus 'collected' -PnPSummary $disabledOnly
Assert-PcCareDriverTimeline (@($disabledFinding.findings | Where-Object { $_.code -eq 'PNP_CONFIG_REVIEW' }).Count -eq 0) 'Deliberate disabling cannot be called a driver failure'
Write-Host 'DRIVER/TIMELINE FIXTURE PASS: scoped PnP codes, privacy, UTC grouping, bounded and noncausal history.' -ForegroundColor Green
