# Pure synthetic event regression; runs under Windows PowerShell 5.1.
# Does not inspect the host's event log or modify the system.
$ErrorActionPreference = 'Stop'
. (Join-Path (Split-Path -Parent $PSScriptRoot) 'tools/event_analysis.ps1')

function Assert-PcCare([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw ('EVENT FIXTURE FAIL: ' + $Message) }
}
$t = [datetime]::Parse('2026-10-30T12:00:00')
$fixtures = @(
    [pscustomobject]@{ Id=41; ProviderName='Microsoft-Windows-Kernel-Power'; RecordId=100; TimeCreated=$t; Message='power lost' },
    [pscustomobject]@{ Id=6008; ProviderName='EventLog'; RecordId=101; TimeCreated=$t.AddMinutes(1); Message='unexpected' },
    [pscustomobject]@{ Id=41; ProviderName='Microsoft-Windows-Kernel-Power'; RecordId=100; TimeCreated=$t; Message='duplicate read' },
    [pscustomobject]@{ Id=1001; ProviderName='Application Error'; RecordId=102; TimeCreated=$t.AddMinutes(4); Message='not a bugcheck' },
    [pscustomobject]@{ Id=1001; ProviderName='Microsoft-Windows-WER-SystemErrorReporting'; RecordId=103; TimeCreated=$t.AddMinutes(5); Message='STOP: 0x0000007e' },
    [pscustomobject]@{ Id=7; ProviderName='disk'; RecordId=104; TimeCreated=$t.AddMinutes(6); Message='disk message must not be stored' },
    [pscustomobject]@{ Id=41; ProviderName='Microsoft-Windows-Kernel-Power'; RecordId=105; TimeCreated=$t.AddMinutes(80); Message='new outage signal' },
    [pscustomobject]@{ Id=1001; ProviderName='FakeBugCheck'; RecordId=106; TimeCreated=$t; Message='forged crash' },
    [pscustomobject]@{ Id=41; ProviderName='Kernel-Power-Helper'; RecordId=107; TimeCreated=$t; Message='forged shutdown' },
    [pscustomobject]@{ Id=6008; ProviderName='EventLogProxy'; RecordId=108; TimeCreated=$t; Message='forged log' },
    [pscustomobject]@{ Id=129; ProviderName='InventoryStore'; RecordId=109; TimeCreated=$t; Message='forged storage' },
    [pscustomobject]@{ Id=7; ProviderName='diskmon'; RecordId=110; TimeCreated=$t; Message='forged disk' }
)
$evidence = @(ConvertTo-PcCareEvidence -Events $fixtures)
Assert-PcCare ($evidence.Count -eq 5) 'Unexpected normalization count / deduplication or spoofed provider'
$bugchecks = @($evidence | Where-Object { $_.kind -eq 'bugcheck_record' })
Assert-PcCare ($bugchecks.Count -eq 1) '1001 requires matching provider'
Assert-PcCare ($bugchecks[0].stopCode -eq '0X0000007E') 'STOP code extraction'
Assert-PcCare ($bugchecks[0].timeBasis -eq 'event_recorded_time') '1001 time cannot be called crash time'
$storage = @($evidence | Where-Object { $_.kind -eq 'storage_signal' })
Assert-PcCare ($storage.Count -eq 1) 'Storage event classification'
Assert-PcCare (($evidence | ConvertTo-Json -Depth 5) -notmatch 'forged') 'Lookalike provider was misclassified'
Assert-PcCare (($evidence | ConvertTo-Json -Depth 5) -notmatch 'disk message must not be stored') 'Raw event content leak'
$malformedIds = @(
    [pscustomobject]@{ Id=41.5; ProviderName='Microsoft-Windows-Kernel-Power'; TimeCreated=$t; RecordId=501 },
    [pscustomobject]@{ Id=$true; ProviderName='Microsoft-Windows-Kernel-Power'; TimeCreated=$t; RecordId=502 },
    [pscustomobject]@{ Id='41.5'; ProviderName='Microsoft-Windows-Kernel-Power'; TimeCreated=$t; RecordId=503 }
)
Assert-PcCare (@(ConvertTo-PcCareEvidence -Events $malformedIds).Count -eq 0) 'Fractional and boolean event IDs cannot create shutdown evidence'
$groups = @(Group-PcCareShutdownSignals -Evidence $evidence)
Assert-PcCare ($groups.Count -eq 2) '41/6008 likely duplicate and distant record must remain separate'
Assert-PcCare ($groups[0].evidenceCount -eq 2) 'Grouped signal must preserve evidence count'
Assert-PcCare ($groups[0].interpretation -eq 'possibly_related_shutdown_signals') 'No confirmed outage claims'
 $badGroups = @(Group-PcCareShutdownSignals -Evidence @(
    [pscustomobject]@{ kind='shutdown_signal'; eventId=41.5; recordedAt='bad'; recordedUtc='2026-10-30T12:00:00Z' },
    [pscustomobject]@{ kind='shutdown_signal'; eventId=$true; recordedAt='bad'; recordedUtc='2026-10-30T12:01:00Z' }
))
Assert-PcCare ($badGroups.Count -eq 0) 'Malformed event IDs cannot inflate grouped shutdown evidence'
Assert-PcCare (@(ConvertTo-PcCareEvidence -Events @()).Count -eq 0) 'Empty event set'
Assert-PcCare (@(Group-PcCareShutdownSignals -Evidence @()).Count -eq 0) 'Empty grouping'
$queryEmpty = Invoke-PcCareEventQuery -Query { @() } -MaxEvents 3
Assert-PcCare ($queryEmpty.status -eq 'no matching events' -and $queryEmpty.returnedCount -eq 0) 'Empty event query'
$queryDenied = Invoke-PcCareEventQuery -Query { throw 'Access denied' } -MaxEvents 3
Assert-PcCare ($queryDenied.status -eq 'unavailable' -and $queryDenied.returnedCount -eq 0) 'Denied query must not become normal zero'
$queryTruncated = Invoke-PcCareEventQuery -Query { 41; 6008; 1001 } -MaxEvents 3
Assert-PcCare ($queryTruncated.status -eq 'truncated' -and $queryTruncated.returnedCount -eq 3) 'Capped event set'
$queryPartial = Invoke-PcCareEventQuery -Query { 41; 6008 } -MaxEvents 3
Assert-PcCare ($queryPartial.status -eq 'collected' -and $queryPartial.returnedCount -eq 2) 'Partial below cap'
$queryOverCap = Invoke-PcCareEventQuery -Query { 1; 2; 3; 4; 5 } -MaxEvents 3
Assert-PcCare ($queryOverCap.status -eq 'truncated' -and $queryOverCap.returnedCount -eq 3) 'Query must not retain records past cap'
# Same instant reported as two different timezone offsets must stay chronologically identical.
$utcStamp = [datetime]::SpecifyKind(([datetime]::Parse('2026-10-30T03:00:00')), [DateTimeKind]::Utc)
$localStamp = $utcStamp.ToLocalTime()
$utcRecords = @(
    [pscustomobject]@{ Id=41; ProviderName='Microsoft-Windows-Kernel-Power'; RecordId=201; TimeCreated=$utcStamp; Message='' },
    [pscustomobject]@{ Id=6008; ProviderName='EventLog'; RecordId=202; TimeCreated=$localStamp; Message='' }
)
$utcEvidence = @(ConvertTo-PcCareEvidence -Events $utcRecords)
Assert-PcCare ($utcEvidence.Count -eq 2) 'Timezone fixture evidence count'
Assert-PcCare ($utcEvidence[0].recordedUtc -eq $utcEvidence[1].recordedUtc) 'Timestamp normalized to UTC'
Write-Host 'EVENT FIXTURE PASS: normalization, provider filter, duplicate grouping, timestamps, privacy.' -ForegroundColor Green
