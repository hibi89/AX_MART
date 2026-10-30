# AXMART PC CARE - consent-ready QR TEXT payload, not a QR image encoder.
# Pure PowerShell 5.1 helper. Uses only fixed labels and validated event time/ID.
# Fails closed above 250 UTF-8 bytes; never silently clips text.
function Get-PcCareSharePayload {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][object]$Summary,
        [ValidateRange(1,250)][int]$MaxUtf8Bytes = 250
    )
    $status = [string]$Summary.assessment
    if ($status -notin @('위험 신호','주의 필요','확인 불완전','관찰 범위 내 특이사항 없음')) {
        $status = '확인 불완전'
    }
    # Whitelisted short tokens only. Never include free-text issue explanations.
    $signalMap = @{
        '저장장치 상태 경고'='저장장치'
        '저장장치 관련 이벤트'='저장장치'
        '저장 공간 매우 부족'='공간부족'
        '저장 공간 부족'='공간부족'
        'BugCheck 관련 기록'='블루스크린기록'
        '비정상 종료 신호'='비정상종료'
        'Windows 업데이트 설치 실패 기록'='업데이트실패'
        '장치 구성 코드 점검'='장치상태'
    }
    $signals = New-Object 'System.Collections.Generic.List[string]'
    foreach ($item in @($Summary.reviewItems)) {
        $label = [string]$item
        if (-not $signalMap.ContainsKey($label)) { continue }
        $tag = [string]$signalMap[$label]
        if (-not $signals.Contains($tag)) { [void]$signals.Add($tag) }
    }
    $signalLine = '미확인'
    $omitted = 0
    if ($signals.Count -gt 0) {
        $chosen = @($signals.ToArray() | Select-Object -First 2)
        $omitted = [math]::Max(0, ($signals.Count - 2))
        $signalLine = $chosen -join ','
        if ($omitted -gt 0) { $signalLine += (' 외 {0}종' -f $omitted) }
    }
    # Re-validate event from the reduced consultation model, not raw logs.
    $record = '미확인'
    foreach ($ev in @($Summary.recordedEvents | Select-Object -First 4)) {
        if ($null -eq $ev) { continue }
        $id = -1
        try { $id = [int]$ev.eventId } catch { continue }
        if ($id -notin @(19,20,41,6008,1001,7,51,55,129,153,157)) { continue }
        $value = [string]$ev.recordedUtc
        if ($value -notmatch '^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$') { continue }
        try {
            [void][datetime]::ParseExact($value, 'yyyy-MM-dd HH:mm', [Globalization.CultureInfo]::InvariantCulture)
        } catch { continue }
        $record = $value
        break
    }
    $lines = @(
        'AXMART PC CARE'
        ('상태:' + $status)
        ('신호:' + $signalLine)
        ('기록UTC:' + $record)
        '시각:로그기록/사고시간아님'
        '원인:미확정'
        '권고:백업후추가점검'
    )
    $payload = [string]::Join([string][char]10, [string[]]$lines)
    $byteCount = [System.Text.Encoding]::UTF8.GetByteCount($payload)
    $valid = ($byteCount -le $MaxUtf8Bytes)
    $payloadStatus = if ($valid) { 'ready' } else { 'too_large' }
    $payloadSafe = if ($valid) { $payload } else { $null }
    [pscustomobject]@{
        schemaVersion = 1
        status = $payloadStatus
        payloadText = $payloadSafe
        byteCount = [int]$byteCount
        maxUtf8Bytes = $MaxUtf8Bytes
        signalCount = [int]$signals.Count
        omittedSignals = [int]$omitted
        qrImageGenerated = $false
        containsIdentifiers = $false
        disclosure = 'QR 또는 공유 텍스트는 촬영/복사한 사람이 읽을 수 있습니다. 생성·복사·공유는 사용자가 선택합니다.'
    }
}
