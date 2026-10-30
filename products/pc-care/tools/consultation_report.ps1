# AXMART PC CARE - privacy-filtered, bounded repair consultation summary.
# PowerShell 5.1 pure function. Never copies device names, serials, paths or messages.
function Get-PcCareConsultationSummary {
    [CmdletBinding()]
    param([Parameter(Mandatory=$true)][object]$Report)
    $observations = $Report.observations
    $issueList = @($Report.issues | Where-Object { $null -ne $_ })
    $codeLabels = @{
        'DISK_HEALTH'='저장장치 상태 경고'
        'STORAGE_EVENTS'='저장장치 관련 이벤트'
        'DISK_SPACE_CRITICAL'='저장 공간 매우 부족'
        'DISK_SPACE_LOW'='저장 공간 부족'
        'BUGCHECK'='BugCheck 관련 기록'
        'UNEXPECTED_REBOOT'='비정상 종료 신호'
        'WINDOWS_UPDATE_FAILURE_RECORD'='Windows 업데이트 설치 실패 기록'
        'PNP_CONFIGURATION'='장치 구성 코드 점검'
    }
    $reviewItems = New-Object 'System.Collections.Generic.List[string]'
    foreach ($item in $issueList) {
        $code = [string]$item.code
        if ($codeLabels.ContainsKey($code)) {
            $label = [string]$codeLabels[$code]
            if (-not $reviewItems.Contains($label)) { [void]$reviewItems.Add($label) }
        }
        if ($reviewItems.Count -ge 4) { break }
    }
    $assessment = [string]$Report.assessment
    if ($assessment -notin @('위험 신호','주의 필요','확인 불완전','관찰 범위 내 특이사항 없음')) {
        $assessment = '확인 불완전'
    }
    $generated = '확인 불가'
    try {
        $timestamp = [datetimeoffset]::Parse([string]$Report.generatedAt, [Globalization.CultureInfo]::InvariantCulture)
        $generated = $timestamp.ToString('yyyy-MM-dd HH:mm zzz', [Globalization.CultureInfo]::InvariantCulture)
    } catch {}
    $build = '확인 불가'
    try {
        $candidate = [string]$observations.windows.build
        if ($candidate -match '^[0-9]{4,6}$') { $build = $candidate }
    } catch {}
    $eventState = [string]$observations.eventCollection
    if ($eventState -notin @('collected','no matching events','truncated','unavailable')) { $eventState = 'unavailable' }
    $updateState = [string]$observations.windowsUpdate.status
    if ($updateState -notin @('collected','no matching events','truncated','unavailable')) { $updateState = 'unavailable' }
    $recorded = New-Object 'System.Collections.Generic.List[object]'
    # Failed/empty collectors are not evidence. Keep partially collected records
    # only when their status explicitly says 'truncated' and disclose that limit.
    # Restrict each evidence stream to its own collector. Stale or forged
    # cross-source events must not populate the 1-page consultation record.
    $eligibleRecords = New-Object 'System.Collections.Generic.List[object]'
    if ($eventState -in @('collected','truncated')) {
        foreach ($event in @($observations.eventEvidence)) {
            [void]$eligibleRecords.Add([pscustomobject]@{ scope='system'; item=$event })
        }
    }
    if ($updateState -in @('collected','truncated')) {
        foreach ($event in @($observations.windowsUpdate.evidence)) {
            [void]$eligibleRecords.Add([pscustomobject]@{ scope='update'; item=$event })
        }
    }
    foreach ($entry in $eligibleRecords) {
        $item = $entry.item
        if ($null -eq $item) { continue }
        if ([string]$item.timeBasis -cne 'event_recorded_time') { continue }
        $label = ''
        $kind = [string]$item.kind
        $id = -1
        try { $id = [int]$item.eventId } catch { continue }
        if ($entry.scope -eq 'system') {
            $provider = [string]$item.provider
            if ($kind -eq 'bugcheck_record' -and $id -eq 1001 -and
                $provider -match '^(?:BugCheck|WER-SystemErrorReporting|Microsoft-Windows-(?:BugCheck|WER-SystemErrorReporting))$') {
                $label = 'BugCheck 기록'
            } elseif ($kind -eq 'shutdown_signal' -and
                (($id -eq 41 -and $provider -match '^(?:Microsoft-Windows-)?Kernel-Power$') -or
                 ($id -eq 6008 -and $provider -match '^EventLog$'))) {
                $label = '비정상 종료 신호'
            } elseif ($kind -eq 'storage_signal' -and $id -in @(7,51,55,129,153,157) -and
                $provider -match '^(?:(?:Microsoft-Windows-)?(?:disk|ntfs|volmgr|storahci|stornvme|storport|storvsc|nvme)|Microsoft-Windows-Storage-Storport|iaStor(?:A|AC|V|VD))$') {
                $label = '저장장치 신호'
            }
        } elseif ($entry.scope -eq 'update') {
            if ([string]$item.provider -cne 'Microsoft-Windows-WindowsUpdateClient') { continue }
            if ($kind -eq 'update_installation_failure_record' -and $id -eq 20) { $label = '업데이트 설치 실패 기록' }
            elseif ($kind -eq 'update_installation_success_record' -and $id -eq 19) { $label = '업데이트 설치 성공 기록' }
        }
        if ($label -eq '') { continue }
        # Reject unzoned/local time or missing provenance. Parsing an ambiguous
        # local timestamp would silently shift its UTC time on another computer.
        $rawTime = [string]$item.recordedUtc
        if ($rawTime -cnotmatch '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{1,7})?(?:Z|[+-]\d{2}:\d{2})$') { continue }
        try {
            $when = [datetimeoffset]::Parse($rawTime, [Globalization.CultureInfo]::InvariantCulture).ToUniversalTime()
            if ($when -eq [datetimeoffset]::MinValue) { continue }
        } catch { continue }
        [void]$recorded.Add([pscustomobject]@{
            eventId=$id
            label=$label
            recordedUtc=$when.ToString('yyyy-MM-dd HH:mm', [Globalization.CultureInfo]::InvariantCulture)
            sortUtc=$when
        })
    }
    # Four newest observations only. No raw log text, provider, username or paths.
    $entries = New-Object 'System.Collections.Generic.List[object]'
    foreach ($item in @($recorded.ToArray() | Sort-Object sortUtc -Descending | Select-Object -First 4)) {
        [void]$entries.Add([pscustomobject]@{
            eventId=[int]$item.eventId
            label=[string]$item.label
            recordedUtc=[string]$item.recordedUtc
        })
    }
    $diskStatus = '미확인'
    $diskCollectionState = [string]$observations.collectionStatus.physicalDisks
    $diskComplete = ($diskCollectionState -eq 'collected')
    $diskItems = @($observations.physicalDisks | Where-Object { $null -ne $_ })
    # Observed warnings are usable only from a collected or truncated inventory.
    # A failed/empty query must never recycle stale warning rows as real evidence.
    $diskEvidenceUsable = ($diskCollectionState -in @('collected','truncated'))
    if ($diskEvidenceUsable -and @($diskItems | Where-Object { $_.status -in @('Warning','Unhealthy') }).Count -gt 0) {
        $diskStatus = '경고 신호 관측'
    } elseif ($diskComplete -and $diskItems.Count -gt 0 -and @($diskItems | Where-Object { $_.status -ne 'Healthy' }).Count -eq 0) {
        $diskStatus = 'Windows 정상 신호 (보증 아님)'
    }
    $limits = New-Object 'System.Collections.Generic.List[string]'
    if ($eventState -eq 'unavailable') { [void]$limits.Add('System 로그 조회 불가') }
    if ($eventState -eq 'truncated') { [void]$limits.Add('System 로그 일부만 수집') }
    if ($updateState -eq 'unavailable') { [void]$limits.Add('업데이트 로그 조회 불가') }
    if ($updateState -eq 'truncated') { [void]$limits.Add('업데이트 로그 일부만 수집') }
    if ($diskStatus -eq '미확인') { [void]$limits.Add('저장장치 상태 미확인') }
    if (-not $diskComplete) { [void]$limits.Add('저장장치 수집 완전성 미확인') }
    if ($limits.Count -eq 0) { [void]$limits.Add('검사 범위 밖의 원인은 확인되지 않음') }
    $questions = @(
        '중요 파일 백업을 먼저 해야 하는 상태인가요?',
        '장치 검사로 고장 원인을 추가 확인할 방법은 무엇인가요?',
        '교체를 권한다면 측정 근거와 예상 비용은 무엇인가요?'
    )
    [pscustomobject]@{
        schemaVersion=1
        title='PC 점검·수리 상담 요약'
        generatedAt=$generated
        windowsBuild=$build
        productVersion='AXMART PC CARE 0.1.0-alpha'
        assessment=$assessment
        storageSignal=$diskStatus
        recordedEvents=@($entries.ToArray())
        reviewItems=@($reviewItems.ToArray())
        limitations=@($limits.ToArray())
        consultationQuestions=$questions
        advice='중요 파일을 별도 물리 저장장치에 먼저 백업하고, 위험한 쓰기 복구 명령을 실행하기 전에 추가 진단을 요청하세요.'
        timeBasis='이벤트 기록 시각(UTC), 실제 장애 발생 시각 확정 아님'
        provenance='Windows에서 읽은 제한적 관측값을 요약했으며 공식 인증·원인 판정·수리 보증이 아닙니다.'
        containsIdentifiers=$false
    }
}
