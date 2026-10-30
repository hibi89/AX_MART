# AXMART PC CARE — NEXT CHAT / AX_MART 총괄 인수인계

**작성 기준:** 2026-10-30 KST  
**제품 개발 저장소:** `hibi89/AX_MART`  
**이 문서 브랜치:** `feature/pc-care-usb`  
**변경 전 정확한 브랜치 HEAD:** `625e65da7da001c1a9e75013a547ae0ad3bd9477`  
**운영 사이트 브랜치:** `main` (현재 브랜치와 분리)

## 반드시 먼저 읽을 기준 파일
1. [최종 기능·보안·시장 포지셔닝 설계](products/pc-care/docs/FINAL_SPEC_V2.md): Gemini 의견 두 건을 통합한 **v2.0** 5대 모듈·스택·수용 기준·로드맵.
2. [제품 현재 상태](products/pc-care/STATUS.md) 및 [이전 작업 이력](products/pc-care/HANDOFF.md).
3. [제품 실행법·제약](products/pc-care/README.md), [Windows 테스트 계획](products/pc-care/docs/WINDOWS_TEST_PLAN.md), [안전 원칙](products/pc-care/docs/SAFETY.md).
4. 사이트 브랜드 정의는 `main`의 `BRAND_GUIDE.md`; **AXMART³ (AXMART CUBE)**는 사이트/플랫폼, **AXMART PC CARE**는 첫 제품이다. 'USB'는 사용 방식/내부 파일명일 뿐 소비자용 제품명 아님.

## 사용자 합의와 최종 제품상
- 사용자가 확정한 시안: 다크 퍼플·민트 미래형 PC 상태 대시보드/USB 포터블. 사이트 `main`의 디자인 프리뷰는 완성품이 아닌 가상 시안.
- 제품의 가치: 근거 있는 PC 상태 진단 -> 블루스크린/저장장치/업데이트 사건 연계 -> 사용자가 이해할 한국어 원인 후보·한계 -> 수리점 제출용 1페이지 Print/PDF + 오프라인 QR -> 백업/수리 의사결정 및 제한적 복구.
- 기술: Windows PowerShell 5.1 + CMD + 자급식 로컬 HTML/CSS/JS + JSON. 기본 비관리자·오프라인·로컬 보고서; 시스템 변경은 별도 관리자·백업·두 단계 명시적 승인.
- 첫째 Gemini 안의 1페이지 보고서/WinRE 사용자 파일 백업 지원, 둘째 안의 QR 요약/Windows 최신 복구 가이드 및 중립적 수리점 체크리스트를 안전하게 결합했다.
- **Release A:** 건강진단·증거 분석·1페이지 인쇄/PDF·QR·이력 및 **WinRE 읽기 전용** 안내/진단. 검증 후 무료 베타.
- **Release B:** 잠김/암호화/물리 디스크 분리/용량/복사 완전성/중단/부분 실패 등 독립 안전 시험을 통과한 경우에만 WinRE 선택 파일 백업 공개. Release B가 미검증이면 백업 기능을 완성·출시했다고 표시하지 않는다.

## 실제 코드가 있는 것 (Windows 실행 성공과 별개)
- `products/pc-care/RUN_HEALTH_CHECK.cmd`, `tools/diagnose.ps1`: Windows OS/드라이브/저장장치/Defender/일부 이벤트·BugCheck 수집 후 HTML/JSON 보고서 생성 코드.
- `RUN_SAFE_REPAIR.cmd`, `tools/repair.ps1`: 관리자 권한, 디스크 상태 확인, BACKUP/REPAIR 입력 후 DISM/SFC 제한 실행 경로.
- `recovery/WINRE_READ_ONLY.cmd`: WinRE 수동 읽기 전용 Windows 설치·BitLocker·BCD/덤프 존재 여부 점검 보조.
- `RUN_SELF_TEST.cmd`, `tests/windows_smoke.ps1`: PowerShell 문법 및 읽기 전용 진단 수동 Windows 테스트 진입점.
- `tools/release.py`, `tests/test_release.py`: 사용자 데이터 제외 허용 목록·해시 검증·내부 시험 ZIP, 과거 Python fixture 테스트 6/6 PASS 보고.
- 제품 브랜치의 기존 소스 및 기능 상태는 GitHub 파일에서 다시 검증. 위 설명은 **코드 존재**만 의미함.

## 현재 미구현·미검증 (주장 금지)
- Windows 10/11 실제 실행, 관리자/표준 권한 실기기, WinRE/BitLocker, DISM/SFC 복구 안전성 및 오류 분석 정확도 **미검증**.
- 사건 중복 제거·시간축 상관관계, 업데이트/배터리 추가 수집·이력, 사용자가 선택한 다크 테크 정식 Windows UI, 인쇄/PDF 전용 1페이지, QR 생성, WinRE 복사/확인 기능 **미구현**.
- 운영 URL `https://ax-mart.pages.dev/`는 이미 존재. Cloudflare `main`의 최근 리브랜딩 소스가 실제 Production에 반영됐는지/새 SHA로 배포됐는지는 별도 확인 필요.
- 미검증 USB ZIP **공개 배포·판매 금지**, Cloudflare/main의 판매·다운로드 차단 유지. WinRE 자체 부팅 이미지나 Microsoft 소유 WinPE 이미지 포함 금지.

## 다음 채팅 첫 작업: P0 (묻지 말고 가능한 범위에서 바로 진행)
1. `feature/pc-care-usb` 최신 HEAD와 `FINAL_SPEC_V2.md`, 현재 `tools/diagnose.ps1`·테스트 확인.
2. PowerShell 5.1 문법 및 수집 예외 처리 강화: 접근 거부, 저장장치 API/이벤트 없음, 장치 없는 컴퓨터, 잘린 로그, 보고서 저장 실패를 구분. 기본 진단에서 관리자 자동승격 금지.
3. 분석 엔진의 **테스트 가능한 사건 공통 스키마**·로그 중복/시각 처리 규칙 마련 및 fixture 테스트. BugCheck 1001 시각≠크래시 발생 시각; 이벤트 41≠확정 BSOD.
4. `@media print` 1페이지 수리점 요약에 필요한 최소 정보 모델·안전한 HTML 인코딩을 설계/구현하고, 오프라인 개인정보 최소 QR은 분리 구현.
5. Windows 실제 실행 접근이 가능할 때 `RUN_SELF_TEST.cmd`로 read-only 진단 테스트 후 결과로 버그 수정. 실기기 없이 **Windows PASS 주장 금지**.
6. WinRE 파일 복사는 검증 가능한 별도 디스크/BitLocker/파일시스템/용량/실패·중단 안전장치 구현 전에는 시작하지 않음. 어떠한 자동 복구/파일 삭제/잠금 해제도 실행하지 않음.
7. 기능 단위로 커밋/푸시, 작업 결과는 PASS/미실행/실패를 구분, `STATUS.md`와 `HANDOFF.md` 갱신. CI가 다음 구현의 의존성이 아니면 지연 없이 다음 기능 진행.

## 하드 세이프티 가드
- 읽기 전용이란 **원본 Windows 시스템/개인 데이터 비변경**이며 로컬 보고서는 생성할 수 있음.
- 물리 디스크 이상·불명·암호화된 볼륨 잠금이면 쓰기 복구/자동 파일 복사 차단. BitLocker 복구키 받거나 저장하지 않음.
- 다른 드라이브 문자만으로 물리적으로 다른 백업 대상이라고 간주 금지. Robocopy /MIR /PURGE /MOVE /MOV 등 파괴적 옵션 금지. 종료 코드 0~7도 온전한 백업 보증 아님, 8 이상은 실패 포함.
- 'SSD 수명 94%', '메인보드 교체 불필요', '수리비 사기 방지 인증', 'AI가 100% 복구' 등 검증 없는 문구 금지. QR에 사용자·장치 식별정보/원문 로그/경로/키 금지.
- 사용자 PC에 Windows 기본 설치된 것 외의 런타임/유료 API 필수화 금지, QR 외부 CDN 금지.

## 완료 판정과 시간
- 최종 설계 기준 개발+실기기 검증 총합 **77~135시간 추정**(검증 환경 확보 가정). Release A/B 분리이므로 이 추정이 납기 보증은 아니다.
- 실기기 Windows, WinRE, 보안·비상 백업 실패·재시작·장치 분리 등 게이트를 통과해야 무료 베타/상용 출시 검토 가능.

## 새 채팅방에서 사용하는 첫 메시지 예시
**“AX_MART 총괄, `feature/pc-care-usb`의 `NEXT_CHAT_PC_CARE.md`와 `products/pc-care/docs/FINAL_SPEC_V2.md` 읽고 P0부터 개발 이어가자. ㄱ”**

## 2026-10-30 KST — P0 후속 실행 기준 최신화

- 이전 P0 첫 작업 항목 중 이벤트 공통 스키마, 보수적 41/6008 그룹, 조회 실패/빈 조회/상한 분리, JSON/HTML 쌍 저장, 비관리자 권한 인식 코드는 개발 브랜치에 구현되었다. 코드 존재와 Windows 실행 검증 완료는 별개.
- 수정한 회귀 결함: 내부 시험 ZIP이 synthetic fixture를 누락한 문제, 옛 Python 테스트의 NoMatchingEventsFound 경로 오류. 신규 event_analysis.tests.ps1은 내부 ZIP에 포함. MaxEvents 상한·UTC 테스트·ReliabilityCounter 상태 구분도 추가했다.
- 실제 확인: GitHub 소스 교차 정적 계약 점검 35/35. Python unittest/PowerShell parser/Windows 10·11·WinRE/USB 저장 실패·복구 실제 실행은 여전히 미검증.
- 다음 ㄱ은 먼저 해당 제품 브랜치의 HEAD를 확인한 뒤, Windows 검증 실행이 가능한 도구/기기를 확보하면 test_package.py, test_release.py, RUN_SELF_TEST.cmd의 명령과 결과를 기록. 다른 독립 소스 개선은 위 게이트가 필요 없는 범위로만 진행.
- 상세 현재 상태와 10항 인수인계는 products/pc-care/STATUS.md 및 HANDOFF.md 최신 섹션, 테스트 표는 docs/WINDOWS_TEST_PLAN.md 참조. main/Cloudflare는 미변경이고 공개 다운로드·결제 금지 유지.

## 2026-10-30 KST — P1 driver/timeline continuation checkpoint

- AXMART PC CARE 개발 브랜치는 feature/pc-care-usb, 최종 목표는 products/pc-care/docs/FINAL_SPEC_V2.md. 기존 운영 main/Cloudflare 배포 무변경.
- 신규 modules: tools/pnp_analysis.ps1 (Win32_PnPEntity ConfigManagerErrorCode, 코드 22와 오류 분리, 장치 이름/ID 비저장) 및 tools/recorded_timeline.ps1 (시스템/업데이트 기록 시간의 UTC/15분 윈도우/최신 80건, 원인 비확정). diagnose.ps1 JSON/HTML 및 incident_analysis.ps1 연동. tests/driver_timeline.tests.ps1, windows_smoke.ps1, internal ZIP/test release 참조 추가.
- 마지막 정적 소스 검사 37/37 조건 충족, Windows/PowerShell 실제 테스트·Python unittest/ZIP 실행은 아직 없음. STATUS.md/HANDOFF.md 최신 항목 참조.
- 다음 작업은 Windows 11 PS5.1 및 Python 테스트의 실측 가능 환경 우선 확인, 불가하면 P2 1페이지 Print/PDF 보고서의 안전한 정보 모델과 CSS 작업 진행. QR은 개인정보 최소·오프라인 스캔 실증 전 완성 표기 금지. WinRE 파일 복사/수리는 여전히 별도 게이트 전 금지.

## 2026-10-30 KST — P2 consultation A4 checkpoint

- Repo hibi89/AX_MART feature/pc-care-usb, main/Cloudflare production remains unchanged. Continue by reading products/pc-care/HANDOFF.md, STATUS.md, docs/FINAL_SPEC_V2.md and latest source.
- New pure helper tools/consultation_report.ps1 creates a bounded consultation summary from the read-only diagnostic report; tools/consultation_render.ps1 builds escaped local HTML. diagnose.ps1 adds consultation JSON key, screen section and dedicated CSS @page A4 / @media print for browser Ctrl+P -> Save as PDF. Up to 4 recorded UTC events, 4 issue types, 3 standard repair questions, no raw names/logs/paths.
- tests/consultation_report.tests.ps1 covers privacy, unknown data, recorded time, bounded output and HTML escaping. windows_smoke parses/runs fixture, internal ZIP/test_release/test_package source references updated. GitHub static contracts 37/37 checked, NOT Windows runtime or actual one-page PDF verified.
- Windows real-device parser/synthetic tests and print preview remain release blockers; QR remains unimplemented. No public ZIP/free download or Kmong services until gates pass. AXMART³ free software/Kmong paid interpretation service is a business proposal, not an active listing.
- Next ㄱ: actual Windows tests if runtime exists; otherwise continue with safe opt-in local share-text preview/QR payload model (not yet QR bitmap or final implementation), or print accessibility improvements. Do not call CSS one-page verified without browser PDF evidence.

## 2026-10-30 KST — QR share-text P2 continuation checkpoint

- hibi89/AX_MART `feature/pc-care-usb` only. AXMART³ main/Cloudflare must remain unchanged; no free/paid downloads yet.
- New pure PS5.1 modules `products/pc-care/tools/share_payload.ps1` (whitelist-only summary, 250 UTF-8 bytes cap, no device IDs/log messages, no silent clipping) and `share_preview.ps1` (`details` opt-in local preview, manual select+Ctrl+C). `diagnose.ps1` includes metadata-only `sharePreview` in JSON and a preview section in offline HTML. No QR image, no cloud, no automatic clipboard copying.
- New `tests/share_payload.tests.ps1`, Windows smoke parser/fixture, internal ZIP and Python static/release tests. Static GitHub source check 40/40 conditions satisfied but PowerShell/Windows/Python/ZIP/QR scan tests have NOT run.
- Next work: acquire actual Windows 11 PS5.1 test execution / run fixtures if possible; choose small permissively licensed local QR encoder and verify physical scanning of generated Korean UTF8 codes. Offline encoder plus opt-in QR generation is necessary before calling QR complete. Continue P2 UI/PDF accessibility while Windows or CI wait; do not begin unsafe WinRE copy/repair.

## 2026-10-30 KST — QR bitmap implementation checkpoint

- hibi89/AX_MART `feature/pc-care-usb` only. Production main/Cloudflare untouched, public/free beta/Kmong listings blocked until actual QA.
- Added offline, opt-in QR **image generation source**: `products/pc-care/ui/qrcode.min.js` (MIT, copyright davidshimjs), `ui/QR_CODE_LICENSE.txt`, `ui/qr_ui.js`. `tools/share_preview.ps1` displays generate button ONLY when verified local JS+license exist; `tools/diagnose.ps1` embeds local QR library, full MIT license and UI JS into the saved HTML; user explicitly clicks to encode the allowlisted 250-byte Korean UTF-8 share text. No network/CDN/auto generation/upload; existing manual text copy remains. Missing library gives text-only fallback.
- Tests updated: `tests/share_payload.tests.ps1`, `tests/test_package.py`, `tests/test_release.py`, `tests/windows_smoke.ps1`; internal ZIP adds three UI files. GitHub static contract 40/40; Windows PS5.1/parser, Python unittest/ZIP build, QR actual image and Android/iOS scan NOT RUN. Docs/STATUS.md and HANDOFF.md have details.
- Next ㄱ: obtain actual Windows/browser/smartphone scan test if possible; otherwise continue P2 UI/accessibility/error-case hardening and safe test harness. Test offline behavior when original USB is removed, Korean UTF-8 payload, quiet zone, QR scan roundtrip and 250-byte limit before QR declared complete. WinRE file copy/repair remains gated.


## 2026-10-30 KST — CI runner unavailable; P2 UX navigation checkpoint

- AXMART PC CARE hibi89/AX_MART `feature/pc-care-usb` only; production main unchanged. Official spec `products/pc-care/docs/FINAL_SPEC_V2.md`; latest `STATUS.md` and `HANDOFF.md` authoritative.
- New `.github/workflows/pc-care-windows-synthetic.yml` would run Windows PS5.1 parser+synthetic fixtures and Python tests, no read-only diagnosis or repair. GitHub run **41034866482** failed before any step (runner_id=0, steps empty, 404 blob logs), so actual runtime tests **not executed**. Workflow turned manual-only (`workflow_dispatch`) to avoid repeated failures/costs on push.
- Improved `tools/diagnose.ps1` with keyboard skip link, ARIA quicknav, 7 in-page sections and responsive CSS. Existing print CSS hides all but A4 consultation; consent-gated QR unchanged. `tests/test_package.py` checks anchors across both diagnose + consultation renderer. Remote source static assertions **9/9** conditions, not runtime PASS.
- Next ㄱ: fix runner availability/billing/permissions if possible, otherwise push independent quality improvements and provide Windows self-test entrypoint. Run PS5.1 fixture + Python tests and scan actual QR/print A4 before release. Never treat unassigned CI job as product test result. No download/payment publication.

## 2026-10-30 KST — Trusted CMD launcher and Node QR runtime checkpoint

- Branch `hibi89/AX_MART feature/pc-care-usb` only. Protect AXMART³ Cloudflare production main. No public ZIP/paid listing.
- Three CMD entrypoints `products/pc-care/RUN_HEALTH_CHECK.cmd`, `RUN_SELF_TEST.cmd`, `RUN_SAFE_REPAIR.cmd` switched from PATH `powershell.exe` to quoted absolute Windows PowerShell 5.1 `%SystemRoot%\\System32\\WindowsPowerShell\\v1.0\\powershell.exe` and fail-closed on absence. Prevent accidental USB-directory binary search; repair approval gates unchanged.
- Local copied `ui/qr_ui.js` source matched GitHub by FNV32 **3087562328**; real Node v22.16.0 VM mock DOM tests **6/6 PASS** and `node --check` PASS. This does NOT prove browser QR render or phone scan. New `tests/test_qr_ui.cjs` with 10 built-in test cases committed, but not yet executed in CI. `tests/windows_smoke.ps1 -RunReadOnly` now verifies saved HTML/JSON privacy, A4, offline QR scripts/attribution; `tests/test_package.py` tests CMD safety.
- GitHub Action 41034866482 failed before runner assigned; workflow remains manual-only with Node QA step. Source checks **21/21**; actual Windows CMD/PowerShell, GitHub runner, Python full suite/ZIP, browser/A4/phone QR, WinRE still unverified. See STATUS.md, HANDOFF.md and docs/WINDOWS_TEST_PLAN.md.
- Next ㄱ: prioritize real Windows standard-user validation and issue fixes. Do not automatically run repair, overwrite reports, or publish free/paid downloads. Windows testing can be done from internal ZIP via RUN_SELF_TEST.cmd with no repair, but carefully review local logs before sharing.

## 2026-10-30 KST — QR stale-image fix / strict data validation

- hibi89/AX_MART `feature/pc-care-usb` only, main unchanged; no user beta/paid listings.
- `products/pc-care/ui/qr_ui.js` now clears previous QR on edits and before regeneration, rejects malformed or expanded arbitrary share strings by enforcing 7-line whitelist schema and <=250 UTF-8 bytes. `tests/test_qr_ui.cjs` has 17 synthetic tests; `tests/test_package.py` adds static coverage; `tests/qr_browser_smoke.py` optional real vendored QR/Chromium/OpenCV UTF-8 exact decode gate (not yet run; requires playwright + opencv + Chromium on developer machine).
- **Evidence:** Linux Chromium Playwright with fake QR constructor and exact current GitHub JS blob b0b06f527bed53f147e05e6512ee289608048de1: 13/13 real browser DOM/validation/network-mock checks passed. No actual QR library bitmap or phone scan verified. GitHub cross-file static 21/21. Windows/PS5.1/USB/ZIP/WinRE QA pending, GitHub Actions runner unassigned and manual-only.
- Next ㄱ: run real QR encoder scanner fixture in available developer environment or fix its failures, then Windows read-only self-test and A4 PDF/phone scans. Continue real code changes, preserve main, update docs, never claim Windows/QR decoder complete without evidence.

## 2026-10-30 KST — QR Gregorian dates and BOM compatibility checkpoint

- Branch `hibi89/AX_MART feature/pc-care-usb` only; production/main unchanged; no public ZIP or paid listing.
- `products/pc-care/ui/qr_ui.js` now checks real UTC calendar dates (Date.UTC round-trip), not regex alone. Exact GitHub blob `13faebe44753b73f2a1cf9c99308aab220745276` used in local Chromium mocked QR UI tests **20/20 PASS**; Node --check PASS. QR schema seven fields and stale-image invalidation preserved.
- `tests/test_qr_ui.cjs` now 21 Node fixture cases; `tests/qr_browser_smoke.py` optional real bundled vendor scanner has date boundary cases and explicit leading UTF-8 BOM reporting, only strips one leading U+FEFF when comparing canonical contents. Both new full fixture suites not executed via Windows GitHub Actions (runner unassigned).
- Independent Python QR encoder + OpenCV (not vendored qrcodejs) confirmed a leading BOM returns U+FEFF when decoded; vendor source contains BOM insertion. Actual vendored bitmap/phone decode unverified. Do not say QR complete until vendor + phone scan passes.
- Next ㄱ priority actual vendor QR scanner proof, then Windows RUN_SELF_TEST.cmd and offline HTML/JSON, A4 PDF print, WinRE backup gates. Preserve report data and no autonomous repair.

