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
$shutdown = @([pscustomobject]@{ kind='shutdown_signal'; eventId=41 })
$shutdownOnly = Get-PcCareIncidentAssessment -EventEvidence $shutdown -DiskObservations $healthy -EventCollectionStatus 'collected'
Assert-PcCareIncident ($shutdownOnly.findings.Count -eq 1) '41 should not become a BugCheck'
Assert-PcCareIncident ($shutdownOnly.findings[0].code -eq 'SHUTDOWN_REVIEW') '41 is only shutdown evidence'
$crash = @([pscustomobject]@{ kind='bugcheck_record'; eventId=1001 })
$bugOnly = Get-PcCareIncidentAssessment -EventEvidence $crash -DiskObservations $healthy -EventCollectionStatus 'collected'
Assert-PcCareIncident ($bugOnly.findings.Count -eq 1) 'Bugcheck should produce one interpretation'
Assert-PcCareIncident ($bugOnly.findings[0].code -eq 'BUGCHECK_REVIEW') 'Bugcheck review'
$badDisk = @([pscustomobject]@{ status='Warning'; model='<not-an-id>' })
$combo = Get-PcCareIncidentAssessment -EventEvidence $crash -DiskObservations $badDisk -EventCollectionStatus 'truncated'
Assert-PcCareIncident ($combo.status -eq 'incomplete') 'Truncated event window'
Assert-PcCareIncident ($combo.findings.Count -eq 2) 'Independent storage and crash findings'
Assert-PcCareIncident ($combo.findings[0].code -eq 'STORAGE_FIRST') 'Storage data protection prioritized'
Assert-PcCareIncident (@($combo.caveats | Where-Object { $_ -match '인과관계' }).Count -eq 1) 'Co-observed evidence is not proof of causation'
Assert-PcCareIncident (@($combo.findings | Where-Object { $_.causeConfirmed }).Count -eq 0) 'No finding asserts causation'
$unknown = Get-PcCareIncidentAssessment -EventEvidence @() -DiskObservations @([pscustomobject]@{ status='Unknown' }) -EventCollectionStatus 'no matching events'
Assert-PcCareIncident ($unknown.status -eq 'incomplete') 'Unknown physical disk state cannot produce complete result'
$serialized = $combo | ConvertTo-Json -Depth 8
Assert-PcCareIncident ($serialized -notmatch '<not-an-id>') 'Do not copy source device names into interpretations'
$failedUpdate = @([pscustomobject]@{ kind='update_installation_failure_record'; recordedAt='2026-10-30T01:00:00Z' })
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
Assert-PcCareIncident (@($diskDangerObserved.findings | Where-Object { $_.code -eq 'STORAGE_FIRST' }).Count -eq 1) 'Observed disk warning is kept despite incomplete inventory'
Assert-PcCareIncident ($diskDangerObserved.status -eq 'incomplete') 'Observed disk warning cannot make incomplete collection complete'
Write-Host 'INCIDENT FIXTURE PASS: missing evidence, 41-only, BugCheck, storage priority, uncertainty.' -ForegroundColor Green
