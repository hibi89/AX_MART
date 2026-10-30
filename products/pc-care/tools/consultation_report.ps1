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
    foreach ($item in (@($observations.eventEvidence) + @($observations.windowsUpdate.evidence))) {
        if ($null -eq $item) { continue }
        $label = ''
        $kind = [string]$item.kind
        $id = -1
        try { $id = [int]$item.eventId } catch { continue }
        if ($kind -eq 'bugcheck_record' -and $id -eq 1001) { $label='BugCheck 기록' }
        elseif ($kind -eq 'shutdown_signal' -and $id -in @(41,6008)) { $label='비정상 종료 신호' }
        elseif ($kind -eq 'storage_signal' -and $id -in @(7,51,55,129,153,157)) { $label='저장장치 신호' }
        elseif ($kind -eq 'update_installation_failure_record' -and $id -eq 20) { $label='업데이트 설치 실패 기록' }
        elseif ($kind -eq 'update_installation_success_record' -and $id -eq 19) { $label='업데이트 설치 성공 기록' }
        else { continue }
        try {
            $when = [datetimeoffset]::Parse([string]$item.recordedUtc, [Globalization.CultureInfo]::InvariantCulture).ToUniversalTime()
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
    $diskItems = @($observations.physicalDisks | Where-Object { $null -ne $_ })
    if (@($diskItems | Where-Object { $_.status -in @('Warning','Unhealthy') }).Count -gt 0) {
        $diskStatus = '경고 신호 관측'
    } elseif ($diskItems.Count -gt 0 -and @($diskItems | Where-Object { $_.status -ne 'Healthy' }).Count -eq 0) {
        $diskStatus = 'Windows 정상 신호 (보증 아님)'
    }
    $limits = New-Object 'System.Collections.Generic.List[string]'
    if ($eventState -eq 'unavailable') { [void]$limits.Add('System 로그 조회 불가') }
    if ($eventState -eq 'truncated') { [void]$limits.Add('System 로그 일부만 수집') }
    if ($updateState -eq 'unavailable') { [void]$limits.Add('업데이트 로그 조회 불가') }
    if ($updateState -eq 'truncated') { [void]$limits.Add('업데이트 로그 일부만 수집') }
    if ($diskStatus -eq '미확인') { [void]$limits.Add('저장장치 상태 미확인') }
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
