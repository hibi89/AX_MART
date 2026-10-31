# Synthetic repair consultation summary fixtures, no Windows or filesystem changes.
$ErrorActionPreference = 'Stop'
. (Join-Path (Split-Path -Parent $PSScriptRoot) 'tools/consultation_report.ps1')
. (Join-Path (Split-Path -Parent $PSScriptRoot) 'tools/consultation_render.ps1')
. (Join-Path (Split-Path -Parent $PSScriptRoot) 'tools/report_io.ps1')
function Assert-Consultation([bool]$condition, [string]$message) {
    if (-not $condition) { throw ('CONSULTATION FIXTURE FAIL: ' + $message) }
}
$privateEvent = [pscustomobject]@{
    kind='bugcheck_record'; eventId=1001; recordedUtc='2026-10-30T03:00:00Z'
    timeBasis='event_recorded_time'; provider='BugCheck'
    Message='PRIVATE-USERNAME'; ProviderName='PRIVATE-SERIAL'; stopCode='PRIVATE-KEY'
}
$report = [ordered]@{
    generatedAt='2026-10-30 12:04:00 +09:00'
    assessment='위험 신호'
    issues=@(
        [pscustomobject]@{ code='STORAGE_EVENTS'; title='PRIVATE-CUSTOM-TITLE'; explanation='PRIVATE-LOG' },
        [pscustomobject]@{ code='BUGCHECK' },
        [pscustomobject]@{ code='SOME-PRIVATE-PATH' }
    )
    observations=[ordered]@{
        windows=[ordered]@{ name='PRIVATE-DEVICE'; build='26100' }
        eventCollection='truncated'
        collectionStatus=[ordered]@{ physicalDisks='collected' }
        eventEvidence=@($privateEvent)
        windowsUpdate=[ordered]@{
            status='unavailable'
            evidence=@([pscustomobject]@{ kind='update_installation_failure_record'; eventId=20; recordedUtc='2026-10-30T03:10:00Z'; Message='PRIVATE-UPDATE' })
        }
        physicalDisks=@([pscustomobject]@{ status='Warning'; model='PRIVATE-DISK'; serial='PRIVATE-SERIAL' })
    }
}
$summary = Get-PcCareConsultationSummary -Report $report
Assert-Consultation ($summary.assessment -eq '위험 신호') 'Confirmed assessment label'
Assert-Consultation ($summary.windowsBuild -eq '26100') 'Only numeric Windows build'
Assert-Consultation ($summary.storageSignal -eq '경고 신호 관측') 'Warning summarized without source model'
Assert-Consultation ($summary.reviewItems.Count -eq 2) 'Issue allowlist and bounded codes'
Assert-Consultation ($summary.recordedEvents.Count -eq 1) 'Unavailable Windows update records must be excluded'
Assert-Consultation ($summary.recordedEvents[0].eventId -eq 1001) 'Valid system record remains'
Assert-Consultation ($summary.recordedEvents[0].recordedUtc -eq '2026-10-30 03:00') 'UTC normalized'
Assert-Consultation ($summary.consultationQuestions.Count -ge 2 -and $summary.consultationQuestions.Count -le 4) 'Bounded consultation checklist'
Assert-Consultation (@($summary.limitations | Where-Object { $_ -match '조회 불가|일부만 수집' }).Count -eq 2) 'Unavailable and truncated states'
Assert-Consultation (-not $summary.containsIdentifiers) 'No identifiers declared'
$serialized = $summary | ConvertTo-Json -Depth 8
Assert-Consultation ($serialized -notmatch 'PRIVATE-') 'Do not copy private event, disk, host or issue text'
Assert-Consultation ($serialized -notmatch 'SOME-PRIVATE-PATH') 'Unknown issue cannot leak through'
$emptyReport = [ordered]@{
    generatedAt='PRIVATE-INVALID-TIMESTAMP'
    assessment='PRIVATE-UNKNOWN-ASSESSMENT'
    issues=@()
    observations=[ordered]@{
        windows=[ordered]@{ build='PRIVATE-HOST' }
        eventCollection='unavailable'
        eventEvidence=@()
        windowsUpdate=[ordered]@{ status='unavailable'; evidence=@() }
        physicalDisks=@()
    }
}
$emptySummary = Get-PcCareConsultationSummary -Report $emptyReport
Assert-Consultation ($emptySummary.generatedAt -eq '확인 불가') 'Invalid timestamp unavailable'
Assert-Consultation ($emptySummary.windowsBuild -eq '확인 불가') 'Invalid build filtered'
Assert-Consultation ($emptySummary.assessment -eq '확인 불완전') 'Unknown assessment filtered'
Assert-Consultation ($emptySummary.recordedEvents.Count -eq 0) 'No fabricated events'
Assert-Consultation ($emptySummary.storageSignal -eq '미확인') 'Missing disks not healthy'
$many = New-Object 'System.Collections.Generic.List[object]'
for ($i=0; $i -lt 20; $i++) {
    [void]$many.Add([pscustomobject]@{
        kind='shutdown_signal'; eventId=41
        timeBasis='event_recorded_time'; provider='Microsoft-Windows-Kernel-Power'
        recordedUtc=([datetimeoffset]'2026-10-30T01:00:00+00:00').AddMinutes($i).ToString('o')
        Message='PRIVATE-LARGE-LOG'
    })
}
$report.observations.eventEvidence = @($many.ToArray())
$bounded = Get-PcCareConsultationSummary -Report $report
Assert-Consultation ($bounded.recordedEvents.Count -eq 4) 'A4 evidence max four'
Assert-Consultation ($bounded.recordedEvents[0].recordedUtc -eq '2026-10-30 01:19') 'Four newest evidence rows'
Assert-Consultation (($bounded | ConvertTo-Json -Depth 8) -notmatch 'PRIVATE-') 'Long history cannot leak private strings'
$printHtml = ConvertTo-PcCareConsultationHtml -Summary $summary
Assert-Consultation ($printHtml -match 'id="consultation-print"') 'Print-only section selector'
Assert-Consultation ($printHtml -match '수리점 상담 질문' -and $printHtml -match 'Event ID') 'Print includes consultation checklist and evidence'
Assert-Consultation ($printHtml -notmatch 'PRIVATE-') 'Rendered HTML does not contain original private strings'
$untrustedSummary = $summary.PSObject.Copy()
$untrustedSummary.generatedAt = '<script>ALERT</script>'
$untrustedSummary.advice = '<img src=x onerror=alert(1)>'
$untrustedSummary.reviewItems = @('<script>test</script>')
$evilHtml = ConvertTo-PcCareConsultationHtml -Summary $untrustedSummary
Assert-Consultation ($evilHtml -notmatch '<script>' -and $evilHtml -notmatch '<img ') 'Untrusted values must be HTML-encoded'
Assert-Consultation ($evilHtml -match '&lt;script&gt;') 'Encoded values retained safely'
# Status provenance: a stale or injected event is never a valid record after failed lookup.
$report.observations.eventCollection = 'unavailable'
$report.observations.windowsUpdate.status = 'unavailable'
$unavailableEvidence = Get-PcCareConsultationSummary -Report $report
Assert-Consultation ($unavailableEvidence.recordedEvents.Count -eq 0) 'Failed collectors cannot present stale event records'
$report.observations.eventCollection = 'truncated'
$report.observations.windowsUpdate.status = 'collected'
$validPartial = Get-PcCareConsultationSummary -Report $report
Assert-Consultation ($validPartial.recordedEvents.Count -eq 4) 'Truncated System and collected update records may appear with limitations'
Assert-Consultation (@($validPartial.limitations | Where-Object { $_ -eq 'System 로그 일부만 수집' }).Count -eq 1) 'Partial collection limitation remains visible'
# Storage collection provenance: Healthy alone does not mean the whole device inventory is complete.
$report.observations['physicalDisks'] = @([pscustomobject]@{ status='Healthy'; model='PRIVATE-DISK' })
$report.observations['collectionStatus'] = [ordered]@{ physicalDisks='unavailable' }
$diskUnavailable = Get-PcCareConsultationSummary -Report $report
Assert-Consultation ($diskUnavailable.storageSignal -eq '미확인') 'Unavailable collection with Healthy item is unknown'
Assert-Consultation (@($diskUnavailable.limitations | Where-Object { $_ -eq '저장장치 수집 완전성 미확인' }).Count -eq 1) 'Storage incompleteness limitation required'
$report.observations.collectionStatus.physicalDisks = 'truncated'
$diskTruncated = Get-PcCareConsultationSummary -Report $report
Assert-Consultation ($diskTruncated.storageSignal -eq '미확인') 'Truncated disks cannot claim healthy'
$report.observations.collectionStatus.physicalDisks = 'collected'
$diskComplete = Get-PcCareConsultationSummary -Report $report
Assert-Consultation ($diskComplete.storageSignal -eq 'Windows 정상 신호 (보증 아님)') 'Only complete all-healthy list may show healthy observation'
$report.observations.physicalDisks = @()
$diskEmpty = Get-PcCareConsultationSummary -Report $report
Assert-Consultation ($diskEmpty.storageSignal -eq '미확인') 'Empty disk list cannot claim healthy'
$report.observations.physicalDisks = @([pscustomobject]@{ status='Warning'; model='PRIVATE-DISK' })
$report.observations.collectionStatus.physicalDisks = 'unavailable'
$diskWarning = Get-PcCareConsultationSummary -Report $report
Assert-Consultation ($diskWarning.storageSignal -eq '미확인') 'Unavailable disk warnings must not be treated as observed'
$report.observations.collectionStatus.physicalDisks = 'truncated'
$observedPartialWarning = Get-PcCareConsultationSummary -Report $report
Assert-Consultation ($observedPartialWarning.storageSignal -eq '경고 신호 관측') 'Truncated inventory retains genuinely observed warnings'
Assert-Consultation (($diskWarning | ConvertTo-Json -Depth 8) -notmatch 'PRIVATE-') 'Warnings never leak model or private data'
# Evidence provenance: only the right collector, known provider, and explicit zoned UTC are allowed.
$report.observations.eventCollection = 'collected'
$report.observations.windowsUpdate.status = 'collected'
$report.observations.eventEvidence = @(
    [pscustomobject]@{ kind='bugcheck_record'; eventId=1001; provider='BugCheck'; timeBasis='event_recorded_time'; recordedUtc='2026-10-30T03:00:00Z' },
    [pscustomobject]@{ kind='bugcheck_record'; eventId=1001; provider='PRIVATE-FORGED-PROVIDER'; timeBasis='event_recorded_time'; recordedUtc='2026-10-30T03:01:00Z' },
    [pscustomobject]@{ kind='bugcheck_record'; eventId=1001; provider='BugCheck'; timeBasis='PRIVATE-NOT-RECORDED'; recordedUtc='2026-10-30T03:02:00Z' },
    [pscustomobject]@{ kind='bugcheck_record'; eventId=1001; provider='BugCheck'; timeBasis='event_recorded_time'; recordedUtc='2026-10-30T03:03:00' },
    [pscustomobject]@{ kind='update_installation_failure_record'; eventId=20; timeBasis='event_recorded_time'; recordedUtc='2026-10-30T03:04:00Z' }
)
$report.observations.windowsUpdate.evidence = @(
    [pscustomobject]@{ kind='update_installation_failure_record'; provider='Microsoft-Windows-WindowsUpdateClient'; eventId=20; timeBasis='event_recorded_time'; recordedUtc='2026-10-30T03:05:00+00:00' },
    [pscustomobject]@{ kind='update_installation_failure_record'; provider='Fake-Microsoft-Windows-WindowsUpdateClient'; eventId=20; timeBasis='event_recorded_time'; recordedUtc='2026-10-30T03:08:00Z' },
    [pscustomobject]@{ kind='update_installation_failure_record'; eventId=20; timeBasis='event_recorded_time'; recordedUtc='2026-10-30T03:09:00Z' },
    [pscustomobject]@{ kind='shutdown_signal'; eventId=41; provider='Microsoft-Windows-Kernel-Power'; timeBasis='event_recorded_time'; recordedUtc='2026-10-30T03:06:00Z' },
    [pscustomobject]@{ kind='update_installation_failure_record'; eventId=20; timeBasis='event_recorded_time'; recordedUtc='2026-02-30T03:07:00Z' }
)
$trusted = Get-PcCareConsultationSummary -Report $report
Assert-Consultation ($trusted.recordedEvents.Count -eq 2) 'Untrusted provider, time basis, zone, and cross-source kinds rejected'
Assert-Consultation ($trusted.recordedEvents[0].eventId -eq 20 -and $trusted.recordedEvents[0].recordedUtc -eq '2026-10-30 03:05') 'Valid offset-normalized update retained'
Assert-Consultation ($trusted.recordedEvents[1].eventId -eq 1001) 'Valid System provider record retained'
Assert-Consultation (($trusted | ConvertTo-Json -Depth 8) -notmatch 'PRIVATE-') 'Forged inputs and private fields never reach shared report'
# Save and read back a synthetic JSON/HTML pair to verify both render the same safe diagnosis.
$pairSummary = Get-PcCareConsultationSummary -Report $report
$report['consultation'] = $pairSummary
$pairJson = $report | ConvertTo-Json -Depth 12
$pairHtml = ConvertTo-PcCareConsultationHtml -Summary $pairSummary
$pairRoot = Join-Path ([IO.Path]::GetTempPath()) ('pc-care-report-pair-' + [guid]::NewGuid().ToString('N'))
[void](New-Item -ItemType Directory -Path $pairRoot)
try {
    $pair = Save-PcCareReportPair -JsonText $pairJson -HtmlText $pairHtml -Candidates @($pairRoot) -FileBase 'synthetic-report'
    $savedJson = Get-Content -LiteralPath $pair.json -Raw -Encoding UTF8 | ConvertFrom-Json
    $savedHtml = Get-Content -LiteralPath $pair.html -Raw -Encoding UTF8
    Assert-Consultation ($savedJson.assessment -eq $pairSummary.assessment) 'Saved JSON preserves report assessment'
    Assert-Consultation ($savedJson.consultation.storageSignal -eq $pairSummary.storageSignal) 'Saved JSON preserves storage signal'
    Assert-Consultation ($savedHtml.Contains([string]$pairSummary.assessment) -and $savedHtml.Contains([string]$pairSummary.storageSignal)) 'Saved HTML displays same assessment and storage signal'
    Assert-Consultation ($savedHtml.Contains('>1001</td>') -and $savedHtml.Contains('2026-10-30 03:00')) 'Saved HTML labels recorded event evidence with its normalized time'
    Assert-Consultation (($savedJson.consultation | ConvertTo-Json -Depth 8) -notmatch 'PRIVATE-' -and $savedHtml -notmatch 'PRIVATE-') 'Consultation JSON and saved HTML exclude source identifiers and raw logs'
    Assert-Consultation ($savedHtml -notmatch '<script>|<img ') 'Saved HTML contains no injected markup'
}
finally {
    Remove-Item -LiteralPath $pairRoot -Recurse -Force -ErrorAction SilentlyContinue
}
Write-Host 'REPORT PAIR E2E PASS: synthetic JSON/HTML agree, escape content, and exclude private source data.' -ForegroundColor Green
Write-Host 'CONSULTATION FIXTURE PASS: bounded evidence, A4 checklist, unknown data, privacy.' -ForegroundColor Green
