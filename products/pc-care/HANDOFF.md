# AXMART PC CARE USB — 개발 인수인계 (2026-10-30 KST)

1. **목표·요구·기술**: AXMART 첫 유료 제품 후보(₩5,000). 정상 Windows PC의 정기 건강검진, 과거 블루스크린·저장장치 오류 진단, 부팅 불능 시 USB + Microsoft Windows RE로 수동 진단, 가능하면 안전한 시스템 파일 복구. PowerShell 5.1 + CMD + HTML/JSON, 오프라인 기본.
2. **완료·변경·선택 근거**: 선택 A안(일반 Windows 진단 USB + WinRE 수동 보조). 온라인 읽기 전용 점검·선택적 DISM/SFC 동의형 수리·WinRE 읽기 전용 점검 스크립트. 상용 WinPE 이미지 번들 제외, 모든 파티션/부트 자동 수정 제외. 보고서 HTML·예시(가상) 데이터 분리.
3. **테스트·성공/실패/미검증**: Linux Python 정적 안전성/구조 테스트 5/5 PASS (`python3 tests/test_package.py`). Chromium Headless OS 브라우저 사용, HTML `set_content` 로 UI 1280/390 폭 스크롤 없음, 페이지 오류 0. 일반 `file://` 로드는 관리자 정책 차단 → 직접 삽입으로 검증. **Windows PowerShell 및 WinRE 실행 테스트는 미검증**. 샘플 데이터는 실제 진단 아님.
4. **현재 상태**: 시제품 코드와 ZIP 제작 완료. 사용자 실제 PC 및 복구 USB 미테스트, 정식 판매 불가. GitHub·Production 미반영.
5. **오류·원인·시도·재시도 금지·대안**: 로컬 Playwright bundled Chromium 바이너리 부재 → 시스템 Chromium 사용. `file://` 브라우저 직접 로드 관리 정책 차단 → `page.set_content()` HTML 검증 통과. 관리자 차단 우회 반복 금지. Windows 스크립트는 Linux에서 실행 불가하여 정적 검증/Windows 실기기 검증 분리.
6. **저장소·브랜치·SHA·주요 경로**: 기존 AXMART 소유 repo `hibi89/AX_MART` Production 소스 유지. 이 신규 시제품 ZIP은 저장소에 아직 올리지 않았으므로 제품 브랜치/SHA **미반영**. 주요 경로 `tools/diagnose.ps1`, `tools/repair.ps1`, `recovery/WINRE_READ_ONLY.cmd`, `docs/*`, `examples/SAMPLE_REPORT_DEMO.html`.
7. **운영 URL·실행 환경**: 기존 AXMART 상점 URL `https://ax-mart.pages.dev/`이며 이 상품은 아직 미등록. 별도 제품 실행: Windows 10/11에서 USB 압축해제 후 `RUN_HEALTH_CHECK.cmd`; WinRE 모드에서 별도 수동 명령. API·토큰·키·백엔드 없음.
8. **원본·백업·인증·수정 금지**: 기존 상점 소스 미수정. 테스트용 파일로 운영체제 변경하지 않았음. 실제 Windows 시스템 파일 복구 전 고객 자신의 개인 데이터 백업 및 두 단계 승인이 필요. BitLocker 키 수집/우회 금지. 자격증명·개인식별·덤프 파일 미수집.
9. **다음 작업·완료 기준·승인**: P0 실제 Windows 스크립트 실행·오류/호환성 검증; P1 WinRE/BitLocker 테스트; P2 보안 서명·복구 정확도/위험성 평가; P3 사용자 승인 하 비공개 GitHub 브랜치에 올리고 실제 상품 등록·결제 연결 검토. 정식 판매 전 '모든 고장 자동 수리' 주장 금지.
10. **확인 시점(KST)·범위·문서 기준**: 2026-10-30 KST. Linux 정적 코드·기능 경로·HTML 데모 렌더만 확인. GitHub 제품 문서 기준 커밋 없음(미반영). ZIP 파일 SHA256은 배포 산출 시 산출·기록.


## GitHub 저장 확정 — 2026-10-30 KST (이전 '미반영' 기록을 대체)
- **현재 15개 소스 파일 GitHub 저장 완료:** `hibi89/AX_MART` / `feature/pc-care-usb` / `products/pc-care/`.
- 최초 원본 업로드 커밋: `5bd374badbb63b1c6bb0aa911f9e2fd1412d36d1`. 기존 홈페이지 Production `main`과 분리했다.
- 파일 구성: `RUN_HEALTH_CHECK.cmd`, `RUN_SAFE_REPAIR.cmd`, `tools/diagnose.ps1`, `tools/repair.ps1`, `recovery/WINRE_READ_ONLY.cmd`, `tests/test_package.py`, `docs/*`, `examples/SAMPLE_REPORT_DEMO.html`, `REPORTS/README.txt`, `README.md`, `STATUS.md`, `HANDOFF.md`.
- 저장은 **소스 버전 관리 완료**를 뜻하며 Windows 실기기 작동 검증/복구 안전성/배포 가능 판정이 아니다. 파일은 비공개 GitHub 브랜치에만 존재하며 홈페이지에서 다운로드되지 않는다.
- 사용자 최신 제품화 요구: 정상 부팅 PC에서 반복적으로 상태 점검, 블루스크린 이력 원인 진단 보조, 부팅 실패 시 USB를 활용한 안전한 장애 분석, 수리가 가능한 일부 경우에만 **명시적 동의 + 백업 후** 제한적 복구. 물리 고장과 BitLocker 문제를 만능 자동 수리라고 표현하지 않는다.
- 가격/출시: 초기 무료 베타+익명 선택적 피드백. 이후 유료 판매 검토시 자체 AXMART 예상 ₩5,000, 크몽 예상 ₩10,000. 실제 판매·사업자·결제는 아직 없음.
- 다음 채팅방 첫 작업: 본 브랜치 HEAD와 실제 코드 검사 → Windows 10/11 읽기 전용 진단 로직 수정·확장 → Windows VM/실기기 검증 계획 및 실행 → WinRE / BitLocker / 장애 상황 재현 → 위험 복구 절차 분리 검증 → 배포·피드백·상점 등록.
- 업로드 원본 `AXMART_PC_CARE_USB_v0.1-alpha.zip` SHA-256: `27350aa7245e2b9d2ea48b360d96f69022caef29e286cef179063b22cbb02dad`. ZIP은 테스트용 별도 산출물로서 홈페이지 배포 불가.

## 2026-10-30 15:35 KST 개발 재개 인수인계
1. **목표/요구/기술**: 원안 유지: Windows 10/11 PS5.1/CMD 오프라인 읽기 전용 진단, 사용자 승인형 DISM/SFC, WinRE 수동 점검, 무료 베타는 안전성 검증 후.
2. **완료/판단**: 기존 제품 코드 정밀 검토 후 UTF-8 BOM 누락, 미수집 이벤트 0건 오인 가능성, 디스크 조회 실패 시 수리 허용, WinRE 출력 저장 결함을 수리. 신규 파일 `tests/windows_smoke.ps1`, `docs/WINDOWS_TEST_PLAN.md`.
3. **검증**: 기존 GitHub 바이트에서 BOM 없음 확인. 정적 회귀 가드 확장. Windows PowerShell 5.1/WinRE/실물 복구는 이 실행환경에서 돌리지 못했으므로 **미검증**. 위험 변경 명령은 직접 실행하지 않음.
4. **완료/대기/차단**: 코드 안전성 강화 완료; Windows 정밀 실행·VM/BitLocker 시나리오·서명·릴리스는 미완료. 자동 복구/판매/무료 ZIP 공개 계속 차단.
5. **문제/원인/대안**: 커넥터 UTF-8 소스 원본 BOM 누락→BOM을 명시해 재저장; 디스크 건강 Unknown/조회 실패→fail closed. 실제 Windows 검증은 Windows 실기기 또는 스냅샷 VM이 필요. 근거 없는 PASS 주장은 금지.
6. **GitHub**: `hibi89/AX_MART` / `feature/pc-care-usb`, 변경 전 SHA `4d48eb5f3078e1442410205923f89fc5b4a77207`, `products/pc-care/` 아래. 본 문서 자체가 포함된 코드 커밋이 다음 검증 기준.
7. **Production/환경**: AXMART `https://ax-mart.pages.dev`는 `main` 배포이며 본 브랜치 미배포. Python 정적 테스트: `python3 products/pc-care/tests/test_package.py`; Windows: `powershell.exe -NoProfile -File .\\tests\\windows_smoke.ps1` (제품 폴더 기준).
8. **원본/보안**: 변경 전 4d48eb5f3078e1442410205923f89fc5b4a77207로 소스 추적 가능. 키·덤프·디스크 시리얼 수집/업로드 없음; WinRE 로그 공유 전 신원정보 검토.
9. **다음 우선순위**: Windows 파서 → 표준 사용자 읽기 전용 1일 진단 → 관리자 진단 → WinRE 격리 VM → 복구/BitLocker/스토리지 장애 스냅샷 시험 → SHA256/코드 서명/무료 베타 승인.
10. **갱신시각/검증범위**: 2026-10-30 15:35 KST. GitHub 코드 정적 검토와 변환 가드; Windows/CI/Production 미검증.

## 2026-10-30 KST — 보고서 실용성 보강
- 범위: `tools/diagnose.ps1` HTML 장치 건강 상태, 드라이버 지원 시 마모율/온도, BugCheck 시각·STOP 코드 표시. 미지원/로그 실패를 정상으로 보이지 않게 함. 보고서 입력은 HTML encoding 유지.
- 파일 변경 전 SHA: `9177ffd8822eb4ac64f3bb9702a7757529c23ab9`; `tests/test_package.py` 계약 정적 검사가 추가됨.
- 코드만 보강, Windows/WinRE 실제 실행·품질은 미검증. 웹 main/Cloudflare 무변경.

## 2026-10-30 KST — 시험 ZIP 파이프라인
- 목적: 외부로 사용자 보고서가 혼입되는 배포 사고 방지. 구현: `tools/release.py` ALLOWLIST 9개, manifest+sidecar SHA256, 결정적 zip, 비정상 BOM/심볼릭링크/대용량 거부.
- 검증: `tests/test_release.py` 임시 fixture 기반 6/6 PASS (Linux Python). Windows 실동작·실제품 ZIP·WinRE 검증은 미확인. 판매/공개는 여전히 금지.
- 변경 전 GitHub 소스 기준 `5a0eb2d904c7877a149f04c3f99084ee2a1ed0e3`, `feature/pc-care-usb`. 기능·버전은 v0.1-alpha 유지, Cloudflare main 미변경.
- 다음 작업: 실제 Windows PS5.1 진단 읽기/보고서·WinRE 테스트와 별도의 복구 VM 시나리오 통과. 검증된 SHA256 산출물만 무료 베타 후보.

## 2026-10-30 KST — Windows 사용자 검증 진입점
- 사용자 기기에서 내부 테스트 ZIP 압축 해제 후 `RUN_SELF_TEST.cmd` 1회 실행만으로 문법+읽기 전용 보고서 생성 여부 확인 가능. 별도의 수리 실행은 절대 금지.
- README, 패키지 ALLOWLIST(11개), 정적 테스트 갱신. Python fixture 패키징 6/6 성공. 실기기·WinRE PASS 주장 금지.
- 변경 전 HEAD `2ee12d9bf1fcf311ca40c7d4e129076d68ce96f0`; 다음 Windows 검증 실패 시 로그 및 명령/환경만 별도 정리하고 개인정보 공유 금지.

## 2026-10-30 KST — 네이밍 인계
- `AXMART³`는 플랫폼명(AXMART CUBE), `AXMART PC CARE`는 제품명. 제품명에 'CUBE'나 'USB'를 포함시키지 않는다. 제품 경로/내부 ZIP에 USB가 있는 것은 기술 파일명일 뿐.
- 브랜드 프리뷰는 `main`의 가상 UI 시안이며 실제 Windows 앱 UI 완성과는 무관. 본 feature HEAD 이전 `69b8bd26caf7fb4a63dec4db627a54d0ae7548a8`.

## 2026-10-30 KST — AXMART PC CARE 통합 스펙 v2.0 확정
- 상세 요구사항과 기능 범위는 products/pc-care/docs/FINAL_SPEC_V2.md를 기준으로 한다. Gemini 제안 두 개 결합: HEALTH, ANALYZE, REPORT(1페이지/PDF/QR), RESCUE(WinRE 조건부 파일 백업), RECOVER.
- Release A(진단+보고서+WinRE 읽기전용)와 Release B(복사 안전 검증 통과 후)를 분리. BitLocker 자동 해제·무인 전체 파일복사·DDU 자동화·하드웨어/사기판단 보증 금지.
- 이번 턴은 사양만 기록, 기존 Windows 코드 변경/테스트/홈페이지 판매 개시는 수행하지 않았다.

## 2026-10-30 KST — 새 채팅방 인계 문서
- **바로 읽을 것:** 저장소 루트 `NEXT_CHAT_PC_CARE.md`, `products/pc-care/docs/FINAL_SPEC_V2.md`.
- Gemini 통합 사양은 고정; 첫 구현 P0는 기존 PowerShell/Windows 읽기 전용 엔진 안정화, 예외/권한/이벤트 기록 처리 및 단위 회귀 테스트. 프로그램 판매/배포 활성화하지 않음.

## [최신 인수인계] 2026-10-30 KST — P0 코드 1차 구현, 실행 검증 대기

1. **목표·기술:** 최종 설계 Release A의 Windows PowerShell 5.1 읽기 전용 진단 안정화. 오프라인 CMD·로컬 HTML/JSON. 우선 NEXT_CHAT_PC_CARE.md → docs/FINAL_SPEC_V2.md → STATUS.md 확인.
2. **완료·변경·결정:** tools/event_analysis.ps1: 정상화된 System 이벤트, BugCheck 공급자 판별, 기록/실제 장애 시간 구별, 41/6008 중복 가능 그룹, UTC 정렬, 원문 로그 비수집. diagnose.ps1: 조회 결과 및 예외 상태 분리, 볼륨 누락값 정상 오인 방지, JSON/HTML 쌍 저장·Documents 폴백.
3. **테스트·성공/실패/미검증:** GitHub 소스 대상 문자열/BOM/경로 참조 등 정적 체크 17/17 조건 충족(실행 테스트 아님). 실행한 Python unittest 0회, Windows 파서·fixture 0회, 실제 진단 0회, WinRE·실제 복구 0회. CI 상태 체크 0개는 통과 판정 불가. 제품 폴더에서 Python test_package.py 및 test_release.py, Windows 표준 권한 RUN_SELF_TEST.cmd 실행이 다음 검증 순서.
4. **완료/진행/대기/차단:** 코드 P0 일부 완료, OS 실측 및 실패 주입 검증 대기. P1·P2와 Release B Rescue 미착수. 무료 다운로드·유료 판매·자동 파일 복구 계속 차단.
5. **오류 근거·원인·시도·대안:** 작업 환경에 PowerShell/pwsh 없음, 컨테이너의 private GitHub DNS 접속도 실패. GitHub 커넥터로 코드 직접 반영 및 정적 검토만 성공. 반복 시도보다 Win11 스냅샷 VM/실기기에서 실행하는 것이 정확. 실측 없이 PASS 주장 금지.
6. **저장소·브랜치·SHA·경로:** hibi89/AX_MART, feature/pc-care-usb, 직전 기능 코드 SHA cad89a644dd18e3a267fda842e3da22c841f9b95. 파일: products/pc-care/tools/diagnose.ps1, tools/event_analysis.ps1, tests/event_analysis.tests.ps1, tests/windows_smoke.ps1, tools/release.py, tests/test_package.py. 후속 문서 커밋이 HEAD를 갱신함.
7. **Production·URL·환경:** Cloudflare Pages ax-mart / https://ax-mart.pages.dev/ 는 main 기반. P0 feature 코드는 Production 미배포·미적용. RUN_SELF_TEST.cmd는 정상 Windows 환경에서만 사용, 수리 명령 금지. 새 배포 SHA/실제 브라우저 QA 미검증.
8. **원본·백업·권한·수정 금지:** 이력 Git SHA로 변경 전 소스를 복구할 수 있으며 main 무수정. 원본 파일, 개인 데이터, 암호, BitLocker 키, 이벤트 원문을 자동 업로드하지 않음. RUN_SAFE_REPAIR.cmd와 WinRE 파일 복사/파티션 쓰기 명령은 VM 스냅샷·별도 승인/검증 전 실행 금지.
9. **다음 작업 및 완료 기준:** Python 정적/패키징 테스트 → Win11 PS5.1 파서·event fixture → 비관리자 1일 진단 → JSON/HTML 쌍·권한 거부/빈 이벤트/상한/읽기 전용 USB/폴백 재현 → Win10 제한 검증. 실패 시 코드 최소 수정 및 재실행. 무료 베타·서명/보안/복구 전 출시 불가.
10. **갱신 시점·검증 범위·문서 기준:** 2026-10-30 KST. GitHub 커넥터로 파일·커밋 작성자/커미터 hibi89 확인, 코드 기준 cad89a644dd18e3a267fda842e3da22c841f9b95. Windows/CI/Production 테스트 미수행. 본 HANDOFF 기록 반영 후 GitHub HEAD 재확인 필요.

## [최신] 2026-10-30 KST — P0 후속 작업 인수인계

1. 목표·기술: AXMART PC CARE Release A P0 수집/권한/시간/로그/보고서 저장 실패 안정화. FINAL_SPEC_V2.md 기준, PowerShell 5.1/CMD, 오프라인·로컬.
2. 구현/변경: 누락된 synthetic fixture를 내부 ZIP에 추가. 옛 Python 정적 테스트의 NoMatchingEventsFound 참조 수정. 자체 임시 보고서만 삭제 허용하도록 검사 보강. 이벤트 최대 조회수 상한, UTC fixture, 권한 state, 물리 저장장치 신뢰성 자료 collected/empty/unavailable 상태 추가.
3. 테스트/실제 결과: GitHub 파일 9개 교차 정적 계약 35/35 충족. Python unittest, PowerShell Parser, fixture 실제 실행, Windows·WinRE, ZIP 빌드/실제 실행 모두 미실행. GitHub CI 체크 0개로 성공 여부 미판정. 명령: 제품 폴더에서 python3 tests/test_package.py 및 python3 tests/test_release.py; Windows 일반 사용자에서 RUN_SELF_TEST.cmd.
4. 완료·진행·대기·차단: P0 소스 및 테스트 보강 진행, Windows 11 실측/예외 재현 대기. P1, P2, Release B의 실제 Rescue 백업은 별도 범위, 출시 불가.
5. 실패·근거·원인·시도·대안: smoke가 호출할 synthetic fixture가 ZIP ALLOWLIST에 없어 Windows self-test 실패 가능 → ALLOWLIST/회귀 추가. 옛 테스트 경로 가정 오판 → 신규 모듈 참조. 이 컨테이너는 pwsh/PowerShell이 없으므로 Windows VM/실기기에서 직접 확인해야 함. 미실행을 PASS로 표시하지 않음.
6. 저장소/브랜치/SHA: hibi89/AX_MART, feature/pc-care-usb, 문서 전 기능 SHA 5dd651ab0d713780bbaac5c730394a141df2ae59. 주요 파일: products/pc-care/tools/diagnose.ps1, event_analysis.ps1, release.py, tests/test_package.py, test_release.py, windows_smoke.ps1, event_analysis.tests.ps1, docs/WINDOWS_TEST_PLAN.md.
7. Production·실행 환경: Cloudflare https://ax-mart.pages.dev/ / main, 이번 P0 코드는 미배포. Windows 11 x64/Windows PowerShell 5.1 대상. RUN_SELF_TEST.cmd는 읽기 전용+로컬 보고서 생성용; 수리 실행 금지.
8. 백업·보안: GitHub 과거 커밋에서 소스 복구 가능. main 미변경. 이벤트 원문/복구키/고객 로그·인증정보 GitHub 업로드 금지, 외부 자동전송 없음. DISM/SFC/WinRE 파일 복사는 실제 VM 스냅샷·별도 안전 검증 전 실행 금지.
9. 우선순위·완료조건: Python 테스트 → Windows 파서/합성 fixture → 일반 사용자 1일 검사 → JSON/HTML 쌍 및 오류/폴백 재현 → 저장장치 지원 차이/권한 → Win10 한정 호환성. 오류 발견 시 최소 수정과 재검증, 그 전 P0 전체 완료/공개 베타 불가.
10. 갱신 시각/범위: 2026-10-30 KST. GitHub 소스 35/35 정적 점검과 브랜치·커밋 작성/커미터 hibi89 확인. 실제 Windows, CI, 배포/브라우저 검증은 미수행. 최종 문서 커밋 후 HEAD 재확인 필요.

## [최신] 2026-10-30 KST — P0 보고서 저장 안전성 보강 인수인계

1. 목표/기술: 최종 설계 v2 Release A P0에서 로컬 HTML/JSON 보고서를 안전하게 저장·복구하는 기능 정비. Windows PowerShell 5.1 기반, 설치/클라우드 없이 오프라인 동작.
2. 변경/근거: 기존 실패 처리에서 기존 보고서 파일까지 삭제할 위험을 발견. tools/report_io.ps1로 함수를 분리하고 이름 충돌 차단·실제 생성/이동 소유 여부에 따른 정리·후보 저장 경로 폴백을 구현. 진단기는 모듈을 불러 사용하며 원본 Windows 데이터 수정 없음.
3. 검증: GitHub 최신 소스/BOM/모듈 연결/테스트 ZIP 의존성 정적 검사 16/16 조건 충족(실제 테스트 실행과 무관). 테스트 코드 tests/report_io.tests.ps1 신규 4개 시나리오. Python unittest 0회, Windows PowerShell 실제 Parser/fixture 0회, Windows/WinRE 동작 0회. CI 상태는 재확인 필요.
4. 상태: P0 보고서 쓰기 보호 코드 반영, 실기기/실패주입 수용검사 대기. P1-P4, Release B까지 전체 완성 아님. 무료 베타/다운로드/판매 금지.
5. 실패와 피벗: 현재 런타임에 Windows/pwsh가 없고 컨테이너에서 비공개 GitHub 클론이 불가하여 실제 PowerShell 실행을 하지 못함. 코드/정적 계약 검증으로 범위를 한정하고 Windows VM/실기기에서 실제 fixture 검증하도록 인계. 임의로 Windows 테스트 성공 처리 금지.
6. 저장소/브랜치: hibi89/AX_MART, feature/pc-care-usb. 경로 products/pc-care/tools/report_io.ps1, diagnose.ps1, tests/report_io.tests.ps1, windows_smoke.ps1, tests/test_package.py, tests/test_release.py, tools/release.py. 최종 commit SHA는 문서 반영 후 원격 HEAD를 확인.
7. Production/환경: AXMART³ Cloudflare Pages https://ax-mart.pages.dev/ 는 main에서 배포, 현재 PC CARE feature 코드는 미배포. Windows 11 x64/PS5.1가 우선 검증 환경; Windows 10은 제한 지원용 호환성 검사 별도.
8. 원본/보안: 원본 소스는 기존 Git 커밋으로 추적 및 되돌리기 가능. 보고서 저장 로직은 원본 사용자 파일을 삭제·수정할 의도 없음. WinRE 쓰기 복구·DISM/SFC·파티션/BitLocker 자동 변경 금지. GitHub에 진단 로그/개인정보/키 업로드 금지.
9. 다음 작업: Python 정적/ZIP 테스트 → Windows 11 Parser 및 synthetic event/report fixture → 일반 사용자 진단 및 1일 JSON/HTML 쌍 → Windows VM에서 이름 충돌/쓰기 실패/폴백 테스트 → Win10 제한 호환성 및 복구 안전성 별도 검증. 실제 증거가 확보될 때만 P0 완료 판정.
10. 갱신 일시/범위: 2026-10-30 KST. GitHub 코드 직접 검토, 교차 정적 계약 16/16. Windows·CI·Production 실제 기능 검증은 미확인. 본 문서 최종 반영 후 SHA 확인.

## [최신] 2026-10-30 KST — P1 증거 해설 1차 인수인계

1. **목표/용도/확정 요구/기술**: AXMART PC CARE v2의 증거 기반, 비확정적 장애 해설. Windows PowerShell 5.1, 단일 로컬 JSON/HTML, 오프라인, 원본 데이터 비변경.
2. **완료·변경·근거**: tools/incident_analysis.ps1 순수 규칙 엔진, 41-only/1001/storage Warning/truncated/unknown을 분리. 원인 확인 true 주장 금지. diagnostics의 analysis 필드/HTML 읽기용 해설 연동, tests/incident_analysis.tests.ps1 및 내부 ZIP·Windows smoke 참조 반영. P1의 나머지 배터리/Windows Update/이력은 미완성.
3. **테스트 명령·성공/실패·미검증**: GitHub 파일 교차 정적 점검 32/32 조건 충족. 실제 Python unittest/Win PS5.1 Parser/새 fixture/제품 ZIP 실행 0회, Windows 10/11 및 WinRE/수리 0회; 결과 미검증. 사용 명령: 제품 폴더 python3 tests/test_package.py, python3 tests/test_release.py; Windows 표준 사용자 powershell.exe -NoProfile -File tests/windows_smoke.ps1 (기본 파서+합성 fixture, 실제 진단은 명시 선택).
4. **완료/진행/대기/차단**: P0 정적 보강 완료 후 Windows 검증 대기, P1 초기 분석 규칙·JSON/HTML 연동 진행, P1 배터리·업데이트·추가 연계/오탐 QA 대기. P2 print/QR, P3 Rescue, WinRE 복사 출시 금지.
5. **오류·근거·원인·시도·대안**: Linux 컨테이너는 pwsh/powershell.exe가 없고 GitHub private repo를 DNS로 가져올 수 없음. GitHub connector에서 커밋 및 정적 교차 점검만 가능. Windows/VM 분리 실측 후 오류 최소 수정. 수행하지 않은 테스트를 PASS 처리하지 않는다.
6. **저장소·브랜치·SHA·주요 경로**: hibi89/AX_MART / feature/pc-care-usb. 변경 시작 SHA ec065d00f031d3e1689ece951945c2a58d9bda63. 핵심 파일 products/pc-care/tools/incident_analysis.ps1, tools/diagnose.ps1, tests/incident_analysis.tests.ps1, tests/windows_smoke.ps1, tools/release.py, tests/test_package.py, tests/test_release.py, docs/WINDOWS_TEST_PLAN.md. 본 문서 변경 뒤 HEAD 확인.
7. **Production/URL/실행환경**: Cloudflare Pages https://ax-mart.pages.dev/ 의 main 운영 소스/배포는 이번 턴 변경하지 않음(미적용). Windows x64 PowerShell 5.1 기준, 사용자 Windows 실측/Console·Network/실서비스 신규 기능 검증은 해당 없음·대기.
8. **원본/백업/권한·금지**: 이전 SHA로 롤백 가능. BitLocker 키/디스크 시리얼/원문 로그/사용자 개인 파일 GitHub 업로드 금지. 공개 테스트 ZIP/무료 베타·결제 중단 유지. 관리자 승격/삭제/파티션·부트 수정/무인 수리 금지.
9. **다음 우선순위/완료조건/승인사항**: 실제 Windows 11 PS5.1 parser+event/report/incident synthetic fixture → 일반 계정 read-only 검사(JSON/HTML 일치와 기기별 unknown) → Python 정적/ZIP 테스트 → 테스트 VM에서 파일 경로·권한/로그 failure injection → P1 배터리·업데이트 지원과 1페이지/QR 점진 구현. 출시에는 별도 Windows/WinRE/보안 검증과 사용자 승인 필요.
10. **KST·확인 시점·검증 범위·문서 기준**: 2026-10-30 KST. GitHub connector의 소스 점검과 커밋 확인, 정적 32/32. Windows/Python 제품 테스트 미실행. 문서 커밋 후 feature branch 실제 HEAD 확인.

## [최신] 2026-10-30 KST — P1 배터리·Windows Update 관측 1차

1. **목표·요구·스택:** FINAL_SPEC_V2.md H05/H06. AXMART PC CARE Release A의 비관리자·오프라인 PowerShell 5.1 배터리/업데이트 증거 수집과 분석 해설 구현. 사용자 기기·시스템 파일 변경 없음.
2. **완료 변경·근거:** 신규 tools/telemetry_analysis.ps1로 Win32_Battery 조회값 정규화(없음/조회 불가/일부 수집, 현재 충전량 vs 배터리 건강도 구별, 설계/완충 용량 미지원 null), WindowsUpdateClient System 이벤트 19/20(기록 시각, 300건 상한, 원문/기기 식별 정보 미저장). tools/diagnose.ps1 JSON/HTML 및 tools/incident_analysis.ps1 보수적 업데이트 검토 규칙 연동.
3. **실제 검증·명령·미검증:** GitHub 소스 9개 파일의 JS 정적 계약 검사 39/39 조건 충족. tests/telemetry_analysis.tests.ps1 신규, tests/incident_analysis.tests.ps1 확장, tests/windows_smoke.ps1에 파서/합성 fixture 추가, Python packaging/내부 ZIP 의존성 수정. 이 환경에 pwsh/PowerShell 없어 실제 PowerShell fixture 0회, Python unittest 및 ZIP 실제 생성 0회, Windows 실기기/VM 0회. 실행 명령: 제품 폴더에서 python3 tests/test_package.py, python3 tests/test_release.py; Windows 일반 사용자에서 powershell.exe -NoProfile -File tests/windows_smoke.ps1, 이후 명시적 -RunReadOnly 테스트.
4. **진행/대기/차단:** P1 배터리·업데이트 기본 관측 코드 완성, 호환성·실측 QA 대기. Windows 11/10 기종별 자료 지원 상태/다른 Windows Update 로그 소스/드라이버 변경 정보 미확인. P0 read-only 실측 게이트 대기, P2 1페이지 Print/PDF·QR, WinRE Release B 미검증. 판매·공개 ZIP 차단.
5. **오류·원인·대안/재시도:** Windows PowerShell 5.1 실기기 없음, 외부 컨테이너는 private GitHub DNS 불가. GitHub connector로 저장/정적 검증은 가능하지만 실제 런타임은 대체할 수 없음. 미실행 테스트를 PASS로 주장 금지. 이벤트 19/20의 원인 진단은 불가, '설치 기록'으로만 출력.
6. **저장소/브랜치/SHA·파일:** hibi89/AX_MART, feature/pc-care-usb, 시작 SHA 9ca1bca478bed6ffb90ba7c1c67e52ee8cef99e3. 핵심 tools/telemetry_analysis.ps1, diagnose.ps1, incident_analysis.ps1, tests/telemetry_analysis.tests.ps1, incident_analysis.tests.ps1, windows_smoke.ps1, tools/release.py, tests/test_package.py, test_release.py, docs/WINDOWS_TEST_PLAN.md. 본 문서 커밋 후 HEAD 확인.
7. **Production URL·환경:** Cloudflare Pages https://ax-mart.pages.dev/ 는 main 운영; feature 브랜치만 변경, 배포/실서비스 변경/확인 없음. Windows 11 x64 PS5.1 우선 검증, Windows 10 x64 제한 검증.
8. **원본·백업·보안 금지:** 과거 Git 커밋으로 원본 소스 복구 가능. Windows 변경·관리자 자동 승격·WinRE 파일 복사·BitLocker 키 수집·원본 이벤트 메시지/배터리 일련번호 기록·원격 통신 금지. 공개 다운로드/결제 비활성 유지.
9. **다음 우선순위와 종료조건:** (1) Windows 11 PS5.1 구문/합성 fixture 실제 실행 (2) 기본 사용자에서 배터리 없음/실배터리/이벤트 19·20 실제 수집 확인 (3) USB 경로/로그 거부/300 cap/저장 실패 재현 (4) Python unittest/내부 ZIP 체크섬 실검증 (5) 장치 드라이버 오류 수집 및 사건 상관 규칙, 1페이지 인쇄 준비. 실패는 최소 수정 후 반복, 실기기 없으면 P0·P1 완료 판정 보류.
10. **갱신 일시/범위:** 2026-10-30 KST. GitHub 원격 소스와 39/39 정적 검사만 실제 수행. 실제 Windows/CI/ZIP/WinRE 테스트 미수행. 문서 기록 후 최신 feature HEAD 확인.

## [최신] 2026-10-30 KST — P1 드라이버·타임라인 인수인계

1. **목표·확정 요구·스택:** AXMART PC CARE v2, 비관리자 Windows PowerShell 5.1/로컬 HTML+JSON/오프라인. P1 드라이버 ConfigManagerErrorCode와 과거 사건 기록 시각 간 제한적 관측. SYSTEM 변경 금지.
2. **완료 기능·차이·근거:** `tools/pnp_analysis.ps1`은 문제 상태 코드(0 제외)와 화이트리스트 장치 범주만 반환하고 사용자 장치명/ID/시리얼을 저장하지 않는다. 코드 22는 의도된 비활성화 가능. `tools/recorded_timeline.ps1`은 다섯 이벤트 kind의 recordedUtc만 15분 윈도우/최신 80건으로 묶는다. 기록 시각 근접은 인과·실제 장애 시각 증거 아님. 공식 문서: https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/win32-pnpentity.
3. **수행 테스트·명령·실패·미검증:** GitHub 소스 9종 정적 계약 37/37 조건 충족. Windows PowerShell 파서·`tests/driver_timeline.tests.ps1`·Python unittest·ZIP 빌드 등 실제 런타임 **미실행**. 커넥터로 remote GitHub 소스 수정 가능, Linux 런타임에 Windows PowerShell 없음. Windows 테스트 진입점: `powershell.exe -NoProfile -File tests/windows_smoke.ps1`; 전체 읽기 전용 검사는 명시적 `-RunReadOnly` 또는 `RUN_SELF_TEST.cmd`.
4. **완료/진행/대기/차단:** 코드 신규 2종과 합성 fixture 1종, diagnose/incident_analysis JSON·HTML 연동, ZIP 의존성 연결 완료. P0·P1 완료 판정은 Windows QA 대기. P2 1페이지/QR, WinRE Release B 및 실제 위험 복구 전부 미검증·공개 차단.
5. **오류/원인/시도/다음 대안:** 장치 상태 코드 22는 고장 확정 위험이 있으므로 독립 비활성화 상태로 취급. 시각 UTC·+09:00 차이/1001 로그 기록 지연을 실제 장애 시각이라고 부르면 오진 위험이 있으므로 근접 그룹으로만 표시. Windows 실행이 없는 정적 검증 결과를 PASS 런타임으로 표시하지 않는다.
6. **저장소·브랜치·SHA·주요 경로:** hibi89/AX_MART / feature/pc-care-usb. 시작 SHA 46db07771cdb45bbd733ef766919672801c2dc47. 주요 `products/pc-care/tools/pnp_analysis.ps1`, `recorded_timeline.ps1`, `diagnose.ps1`, `incident_analysis.ps1`, `tests/driver_timeline.tests.ps1`, `windows_smoke.ps1`, `tools/release.py`, `tests/test_package.py`, `tests/test_release.py`, `docs/WINDOWS_TEST_PLAN.md`. 문서 커밋 후 최종 SHA 확인.
7. **Production·실행환경:** https://ax-mart.pages.dev/ 는 main/Cloudflare 운영 사이트; 이 브랜치 내용은 미배포. Windows 11 x64/PS5.1 우선, Win10 제한 호환성 검증 필수. Python 3.13.5는 본 도구 런타임에만 확인, 실제 사용자 배포에는 Python 필요 없음.
8. **원본·백업·권한·금지:** Git 커밋으로 롤백 가능, main 변동 없음. 원본 이벤트 로그, 사용자 장치 ID/이름/키/경로 전송/커밋 금지, 관리자 자동승격·자동 드라이버 재설치·레지스트리·부트/파티션 수정·WinRE 파일 복사 금지. 공개 테스트 ZIP/판매 금지.
9. **다음 우선순위와 완료 조건:** ①Windows PS5.1 파서+모든 합성 fixture 실제 실행 ②표준 사용자 Windows 장치 코드·로그 수집 확인 ③USB 경로/권한·로그 실패, 101건 PnP cap/80건 timeline cap 확인 ④Python 정적 unittest/ZIP SHA 실제 실행 ⑤P1 오탐 회귀 보강 후 P2 한 장 수리 상담표·Print CSS/오프라인 QR 준비. 게이트 통과 전 실제 Windows PASS/제품 완성 주장 금지.
10. **갱신 시각·범위·재시작 방법:** 2026-10-30 KST, GitHub source 정적 계약 37/37. 다른 작업방에서도 `NEXT_CHAT_PC_CARE.md`→`FINAL_SPEC_V2.md`→`STATUS.md`→본 파일 순서로 읽고 feature branch 최신 HEAD로 이어갈 것. 사용자 'ㄱ'에 묻지 말고 가능한 정적 독립 작업 계속; 실기기 검증 결과 없으면 완료 판정 보류.

## [최신] 2026-10-30 KST — P2 수리 상담 A4 인쇄 요약 인수인계

1. **목표·용도·확정 요구·기술:** AXMART PC CARE Release A R01/R02/R03/R05/R07: 기존 read-only Windows PowerShell 5.1 진단에서 수리점 상담용 객관적 1페이지 정보를 로컬 HTML/CSS와 브라우저 인쇄→PDF로 내보내기. P2 초기 개발 단계.
2. **완료 기능·변경·결정 근거:** `tools/consultation_report.ps1`에서 상담표 데이터를 whitelist로 최소화. Event ID/기록 UTC/Windows build/상태/백업·질문, 고장 원인 미확정. `tools/consultation_render.ps1`에서 HTML encoding 후 A4 section 생성. `tools/diagnose.ps1`는 기존 JSON/HTML 보존하며 consultation 필드와 전용 print CSS 추가. 실제 프린트·PDF는 브라우저 수동 실행, 서버/API/외부폰트 없음. 기존 read-only 분석·기기 데이터 삭제/복구 없음.
3. **테스트 명령·성공/실패·미검증:** 소스 간 정적 계약 37/37 조건 충족(실제 런타임 검증 아님). `tests/consultation_report.tests.ps1` 합성 개인정보 제거·악성 HTML escape·4건 상한·UTC·조회 실패 시나리오 작성, `tests/windows_smoke.ps1` 파서/fixture 등록. Python `tests/test_package.py`, `tests/test_release.py` ZIP 참조 수정, 실제 실행 0회. Windows PowerShell 5.1/인쇄/PDF/WinRE 실행 0회; CI 상태 별도 확인.
4. **완료/진행/대기/차단:** P2 A4 CSS+요약 모델+상담표 HTML 초기 구현. QR·실제 A4 한 장/장치별 브라우저 QA·홈 UI 미완성. P0/P1 Windows 실기기 QA 미통과, Release A 공개 불가, Release B WinRE 파일 백업 출시 금지.
5. **오류·원인·시도·중단·대안:** 이 환경에는 Windows PowerShell 및 GUI 프린터가 없어 한 페이지 출력과 PS5.1 parser 검증이 안 됨. 코드 정적 점검은 Windows 통과와 다르다. Windows VM/실기기에서 Ctrl+P PDF·실제 인쇄·긴 문자열·한글·USB 저장/권한 실패를 재현 후 최소 수정. 기존 검증 없는 출시 강행 금지.
6. **저장소·브랜치·SHA·경로:** hibi89/AX_MART / feature/pc-care-usb, 시작 SHA 0c67459fa02b31271f7f4b9f2c295e22d0eb8c74. 핵심 `products/pc-care/tools/consultation_report.ps1`, `consultation_render.ps1`, `diagnose.ps1`, `tests/consultation_report.tests.ps1`, `windows_smoke.ps1`, `tools/release.py`, `tests/test_package.py`, `tests/test_release.py`, `docs/WINDOWS_TEST_PLAN.md`. 문서 이후 HEAD 확인.
7. **Production URL·Vercel/Cloudflare·실행환경:** https://ax-mart.pages.dev/ 는 main Cloudflare Pages 운영, feature 코드는 미배포. Windows 11 x64+Windows PowerShell 5.1과 Edge/Chrome 브라우저 대상. Vercel 배포 대상 아님.
8. **원본·백업·권한·수정 금지:** Git 기존 커밋으로 복구 가능, main 변경 없음. 기존 보고서·수리/WinRE 코드 변경 없음. 비밀번호·BitLocker 복구키·기기 식별자·민감 원문을 상담표/QR/외부 서버에 담지 않음. PDF 공유/인쇄는 사용자가 수동으로 실행.
9. **다음 우선순위·완료 기준·승인:** Windows PS5.1 파서+synthetic fixture → Windows 11 read-only RUN_SELF_TEST.cmd → A4/한글/브라우저 PDF 실제 파일 검증 → 오류 수정 후 P2 QR 명시 생성·미리보기·용량·스캔/오프라인 검증. WinRE/복구 위험 기능은 별도 백업/안전 테스트 및 승인 필요. 무료 배포 및 크몽 19,900원부터 검토하는 분석 서비스 등록은 실제 출시 승인 전 보류.
10. **KST·검증 범위·문서 기준:** 2026-10-30 KST. GitHub connector 소스 직접 검사, 정적 37/37. Windows·CI·실기기·인쇄/PDF·QR 런타임 검증 미실행. 본 문서 최신 커밋/feature HEAD 재확인.

## [최신] 2026-10-30 KST — P2 QR용 로컬 공유 문구 인수인계

1. **목표·용도·스택:** FINAL_SPEC_V2.md R04–R07. AXMART PC CARE 오프라인 QR 공유 준비를 위해 사용자 선택형 개인정보 최소 텍스트/미리보기 구현. Windows PowerShell 5.1/로컬 HTML, 무계정/무서버. 실제 QR 이미지는 **미구현**.
2. **완료 기능·근거:** `tools/share_payload.ps1`가 A4 consultation 요약의 허용 상태·신호 범주·검증된 UTC 로그 기록 시각만 사용, 250 UTF8 byte 상한 검사, 초과 시 fail-closed. `tools/share_preview.ps1`가 `<details>`로 명시 펼치기, HTML encode+readonly textarea와 전체선택 버튼을 제공. 직접 Ctrl+C/공유는 사용자 실행. 시간은 사고 시각 아님, 원인 미확정 표시. 로그·장치명·일련번호·키/파일경로 복제 없음.
3. **실제 테스트·명령·결과:** 원격 GitHub 소스 정적 교차 계약 40/40 충족(UTF8 BOM, 250byte, allowlist, HTML encode, 미리보기·ZIP 연동). `tests/share_payload.tests.ps1` 신규 합성 fixture는 아직 Windows PS5.1 실행 안 됨. `tests/windows_smoke.ps1`에 parser·fixture 및 JSON schema 연결. `tools/release.py` internal-testing, `tests/test_release.py`·`tests/test_package.py` 반영했으나 Python unittest/ZIP 실제 실행 0회. 실제 Windows/Edge/Chrome·QR 스캔 미실행.
4. **상태·대기·차단:** P2 QR **텍스트 모델과 미리보기 구현**, QR bitmap/이미지/스캔 미완료. A4 인쇄 한 페이지 검증 대기. P0/P1 실기기 런타임, Release B WinRE 파일 복사, 복구 안전성 QA도 미완료. 무료 베타/크몽 유료 등록/Cloudflare 제품 다운로드 금지.
5. **이슈·안전·대안:** 개인정보 문구는 진단 JSON에 넣지 않고 `sharePreview` 바이트·상태·bitmap 미생성만 기록. 로컬 HTML 안에는 미리보기가 펼치기 전에도 텍스트로 포함될 수 있으므로 HTML 전체 공유는 위험 안내. 과대 UTF8 payload 무단 자르기 금지. QR 실제 인코더는 라이선스·오프라인·스마트폰 스캔 QA 확보 전 추가하지 않음. 외부 QR URL/전송 금지.
6. **저장소·브랜치·SHA·파일:** hibi89/AX_MART / feature/pc-care-usb. 시작 SHA 2684cd3b55f9186921e630fe4a672be4c27ad1e6. 변경 files: `products/pc-care/tools/share_payload.ps1`, `share_preview.ps1`, `diagnose.ps1`, `tests/share_payload.tests.ps1`, `windows_smoke.ps1`, `tools/release.py`, `tests/test_package.py`, `test_release.py`, `README.md`, `docs/WINDOWS_TEST_PLAN.md`. 문서 커밋 후 최종 HEAD 확인.
7. **Production·환경:** https://ax-mart.pages.dev/ 는 main/Cloudflare Pages의 운영 사이트; feature 브랜치만 변경, 실제 공개 제품 적용/판매 기능 없음. Windows 11 x64+Windows PowerShell 5.1 우선 대상. Win10 제한 지원/WinRE 별도.
8. **보안·원본·백업·금지:** Git SHA로 롤백 가능. 사용자 Windows 읽기 전용 진단과 로컬 보고서 저장 외 OS/개인 파일 수정 없음. 원문 로그/DeviceID/계정/BitLocker 키·복구키 전송 금지. 관리자 자동승격, 실제 드라이버 설치, 데이터 복사·삭제·파티션/BCD 변경, 원격 URL 없는 QR 클라우드 사용 금지.
9. **다음 우선순위·완료조건:** Windows PS5.1 parser 및 synthetic fixture 실행 → Windows USB에서 실제 read-only 진단 및 상담표·공유 미리보기 작동 확인 → 로컬 QR 인코더의 라이선스·무네트워크 검사·UTF8 250byte/QR scannability 실증 → A4/PDF 1페이지/한글 테스트 → 베타 게이트. CI 없으면 그 자체가 성공이 아니며 다음 독립 작업은 지연하지 않는다.
10. **갱신 시각·검증 범위:** 2026-10-30 KST. GitHub source 정적 검사 40/40, PS5.1/QR/Python/ZIP/Windows 실측 0회. 다음 ㄱ은 브랜치 확인 후 남은 작업을 이어가고 완료/검증 여부를 구별.

## [최신] 2026-10-30 KST — 오프라인 QR 비트맵 명시 생성 인수인계

1. **제품/목표/스택:** AXMART PC CARE의 P2 REPORT R04-R07. Windows 11 x64, Windows PowerShell 5.1, 저장된 로컬 HTML + 내장 JavaScript. QR 공유 문구 250 UTF-8 bytes 제한·비식별화·사용자 선택 미리보기와 선택 시 bitmap 생성. Cloudflare/외부 QR 서버·계정 없음.
2. **완료 코드·기술/근거:** ui/qrcode.min.js는 공개 davidshimjs/qrcodejs MIT 코드 원문을 동봉. ui/QR_CODE_LICENSE.txt에 저작권/라이선스 전문 저장. ui/qr_ui.js는 QR 생성 버튼의 직접 click에만 new QRCode 실행하며 TextEncoder로 250바이트 재검증. tools/diagnose.ps1은 라이브러리·자체 JS·MIT 전문을 저장되는 HTML에 인라인 삽입하고 없는 경우 텍스트-only로 돌아감. tools/share_preview.ps1은 명시 생성 버튼·상태 영역·QR DOM 대상 및 사용자 경고 표시. QR 자동 생성/업로드/clipboard 저장 없음.
3. **테스트 명령·실제 결과·한계:** GitHub 소스 11개 cross-file static 검증 40/40 충족. tests/share_payload.tests.ps1 확장(QR 조건 지원/불지원, 버튼 존재, 생성 전 이미지 없음). tests/test_package.py, test_release.py, windows_smoke.ps1, tools/release.py internal ZIP 파일/fixture 의존성 수정. 실제 `powershell.exe -NoProfile -File tests/windows_smoke.ps1`, Python unittest/ZIP 생성, Edge/Chrome QR 렌더, Android/iOS 스캔/한글 디코딩, Wireshark/오프라인 네트워크 확인, A4 출력은 전부 미실행. 이는 소스 계약이지 실제 작동 PASS가 아님.
4. **진행/대기/차단:** P2 QR 비트맵 생성 소스 및 UX 구현, QR 텍스트/인쇄 모델 코드 존재. 실측 QA, 홈 UI/접근성/UI 디자인 다듬기, P0/P1 Windows 런타임 수정과 WinRE Release B 검증 대기. 실제 스마트폰 스캔 증명 전 공개 QR 완성·베타/판매 중단.
5. **오류/실패·원인·대안:** QR 라이브러리 자산 분실/변조 등 문제 시 보고서 전체 실패를 피하려고 HTML 생성 전 QR 사용 가능성 분리, missing/invalid 시 텍스트-only 폴백. 250바이트 초과/검증 실패 시 QR 생성 차단. QR 라이브러리는 로컬 JS이고 실제 한국어 스캔 호환성은 별도 검증. MIT 전문은 독립 HTML에도 삽입되도록 설계.
6. **저장소·브랜치·SHA·파일:** hibi89/AX_MART feature/pc-care-usb. 기능 전 체크포인트 c5a2251a5edf33d3a9cab94eae97b2913bbd1803. 주요 `products/pc-care/ui/qrcode.min.js`, `ui/QR_CODE_LICENSE.txt`, `ui/qr_ui.js`, `tools/share_payload.ps1`, `tools/share_preview.ps1`, `tools/diagnose.ps1`, `tests/share_payload.tests.ps1`, `tests/windows_smoke.ps1`, `tools/release.py`, `tests/test_release.py`, `tests/test_package.py`, `docs/WINDOWS_TEST_PLAN.md`; HEAD는 본 파일 이후 재확인.
7. **Production·환경:** https://ax-mart.pages.dev/ 운영 main은 변경 없음. 이 feature 코드는 공개 페이지 미배포. 고객 브라우저: Windows Edge/Chrome 우선. Windows 10 제한 호환성, 다른 스마트폰 OS 스캔 검증 별도.
8. **보안·원본/백업·권한:** 기존 Git commit으로 코드 복구 가능. Windows 사용자 데이터 삭제/레지스트리/파티션/BCD/WinRE 자동 조작 없음. 외부 서비스·CDN·계정/위치/복구키·이벤트 원문 QR 자동 삽입 금지. ZIP에는 MIT 전문 포함, 생성 HTML에는 원문 고지 인라인; 전체 HTML/JSON 공유 전 개인정보 검토 필요.
9. **다음 우선순위·완료 조건:** Windows 11 PowerShell parser+fixture 실제 실행 → RUN_SELF_TEST.cmd 로컬 ZIP에서 read-only 진단 → Edge/Chrome 버튼 직접 클릭으로 QR 생성 → Android/iOS 스캔한 문자열 UTF-8 원본과 바이트 동일 비교 → 한글/250바이트/USB 분리/offline/모바일 카메라, A4 PDF 한 페이지 검증 → P2 UI 마감, Release A/B 별도 QA. CI 기다리는 동안 다른 독립 UI/회귀 보강은 진행 가능.
10. **시각/검증 범위:** 2026-10-30 KST. GitHub 원격 정적 계약 40/40. 어떤 Windows/QR 스캔·Python 제품 테스트도 통과 판정을 내릴 실제 실행 증거는 없다. 다음 채팅에서 최신 GitHub branch HEAD와 본 인수인계 확인.


## [최신] 2026-10-30 KST — Windows CI 시도·P2 화면 탐색 인수인계

1. **목표/스택:** AXMART PC CARE Release A P2 로컬 보고서 UX, Windows PowerShell 5.1 실제 합성 fixture 검증을 통한 출시 게이트 확보. GitHub 리포지토리 `hibi89/AX_MART` feature/pc-care-usb만 변경.
2. **구현:** `.github/workflows/pc-care-windows-synthetic.yml` Windows 5.1 Parser/fixtures + Python stdlib unittest·내부 ZIP 테스트 워크플로 구축, 최소 read 권한/12분 제한/무수리. `tools/diagnose.ps1` 오프라인 보고서에 ARIA quicknav, 키보드 스킵 링크, 7개 section 앵커 및 mobile CSS. 기존 A4 #consultation-print 전용 print media, QR 사용자 명시 클릭/개인정보 최소 규칙 유지. `tests/test_package.py`에 nav anchor coverage.
3. **실행·검증·증거:** GitHub Actions run https://github.com/hibi89/AX_MART/actions/runs/41034866482, run_id 41034866482, job_id 123993114299, 결론 failure, `steps=[]`, `runner_id=0`, 0초 런타임 테스트, Job log 접근은 404 BlobNotFound. 러너 미배정·인프라 문제 상태; PS5.1/ Python 자체 테스트 PASS/FAIL 확정 불가. GitHub 소스 비교 9/9 정적 조건 충족; 인쇄 UI 실제 브라우저·QR 카메라 스캔도 여전히 미실행.
4. **차단/상태:** 워크플로 실행 첫 실패 이후 push마다 실패/비용 반복하지 않도록 `workflow_dispatch` 수동 전용 전환. 원인은 계정 Actions 러너/결제/가용성 가능성 등 미확인으로 단정 금지. Windows/USB/WinRE 사용자 기기 실제 QA 출시 차단.
5. **후속 우선순위:** (1) GitHub Actions 실행 기록의 러너 배정/계정/조직 설정 확인 및 러너 확보 후 수동 dispatch (2) Windows 11 일반 사용자 PowerShell 5.1 `tests/windows_smoke.ps1` 실행 (3) Edge/Chrome 인쇄 한 페이지 PDF, QR 한국어 UTF8 스캔/오프라인 확인 (4) USB 저장 실패/권한 문제, WinRE 읽기 전용 검증 (5) Release B 복사/복구는 별도 안전 게이트 후 진행. 기다리는 동안 추가 UI/정적 회귀 작업 가능.
6. **파일/브랜치:** `feature/pc-care-usb`, 변경 핵심 `.github/workflows/pc-care-windows-synthetic.yml`, `products/pc-care/tools/diagnose.ps1`, `products/pc-care/tests/test_package.py`. 이전 QR 파일/설계는 기존 HANDOFF의 최신 이전 장 참조.
7. **운영/보안:** main Cloudflare `https://ax-mart.pages.dev/` 변경 없음. 자동 복구/업로드/기기 식별 정보 외부 발송/출시 금지.
8. **원본/복구:** Git commit revert로 되돌릴 수 있음. 인쇄/진단 원본 구조 보존.
9. **완료 조건:** Windows 합성 fixture와 Python unittest 실제 PASS, 수리/WinRE 독립 QA, 실제 PDF 한 장/QR 스캔 실증 후만 Release A 공개 승인.
10. **시각·맥락:** 2026-10-30 KST. 초기 feature HEAD c32ab92576ce1c5c299ae069ebf49c64e486c20f. 최종 HEAD는 문서 기록 후 확인. 다음 'ㄱ'은 CI 실패가 테스트 실패가 아님을 구분하고 개발 계속.

## [최신] 2026-10-30 KST — CMD 실행기 신뢰경로·Node QR 테스트 인수인계

1. **요구/목표:** AXMART PC CARE Release A 포터블 Windows/USB 안전 사용성 보강. P2 QR 버튼 작동 검증 및 P0 신뢰된 OS 실행기 절대경로. `hibi89/AX_MART` 브랜치 `feature/pc-care-usb`, main 무변경.
2. **수정 코드:** `products/pc-care/RUN_HEALTH_CHECK.cmd`, `RUN_SELF_TEST.cmd`, `RUN_SAFE_REPAIR.cmd`에서 `powershell.exe` PATH/현 디렉터리 검색 호출을 없애고 `%SystemRoot%\\System32\\WindowsPowerShell\\v1.0\\powershell.exe` 절대경로 확인 및 실패 시 종료. `DisableDelayedExpansion` 설정. `tests/windows_smoke.ps1`이 실제 저장된 JSON/HTML의 A4/QR 로컬 인라인/MIT 고지/지원 상태/무전송 태그 여부 추가 점검. 복구 자동 승인, 시스템 수정, 새 네트워크 기능은 없음.
3. **실행 테스트와 증거:** GitHub `ui/qr_ui.js` 동일 소스 FNV32 `3087562328` 직접 확인, 로컬 Node v22.16.0 실제 VM+가짜 DOM/QR 생성자로 6/6 시나리오 통과 및 `node --check` 성공(실제 QR 스캔 아님). `tests/test_qr_ui.cjs` 별도 Node 내장 test를 저장하고 workflow에 연결했지만 runner에서 파일 자체 테스트는 아직 미실행. 원격 GitHub 정적 계약 21/21 확인. Windows PS5.1/CMD/HTML/브라우저·QR 실제 출력·Python unittest·ZIP·WinRE **미실행**.
4. **CI/막힘:** GitHub run 41034866482는 러너 미배정(runner_id 0, steps []), logs 404. workflow manual `workflow_dispatch`만, 자동 push 비활성. CI 실패는 실행/구문 테스트 실패를 뜻하지 않으며 성공도 아님.
5. **남은 핵심:** Windows 11 사용자 PC에서 `RUN_SELF_TEST.cmd` 실행/자가 검사·표준 사용자/USB 공백·한글 경로/문서 폴백을 확인. GitHub 러너 확보 시 수동 workflow dispatch, Node `node --test tests/test_qr_ui.cjs`, Python unittest와 PowerShell synthetic fixtures. PDF A4 실제 한 페이지, QR iOS/Android UTF8 스캔 및 원본 바이트 일치, 무네트워크·UI 접근성 테스트.
6. **관련 경로:** `RUN_HEALTH_CHECK.cmd`, `RUN_SELF_TEST.cmd`, `RUN_SAFE_REPAIR.cmd`, `tests/windows_smoke.ps1`, `tests/test_package.py`, `tests/test_qr_ui.cjs`, `ui/qr_ui.js`, `.github/workflows/pc-care-windows-synthetic.yml`, `docs/WINDOWS_TEST_PLAN.md`, `STATUS.md`. 최신 HEAD는 문서 완료 후 확인.
7. **운영/실행환경:** 운영 main `https://ax-mart.pages.dev/` 변경 없음. Windows 11 x64 + PowerShell 5.1 목표, Node/Python은 개발 QA에서만 필요. WinRE는 별도 읽기 전용 실행기, Windows 복구 미디어 필요.
8. **보안/원본:** Git feature branch 커밋으로 롤백 가능. BitLocker 키, 사용자 파일, 장치 시리얼/로그 원문 유출 금지. 관리자 자동승격, Windows 파티션/레지스트리 자동 수정, 외부 QR 서비스 사용 금지.
9. **상태/완료 조건:** P2 UI/QR/인쇄 소스 구현에 진전 있으나 실제 실기기 QA 제로. Release A/B 완료·무료/크몽 판매·일반 배포 불가. 제품 전체는 약 30% 추정에 머무르며 과장하지 않음.
10. **기록시각/맥락:** 2026-10-30 KST. GitHub connector 직접 수정, Node VM 로컬 테스트 6/6+JS syntax, GitHub 정적 21/21, Windows/WinRE 실제 실행 미확인. 다음 ㄱ은 Windows QA 확보를 우선하되 사용자가 직접 테스트할 수 있는 명확한 로컬 진입점과 증거 수집에 집중.

## [최신] 2026-10-30 KST — QR stale-image/privacy bugfix and Chromium test handoff

1. **목표/기술:** AXMART PC CARE 포터블 진단의 P2 비식별 오프라인 QR. `feature/pc-care-usb` 브랜치만 수정; PowerShell 5.1 비식별 모델 + 정적 HTML/JS. main/Cloudflare 미변경.
2. **완료 구현/근거:** `ui/qr_ui.js`는 `clearPreviousQr()`로 입력 수정 즉시/생성 시도 전에 QR 이미지를 제거. 클릭 시 250 UTF-8 byte + 고정 7줄 schema, 허용 평가·신호·UTC/시간 의미·원인 미확정·백업 문구를 재검증. 입력 변조·개인정보 자유 문장·인과 확정 문구를 QR로 인코딩하지 않음. 기존 실제 QR 엔진/라이선스/요약·리포트 소스 보존.
3. **실제 수행 테스트:** 로컬 Chromium Playwright에서 GitHub `ui/qr_ui.js` exact Git blob `b0b06f527bed53f147e05e6512ee289608048de1` 동일 소스 확인 후 **13/13 브라우저 mocked-QR 동작 PASS**, JS 문법 `node --check` PASS. 범위: 실제 브라우저의 이벤트/DOM/UTF8 크기/오류 상태·네트워크 요청 0. `tests/test_qr_ui.cjs` 17개 synthetic Node fixture 코드 갱신 및 `tests/test_package.py` 계약 추가했지만 새 17개 테스트 파일 자체는 runner에서 미실행. GitHub remote static 21/21. QR 실제 라이브러리 bitmap/디코딩·휴대전화 스캔·Windows PS5.1·Python ZIP 테스트는 미실행.
4. **상태:** QR UI 수정 완료/Chromium mocked 인수테스트 완료. 실제 QR 이미지 디코딩/휴대전화 오프라인 QR 스캔, A4 PDF 실기기, WinRE 백업 및 복구 QA 대기; 무료 다운로드/유료 서비스 게시 금지.
5. **발견한 문제/해결/중단:** 과거 QR 잔류는 사용자에게 다른 내용 공유할 수 있는 결함. onInput/생성 시도에 clear 수행해 해결. 네트워크 접근 금지된 도구 환경 때문에 벤더 QR 파일로 실제 픽셀 해독 검증 불가; 실제 소스 `ui/qrcode.min.js`를 가진 Windows 개발 환경에서 아래 browser smoke 실행. 임의 재시도·검증 없는 스캔 성공 주장 금지.
6. **브랜치·SHA·경로:** hibi89/AX_MART `feature/pc-care-usb`, 시작 HEAD `b171525c98e1c73a7f7844e427d3bf72ce9ed65b`. 핵심 `products/pc-care/ui/qr_ui.js`, `tests/test_qr_ui.cjs`, `tests/qr_browser_smoke.py`, `tests/test_package.py`, `README.md`, `docs/WINDOWS_TEST_PLAN.md`. 최신 SHA는 문서 커밋 뒤 재조회.
7. **Production/실행환경:** https://ax-mart.pages.dev/ Cloudflare 운영 main 수정 없음. Windows 11 + PowerShell 5.1, Edge/Chrome 실기기 목표. 브라우저 synthetic QA는 Linux Chromium (가짜 QR 생성자)에서만 실행.
8. **원본/백업/인증:** 기존 main·사용자 보고서·분석 스키마 보존, Git SHA로 복구 가능. 사용자 비밀/키/이벤트 원문/장치 ID를 QR/웹으로 보내지 않음. QR 원문은 촬영 시 제3자가 읽을 수 있음을 UI 고지, 수리 권한 자동 상승·서버 통신 없음.
9. **다음 우선순위/완료 기준:** ①실제 `qrcode.min.js` 렌더+OpenCV 정확 UTF-8 roundtrip: `python tests/qr_browser_smoke.py --chromium <경로>` (개발 환경/의존성 필요) ②Windows `RUN_SELF_TEST.cmd` PS5.1/parser/HTML JSON 저장+USB 권한/한글 경로 ③Edge/Chrome 인쇄 PDF A4 한 페이지 ④Android/iOS 스캔 및 텍스트 대조 ⑤Release A/B 게이트 독립 통과 후 사용자 승인하에 공개.
10. **작성/검증/재개:** 2026-10-30 KST, GitHub source 수정·정적 21/21, 로컬 Chromium mock 13/13 PASS. GitHub Windows Action 41034866482는 runner 미배정/steps=[]/FAIL, 그 뒤 수동-only. ZIP/PowerShell/QR 실제 디코드/WinRE 검증 대기. 다음 ㄱ은 원격 브랜치 HEAD·이 문서·STATUS·FINAL_SPEC 확인 후 QA 또는 독립 P0/P2 수정 재개.

## [최신] 2026-10-30 KST — QR 달력 검증/UTF-8 BOM 호환성 인수인계

1. **목표:** AXMART PC CARE P2 QR 오프라인 공유의 정확한 로그 기록 시각·실제 스캔 호환성을 강화. 기존 7줄 최소화 모델/문서·HTML 보존, main/배포 변경 없음.
2. **구현:** `ui/qr_ui.js`에서 `Date.UTC` 기준 실달력 검증을 추가. 2026-02-29/02-30 등 존재하지 않는 날짜 차단; 윤년 2024-02-29와 `미확인` 허용. `tests/qr_browser_smoke.py`는 실제 벤더 라이브러리 장착 시 날짜 5건 테스트와 선행 U+FEFF BOM 감지/명시적 1회 정규화/내용 SHA-256 대조를 수행하도록 보강.
3. **실행 테스트:** GitHub `ui/qr_ui.js` Git blob `13faebe44753b73f2a1cf9c99308aab220745276`와 로컬 bytes 동일. Linux Chromium 실제 UI JavaScript를 *모의 QR 생성자*로 구동하여 총 20/20 브라우저 조건 PASS(기존 13, 달력 7). Node --check 성공. 독립 Python qrcode/OpenCV reference에선 synthetic 한글 QR, BOM 없음/선행 BOM QR 디코딩 확인. 이는 실제 벤더 QR bitmap/스마트폰 스캔 증거가 아님. `tests/test_qr_ui.cjs` 21개 fixture 작성, GitHub runner 실제 실행 대기.
4. **진행/차단:** QR UI 날짜 방어 완료; 실제 QR 이미지/디코딩/BOM 처리·스마트폰·Windows/USB/WinRE·A4 인쇄·Python 전체 unittest/ZIP 런타임 미검증. 공개/판매 금지. Actions runner 이전 실패 41034866482, push 자동 재시도 꺼짐.
5. **기술위험·대안:** 벤더 qrcodejs 소스가 비ASCII 텍스트에 EF BB BF를 삽입할 수 있음. OpenCV는 독립 실험에서 복원 U+FEFF를 반환. 스캐너 검증기는 이 사실을 숨기지 않고 표시, 단일 선행 BOM 외 변경은 실패. 휴대전화 스캔이 불편하면 새로운 로컬 MIT 등 QR 인코더 교체 검토/승인 및 회귀 검증. 벤더 최소화 코드의 무증거 직접 패치 금지.
6. **저장소:** `hibi89/AX_MART`, `feature/pc-care-usb`; 새 주요 경로 `products/pc-care/ui/qr_ui.js`, `tests/test_qr_ui.cjs`, `tests/qr_browser_smoke.py`, `tests/test_package.py`, `docs/WINDOWS_TEST_PLAN.md`, `STATUS.md`; 문서 이후 SHA 검증.
7. **Production/실행:** AXMART³ `https://ax-mart.pages.dev/` Cloudflare main 미변경; 벤더 QR과 Windows 실행기 검증은 아직 운영 환경/일반 소비자 공개 대상 아님.
8. **안전/백업:** 원본 시스템/개인파일/복구키/장치 ID 변경·전송 없음. Git feature 커밋으로 복구 가능. 모든 QR/진단 테스트는 합성 데이터, 사용자 실제 로그 활용 금지. 인터넷 자동 전송 금지.
9. **다음 순서/완료조건:** ①실제 `qrcode.min.js` 로컬 Chromium 렌더 + QRCodeDetector & BOM 여부 확인(필요시 QR 인코더 비교) ②Windows PowerShell 5.1 테스트 및 보고서 저장/USB 안전성 ③A4 PDF/폰카 iOS·Android 스캔 ④WinRE 승인형 복구 분리 QA. 결과와 ZIP SHA 매칭 후 출시 평가.
10. **갱신 일시/검증 범위:** 2026-10-30 KST. 정확한 GitHub source 검증, headless Chromium mocked QR UI 20/20, 독립 Python reference QR decoding 성공; **벤더 QR/Windows 실제 QA는 미실행**. 본 문서가 다음 ㄱ의 기준.

## [최신] 2026-10-30 KST — QR UTF-8 원본 엔진 오류 수정 및 실제 모듈 디코딩 인수인계

1. **목표/용도/확정 요구/스택:** AXMART PC CARE Release A P2 개인정보 최소 오프라인 한글 QR 안정화, 7줄 상담 요약, 원인 미확정·로그 기록 시각 표시, 사용자 버튼 명시 생성. Windows PowerShell 5.1, HTML/CSS, 로컬 JS qrcodejs(MIT), Python/OpenCV는 개발 QA 전용.
2. **구현 완료·근거:** 동봉 `ui/qrcode.min.js`가 한글 이후 ASCII에서 이전 UTF-8 3바이트 버퍼를 재사용해 QR code length overflow 유발. 미니파이된 벤더의 단 하나 substring에 `b=[];` (5문자) 초기화 추가. 핵심 제품 설계/관리자 승인/로컬 HTML/보호 데이터 로직 변경 없음. 원본 MIT `ui/QR_CODE_LICENSE.txt` 그대로 보존.
3. **실제 테스트·증거:** 원본 벤더 `ui/qrcode.min.js` Git blob `993e88f396640f881b69f98db7a4d17401ef83ca`, V8에서 상담 문구(195 UTF8 bytes) QR 인코딩 시 `Error: code length overflow. (2180>1728)` 확인. 수정본 실제 vendor V8 실행 한글+ASCII 5종 및 ASCII 1종 **6/6 byte array 값 정확**, Unicode BOM EF BB BF 표기, 57×57 모듈/3개 finder 정상. 이 실제 QR module matrix를 Python OpenCV에 넘겨 **실제 디코딩 성공**; 텍스트는 한 글자 선행 `U+FEFF` 뒤 7줄 원문과 일치(원시 바이트 동일 아님). `tests/test_qr_vendor.cjs` 6개 Node 실제 vendor 테스트 작성하고 수동 CI 연결; GitHub Actions에서 신규 Node test 파일 자체는 러너 미배정으로 아직 미실행. Python 패키징 전체 suite/ZIP 실제 생성도 미실행.
4. **진행/대기/차단:** QR 용량 overflow 문제 수정 및 QR 행렬 데이터 복원 증명. 벤더 라이브러리 실제 브라우저 캔버스·Chromium/Edge/휴대전화 QR 읽기, A4 PDF 한 페이지/Windows 실행·USB/WinRE 안전성·스마트폰 BOM 사용성은 별도 미검증, 출시 전 차단. 전체 약 30% 보수적 추정.
5. **오류/원인/시도·금지 재시도/대안:** 이전 모의 QR constructor만으로 'QR 성공'이라고 단정하는 방법 반복 금지; 반드시 실제 vendor `ui/qrcode.min.js`를 이용. 5문자 최소 수정을 덮어쓰는 upstream 갱신 금지, 원본 SHA와 비교/Node regression 없이 재벤더링 금지. BOM은 원본 인코더의 특성으로 남아 있어 휴대폰 스캔 시 눈에 보이는지 확인; 필요할 때만 라이선스 명확한 대체 인코더 검토. 외부 QR API 전송 불허.
6. **저장소/브랜치/SHA/경로:** `hibi89/AX_MART` `feature/pc-care-usb` (시작 SHA `f775961a0e8a6bb840fa9af1be8c472c8be3b48d`). 주요 `products/pc-care/ui/qrcode.min.js`, `ui/QR_CODE_LICENSE.txt`, `tests/test_qr_vendor.cjs`, `tests/test_qr_ui.cjs`, `tests/qr_browser_smoke.py`, `tests/test_package.py`, `.github/workflows/pc-care-windows-synthetic.yml`. 최신 HEAD는 본 문서 이후 다시 확인.
7. **Production·Vercel/Cloudflare·명령/환경:** `https://ax-mart.pages.dev/` Cloudflare Pages main 운영 불변, feature 미배포. 로컬 QR QA `node --test products/pc-care/tests/test_qr_vendor.cjs` (개발용), `python products/pc-care/tests/qr_browser_smoke.py --chromium /path/to/chromium` (추가 playwright/opencv 및 원본 vendor 필요). Windows 실기기 `RUN_SELF_TEST.cmd` 우선. Vercel 적용 없음.
8. **원본/백업·권한/금지:** Git feature 커밋에서 최소 패치 revert 가능, 기존 전체 보고서/기기 데이터/운영 main 변경 안 함. BITLOCKER 복구키·로그 원문·개인 식별자를 QR/네트워크로 보내지 않음. 고객 기기 시스템 파일/디스크·부트로더 무단 변경 금지. 실제 Android/iOS 촬영 전 QR 내용 민감성 안내.
9. **다음 작업 우선순위·절차·완료 기준/승인:** QR 실제 브라우저 렌더 및 스캐너 시각 검증, BOM 사용자 체험 확인 → Windows PS5.1 전체 read-only fixture와 HTML/JSON 저장, USB·한글 경로·출력 실패 테스트 → A4 한 장 PDF → WinRE/백업 승인과 무변경 회귀 → 종합 QA 후 제품 무료 배포/크몽 서비스 등록은 사용자 승인. Windows Actions run 41034866482 실패(러너 0·steps[]), 수동-only 유지.
10. **갱신 일시·검증 범위·문서 기준:** 2026-10-30 KST. GitHub connector 소스 직접 실행(V8 QR 인코더), Python OpenCV 실모듈 디코딩 **PASS**, 신규 Node/Windows 자체 테스트 runner 실행 **미수행**. STATUS.md/README.md/docs/WINDOWS_TEST_PLAN.md와 동기화; 본 문서 커밋 후 GitHub feature HEAD 재검사.


## [최신] 2026-10-30 KST — P2 실제 QR 252 조합·오프라인 파일 브라우저 검증 인수인계

1. **목표·확정 요구·기술:** AXMART PC CARE Release A 고장 근거 요약을 한글 7줄·250 UTF-8 byte 이내 QR로 명시 생성. Windows PowerShell 5.1, MIT qrcodejs, 로컬 HTML/JS, 별도 개발 전용 Node/Playwright/OpenCV QA. 단일 원칙: 실제 UI·기기 작동을 검증하기 전 출시 금지.
2. **기능·변경·설계 근거:** 제품 JS/QR 라이브러리는 기존 설계 그대로 유지하며 실제 QR 인코딩 허용 조합 검증 확장. `tests/test_qr_vendor.cjs`에 상태×신호×생략 252회 반복 검증. `tests/qr_browser_smoke.py`를 한글 파일명 `file://` HTML / 외부 HTTP(S) 차단 / 전체 JavaScript 오류 검출 / PNG→OpenCV 정확 디코딩 테스트로 보강. 원본/고객 데이터 전송·복구 기능 변경 없음.
3. **테스트·명령·성공 실패:** GitHub의 실제 수정된 vendor source V8로 252개 유효 한글 문구에서 **252/252 PASS**, source payload max 228 bytes, QR matrix 53~61, BOM 선행 3바이트 명시. GitHub 정적 17/17. `node --test tests/test_qr_ui.cjs tests/test_qr_vendor.cjs`, `python tests/qr_browser_smoke.py --chromium <실행파일>` 두 정규 개발 테스트는 아직 실제 체크아웃 환경에서 미실행. Windows PowerShell 5.1/real HTML/PDF/Android/iOS/WinRE 미실행.
4. **완료·진행·대기·차단:** QR 인코더 자체의 다변량 V8 검사 정상; 정상 USB 고객 설치/실제 QR 픽셀 브라우저 스캔·A4 한장·WinRE 승인 검증은 차단. 전체 프로젝트 약 31% 추정. 인코더 검사 PASS를 UI/스마트폰/제품 출시 PASS로 확대 금지.
5. **오류·원인·시도·중단·대안:** 상류 MIT qrcode.min.js 공용 소스를 컨테이너로 다운로드해 Github 원본과 blob 대조하고 로컬 Chromium에서 돌리려 했지만 raw/CDN/HTML 파일 다운로드 제한. 동일 방식 무의미한 재시도는 중지. 최선은 소스 체크아웃+Chromium Playwright가 모두 있는 실제 개발자/Windows 환경에서 원본 고정 테스트 실행. 자동 CI runner도 미배정(run 41034866482)이라 수동 워크플로만 유지.
6. **저장소·브랜치·SHA·주요 경로:** hibi89/AX_MART feature/pc-care-usb (작업 시작 SHA f4e494dc716000c1ad0b845342cacf3e6e50183b), `products/pc-care/tests/test_qr_vendor.cjs`, `tests/qr_browser_smoke.py`, `ui/qrcode.min.js`, `ui/qr_ui.js`, `tests/test_package.py`, `README.md`, `docs/WINDOWS_TEST_PLAN.md`; 문서 최신 커밋 후 HEAD 다시 확인.
7. **Production/실행환경:** https://ax-mart.pages.dev/ Cloudflare main 미변경, Vercel 미대상. Windows 11 x64/Windows PowerShell 5.1 및 Edge/Chrome/USB 우선, Linux Node+Chromium은 합성 개발 검증만.
8. **원본·백업·권한·금지:** Git feature SHA로 최소 롤백 가능, MIT 원문·vendor 5자 버퍼 수정 보존. 사용자 보고서/로그·일련번호·BitLocker/민감 키/파티션 조작·네트워크 발송 없음. QR 공유는 사용자가 미리보기/생성 버튼을 직접 선택.
9. **다음 우선순위·절차·완료조건:** (1) git checkout된 Windows/Linux 브라우저 환경에서 실제 QR canvas PNG+OpenCV 디코드 (2) Windows 일반 사용자 `RUN_SELF_TEST.cmd`, 로컬 JSON+HTML·USB 한글 경로 및 권한 실패 (3) Edge/Chrome A4 PDF 1장·폰카 UTF-8/BOM 스캔 (4) Release B WinRE/파일 복사 별도 VM 안전성·두 단계 승인 (5) 공식 출시/크몽은 사용자 승인. CI 대기 때문에 다음 독립 오류 수정까지 막지 않음.
10. **갱신 일시/검증 범위·문서 기준:** 2026-10-30 KST. 실제 GitHub vendor V8 252/252 인코딩, 소스 교차 검증 17/17. GitHub CI·제품 Windows/browser/phone 스캔 미검증. STATUS.md와 동일 단계, HEAD 커밋은 후속 도구로 재조회.


## [최신] 2026-10-30 KST (PC CARE 메뉴 구현, 실기기 미검증) — 비관리자 START 메뉴

1. **목표/환경:** 확정 FINAL_SPEC_V2 홈 진입점 구현, Windows 11 x64/CMD, USB/폴더 공통, 오프라인 기본.
2. **완료/근거:** 신규 `START_PC_CARE.cmd` 선택지 1/2/3/4/0. 오직 기존 읽기 전용 진단/자가검사만 연결하고 복구 및 수리는 안내 텍스트에 한정. 기존 건강검진·QR·상담표·DISM/SFC 파일 미수정.
3. **테스트:** GitHub 코드를 대상으로 allowlist 및 금지 명령·전달 경로 정적 계약 확인. Windows 실제 CMD, PowerShell5.1, Python unittest, ZIP 생성, QR 브라우저/실폰, A4 PDF **미검증**. 정적 확인을 런타임 PASS로 간주하지 않음.
4. **상태:** 시작 메뉴 소스 완료, 실제 기기 및 QA 대기. Release A/B 완성/출시 승인 아님.
5. **문제/대안:** Linux 개발환경에는 Windows cmd.exe/PS5.1 없음. 동일한 도구로 Windows 결과를 추정하지 말고 표준 사용자 Windows11/USB에서 테스트. GitHub Actions runner 미배정 41034866482 재시도 반복 금지.
6. **저장소/브랜치/SHA:** hibi89/AX_MART `feature/pc-care-usb`. 이전 SHA `92294f15486e63d08c4b707024c0409779e1ba92`; 주요 신규 경로 `products/pc-care/START_PC_CARE.cmd`, `tools/release.py`, `tests/test_package.py`, `tests/test_release.py`.
7. **Production/실행:** Cloudflare `https://ax-mart.pages.dev/` 는 `main` 전용이며 이번 기능 미배포. Windows 실행은 ZIP 해제 후 `START_PC_CARE.cmd`를 직접 선택.
8. **원본/보안:** Git 이전 SHA로 복구 가능. 기존 보고서·사용자 원본/비밀키·배포 자산 미수정. 시작 메뉴가 시스템 수리 명령/관리자 요청/네트워크·삭제를 수행하지 않음.
9. **다음 순서:** Windows11 CMD에서 1/2/0 및 누락 파일·표준 권한·USB 특수문자 테스트→로컬 HTML/JSON/QR·A4 한 장→Windows 10/WinRE/VM에서 별도 안전 시험→검증 후 사용자 출시 승인.
10. **갱신:** 2026-10-30 KST. GitHub 작업 브랜치 코드 및 정적 계약만 검증, 기준 변경 전 커밋 `92294f1`; 변경 후 실제 HEAD 재조회.

## [최신] 2026-10-30 KST — P0 원자적 신규 파일 생성·타 실행 결과 보존
1. **목표/스택:** AXMART PC CARE Windows PowerShell5.1 보고서 페어(JSON/HTML) 생성 충돌·타 실행 결과 보존 안전 보강.
2. **변경:** `report_io.ps1`의 Check-then-WriteAllText 경쟁 조건을 `FileMode.CreateNew`로 해결. File.Move는 기존 최종 파일 덮어쓰기 거부, catch는 `ownedJson/ownedHtml/movedJson/movedHtml` 플래그가 참인 본 실행 생성물만 정리.
3. **테스트:** `report_io.tests.ps1`에 다른 실행의 부분파일 시뮬레이션 및 한쪽 최종 HTML 보존 시험 추가. `test_package.py` 정적 계약 갱신. Windows 파서/실행, Python 전체 suite 및 ZIP 빌드 **미실행**. GitHub 원본 문자열·코드 구조 정적 대조만 수행.
4. **상태:** P0 파일 저장 안전장치 코드 업데이트. 동시성·전원중단·Windows 실제 QA 여전히 대기. Release A/B·무료 공개·판매 금지.
5. **오류/피벗:** 과거 Test-Path 이후 WriteAllText는 파일 생성 사이 경쟁 시 기존 임시 파일을 덮어쓸 수 있음. 소유권 없는 파일 삭제도 위험. 더 이상의 파서 없는 'PASS' 주장은 금지. Windows sandbox에서 정상/충돌 fixture 검증.
6. **저장소/브랜치/경로/SHA:** `hibi89/AX_MART` / `feature/pc-care-usb`; 변경 전 `9087a3bc3b72c14e3b8730d6f4709b9dbdc50056`. `products/pc-care/tools/report_io.ps1`, `tests/report_io.tests.ps1`, `tests/test_package.py`.
7. **배포/환경:** `https://ax-mart.pages.dev/`는 Cloudflare main 전용, 변경/배포 없음. Windows 11 x64 PS5.1/표준 권한에 대한 실제 테스트 대기.
8. **원본/백업/보안:** 기존 보고서·QR·진단 원본 및 실제 개인정보 미변경. Git 이전 SHA로 제품 코드 복원 가능. 시스템 변경/수리 명령/외부 통신 추가 없음.
9. **다음 작업:** 독립 Windows11에서 `RUN_SELF_TEST.cmd`로 report_io fixture + 생성 보고서 검증 → 읽기 전용/권한 거부/동시 실행 실증 → QR/PDF/USB/WinRE 별도 안전 게이트.
10. **갱신:** 2026-10-30 KST. 정적 계약 확인만, 브랜치 HEAD는 새 커밋 적용 후 재조회.

## [최신] 2026-10-30 KST — 자가검사 결과 일치 보강
1. 목표: Windows 자가검사가 다른 프로세스의 보고서를 오인하는 경쟁 상태 차단. PowerShell 5.1/CMD 오프라인.
2. 변경: `diagnose.ps1` 진단 완료시 선택적 `-PassThru` 경로 receipt 및 `-NoOpenReport` 추가. `windows_smoke.ps1`에서 파일 시간 스캔 삭제, 실제 반환한 JSON/HTML 페어 경로/이름/위치/존재 검증. 기존 사용자 실행기 기본 동작과 수리 코드는 보존.
3. 테스트: 파라미터/스모크/정적 테스트 소스 교차 확인만. 실제 PowerShell5.1, Windows11, Python 전체 suite/ZIP, 실기기 QR·A4·USB·WinRE **미실행**.
4. 상태: 코드·테스트 소스 반영 대상, 기능 검증 대기. 릴리스 및 공개 다운로드 차단 유지.
5. 오류: 이전 최신 파일 LastWriteTime 탐색은 동시 실행의 타 결과를 수용할 수 있음. 정확한 경로 receipt로 해결 시도, Windows 환경 실제 경쟁 테스트 필요.
6. 저장소: hibi89/AX_MART `feature/pc-care-usb`; 작업 전 SHA `3da0c5bb236064328e1c506143a48ce9f20dadea`; 대상 `products/pc-care/tools/diagnose.ps1`, `tests/windows_smoke.ps1`, `tests/test_package.py`.
7. 배포: Cloudflare https://ax-mart.pages.dev/ 운영 main 수정 없음. 제품 ZIP/판매도 변경하지 않음.
8. 보안: 고객 실데이터·보고서 업로드 없음. receipt는 테스트 함수로만 반환하며 일반 보고서 로컬 저장 유지. 기존 SHA 복구 가능.
9. 다음: Windows 11 PowerShell5.1 파서·fixtures·실제 read-only 출력과 USB 한글/공백 경로 테스트→오프라인 QR/PDF→WinRE 격리 승인.
10. 갱신: 2026-10-30 KST. GitHub 원격 소스 정적 검토 및 새 커밋 반영 후 HEAD 재확인.

## 2026-10-30 KST — 자가검사 receipt 블록 구문 복구
- 이전 2c83634 커밋의 windows_smoke.ps1에 중복된 JSON 검사와 잘린 정규식 문장이 발견되어 정상 실행을 방해할 위험이 있었다. 해당 블록을 단일 유효 구조로 교체, [.]json filename 매칭 및 경로/파일 검증 보강, 정적 테스트 동기화.
- 실제 Windows PowerShell 5.1 실행·VM/USB/WinRE/QR/A4 검증 여전히 대기. 2c83634 이전 소스 기준 복구 가능. 운영 main/Cloudflare 미변경.

## [최신] 2026-10-30 KST — 공급자 이름 오탐 방지 인수인계
1. 목표/스택: PC CARE Windows/PS5.1 오프라인 오류 증거의 신뢰도 개선과 JSON 버전 명시.
2. 변경: 이벤트 1001/41/6008/스토리지 소스 이름을 앵커 화이트리스트로 제한; JSON 루트 schemaVersion=1; fixture·스모크·정적 가드 추가.
3. 테스트: 소스 기반 14개 regex 경계 사례 교차검증, Windows PowerShell5.1/전체 테스트/USB/QR/PDF **미수행**.
4. 상태: 코드·테스트 소스 완료, 실기기 및 OEM 공급자 테스트 대기, 배포 미승인.
5. 위험/대안: 부분문자열은 오탐 가능, 엄격 필터는 OEM 누락 가능. 실제 공급자명+EventID로 보정; 원본 개인정보 공유 불필요.
6. GitHub: `hibi89/AX_MART` `feature/pc-care-usb`, 수정 전 `092864ccbedd7b185176e262bf54a51814fea7f4`; `products/pc-care/tools/event_analysis.ps1` 및 테스트·보고서 파일.
7. Production: https://ax-mart.pages.dev/ 운영 main 미변경/feature 미배포.
8. 보안/복원: 이전 SHA 복구 가능, 시스템 변경·원본 사용자 데이터·BitLocker 키·외부 네트워크 다루지 않음.
9. 다음: Windows PS5.1 fixture, 실장치 공급자 확인 → 로컬 A4/QR/USB 검증 → 격리 VM WinRE 승인형 QA.
10. 기준: 2026-10-30 KST, GitHub 코드·V8 정규식 모델; Windows OS 런타임 미검증.
