/* AXMART PC CARE: client-only, opt-in consultation summary; never authorizes repair. */
(function (root) {
  'use strict';
  const STATES = new Set(['위험 신호', '주의 필요', '확인 불완전', '관찰 범위 내 특이사항 없음']);
  const STORAGE = new Set(['경고 신호 관측', 'Windows 정상 신호 (보증 아님)', '미확인']);
  const CODES = new Set([
    '저장장치 상태 경고', '저장장치 관련 이벤트', '저장 공간 매우 부족', '저장 공간 부족',
    'BugCheck 관련 기록', '비정상 종료 신호', 'Windows 업데이트 설치 실패 기록', '장치 구성 코드 점검'
  ]);
  const EVENTS = new Set([7, 19, 20, 41, 51, 55, 129, 153, 157, 1001, 6008]);
  const MAX_BYTES = 2000000;
  const isObject = value => !!value && typeof value === 'object' && !Array.isArray(value);
  function rejected() { throw new Error('지원되지 않거나 검증되지 않은 진단 JSON입니다. 원본을 수정하지 않았습니다.'); }
  function validUtcMinute(value) {
    if (typeof value !== 'string' || !/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$/.test(value)) return false;
    const [year, month, day, hour, minute] = value.match(/\d+/g).map(Number);
    if (year < 2000 || year > 2100 || month < 1 || month > 12 || hour > 23 || minute > 59) return false;
    const d = new Date(Date.UTC(year, month - 1, day, hour, minute));
    return d.getUTCFullYear() === year && d.getUTCMonth() === month - 1 && d.getUTCDate() === day;
  }
  function model(raw) {
    if (typeof raw !== 'string' || new TextEncoder().encode(raw).length > MAX_BYTES) rejected();
    let report;
    try { report = JSON.parse(raw); } catch (_) { rejected(); }
    if (!isObject(report) || report.schemaVersion !== 1 || report.product !== 'AXMART PC CARE' || report.mode !== 'read-only') rejected();
    const c = report.consultation;
    if (!isObject(c) || c.schemaVersion !== 1 || c.containsIdentifiers !== false ||
        !STATES.has(c.assessment) || report.assessment !== c.assessment || !STORAGE.has(c.storageSignal) ||
        !Array.isArray(c.reviewItems) || c.reviewItems.length > 12 ||
        !c.reviewItems.every(x => typeof x === 'string' && CODES.has(x)) ||
        !Array.isArray(c.recordedEvents) || c.recordedEvents.length > 4) rejected();
    const build = typeof c.windowsBuild === 'string' && /^\d{4,6}$/.test(c.windowsBuild) ? c.windowsBuild : '미확인';
    const records = [];
    for (const event of c.recordedEvents) {
      if (!isObject(event) || !Number.isInteger(event.eventId) || !EVENTS.has(event.eventId) ||
          !validUtcMinute(event.recordedUtc)) rejected();
      records.push('이벤트 ' + event.eventId + ' · 기록 UTC ' + event.recordedUtc);
    }
    const statuses = isObject(report.observations) && isObject(report.observations.collectionStatus)
      ? report.observations.collectionStatus : null;
    const diskCollected = !!statuses && statuses.physicalDisks === 'collected';
    // Never let a partial collector or contradictory warning appear clean.
    // This output is evidence review only, not a diagnostic reclassification
    // that can authorize recovery or device writes.
    const statusLabel = c.assessment === '관찰 범위 내 특이사항 없음'
      ? ((!diskCollected || c.storageSignal === '미확인') ? '확인 불완전 (저장장치 수집/상태 미확인)'
        : (c.storageSignal === '경고 신호 관측' || c.reviewItems.length > 0)
          ? '주의 필요 (상충하는 경고 근거의 재검토 필요)'
          : c.assessment)
      : c.assessment;
    const lines = [
      'AXMART PC CARE · 상담용 검토 초안', '검토 보류 / 수리·백업 승인 아님',
      '현재 판정: ' + statusLabel, '저장장치 관측: ' + c.storageSignal,
      'Windows 빌드: ' + build, '진단 도구 작성 진본성: 미검증',
      '근거 코드: ' + ([...new Set(c.reviewItems)].join(' / ') || '표시 가능 항목 없음'),
      '기록 시각: ' + (records.join(' / ') || '확인할 기록 없음'),
      '주의: 이벤트 기록 시각은 실제 장애 발생 시각이나 원인을 증명하지 않습니다.',
      '질문 1. 중요 파일의 별도 저장장치 백업·복원 가능성을 확인했나요?',
      '질문 2. 증상과 측정 근거를 어떤 방법으로 추가 확인하나요?',
      '질문 3. 부품 교체를 제안한다면 비용·대안·재검사 기준은 무엇인가요?',
      '읽은 원본의 경로·로그 메시지·시리얼·계정 정보는 이 화면에 표시하지 않습니다.',
      '인쇄 또는 전달 전 화면 내용을 직접 확인하세요. 자동 전송·저장·수리 없음.'
    ];
    return Object.freeze({lines: Object.freeze(lines), status: 'REVIEW_HOLD', authorized: false});
  }
  function bind(doc, win) {
    const fileInput = doc.getElementById('case-file');
    const analyze = doc.getElementById('case-analyze');
    const print = doc.getElementById('case-print');
    const output = doc.getElementById('case-output');
    const sheet = doc.getElementById('case-print-sheet');
    let revision = 0;
    function reset() {
      revision++;
      print.disabled = true;
      sheet.textContent = '';
      output.textContent = '선택한 JSON을 검토하기 전에는 아무 내용도 출력하지 않습니다.';
    }
    fileInput.addEventListener('change', reset);
    analyze.addEventListener('click', async () => {
      const current = ++revision;
      print.disabled = true;
      sheet.textContent = '';
      const file = fileInput.files && fileInput.files[0];
      if (!file || file.size <= 0 || file.size > MAX_BYTES || !/\.json$/i.test(file.name)) {
        output.textContent = '2MB 이하 진단 JSON 파일 하나를 명시적으로 선택하세요.';
        return;
      }
      output.textContent = '선택 파일을 로컬 메모리에서 확인 중입니다.';
      try {
        const raw = await file.text();
        if (current !== revision) return;
        const checked = model(raw);
        if (current !== revision) return;
        const summary = checked.lines.join('\n');
        output.textContent = summary;
        sheet.textContent = summary;
        print.disabled = false;
      } catch (_) {
        if (current !== revision) return;
        output.textContent = '검토 실패: 지원 형식·수집 상태를 확인하세요. 진단 원본은 보존됩니다.';
      }
    });
    print.addEventListener('click', () => { if (!print.disabled) win.print(); });
    reset();
  }
  const api = Object.freeze({model, bind, validUtcMinute, MAX_BYTES});
  if (typeof module !== 'undefined' && module.exports) module.exports = api;
  if (typeof document !== 'undefined' && document.getElementById('case-file')) bind(document, root);
})(typeof window !== 'undefined' ? window : globalThis);
