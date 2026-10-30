# Synthetic repair consultation summary fixtures, no Windows or filesystem changes.
$ErrorActionPreference = 'Stop'
. (Join-Path (Split-Path -Parent $PSScriptRoot) 'tools/consultation_report.ps1')
. (Join-Path (Split-Path -Parent $PSScriptRoot) 'tools/consultation_render.ps1')
function Assert-Consultation([bool]$condition, [string]$message) {
    if (-not $condition) { throw ('CONSULTATION FIXTURE FAIL: ' + $message) }
}
$privateEvent = [pscustomobject]@{
    kind='bugcheck_record'; eventId=1001; recordedUtc='2026-10-30T03:00:00Z'
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
Assert-Consultation ($summary.recordedEvents.Count -eq 2) 'System and update records included'
Assert-Consultation ($summary.recordedEvents[0].eventId -eq 20) 'Newest events first'
Assert-Consultation ($summary.recordedEvents[0].recordedUtc -eq '2026-10-30 03:10') 'UTC normalized'
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
Write-Host 'CONSULTATION FIXTURE PASS: bounded evidence, A4 checklist, unknown data, privacy.' -ForegroundColor Green
