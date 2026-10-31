# Synthetic interpretation regression: no actual PC inspection or system repair.
$ErrorActionPreference = 'Stop'
. (Join-Path (Split-Path -Parent $PSScriptRoot) 'tools/incident_analysis.ps1')
function Assert-PcCareIncident([bool]$Ok, [string]$Message) {
    if (-not $Ok) { throw ('INCIDENT FIXTURE FAIL: ' + $Message) }
}
$empty = Get-PcCareIncidentAssessment -EventEvidence @() -DiskObservations @() -EventCollectionStatus 'unavailable'
Assert-PcCareIncident ($empty.status -eq 'incomplete') 'Unavailable event and disk state'
Assert-PcCareIncident ($empty.findings.Count -eq 0) 'Unavailable data is not a healthy finding'
Assert-PcCareIncident (-not $empty.causeConfirmed) 'No confirmed causal claim'
$healthy = @([pscustomobject]@{ status='Healthy' })
$shutdown = @([pscustomobject]@{ kind='shutdown_signal'; eventId=41; provider='Microsoft-Windows-Kernel-Power'; timeBasis='event_recorded_time'; recordedUtc='2026-10-30T01:00:00Z' })
$shutdownOnly = Get-PcCareIncidentAssessment -EventEvidence $shutdown -DiskObservations $healthy -EventCollectionStatus 'collected'
Assert-PcCareIncident ($shutdownOnly.findings.Count -eq 1) '41 should not become a BugCheck'
Assert-PcCareIncident ($shutdownOnly.findings[0].code -eq 'SHUTDOWN_REVIEW') '41 is only shutdown evidence'
$crash = @([pscustomobject]@{ kind='bugcheck_record'; eventId=1001; provider='BugCheck'; timeBasis='event_recorded_time'; recordedUtc='2026-10-30T01:02:00Z' })
$bugOnly = Get-PcCareIncidentAssessment -EventEvidence $crash -DiskObservations $healthy -EventCollectionStatus 'collected'
Assert-PcCareIncident ($bugOnly.findings.Count -eq 1) 'Bugcheck should produce one interpretation'
Assert-PcCareIncident ($bugOnly.findings[0].code -eq 'BUGCHECK_REVIEW') 'Bugcheck review'
$badDisk = @([pscustomobject]@{ status='Warning'; model='<not-an-id>' })
$combo = Get-PcCareIncidentAssessment -EventEvidence $crash -DiskObservations $badDisk -DiskCollectionStatus 'truncated' -EventCollectionStatus 'truncated'
Assert-PcCareIncident ($combo.status -eq 'incomplete') 'Truncated event window'
Assert-PcCareIncident ($combo.findings.Count -eq 2) 'Independent storage and crash findings'
Assert-PcCareIncident ($combo.findings[0].code -eq 'STORAGE_FIRST') 'Storage data protection prioritized'
Assert-PcCareIncident (@($combo.caveats | Where-Object { $_ -match '인과관계' }).Count -eq 1) 'Co-observed evidence is not proof of causation'
Assert-PcCareIncident (@($combo.findings | Where-Object { $_.causeConfirmed }).Count -eq 0) 'No finding asserts causation'
$unknown = Get-PcCareIncidentAssessment -EventEvidence @() -DiskObservations @([pscustomobject]@{ status='Unknown' }) -EventCollectionStatus 'no matching events'
Assert-PcCareIncident ($unknown.status -eq 'incomplete') 'Unknown physical disk state cannot produce complete result'
$serialized = $combo | ConvertTo-Json -Depth 8
Assert-PcCareIncident ($serialized -notmatch '<not-an-id>') 'Do not copy source device names into interpretations'
$failedUpdate = @([pscustomobject]@{ kind='update_installation_failure_record'; eventId=20; provider='Microsoft-Windows-WindowsUpdateClient'; timeBasis='event_recorded_time'; recordedUtc='2026-10-30T01:03:00Z' })
$updateOnly = Get-PcCareIncidentAssessment -EventEvidence @() -DiskObservations $healthy -EventCollectionStatus 'collected' -UpdateEvidence $failedUpdate -UpdateCollectionStatus 'collected'
Assert-PcCareIncident ($updateOnly.findings.Count -eq 1 -and $updateOnly.findings[0].code -eq 'UPDATE_FAILURE_REVIEW') 'Update failure is an independent record'
Assert-PcCareIncident ($updateOnly.observedCounts.updateFailureRecords -eq 1) 'Update failure count'
Assert-PcCareIncident (-not $updateOnly.findings[0].causeConfirmed) 'Update failure must not be assigned as root cause'
$updateWithCrash = Get-PcCareIncidentAssessment -EventEvidence $crash -DiskObservations $healthy -EventCollectionStatus 'collected' -UpdateEvidence $failedUpdate -UpdateCollectionStatus 'truncated'
Assert-PcCareIncident ($updateWithCrash.status -eq 'incomplete') 'Truncated update window is incomplete'
Assert-PcCareIncident (@($updateWithCrash.caveats | Where-Object { $_ -match '연관성은 입증되지' }).Count -eq 1) 'Coincident update and crash do not prove causality'
$updateDenied = Get-PcCareIncidentAssessment -EventEvidence @() -DiskObservations $healthy -EventCollectionStatus 'collected' -UpdateCollectionStatus 'unavailable'
Assert-PcCareIncident ($updateDenied.status -eq 'incomplete') 'Missing Windows Update logs cannot be called complete'
# Collection provenance must govern which evidence may create causal hypotheses.
$staleCrash = Get-PcCareIncidentAssessment -EventEvidence $crash -DiskObservations $healthy -DiskCollectionStatus 'collected' -EventCollectionStatus 'unavailable'
Assert-PcCareIncident ($staleCrash.observedCounts.bugcheckRecords -eq 0) 'Failed event lookup cannot report a stale BugCheck'
Assert-PcCareIncident ($staleCrash.findings.Count -eq 0) 'Failed event lookup cannot create a BugCheck finding'
$staleNoMatch = Get-PcCareIncidentAssessment -EventEvidence $shutdown -DiskObservations $healthy -DiskCollectionStatus 'collected' -EventCollectionStatus 'no matching events'
Assert-PcCareIncident ($staleNoMatch.observedCounts.shutdownSignals -eq 0) 'No matching events excludes stale shutdowns'
$staleUpdate = Get-PcCareIncidentAssessment -EventEvidence @() -DiskObservations $healthy -DiskCollectionStatus 'collected' -EventCollectionStatus 'collected' -UpdateEvidence $failedUpdate -UpdateCollectionStatus 'unavailable'
Assert-PcCareIncident ($staleUpdate.observedCounts.updateFailureRecords -eq 0) 'Unavailable Windows Update query excludes stale update events'
Assert-PcCareIncident (@($staleUpdate.findings | Where-Object { $_.code -eq 'UPDATE_FAILURE_REVIEW' }).Count -eq 0) 'No update hypothesis from unavailable collection'
$staleUpdateNoMatch = Get-PcCareIncidentAssessment -EventEvidence @() -DiskObservations $healthy -DiskCollectionStatus 'collected' -EventCollectionStatus 'collected' -UpdateEvidence $failedUpdate -UpdateCollectionStatus 'no matching events'
Assert-PcCareIncident ($staleUpdateNoMatch.observedCounts.updateFailureRecords -eq 0) 'No matching Windows Update events excludes stale records'
$unknownPnP = [pscustomobject]@{ status='unavailable'; samples=@([pscustomobject]@{ configurationCode=10 }) }
$stalePnP = Get-PcCareIncidentAssessment -EventEvidence @() -DiskObservations $healthy -DiskCollectionStatus 'collected' -EventCollectionStatus 'collected' -PnPSummary $unknownPnP
Assert-PcCareIncident ($stalePnP.observedCounts.pnpIssueSamples -eq 0) 'Unavailable PnP query excludes stale samples'
Assert-PcCareIncident (@($stalePnP.findings | Where-Object { $_.code -eq 'PNP_CONFIG_REVIEW' }).Count -eq 0) 'No PnP hypothesis from unavailable collection'
$partialPnP = [pscustomobject]@{ status='truncated'; samples=@([pscustomobject]@{ configurationCode=10 }) }
$partialFinding = Get-PcCareIncidentAssessment -EventEvidence @() -DiskObservations $healthy -DiskCollectionStatus 'collected' -EventCollectionStatus 'collected' -PnPSummary $partialPnP
Assert-PcCareIncident ($partialFinding.observedCounts.pnpIssueSamples -eq 1) 'Truncated PnP retains actually observed sample'
Assert-PcCareIncident ($partialFinding.status -eq 'incomplete') 'Truncated PnP always marked incomplete'
$unknownDiskCollection = Get-PcCareIncidentAssessment -EventEvidence @() -DiskObservations $healthy -DiskCollectionStatus 'unavailable' -EventCollectionStatus 'no matching events'
Assert-PcCareIncident ($unknownDiskCollection.status -eq 'incomplete') 'Healthy disk sample with unavailable inventory cannot imply complete assessment'
Assert-PcCareIncident (@($unknownDiskCollection.caveats | Where-Object { $_ -match '물리 저장장치 상태의 일부' }).Count -eq 1) 'Incomplete disk inventory has clear caveat'
$knownDiskCollection = Get-PcCareIncidentAssessment -EventEvidence @() -DiskObservations $healthy -DiskCollectionStatus 'collected' -EventCollectionStatus 'no matching events'
Assert-PcCareIncident (@($knownDiskCollection.caveats | Where-Object { $_ -match '물리 저장장치 상태의 일부' }).Count -eq 0) 'Complete all-healthy disk inventory lacks false collection caveat'
$diskDangerObserved = Get-PcCareIncidentAssessment -EventEvidence @() -DiskObservations $badDisk -DiskCollectionStatus 'unavailable' -EventCollectionStatus 'no matching events'
Assert-PcCareIncident (@($diskDangerObserved.findings | Where-Object { $_.code -eq 'STORAGE_FIRST' }).Count -eq 0) 'Failed inventory cannot create a warning from stale disk observations'
$diskEmpty = Get-PcCareIncidentAssessment -EventEvidence @() -DiskObservations $badDisk -DiskCollectionStatus 'empty' -EventCollectionStatus 'no matching events'
Assert-PcCareIncident (@($diskEmpty.findings | Where-Object { $_.code -eq 'STORAGE_FIRST' }).Count -eq 0) 'Successful empty inventory excludes stale warnings'
$diskTruncated = Get-PcCareIncidentAssessment -EventEvidence @() -DiskObservations $badDisk -DiskCollectionStatus 'truncated' -EventCollectionStatus 'no matching events'
Assert-PcCareIncident (@($diskTruncated.findings | Where-Object { $_.code -eq 'STORAGE_FIRST' }).Count -eq 1) 'Truncated but observed warning is retained'
Assert-PcCareIncident ($diskTruncated.status -eq 'incomplete') 'Truncated disk source cannot imply full coverage'
$diskCollected = Get-PcCareIncidentAssessment -EventEvidence @() -DiskObservations $badDisk -DiskCollectionStatus 'collected' -EventCollectionStatus 'no matching events'
Assert-PcCareIncident (@($diskCollected.findings | Where-Object { $_.code -eq 'STORAGE_FIRST' }).Count -eq 1) 'Collected valid warning still reported'
Assert-PcCareIncident ($diskDangerObserved.status -eq 'incomplete') 'Observed disk warning cannot make incomplete collection complete'

# Untrusted kind/provider/time combinations must never create causal hypotheses.
$spoofSystem = @([pscustomobject]@{ kind='bugcheck_record'; eventId=1001; provider='PRIVATE-BugCheck'; timeBasis='event_recorded_time'; recordedUtc='2026-10-30T01:00:00Z' })
$invalidSystem = Get-PcCareIncidentAssessment -EventEvidence $spoofSystem -DiskObservations $healthy -DiskCollectionStatus 'collected' -EventCollectionStatus 'collected'
Assert-PcCareIncident ($invalidSystem.observedCounts.bugcheckRecords -eq 0 -and $invalidSystem.findings.Count -eq 0) 'Spoofed BugCheck provider never triggers a diagnostic finding'
Assert-PcCareIncident ($invalidSystem.status -eq 'incomplete' -and $invalidSystem.observedCounts.rejectedSystemEvidence -eq 1) 'Rejected System evidence must mark coverage incomplete'
$spoofUpdate = @([pscustomobject]@{ kind='update_installation_failure_record'; eventId=20; provider='Fake-Microsoft-Windows-WindowsUpdateClient'; timeBasis='event_recorded_time'; recordedUtc='2026-10-30T01:00:00Z' })
$invalidUpdate = Get-PcCareIncidentAssessment -EventEvidence @() -DiskObservations $healthy -DiskCollectionStatus 'collected' -EventCollectionStatus 'no matching events' -UpdateEvidence $spoofUpdate -UpdateCollectionStatus 'collected'
Assert-PcCareIncident ($invalidUpdate.observedCounts.updateFailureRecords -eq 0 -and $invalidUpdate.status -eq 'incomplete') 'Spoofed update record cannot create installation failure'
Assert-PcCareIncident ($invalidUpdate.observedCounts.rejectedUpdateEvidence -eq 1) 'Rejected Update evidence count is explicit'
$crossSource = Get-PcCareIncidentAssessment -EventEvidence $failedUpdate -DiskObservations $healthy -DiskCollectionStatus 'collected' -EventCollectionStatus 'collected' -UpdateEvidence $crash -UpdateCollectionStatus 'collected'
Assert-PcCareIncident ($crossSource.findings.Count -eq 0 -and $crossSource.observedCounts.rejectedSystemEvidence -eq 1 -and $crossSource.observedCounts.rejectedUpdateEvidence -eq 1) 'System and Update records cannot cross collector boundaries'
$noZone = [pscustomobject]@{ kind='shutdown_signal'; eventId=41; provider='Microsoft-Windows-Kernel-Power'; timeBasis='event_recorded_time'; recordedUtc='2026-10-30T01:00:00' }
$invalidDate = [pscustomobject]@{ kind='shutdown_signal'; eventId=41; provider='Microsoft-Windows-Kernel-Power'; timeBasis='event_recorded_time'; recordedUtc='2026-02-30T01:00:00Z' }
$wrongId = [pscustomobject]@{ kind='bugcheck_record'; eventId=41; provider='BugCheck'; timeBasis='event_recorded_time'; recordedUtc='2026-10-30T01:00:00Z' }
$fractionalId = [pscustomobject]@{ kind='bugcheck_record'; eventId=1001.5; provider='BugCheck'; timeBasis='event_recorded_time'; recordedUtc='2026-10-30T01:00:00Z' }
$booleanId = [pscustomobject]@{ kind='bugcheck_record'; eventId=$true; provider='BugCheck'; timeBasis='event_recorded_time'; recordedUtc='2026-10-30T01:00:00Z' }
$wrongTimeBasis = [pscustomobject]@{ kind='bugcheck_record'; eventId=1001; provider='BugCheck'; timeBasis='estimated_crash_time'; recordedUtc='2026-10-30T01:00:00Z' }
$partValid = Get-PcCareIncidentAssessment -EventEvidence @($crash[0],$noZone,$invalidDate,$wrongId,$fractionalId,$booleanId,$wrongTimeBasis) -DiskObservations $healthy -DiskCollectionStatus 'collected' -EventCollectionStatus 'collected'
Assert-PcCareIncident ($partValid.observedCounts.bugcheckRecords -eq 1 -and $partValid.observedCounts.rejectedSystemEvidence -eq 6) 'Only observed normalized record survives mixed untrusted evidence'
Assert-PcCareIncident ($partValid.status -eq 'incomplete') 'Mixed valid and invalid evidence is not complete'
Assert-PcCareIncident (@($partValid.findings | Where-Object { $_.causeConfirmed }).Count -eq 0) 'Verified record is not a confirmed root cause'
Assert-PcCareIncident (($partValid | ConvertTo-Json -Depth 8) -notmatch 'PRIVATE') 'Rejected source identity is never copied to report'

# Coverage and severity must agree with the public-facing verdict.
$emptyVerdict = Get-PcCareAssessmentLabel -Issues @() -Limitations @() -IncidentAssessment $empty
Assert-PcCareIncident ($emptyVerdict -eq '확인 불완전') 'Incomplete evidence cannot show an all-clear verdict'
$highVerdict = Get-PcCareAssessmentLabel -Issues @([pscustomobject]@{ severity='high'; code='DISK_HEALTH' }) -Limitations @() -IncidentAssessment $empty
Assert-PcCareIncident ($highVerdict -eq '위험 신호') 'Observed high-severity warning remains visible during incomplete collection'
$mediumVerdict = Get-PcCareAssessmentLabel -Issues @([pscustomobject]@{ severity='medium'; code='BUGCHECK' }) -Limitations @() -IncidentAssessment $empty
Assert-PcCareIncident ($mediumVerdict -eq '주의 필요') 'Observed medium warning remains visible during incomplete collection'
$cleanVerdict = Get-PcCareAssessmentLabel -Issues @() -Limitations @() -IncidentAssessment ([pscustomobject]@{ status='limited_observations' })
Assert-PcCareIncident ($cleanVerdict -eq '관찰 범위 내 특이사항 없음') 'Valid bounded observations preserve original clean verdict'
$missingVerdict = Get-PcCareAssessmentLabel -Issues @() -Limitations @() -IncidentAssessment $null
Assert-PcCareIncident ($missingVerdict -eq '확인 불완전') 'Missing analysis never becomes a clean verdict'
$limitedVerdict = Get-PcCareAssessmentLabel -Issues @() -Limitations @('로그 접근 불가') -IncidentAssessment ([pscustomobject]@{ status='limited_observations' })
Assert-PcCareIncident ($limitedVerdict -eq '확인 불완전') 'Explicit source limitation overrides no-warning output'
Write-Host 'INCIDENT FIXTURE PASS: missing evidence, 41-only, BugCheck, storage priority, uncertainty.' -ForegroundColor Green
