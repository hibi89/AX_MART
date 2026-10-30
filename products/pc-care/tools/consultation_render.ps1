# AXMART PC CARE - self-contained HTML for a privacy-reduced consultation print view.
# Pure function: no disk, network, repair or print invocation.
function ConvertTo-PcCareConsultationHtml {
    [CmdletBinding()]
    param([Parameter(Mandatory=$true)][object]$Summary)
    function Encode-Consultation([object]$Value) {
        return [System.Net.WebUtility]::HtmlEncode([string]$Value)
    }
    $issueRows = New-Object 'System.Collections.Generic.List[string]'
    foreach ($item in @($Summary.reviewItems | Select-Object -First 4)) {
        if ($null -eq $item) { continue }
        [void]$issueRows.Add(('<li>{0}</li>' -f (Encode-Consultation $item)))
    }
    if ($issueRows.Count -eq 0) {
        [void]$issueRows.Add('<li>명확한 위험 신호가 없거나 확인 가능한 정보가 부족합니다.</li>')
    }
    $eventRows = New-Object 'System.Collections.Generic.List[string]'
    foreach ($event in @($Summary.recordedEvents | Select-Object -First 4)) {
        if ($null -eq $event) { continue }
        [void]$eventRows.Add(('<tr><td>{0} UTC</td><td>{1}</td><td>{2}</td></tr>' -f (Encode-Consultation $event.recordedUtc),(Encode-Consultation $event.eventId),(Encode-Consultation $event.label)))
    }
    if ($eventRows.Count -eq 0) {
        [void]$eventRows.Add('<tr><td colspan="3">표시할 기록이 없습니다. 로그 조회 불가 여부도 확인해야 합니다.</td></tr>')
    }
    $questions = New-Object 'System.Collections.Generic.List[string]'
    foreach ($item in @($Summary.consultationQuestions | Select-Object -First 3)) {
        if ($null -eq $item) { continue }
        [void]$questions.Add(('<li>{0}</li>' -f (Encode-Consultation $item)))
    }
    $limits = New-Object 'System.Collections.Generic.List[string]'
    foreach ($item in @($Summary.limitations | Select-Object -First 4)) {
        if ($null -eq $item) { continue }
        [void]$limits.Add(('<li>{0}</li>' -f (Encode-Consultation $item)))
    }
    $html = @"
<section id="consultation-print" class="consult-sheet" aria-labelledby="consult-title">
  <div class="consult-top"><div class="consult-mark">AXMART <b>PC CARE</b></div><div class="consult-version">$(Encode-Consultation $Summary.productVersion) / 상담 참고용</div></div>
  <h2 id="consult-title">PC 점검 · 수리 상담 요약</h2>
  <p class="consult-disclaimer">검사기 자동 생성 참고자료 · 공식 인증서가 아니며 특정 부품 고장/교체 필요를 확정하지 않습니다.</p>
  <div class="consult-facts"><div><span>검사 기록</span><strong>$(Encode-Consultation $Summary.generatedAt)</strong></div><div><span>Windows 빌드</span><strong>$(Encode-Consultation $Summary.windowsBuild)</strong></div><div><span>검사 판단</span><strong>$(Encode-Consultation $Summary.assessment)</strong></div><div><span>저장장치 신호</span><strong>$(Encode-Consultation $Summary.storageSignal)</strong></div></div>
  <div class="consult-symptom"><b>증상 메모</b> (사용자가 직접 기입): ______________________________________________</div>
  <div class="consult-group"><h3>1. 확인할 관측 신호</h3><ul>$($issueRows -join [Environment]::NewLine)</ul></div>
  <div class="consult-group"><h3>2. 최근 주요 이벤트 기록 (최대 4건)</h3><table class="consult-table"><thead><tr><th>기록 시각</th><th>Event ID</th><th>분류</th></tr></thead><tbody>$($eventRows -join [Environment]::NewLine)</tbody></table><p class="consult-hint">$(Encode-Consultation $Summary.timeBasis)</p></div>
  <div class="consult-group"><h3>3. 우선 권장사항</h3><p>$(Encode-Consultation $Summary.advice)</p></div>
  <div class="consult-group"><h3>4. 수리점 상담 질문</h3><ol>$($questions -join [Environment]::NewLine)</ol></div>
  <div class="consult-group"><h3>5. 검사 한계</h3><ul>$($limits -join [Environment]::NewLine)</ul></div>
  <div class="consult-bottom">$(Encode-Consultation $Summary.provenance) 원문 이벤트/장치명/일련번호/개인 경로는 이 상담표에 싣지 않습니다.</div>
</section>
"@
    return $html
}
