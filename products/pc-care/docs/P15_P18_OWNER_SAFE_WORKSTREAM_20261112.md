# AXMART PC CARE P15–P18: 오프라인 고객 진입·검수 보안, 목표 85% 검증 게이트 (2026-11-12 KST)

## 정본·범위·제약
- 저장소 PRIVATE `hibi89/AX_MART`, 원본 브랜치 `feature/pc-care-offline-casepack-20261111@9c25ec379899b7e982cba429acf4ef9d01b8ce6e` **미변경**.
- P15–P18 작업 브랜치 `feature/pc-care-p15-p18-85-20261112` 실제 코드 SHA **`c944b9e75575f8ddced103421edc9083eedb1c60`**, [Draft PR #1](https://github.com/hibi89/AX_MART/pull/1) **미병합**.
- 제품 전체 FINAL_SPEC_V2 (HEALTH+ANALYZE+REPORT+RESCUE+RECOVER+QA) 원래 100점 기준 유지. 원본 개발공정 baseline 70%, 이번 검증 가능 신규 기능 가중 +10%p → **80% 잠정 기술범위**, 목표 85%는 **미달**. 100%=실고객/출시 기능 및 실제 WinRE/안전성 검증을 포함. 출시 `RELEASE HOLD`, 무료 배포·결제·웹사이트 프로덕션 변경 금지.
- 설계 비교 A: WinRE/BitLocker/Robocopy 실제 선택파일 복사와 수리 엔진 즉시 확대 → 실기기·스냅샷/중단/디스크 식별 증거가 없어 원본 파손·보안 위험, 검증 비용 큼. B: 기존 복구/수리·USB를 보존하고 로컬 고객 진입점, 검수 fail-closed, 경로/JSON 개인정보 경계, 독립 테스트 확대 → 무과금, 낮은 유지보수 위험, 즉시 코드 리뷰와 로컬 검증 가능. **B 채택**. 실 WinRE 백업/변경 작업은 안전성 증명 전 차단.

## 구현·검증 가능한 신규 작업 (P15–P18)
1. **P15 +3%p**: `START_PC_CARE.cmd`의 메뉴 6에 읽기 전용 `ui/case_review.html`, 메뉴 7에 오프라인 `ui/recovery_readiness.html`를 연결. 메뉴 8이 안전 종료, 기존 1–5 보존. 새 카드 독립 HTML/CSP·A4 인쇄 스타일·수동 점검 체크박스, JavaScript/CDN/서버/자동 수리/외부 통신/원본 스캔 없음. 실제 A4 크기/브라우저 파일 처리·프린터는 미검증.
2. **P16 +3%p**: Python 개발용 `casepack.py` 및 배포 기존 browser `case_review.js`에서 **원본 판정이 깨끗해도 디스크 수집 불완전 또는 storageSignal=미확인 시 '확인 불완전', 수집 완료여도 경고 신호/검토 코드가 있으면 '주의 필요'로 강등**. 원본 raw JSON 변경 없음, 최종 상태 `REVIEW_HOLD`·`repair_authorized=false`.
3. **P17 +2%p**: Python 개발 상담 패킷 `reject_untrusted_local_path`로 UNC/Windows mapped network/비고정 드라이브, 알려진 OneDrive/Dropbox/Google Drive/iCloud/Box sync, symlink·Windows reparse/junction 경로 차단. 고유 폴더+파일 독점 생성, 기존 원본 덮어쓰기 차단 유지. JSON 중복 키·bool schema·비문자열 assessment/storageSignal를 거부. 모든 서드파티 sync/TOCTOU 완전 방어 또는 개인정보 적법성 인증은 아님. 고객 배포 ZIP에는 Python 도구 미포함.
4. **P18 +2%p**: 2개 고객 화면을 내부 테스트 ZIP allowlist에 포함, 기존 `test_package.py` 메뉴 검사·`test_release.py` 번들 상속 회귀 수정. `test_owner_readiness_p15.py` 5개 정적 Python 테스트/기존 `test_casepack.py`·Node `test_case_review.cjs`에 부정 시나리오 추가. API 비용·설치·외부 데이터 0. **실제 원본 전체 테스트 실행 없이 신규 테스트가 합격했다고 표시하지 않음.**

## 실행한 검증과 정확 범위
- GitHub 도구로 **최신 기능 브랜치의 정확한 원격 파일** 9개 Git blob을 다시 읽어 source/menu/privacy/ZIP 경계의 독립 JavaScript 정적 계약 **62/62 PASS**. GitHub JS 파일 `ui/case_review.js` 격리 V8 모델/모의 파일 입력 **19/19 PASS(이전 동일 작업 중 source SHA)**, 최종 최신 JS SHA `d8726c1a059e5445bb0ac8f53c6643b413a7cb8c`에서 위험 판정 6/6 PASS. **실제 Node `node --test`나 Windows Edge를 실행한 것이 아님**.
- Python3.13.5 오프라인 격리 **동일 설계를 발췌 재구성한 경로/판정 로직** 18/18 PASS. 이것은 **GitHub 전체 `tools/casepack.py` 바이트 동일성/전체 Python unittest의 실행 증거가 아니므로 85% 증빙으로 취급하지 않음**.
- 과거 전체 Windows PowerShell 5.1/QA 내부 ZIP/Node 117/Python79+3SKIP는 **2026-10-31 이전 기능 SHA**에서 통과한 역사이며 이 P15–P18 소스에 재적용 주장 금지.
- 현재 `.github/workflows/pc-care-windows-synthetic.yml`는 최초 #41034866482에서 runner 할당 전 FAIL 후 자동 실행 중지·workflow_dispatch로 유지(비용/권한/러너 상태 미확인). **새 작업 SHA에 대해 GitHub CI/Windows PowerShell 5.1, full Python/Node source regression, 실제 ZIP 빌드·SHA, USB·WinRE·QR 카메라·A4 인쇄/복구, Prod 실행 모두 미실행/미검증**. 실 장비 사용자 원본 복사·수리 금지, 부품 손상 복구 보장 금지.

## 남은 85% 목표 (+5p; 승인·기술 게이트)
- **P19 +5pp 조건부:** Windows10/11 정상 사용자 실제 실행 전에, 승인된 무료/포함 할당량 또는 사용자의 **완전한 기존 로컬 Git 체크아웃**에서 `RUN_RELEASE_QA.cmd`/정확 소스 Python `python -m unittest discover -s tests -p "test_*.py" -v`/Node `node --test tests/test_case_review.cjs`/PS5.1 `tests/windows_smoke.ps1`, 내부 ZIP `tools/release.py --internal-testing` 생성·`--verify`가 모두 현재 SHA에서 PASS이고 Windows 정상 동작 계약을 검증해야 기술 진척 85로 올릴 수 있다. 유료 Actions 사용량·결제 수단 변경, 라이브 고객 진단·복구·보안 권한·원본 수정·상업 배포는 사전 승인 없이는 수행하지 않는다.
- 실제 Edge file://·USB 한글/공백 경로·QR 스마트폰·A4 PDF·WinRE 및 BitLocker 복구/Robocopy/실데이터 파일 백업·실수리와 물리 고객 실기기/라이선스/서명/지원은 **85 이후도 미검증·RELEASE HOLD**, 고객 구매자에게 자동 해결/파일 구출 성공 보증 금지.

## 실행/복구
- 기존 제품 개발용 단일 QA: 소스 루트 `products/pc-care/`에서 `RUN_RELEASE_QA.cmd`(Windows cmd). 실패해도 real diagnose/repair 실행하지 않는다는 원본 계약을 유지.
- 단일 Node 예제: `node --test products/pc-care/tests/test_case_review.cjs` (repo root).
- Python: `python -m unittest discover -s products/pc-care/tests -p "test_*.py" -v`.
- 보안 판정·복구 절차 문서: `products/pc-care/docs/FINAL_SPEC_V2.md`, `docs/SAFETY.md`, `docs/WINDOWS_TEST_PLAN.md`.
- 이전 기준 `feature/pc-care-offline-casepack-20261111@9c25ec379899b7e982cba429acf4ef9d01b8ce6e` 원본을 변경하지 않아 브랜치 전환/PR 닫기로 코드 롤백 가능. `main`/Cloudflare `https://ax-mart.pages.dev` 무변경.
