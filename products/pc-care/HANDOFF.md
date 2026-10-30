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

## [최신] 2026-10-30 KST — 이벤트 공급자 정확도/JSON schemaVersion 인수인계
1. 목표/기술: Windows11 PowerShell5.1 오프라인 건강검진에서 유사 이름 이벤트 공급자의 오탐 방지, JSON 스키마 버전 명시.
2. 완료: event_analysis.ps1 공급자 앵커 allowlist, diagnose.ps1 schemaVersion=1, 5개 음성 synthetic fixture 및 Windows smoke/Python 계약 검사. 원래 수리/WinRE/QR 인터페이스 변경 없음.
3. 테스트: 14개 공급자 정규식 V8 모형 테스트 PASS, GitHub Base64 blob 바이트 단위 readback. Windows PS5.1 파서/fixture·Python 전체 테스트·실기기 USB·QR/A4·WinRE 검증 미수행.
4. 상태: 소스 작성 및 GitHub 저장 무결성 확인, 실제 Windows/OEM 테스트 대기. 공개/무료/크몽 배포 불가.
5. 문제/원인/피벗: 기존 부분문자열 매칭 오탐, 엄격 매칭 OEM 누락 위험. 중간 결함 코드 a7b6c4d는 JS replace 특수 $ 문자 확장에 의한 중복이었으며 e39f345 롤백으로 복원; 재시도 금지. 함수형 치환 + Base64 blob readback 방식 채택.
6. 저장소/브랜치: hibi89/AX_MART, feature/pc-care-usb, 복구 기준 e39f345a88d8f03d3cfb1432ca7cee0e2b9b9dc3. 경로 products/pc-care/tools/event_analysis.ps1, diagnose.ps1, tests/.
7. Production: https://ax-mart.pages.dev/ Cloudflare main 불변. Windows 실행명령 RUN_SELF_TEST.cmd 또는 START_PC_CARE.cmd, feature 미배포.
8. 원본/보안: 사용자 로그·민감정보 업로드 없음; 시스템 파일/파티션/BitLocker/수리 실행 변경 없음. Git SHA로 되돌리기 가능.
9. 다음 순위: Windows 11 PS5.1 syntax + fixture + 표준 사용자 진단, 실 OEM 이벤트 공급자 확인 → USB 한글/특수경로 → QR 실제 스캔·A4 PDF → WinRE/안전 수리 별도 VM/승인 후 출시 판단.
10. 확인/갱신: 2026-10-30 KST, GitHub 원격 바이트 및 JS regex 모델, 실제 Windows/Production 동작 검증 범위 제외. 변경 후 HEAD 확인.

## [최신] 2026-10-30 KST — H08 반복진단 오프라인 수동 비교 1단계
1. **목표·기술:** AXMART PC CARE Release A H08, 파일 탐색기 수동 선택/브라우저 JS만으로 같은 PC의 반복 검사 두 건 비교. 관리자 권한·네트워크·PowerShell 추가 권한 불필요.
2. **완료 기능·설계 결정:** ui/history_compare.html/js 추가. 사용자가 이전·현재 JSON을 명시 선택하고 신규/미관찰 경고 코드, 드라이브 가용 GB, 조회조건이 같은 이벤트 신호 수, 저장장치 경고 합계만 비교. 같은 PC·디스크인지 보증 못하므로 주의 문구 제공. 자동 이력 검색/삭제 대신 사용자 수동 제어 선택.
3. **테스트:** 순수 JS V8 synthetic 16/16 통과. test_history_compare.cjs Node 9 테스트 등록, 패키지 allowlist/메뉴/CI 연결. 원본 Git Blob readback 확인. 실제 Node/Windows PowerShell5.1·Edge/Chrome file://·USB·QR/PDF·WinRE·ZIP 빌드 미실행.
4. **완료/대기:** H08 수동 비교 UI와 소스 완료, 자동 보존기간·검색·삭제 UI/실기기 QA 대기. Release A/B 출시 승인 아님.
5. **오류 근거·대안:** 다른 PC의 리포트 혼합/개인정보 과잉 읽기 위험으로 사용자가 2개 파일 직접 선택. malformed/2MB 초과/미지원 스키마 차단. 기존 GitHub long Unicode Base64 문서 Blob 오류 발생 → 직접 UTF-8 Blob 저장 및 readback 검증. CI runner 미배정 재시도 반복 금지.
6. **저장소·브랜치·SHA:** hibi89/AX_MART feature/pc-care-usb, 작업 시작 789a831f0e21f52071f642effafee94ca0a89141. 파일 ui/history_compare.html/js, tests/test_history_compare.cjs, START_PC_CARE.cmd, tools/release.py, test_release.py, test_package.py 및 문서.
7. **Production/실행 환경:** https://ax-mart.pages.dev/ Cloudflare main 미변경/미배포. Windows CMD 시작 메뉴 5, 아니면 ui/history_compare.html 직접 열기. JS 로컬 File API, account/server 없음.
8. **원본·백업·보안:** 기존 보고서/수리·WinRE/PC 시스템·BitLocker·사이트 코드는 수정하지 않음. 보고서를 브라우저 메모리에서만 읽고 업로드/삭제/자동 보관하지 않음. Git 이전 SHA로 복원 가능.
9. **다음 작업:** Node 테스트 실제 실행→Windows 11 표준권한 메뉴5/0→Edge/Chrome file:// 2개 진짜 JSON 실험(한글 USB 경로·오프라인)→A4/QR/WinRE 안전성 별도 검증. 출시 전 사용자 승인 필수.
10. **갱신/검증 범위:** 2026-10-30 KST. 순수 V8 비교 로직 및 GitHub 소스 읽기 일치만 입증. Windows/Production/USB·실기기 브라우저 미검증. 최종 HEAD 반영 후 재조회.

## [최신] 2026-10-30 KST — H08 Node 실검증 및 비동기 결과 경합 인계
1. **목표·기술:** 오프라인 Windows PC CARE H08 수동 JSON 비교 결과의 파일 변경 경합 방지, Linux Node 22와 가상 DOM에서 재현 및 시험.
2. **구현/근거:** JS `selectionRevision`으로 선택 상태가 바뀌면 이전 JSON 비교 또는 파싱 실패 메시지를 렌더하지 않음. `tests/test_history_dom.cjs` 파일선택 UI 5종, CI·Python 정적 계약, README 갱신. 원본 진단/복구·REPORTS 불변.
3. **테스트 명령/성공·실패:** `node --test tests/test_history_compare.cjs tests/test_history_dom.cjs` Linux Node v22.16.0, **14/14 PASS, 0 FAIL**. 소스 SHA `bd793bb5cf1dabbbb82ba4210faade3b7f22994a`, DOM fixture `93679760ea7e090bb33af0e07846e9040d7c3605`. Chromium 144 실제 file://, localhost 모두 `ERR_BLOCKED_BY_ADMINISTRATOR`; 코드 실행 확인 불가.
4. **상태:** 비교 순수 JS+가상 DOM 검증 완료. Windows 11 Edge/Chrome file:// USB·CMD·PowerShell·실제 QR/PDF·WinRE **검증 대기**. H08 자동 저장/삭제 미구현; 일반 출시 금지.
5. **장애 계층/시도·대안:** 브라우저 두 주소가 관리자 정책 차단, 제품 버그 단정 불가. 동일 환경 우회/반복 금지. 실제 Windows 사용자 환경에서 정상 접근 확인 또는 별도 승인된 브라우저 시험 환경. Node 가상 DOM은 브라우저 검증을 대체하지 못함.
6. **저장소/브랜치/SHA:** hibi89/AX_MART `feature/pc-care-usb`, 시작 `518413d3def107633b1215eeddf5f30be067e4e8`, `products/pc-care/ui/history_compare.js`, `tests/test_history_dom.cjs`, CI/README/tests/evidence.
7. **Production:** https://ax-mart.pages.dev/ 운영 main/배포 불변, feature 브랜치 내부 시험만. 실행: 사용자 PC `START_PC_CARE.cmd` 메뉴 5; 개발 QA Node 22.
8. **원본/백업·보안:** 이전 HEAD로 소스 복구 가능. 원본 보고서/개인 정보 전송 없음, 디스크·레지스트리·BitLocker/수리 변경 없음. Chromium 정책 우회 시도 금지.
9. **다음 우선순위/완료 기준:** Windows 실장치 Edge file:// 두 JSON 선택/네트워크 0·콘솔 오류 0 확인→CMD 메뉴5/0·PowerShell5.1 fixtures→한글 USB·QR 실 스캔/A4 PDF→WinRE 격리. 공개·유료 배포는 사용자 승인 전 보류.
10. **갱신 KST·검증 범위:** 2026-10-30, SHA 확인된 GitHub 원본 JS/fixture를 Node 실제 실행; 브라우저 접근 실패는 환경 정책. 최종 HEAD 커밋 후 재확인.

## [최신] 2026-10-30 KST — H08 관측값 미확인·불완전 비교 오판 차단
1. **목표·기술:** AXMART PC CARE Release A H08, JS/Node 오프라인 진단 비교의 불완전 근거를 오류 없이 표현. 보고서 `schemaVersion=1`, `observations.collectionStatus.physicalDisks` 계약 활용.
2. **완료/설계:** 경고 목록 없는 JSON은 기존 빈 배열처럼 '없음' 표시하지 않고 null=비교 불가. 저장장치 건수 비교는 양쪽 결과가 collected이고, 비어 있지 않고, 장치 수가 같고, 미확인 상태가 없을 때만 허용. 하드웨어 추적용 시리얼/식별자를 추가하지 않으며 물리적 동일성 보증 없음.
3. **검증 명령/결과:** Linux Node v22.16.0 `node --test tests/test_history_compare.cjs tests/test_history_dom.cjs` **18 PASS/0 FAIL**, 실제 프로세스 exit 0. JS 및 두 테스트 Git hash-object SHA 각각 `56ecd3f0`, `d94edc31`, `958b5a68`; GitHub Blob readback 확인. 테스트 증빙 `tests/evidence/history_fail_closed_qa_20261030.json`.
4. **상태:** H08 수동 반복 비교 안전성 보강 완료(전체 제품은 부분 완료). 자동 보관/검색/삭제 기능 미구현. Windows·USB·WinRE 실기기 QA 대기, 일반 배포/판매 중단.
5. **원인·재시도 금지·대안:** 이전 빈 physicalDisks 배열이 경고 0건으로 해석되는 오탐과 `issues` 누락이 '없음'으로 표시되는 오탐. 개인 시리얼 수집 대신 fail-closed 비교. 기존 Chromium file:///localhost 관리자 정책 차단 `ERR_BLOCKED_BY_ADMINISTRATOR`로 제품 정상/오류 판정 불가, 우회·무의미한 재시도 금지.
6. **GitHub:** `hibi89/AX_MART`, `feature/pc-care-usb`, 이전 정상 SHA `712db3ab8d70dda8f3ad61604668747d816dcb98`; `products/pc-care/ui/history_compare.js`, tests 및 docs.
7. **Production/환경:** `https://ax-mart.pages.dev/` 운영 `main` 불변·미배포; Windows 메뉴 5→로컬 HTML, QA는 Linux Node22.
8. **원본·백업·보안:** 이전 커밋으로 코드 복원 가능, 실제 PC 고객 로그/BitLocker 키/시스템 수정·권한 상승·외부 통신 없음. 보고서 자동 읽기/삭제 없음.
9. **다음 우선순위/완료:** Windows11 PowerShell5.1 실제 보고서 생성→같은 PC 2회 JSON을 Edge/Chrome `file://`에서 비교 및 Network/Console 무오류→USB 한글/특수문자→QR/A4 PDF→VM WinRE/Release B 승인형 안전 시험. 공개/판매 사용자 별도 승인 필수.
10. **갱신/검증 범위:** 2026-10-30 KST, Node 18/18 및 Git SHA만 검증. 전체 Python/ZIP, Windows/Production 미검증. 변경 후 GitHub HEAD 재조회.

## [최신] 2026-10-30 22:27 KST — H08 날짜 파싱 정확성 및 안전한 상태 출력
1. **목표·확정기술:** PC CARE Release A의 수동 JSON 두 건 비교 기능(H08), Windows PS5.1 생성시각 `yyyy-MM-dd HH:mm:ss zzz`을 OS/브라우저 차이 없이 UTC로 환산하고 출력 안전성 강화. 서버/계정/사용자 로그 전송 없음.
2. **구현·결정:** `ui/history_compare.js`의 `Date.parse` 제거, 엄격한 숫자/실제 캘린더(윤년 포함)·UTC 오프셋 파싱. 서로 다른 시간대의 동일 순간 거부. 예상 범위 밖의 `assessment` 텍스트는 `확인 불가`로 최소화. 기존 메뉴/파이프라인/저장 경로/수리 불변.
3. **테스트:** 개발용 Linux Node v22.16.0에서 `node --check ui/history_compare.js` PASS, `node --test tests/test_history_compare.cjs tests/test_history_dom.cjs` **22 PASS/0 FAIL**. Git Blob SHA `c57d4fd2e98bd4f0bbe53dc7570f284ca5442de8` 및 `5c533efe63ac8db0c9e8a07072303f2d73243dea` 일치. 신규 test_history_compare.cjs 4가지 회귀와 Python 정적 가드. 증빙 `tests/evidence/history_date_offset_qa_20261030.json`.
4. **상태:** H08 반복 검사 비교의 비표준 날짜 의존 및 오염된 상태 텍스트 방어 구현. Release A 전체 여전히 부분 완료. Windows/브라우저/USB/WinRE QA 대기; 일반 유통 금지.
5. **실패·위험/대안:** JS `Date.parse` 비표준 날짜 포맷은 구현별 허용/오해 위험; 직접 엄격 파싱으로 전환. `assessment`의 임의 텍스트 노출 위험을 allowlist로 제한. 미래 포맷의 날짜는 JSON schemaVersion 업그레이드/테스트 동반 필요. 기존 Chromium sandbox의 `ERR_BLOCKED_BY_ADMINISTRATOR` 우회·재실행 금지; Windows 기기에서 안전한 실제 file:// 테스트 권고.
6. **GitHub:** `hibi89/AX_MART` `feature/pc-care-usb`, 변경 전 `4af8e8b0ffaccf78fb5d90898d19017d8b8c9dc7`; 주요 파일 `products/pc-care/ui/history_compare.js`, `tests/test_history_compare.cjs`, `tests/test_package.py`, 테스트 증빙, 문서.
7. **Production/실행:** Cloudflare `https://ax-mart.pages.dev/` 운영 main 불변, feature 개발/배포 미적용. 사용자 PC는 `START_PC_CARE.cmd` 5번으로 수동 진입.
8. **원본/보안·백업:** 기존 REPORTS/컴퓨터 설정/BitLocker/관리자 수리 및 개인 데이터 수정·전송 없음. 원래 브랜치 SHA를 복원 지점으로 보유, Git 강제 기록 수정 금지.
9. **다음 우선순위·완료 기준:** Windows11 PS5.1 구문·읽기전용 진단 실제 실행→Edge `file://`에서 같은 PC 2회 JSON 비교(윤년·다른 시차 synthetic 포함)→한글 USB/QR 실제 스캔/A4 PDF/WinRE VM 안전성 검증. 사용자 승인 없는 다운로드·판매 금지.
10. **갱신 시점·검증 범위:** 2026-10-30 22:27 KST. Node·소스 해시만 확인; 전체 Python/ZIP/실기기 OS·브라우저·Production 미검증. 최종 HEAD는 커밋 후 원격 재확인.

## [최신] 2026-10-30 KST — H08 확장 신호 3종 / CI 비차단 운영 인계
1. **목표·기술:** AXMART PC CARE Release A H08의 실질적인 변화 탐지 확대. 오프라인 두 리포트 비교에 Windows build, WindowsUpdateClient 설치 실패 이벤트, PnP 구성 코드 관측 건수 추가. 기존 WinPS5.1 생성 JSON/HTML/CMD에 새 권한 없음.
2. **구현·설계:** 순수 JS 모듈 `ui/history_signals.js`를 별도 파일로 분리하고 기존 `history_compare.js/html`에 연결. 상태/표본/조회기간 완전한 때만 비교, 오염·누락·상한 도달이면 '비교 불가'. 동작상 비교 신호는 원인 확정이 아니며 개인정보/디스크 ID 추적 추가 없음. Python 패키지 allowlist와 Windows CI Node suite 연동.
3. **실행 테스트:** Linux Node v22.16.0 `node --test tests/test_history_signals.cjs` 신규 7/7 PASS/0 FAIL; GitHub 원본을 사용한 V8 단일 통합 시나리오 PASS. 새 모듈 Blob `f4d47bd2f0bb9850019b0fd3feb81a0dfd50c1fe`; 회귀 Blob `5b0d3a4db182314371c56d0aa9fcc0db2426a316`. 변경 후 과거 22개 suite / Windows CI / 전체 Python / ZIP 실제 실행은 미검증.
4. **현상태:** H08 수동 비교 필드 확대 완료, Release A 전체 및 실제 Windows QA 미완료, H08 자동 저장·삭제 미구현. 출시/판매 차단 유지.
5. **CI 실패·원인/재시도 금지:** Actions run 41034866482 failure, job에 steps 비어 있어 테스트 실행 증거 없음. GitHub 연결 기능에 신규 workflow_dispatch가 없고, runner 미배정 원인 재현·확정 불가. 무의미한 rerun 반복 금지; 새 실행 권한/runner 이용가능 상태일 때 별도 1회 확인. 내부 로컬 테스트 우선.
6. **저장소·브랜치:** `hibi89/AX_MART`, `feature/pc-care-usb`, 기준 `04d9979b89739c4dfaad336875489aaeca9b02c3`. 새 파일 `products/pc-care/ui/history_signals.js`, `tests/test_history_signals.cjs`, `tests/evidence/h08_extended_signals_qa_20261030.json`; 기존 JS/HTML/ZIP CI/tests/docs 변경.
7. **Production/실행:** `https://ax-mart.pages.dev/` Cloudflare main 불변; 제품은 `START_PC_CARE.cmd` 메뉴 5 또는 `ui/history_compare.html`, 브라우저 로컬 JS, 데이터 업로드 없음. Node는 개발용 QA만 사용.
8. **원본·백업/보안:** 전 feature SHA로 복원 가능, 실제 사용자 데이터/Windows 설정/BitLocker/WinRE/수리 코드/게시 상품 불변. Git secret 없음, source는 읽기 전용.
9. **다음 실행 계획:** 개별 CI 실패를 막힘으로 취급하지 않고 남은 Release A(오프라인 보고서·이력 관리·QR/PDF)의 기능 완성 병렬 진행. Windows 표준권한 실증 → file:// UTF-8/USB → 1페이지 PDF·휴대폰 QR → WinRE 별도 VM/승인 Gate. 완료 전 판매 금지.
10. **확인·검증:** 2026-10-30 KST GitHub 원격 원본 JS/Blob 무결성 + Node 신규 7 tests + V8 통합. Windows/Edge/USB/WinRE·전체 CI 등 **미검증**; 커밋 후 최종 SHA 재확인.

## [최신] 2026-10-30 KST — H08 multi-file batch 선택·검증 인수인계
1. **목표·용도·기술:** PC CARE Release A H08, 사용자 로컬 기존 진단 보고서 2~25건을 편리하게 비교. Windows 설치/계정/서버/추가 권한 없이 브라우저 File API/JS.
2. **완료 기능·결정 근거:** `history_compare.html/js`에 다중 파일 input(25건·총12MB·개별2MB), JSON schema·시간 검증/시간순 목록, 허용 상태명, 과거/현재 선택, 기존 비교 경로 연결. 파일명·경로 비노출. 자동 탐색/보관·삭제는 기기 안전을 위해 추가하지 않음; 수동 2파일 방식을 보존.
3. **테스트·성공/실패:** Linux Node v22.16.0 `node --check ui/history_compare.js && node --test tests/test_history_*.cjs` **37 PASS/0 FAIL**. 이전 29개+신규 8개 VM mock DOM. 셀프 파일 선택, malformed batch 전체 차단, 개수/총용량, 중복 선택, manual override, stale async, 인덱스 변조, 불명확한 시각/민감 텍스트 검증. 원격 blob readback 및 Git hash-object 확인.
4. **상태:** 기능 소스·Node QA 완료, Windows 실제 구동/USB·브라우저·WinRE·판매 배포 **검증 대기**. H08 자동 보관/삭제 UI 미구현. 전체 제품 부분 완료.
5. **문제·실패 근거·대안:** 기존 Chromium 브라우저 테스트 환경은 관리자 정책으로 file:// 접근 거부. 이 환경 우회/반복 금지. GitHub CI 이전 run 41034866482 job steps 없음·failed, 새 workflow dispatch 도구 없음. Windows 실기기에서 별도 검증하거나 CI runner 가용 시 실행; 테스트 통과 주장 금지.
6. **저장소·브랜치·SHA·경로:** `hibi89/AX_MART`, `feature/pc-care-usb`, 백업 HEAD `b64635b25355963544303acd803c73f78db31d07`. 신규 `products/pc-care/tests/test_history_batch.cjs`, `ui/history_compare.js/html`, `tests/evidence/h08_batch_history_qa_20261030.json`, docs, CI.
7. **Production/실행:** `https://ax-mart.pages.dev/` Cloudflare main `fbb32362455378b85bcdd0b5037d1f338055fb71` 미변경; `START_PC_CARE.cmd` 메뉴5→로컬 HTML. JS는 업로드/네트워크 전송 없음.
8. **원본·보안·복구:** 원본 PC 데이터/REPORTS/수리·WinRE/BitLocker 설정 미변경. 사용자가 브라우저에서 명시 선택한 JSON만 메모리 읽기. Git 이전 HEAD로 복원, force push 없음.
9. **다음 우선순위·완료기준·승인:** Windows11 표준 사용자 진단 두 건→Edge file:// batch UI·한글 USB 경로·네트워크 0·오류 0→A4 인쇄/휴대폰 QR/WinRE VM 통과. 출시·다운로드/결제 활성화는 별도 사용자 승인 필요.
10. **갱신 시각/검증범위:** 2026-10-30 KST. 실제 Node 37/37·SHA 검증, Windows/브라우저 실기기·전체 Python/ZIP·Cloudflare Production 적용 미검증. 작업 후 원격 Git HEAD 재확인.

## 2026-10-30 — 개발 QA 통합 인계
1. 목표: Release A/B 개발 QA 병렬화. 기존 사양 유지.
2. 구현: `tools/preflight.py` 병렬 Python/Node/임시 ZIP 검사, `tests/test_preflight.py` 4개, CI ZIP 확인.
3. 실행: Linux Python 3.13.5 전용 테스트 4 PASS/0 FAIL, `py_compile` PASS. 전체 프로젝트 suite 미실행.
4. 상태: 개발 QA 도구 완료, 실제 Windows/USB/QR/PDF/WinRE QA 대기.
5. 장애: 전체 비공개 원본을 이 환경에 내려받을 수 없음. CI 기존 실패 run 41034866482 반복 재시도 금지.
6. 위치: `hibi89/AX_MART` `feature/pc-care-usb`, 백업 SHA `de5da50f851bfd18b75e9e78fa8b7dceef380f3d`.
7. 환경: 운영 `https://ax-mart.pages.dev/` 불변. 개발 환경 Python/Node.
8. 보존: 원본 보고서·수리 코드 수정 없음. 내부 ZIP은 임시 생성 후 폐기.
9. 다음: `python tools/preflight.py` 전체 환경 실증, Windows 현장 테스트 후 별도 출시 승인.
10. 확인: 2026-10-30 KST, 테스트 4건 및 Git Blob 동일성만 검증. 전체 빌드·CI·Production 미검증.

## [최신] 2026-10-30 — Release A H08 A4 비교 요약 인쇄 인수인계
1. 목표·기술: Windows/USB 오프라인 HTML 비교 결과를 A4 또는 사용자가 저장하는 PDF로 전달; 기존 FINAL_SPEC_V2 규칙과 원본 데이터 보존.
2. 구현: `ui/history_print.js`(안전한 고정 출력·경고코드 6개 제한), `ui/history_compare.js/html` 인쇄 버튼 및 별도 인쇄 전용 섹션. valid 비교 후만 활성, 비교 시작/JSON 선택 변경/실패 시 즉시 무효화, 자동 저장·전송 금지.
3. 검증: V8 순수+가상DOM 통합 6/6 PASS, 9개 신규 Node 회귀 시나리오를 V8 Node API adapter로 실행해 9/9 PASS. Git Blob readback 확인. `tests/evidence/history_print_qa_20261030.json` 참고. 기존 네이티브 Node 37개, 새 네이티브 Node 9개, Python/ZIP/Windows CI 미실행.
4. 상태: H08 비교 인쇄 코드 완료, Windows A4 페이지·PDF 한글 렌더링/Print API는 실제 브라우저 검증 대기. 제품 전체 미완료·판매/무료 공개 보류.
5. 장애·대안: 이전 Chromium는 환경 관리자 정책 `ERR_BLOCKED_BY_ADMINISTRATOR`; 반복 우회 금지. CI run 41034866482 실패·step 없음, 신규 dispatch 미지원. Windows 사용자 환경 또는 가용 Windows runner로 실제 QA.
6. Repo/branch/SHA: `hibi89/AX_MART`, `feature/pc-care-usb`, 이전 SHA `2a4a6bef056f9ffb1ba14b10a218d802cb98d9eb`. 주요 파일 `products/pc-care/ui/history_print.js`, `tests/test_history_print.cjs`, 기존 HTML/JS, release/CI/preflight/tests.
7. Production: `https://ax-mart.pages.dev/` main 변경 없이 미적용. Windows `START_PC_CARE.cmd` 메뉴 5→로컬 HTML→JSON 비교→사용자 인쇄.
8. 원본/백업/보안: 변경 전 SHA 복원 가능; 사용자 REPORTS·BitLocker·수리·WinRE 코드/실제 데이터 미변경, 강제 push 없음.
9. 다음 작업: 기존 37+9 Node 테스트를 한 번에 실행 후 Windows 실제 `file://`, USB 한글 경로, 인쇄 PDF 1페이지, QR 카메라, WinRE VM 안전성 체크. 완료/출시는 승인 후.
10. 시점/범위: 2026-10-30 KST, Git blob과 V8 합성 15 checks only, 네이티브 실행/실사용·Production 미검증.

## [최신] 2026-10-30 KST — ZIP bounded verification / H08 regression
1. **목표·기술:** PC CARE Release A/B 내부 ZIP 검증 무결성과 메모리 안전성 강화, H08 전체 합성 퇴행 방지. Python 표준 라이브러리 `zipfile/hashlib`, 기존 오프라인 설계 유지.
2. **구현·근거:** `tools/release.py`에서 archive metadata(중복·예상 파일·member size·암호화·symlink) 먼저 검사; MAX_FILE_BYTES+1 범위로 읽은 뒤 manifest/CRC 검사. SHA256 streaming. `--verify` 시 `.sha256` sidecar 의무화, symlink 부모 디렉터리 포함 금지. 기존 build_internal/파일 목록 보존.
3. **테스트:** GitHub H08 소스 기반 V8 호환 단위/가상 DOM 46 PASS/0 FAIL; 별도 로컬 Python 3.13.5 ZIP 구현 5 PASS/0 FAIL. `tests/test_release.py` 신규 4개 회귀 및 `test_package.py` 정적 계약 1개 추가. 새 GitHub Python suite/실제 ZIP/네이티브 Node 전체는 미실행. 증빙 `tests/evidence/zip_bounded_security_qa_20261030.json`.
4. **상태:** ZIP 보안 수정 구현, 제품 전체/Release A 실기기 QA 미완료. QA 테스트 실행 권한 복구 대기. 일반 배포 미승인.
5. **문제·시도/대안:** 기존 `archive.testzip()`은 크기 제한 확인 전에 압축을 풀어 악성 아카이브 메모리 위험. bounded read/metadata-before-decompression으로 전환. CI run 41034866482는 runner/step 테스트 증거 없음, 권한·runner 문제 먼저 해결할 때까지 무의미한 재시도 금지. 로컬에서 Zip safety 대표 구현 native 5/5 검증.
6. **저장소/브랜치/SHA/경로:** `hibi89/AX_MART`, `feature/pc-care-usb`, 변경 전 `a7bfc292fff36b4088698fb82440397cd7538388`. `tools/release.py`, `tests/test_release.py`, `tests/test_package.py`, QA evidence, docs.
7. **Production/실행:** `https://ax-mart.pages.dev/`은 Cloudflare main 자동배포, feature 이번 변경 미적용. 제품 QA `python tools/preflight.py`; 검증 전 다운로드/판매 불가.
8. **원본/백업·인증:** Git 이전 SHA 보존, user REPORTS, Windows 수리/WinRE/BitLocker/권한/토큰·환경변수 미변경. Force push 없음.
9. **다음 작업:** full source Python/Node/ZIP 일괄 실제 실행, Windows11 표준/USB/Edge·PDF·QR, WinRE 가상머신 별도 검증 및 사용자 승인. 완료 기준은 실기기 기능·안전·정식 배포 검증 모두.
10. **갱신:** 2026-10-30 KST, 검증은 V8 호환 테스트 및 고립 Python 구현 5개만; GitHub Actions, native full repo ZIP, Production 미검증. 최종 SHA는 원격 재확인.

## [최신] 2026-10-30 KST — Release B RESCUE_READINESS 인수인계 10항
1. 목표/확정 요구/기술: WinRE CMD에서 비상 백업 전 확인 가능한 최소 정보를 안전하게 보며, 실제 복사는 물리 분리/BitLocker/용량/완전성 확인 전 절대 실행하지 않음. 기존 FINAL_SPEC_V2 Release A/B 분리 유지.
2. 완료/변경/근거: `recovery/RESCUE_READINESS.cmd` 독립 수동 실행. Windows OS 후보 문자 및 관리 도구의 존재만 확인; 원시 사용자 경로/개인 데이터/키 미수집. 기본 종료코드 3(차단). CMD를 선택한 근거는 WinRE에 PS5.1이 기본 제공되지 않을 가능성과 최소 의존성.
3. 테스트 명령/결과/범위: Linux Python 3.13.5 `python -m unittest discover -s /mnt/data/axmart_rescue/tests -p test_rescue_readiness.py -v` **4 PASS/0 FAIL**, py_compile PASS. cmd.exe/WinRE 실제 구동 미실행, 기능 파일 Git Blob SHA는 로컬 실행 코드와 일치.
4. 상태: 후보 탐지/안전 차단 코드는 구현됨, WinRE 런타임·물리 디스크 분리·잠금·사용량·대상 empty folder·전체/샘플 hash·실제 복사·복구/VM 검증 대기. 최종 제품 부분 완료.
5. 오류/근거/대안/재시도 금지: 첫 정적 테스트의 echo 문구 때문에 가짜 복사 명령 탐지 1건, 검사문과 사용자 메시지를 분리해 해결 후 4/4 PASS. 동일 GitHub CI runner 이전 실패 41034866482 반복 재시도하지 않음. 자동 복사를 조기에 활성화하는 방식은 사용 금지.
6. 저장소/브랜치/SHA: `hibi89/AX_MART`, `feature/pc-care-usb`, 변경 전 `b1ab5de8c4274b9b699fdc886a5b4d911c95ed9a`; 새 `products/pc-care/recovery/RESCUE_READINESS.cmd`, `tests/test_rescue_readiness.py`, 증빙 `tests/evidence/rescue_readiness_static_qa_20261030.json`.
7. URL/실행 명령/환경: Cloudflare `https://ax-mart.pages.dev/` main 변경 없음. 사용자는 공식 WinRE 명령창에서 스크립트를 별도 수동 실행(자동실행·고권한 수리·외부 네트워크 없음). 제품 빌드의 시험용 ZIP에만 포함.
8. 원본/백업/인증/수정금지: 모든 실제 고객 파일·OS 복구상태·BitLocker/BCD·로컬 보고서 불변. Git 전 SHA 복원 가능, 민감값/키/로그 repo 업로드 없음.
9. 다음 작업/승인: Windows VM+실기기에서 사전 검사·종료값·오탐 QA → 물리 저장장치 식별 실패시 차단 확인 → 별도 신규/빈 디스크·용량·연결끊김·FAT32/EFS/OneDrive/다중 프로필 테스트 → 승인 전까지 파일 복사 기능 구현을 릴리스로 취급하지 말 것.
10. 확인 시각·범위·문서 기준: 2026-10-30 KST. Linux Python 정적 경계 테스트만 검증, Windows/WinRE/실백업/실패복구·운영서비스 미검증. 커밋 후 HEAD·문서 갱신 검증.

## [최신] 2026-10-31 KST — Release A 상담보고서 수집 신뢰성 인계
1. **목표·기술:** PowerShell 5.1 기반 `Get-PcCareConsultationSummary`에서 저장장치/이벤트 수집 실패를 정상·실측으로 오인하지 않기.
2. **구현·판단:** `collectionStatus.physicalDisks=collected`인 완전·비어 있지 않은 Healthy만 정상 표기, 미확인 경우 정상 주장 금지. 수집 실패해도 실제 관찰된 Warning은 남기고 수집 한계 추가. `eventCollection`/Windows Update 상태 collected 또는 truncated일 때만 이벤트 목록 반영, unavailable/no matching events 제외. 기존 보고서 구조와 HTML 출력 유지.
3. **테스트:** GitHub 이전/수정 원본 기반 소스 계약 V8 7/7 PASS. `tests/consultation_report.tests.ps1` 신규 Assertion 10개·기존 기대값 변경, `tests/test_package.py` 정적 소스 계약. **PowerShell 5.1 네이티브 합성·전체 Python·ZIP·Windows·CI는 이번 턴 미실행**. 증빙 `tests/evidence/consultation_provenance_qa_20261031.json`.
4. **현상태:** 코드 구현/정적 안전계약 완료. 실제 Windows 건강검진 및 인쇄/A4/QR/USB·WinRE 검증/배포 미완료.
5. **오류/재시도:** 기존 보고서는 'healthy 표본 + 조회 실패'를 정상으로 표시 가능, '업데이트 조회 실패+잔류 이벤트'를 근거로 노출 가능. 정적 계약 확보, Windows PS5.1 실제 실행은 CI runner 없음으로 미검증. runner 이전 실패 `41034866482` 무의미한 재시도 금지.
6. **Git:** `hibi89/AX_MART` `feature/pc-care-usb`; 변경 전 SHA `ad392a6d646f1e104c9ed20ba32ad43d26ed73c5`. 소스 `tools/consultation_report.ps1`, 테스트 `tests/consultation_report.tests.ps1`, `tests/test_package.py`, 증빙 JSON, 문서.
7. **운영:** Cloudflare `https://ax-mart.pages.dev/` 기존 main 불변. `START_PC_CARE.cmd` → READ ONLY 진단·상담 HTML, Windows QA는 `tests/windows_smoke.ps1` 명령으로 검증 필요.
8. **데이터·보안:** 고객 원본 보고서/물리 디스크/BitLocker/레지스트리·WinRE 복구/비밀 키 미변경. 기존 SHA로 안전 복구 가능. 원격 배포·판매 비활성.
9. **다음 작업:** PowerShell 5.1 synthetic fixtures 테스트 → 전체 Python/Node·정식 내부 ZIP build/verify → Windows 표준권한 USB/file://·QR 실스캔·A4 PDF 확인 → WinRE 분리 실기기 QA. 물리 디스크 분리 증명 없는 Release B 실제 복사는 계속 금지. 공개/판매 승인 별도.
10. **시각·검증범위:** 2026-10-31 KST, 검증은 V8 정적 계약 7개·Git blob 일치. Windows/WinRE/Production 미검증, 최종 SHA 푸시 후 확인.

## [최신] 2026-10-31 KST — H08 화이트리스트/개인정보 방지 인계
1. 목표·확정 기술: Win11/PS5.1 offline H08 화면+PDF에 지정된 경고 코드만 표시; 개인정보 최소화.
2. 수정/결정: `history_compare.js`와 `history_print.js`의 단순 /^[A-Z_]+$/ 허용을 진단기 고정 8코드 whitelist로 변경. 새 알 수 없는 코드가 섞이면 경고 목록 전체 ‘비교 불가’로 보수적 처리.
3. 테스트: Linux Node v22.16.0 `node --test tests/test_history_*.cjs` **45/45 PASS**, Node 구문 검사 PASS. GitHub 원본 소스 V8 어댑터 인쇄 포함 54/54 PASS, 8개 정적 계약 PASS. 전체 Python/ZIP/PS5.1 CI 미실행.
4. 상태: Release A H08 소스·테스트 개선, 실제 Windows·USB·A4/QR·WinRE·출시 QA 대기.
5. 오류·대안: 단순 대문자 필터가 식별자를 노출하는 위험을 없애기 위해 절대 whitelist 사용. 향후 새 진단 코드 등장 시 `test_history_warnings_use_exact_known_collector_codes`가 실패하도록 계약 추가. CI 41034866482 테스트 시작 전 실패, 불필요한 재시도 금지.
6. 저장소/브랜치: `hibi89/AX_MART` / `feature/pc-care-usb`, 변경 전 SHA `6db12369123a2902e55aad84809ee6ab5dc0c94d`. `ui/history_compare.js`, `ui/history_print.js`, `tests/test_history_issue_allowlist.cjs`, CI/preflight/README, QA evidence.
7. Production/실행: `https://ax-mart.pages.dev/` 기존 main 그대로, 이 변경 배포 미적용; QA는 제품 폴더에서 `node --test tests/test_history_*.cjs`.
8. 원본/복구·안전: 사용자 JSON/로그 원본 불변, BitLocker/WinRE/시스템 변경 없음, Git 이전 SHA 복구. Release B 물리 분리 불확실성으로 복사 코드 차단·미배포 유지.
9. 다음 우선순위/완료 기준: 전체 Python/ZIP 실제 생성→Windows PS5.1 합성 QA→Edge USB 한글 경로/A4 PDF/QR 실스캔→WinRE VM 물리 디스크 분리 검증→사용자 승인 전 출시 금지.
10. 갱신 일시/범위: 2026-10-31 KST, 소스 SHA/Node/V8 정적 계약 확인, CI/Windows/Production 미검증. GitHub 최종 SHA는 커밋 푸시 후 검증.

## 2026-10-31 KST — AXMART PC CARE native Python packaging validation
- GitHub feature baseline 728e5d96b36cc29e29c0057c0af758bc3da32dda. Four Git-blob-identical sources: tools/release.py, tests/test_release.py, tools/preflight.py, tests/test_preflight.py. Executed Python 3.13.5 unittest discover natively on Linux: **16 PASS, 0 FAIL, 0 SKIP** (12 release, 4 preflight).
- The actual remote repository tree has all 37 package allowlist members (none missing, empty or above 5MB; total 235361 bytes). All 20 PowerShell files in the allowlist have valid UTF-8 BOM.
- Synthetic source fixture used to create and verify ZIP, not a full original production ZIP build. Full repo Python/Node, Windows 11/PS5.1, Edge file://, USB, QR, A4, WinRE, CI and Production remain **UNVERIFIED**. No customer files or repair commands accessed.
- Evidence: products/pc-care/tests/evidence/native_package_preflight_qa_20261031.json. No changes to public main/Cloudflare; WinRE backup copying remains blocked.

## [2026-10-31 KST] Native packaging QA handoff (10 requirements)
1. Goal/technology: Validate Release A internal-only ZIP packaging with actual Python 3.13.5 rather than synthetic JS simulation.
2. Done/why: Retrieved four source files from GitHub branch at exact Git blob SHA, rebuilt sources byte for byte, ran native unit suites. Product code left intact.
3. Tests: python -m unittest discover -s tests -p 'test_*.py' -v => 16 PASS, 0 FAIL, 0 SKIP. GitHub tree 37/37 ZIP allowlist present, 20/20 PowerShell UTF-8 BOM.
4. Status: Unit-test verified; full actual-source ZIP and native Windows workflow remain pending.
5. Failure/alternative: git clone blocked by DNS; used GitHub connector per-file retrieval, Git blob verification, local native Python. Do not rerun old failed Actions 41034866482 without environment fix.
6. Repo/branch/SHA: hibi89/AX_MART, feature/pc-care-usb, source benchmark 728e5d96b36cc29e29c0057c0af758bc3da32dda. Evidence at products/pc-care/tests/evidence/native_package_preflight_qa_20261031.json.
7. Production/runtime: https://ax-mart.pages.dev/ main fbb32362455378b85bcdd0b5037d1f338055fb71 unchanged. Linux Python 3.13.5 unit QA only.
8. Preservation: No user REPORTS, system settings, BitLocker, repair/WinRE, secrets, public deployment or billing modified; previous feature commit is rollback source.
9. Next: Actual full repository Python/Node and ZIP build/verify in available PC/runner, then Windows PS5.1 + USB/Edge/QR/A4 validation; Release B physical disk identity and WinRE VM needed before any real copy or release.
10. Checked at 2026-10-31 KST: 16 native unit tests + source inventory/BOM checks verified, all real Windows/production checks unverified; confirm updated SHA after push.

## [Latest] 2026-10-31 KST — Incident provenance QA handoff (10 sections)
1. Goal/tech: Prevent unsupported root-cause findings from unavailable Windows event/update/PNP sources, read-only Windows 11 PowerShell 5.1.
2. Done/decision: Gate event/update/PNP evidence to collected or truncated; do not interpret stale arrays under unavailable/no matching. Explicitly pass disk collection state from Safe-Collect; incomplete inventories flag output while warning signs retained.
3. Test commands/results: `tests/incident_analysis.tests.ps1` +15 assertions, `tests/test_package.py` new source contract. Remote source V8 static 12 PASS and 10 PASS; actual PS5.1, whole Python/Node, real internal ZIP, Windows CI unrun.
4. Status: Code/fixtures finished, runtime acceptance pending; A/B launch incomplete, B file copying remains blocked.
5. Failure evidence/alternatives: Raw stale arrays could be used when a query failed. Status gating now prevents these in incident engine; prior failed workflow `41034866482` not rerun without runner access.
6. Repo/branch/SHA: `hibi89/AX_MART` / `feature/pc-care-usb`, prior `3ef198b3266e7da7382db8fe9a36a4cccedbc5b7`; code `tools/incident_analysis.ps1`, `tools/diagnose.ps1`, tests and evidence.
7. Production/environment: `https://ax-mart.pages.dev/` main unchanged; Windows PowerShell 5.1 `tests/windows_smoke.ps1` required for actual fixture execution.
8. Source/backups/credentials: Report data and system unchanged; feature previous commit recoverable; no credentials exposed, no forced Git rewrite.
9. Next steps/acceptance/approval: Native PS5.1 synthetic, whole source Python/ZIP, USB/file://, real PDF/QR, WinRE physical backup gate, user approval before public release.
10. Confirmed at 2026-10-31 KST; 22 remote source contract checks passed, all native Windows/Production checks unverified; re-read final Git commit after push.

## 2026-10-31 — PC CARE collection provenance
- System/Update collector arrays now enter normalization only for collected/truncated status. Failed and no-match results cannot create incidents or timeline entries. PnP failed/no-match records similarly yield no samples.
- Changed: tools/diagnose.ps1, tools/pnp_analysis.ps1, tests/driver_timeline.tests.ps1 (+4 assertions), tests/test_package.py (+1 contract). GitHub source static checks 14/14 PASS; native Windows, full suite, original ZIP and CI not run.
- Evidence: tests/evidence/collector_provenance_qa_20261031.json. Source baseline a0548d62d18fbb7dd59c60399ccbe3290310c7d4. Feature only; main and deployment unchanged.

Handoff: Objective—avoid untrusted stale observations; status—source checked, runtime pending. Restore SHA: a0548d62d18fbb7dd59c60399ccbe3290310c7d4. Next—PowerShell 5.1 fixtures, full native Python/Node, original ZIP, USB/QR/PDF and WinRE VM. Customer files and credentials unchanged. Checked 2026-10-31 KST.

## [2026-10-31] Developer one-click QA handoff
1. Goal: full source-tree preflight for Release A, no unauthorized system actions.
2. Implemented: internal `RUN_RELEASE_QA.cmd` invokes existing `tools/preflight.py --root .`; customer ZIP excludes the launcher.
3. Verified: Linux Python 3.13.5 static tests 8 PASS, 0 FAIL; missing-source full QA exits 1. Actual Windows cmd.exe and whole source ZIP unverified.
4. Status: code ready for native Windows validation, product release not ready.
5. Blocker: full private GitHub tree cannot be materialized via accessible clone; use trusted Windows checkout as native acceptance environment.
6. Repository: `hibi89/AX_MART` `feature/pc-care-usb`, prior SHA 489f15a72e1581c68a708c2734cfe4fd0a840537; evidence `tests/evidence/oneclick_qa_20261031.json`.
7. Production: `https://ax-mart.pages.dev/` unchanged; developer cmd.exe, Python 3.11+, Node, PS5.1.
8. Security: no user reports or Windows settings touched, WinRE backup disabled, prior Git SHA rollback available.
9. Next: run one-click QA on full checkout, then USB/QR/A4 and WinRE VM before explicit release approval.
10. Checked 2026-10-31 KST: Python tests/negative case only; Windows/runtime/production not verified. Final SHA to reconfirm.

## 2026-10-31 KST — 시간축 근거 무결성 개발 묶음 (10항)
1. 목표/스택: Windows 11 PS5.1 로컬 진단 → 정규화된 System/Update 근거 → 시간축 → JSON/HTML 경로를 강화, 제품 v2.0 전체 목표는 보존. 최종 사양 `docs/FINAL_SPEC_V2.md`, 구성 기준선 `docs/PRODUCT_AND_INTEGRATION_BASELINE.md`.
2. 변경/판단: 새로운 서버·DB를 도입하는 B안 대신 기존 모듈 최소 변경 A안. `tools/recorded_timeline.ps1` 실패·무결과 수집 차단, 출처/종류+ID 화이트리스트, UTC 시차 엄격 검사, truncation/collection provenance 추가. `diagnose.ps1` 상태 연결 및 driver/timeline fixtures 강화.
3. 테스트: 원격 소스 readback 및 정적 불변 조건 **17 PASS/0 FAIL**. Windows 네이티브 PowerShell parser/fixture, 전체 Python·Node·ZIP, 실제 진단·브라우저·QR/PDF·WinRE는 **NOT_RUN** (실환경 검증 PASS 아님).
4. 상태: 소스 수정·원격 반영 완료, 코드가 실행되는지는 미검증. Release A/B 출시 미완료; `main`·운영 사이트/실판매는 미변경.
5. 실패/복구: 첫 자동 문자열 치환이 PowerShell 정규식의 `$'`를 치환 메타문자로 해석하여 원격 파일 손상. 즉시 사전 HEAD `dc53774703d1ea856599c599f3cf4b97418d885c`의 blob을 읽어 함수형 치환으로 재구성하고 재조회 정확성 확인. 이 잘못된 문자열 치환 방식 재사용 금지. Windows runner 미배정 CI의 무의미한 재시도 금지.
6. 저장소/경로: `hibi89/AX_MART@feature/pc-care-usb`; `tools/recorded_timeline.ps1`, `tools/diagnose.ps1`, `tests/driver_timeline.tests.ps1`, `docs/PRODUCT_AND_INTEGRATION_BASELINE.md`. 복구 SHA 위 참조, 최종 HEAD는 원격 확인값을 이 대화에서 보고.
7. Production/실행: `https://ax-mart.pages.dev/`는 `main` 운영, 해당 기능 미배포. Windows 전체 소스에서 `RUN_RELEASE_QA.cmd` → `tests/windows_smoke.ps1`, 이후 opt-in `RUN_SELF_TEST.cmd`.
8. 보안/원본: 로그/경로/식별자 외부 전송 없음; 사용자 REPORTS·OS·수리·BitLocker·WinRE 복사 변경 없음. 원본 기존 SHA에서 복원 가능. UI/QR 자동 업로드 및 무인 수리 금지.
9. 다음/완료 게이트: PS5.1 네이티브 합성 → 실제 표준 권한 보고서 생성/JSON·HTML → 한글 USB 경로/Edge file://·QR 스마트폰 스캔·A4 PDF → WinRE 격리 VM 물리 디스크 분리/용량/BitLocker 실패 테스트. 출시/복사 활성화 별도 승인.
10. 갱신: 2026-10-31 KST, 소스 정적 17개만 확인, CI 상태 체크 없음·Windows 미실행. 문서 기준은 본 업데이트 시점의 `feature/pc-care-usb` HEAD 및 위 사전 SHA.

## 2026-10-31 KST — CUBE Release A time-axis evidence contract / 10항
1. 목표·기술: PC CARE `FINAL_SPEC_V2.md` HEALTH/ANALYZE/REPORT 로컬 Windows PowerShell5.1/CMD/HTML/JSON 코어 실증, 기록 시간축의 근거 완전성 및 원인 오판 방지.
2. 구현: `recorded_timeline.ps1` 출처/시간/ID 확인에 더해 수집 결과 `collected`, `no matching events`, `truncated`, `incomplete`, `unavailable` 구분, coverageComplete, 기록 시각 15분 이내 근접 조합 3종(인과 판정 금지). `diagnose.ps1` HTML/JSON 표시·한계 반영.
3. 검증: GitHub 원격 파일 readback 후 정적 소스 계약 **32/32 PASS**. Windows PS5.1 native parser/fixture, 전체 Python/Node/ZIP, 실제 Windows·USB·QR·PDF·WinRE와 CI **NOT_RUN**.
4. 단계: 코드 소스·fixture·Windows 실행기 검증 계약 GitHub 반영. Release A/B 실제 사용 적합성과 판매/무료 배포는 차단 유지.
5. 오류·재시도 정책: 직전 턴의 정규식 치환 문제는 앞선 `ce390930354e38bf267f716f3043e401c3ec613a`에서 복구됨. 본 묶음은 치환 함수형 패치로 원격 내용 재조회. 기존 러너 미배정 작업을 무작정 재실행하지 않음. 런타임 없으면 NOT_RUN.
6. Git: `hibi89/AX_MART@feature/pc-care-usb`의 `tools/recorded_timeline.ps1`, `tools/diagnose.ps1`, `tests/driver_timeline.tests.ps1`, `tests/test_package.py`, `tests/windows_smoke.ps1`, `tests/evidence/timeline_coverage_static_qa_20261031.json`. 변경 전 rollback `dfe918e3c1860aaa6fe9bd1deeaf1e8eb2fc1274`.
7. 실행/배포: `RUN_RELEASE_QA.cmd`·`tests/windows_smoke.ps1`; Windows 11/PS5.1 필요. Cloudflare `https://ax-mart.pages.dev/`는 `main` 상점이며 이 기능 미배포.
8. 원본·보안: REPORTS/BitLocker 키/고객 로그·개인 파일/복구·Windows 설정·공개 사이트 무변경. 데이터 외부 전송·자동 수리/삭제·WinRE 실제 복사 없음. Source snapshot Git SHA로 복원 가능.
9. 다음: Windows 11 전체 소스 QA→PS5.1 fixture→읽기 전용 보고서→한글 USB·Edge file://·오프라인 QR 스마트폰·A4 PDF→격리 WinRE VM·실제 물리 디스크 분리/잠금/용량/중단 안전 검증. 판매/복사 활성화 별도 승인.
10. 갱신: 2026-10-31 KST, 원격 정적 계약만 검증. 근거 `tests/evidence/timeline_coverage_static_qa_20261031.json`; 최종 feature SHA는 이번 문서 커밋 후 원격 확인하여 사용자에게 보고.

## 2026-10-31 KST — H08 실제 데이터 정규화 검증 인수인계
1. 목표/기술: 최종 승인 `docs/FINAL_SPEC_V2.md` Release A H08 반복 진단 비교가 잘못된 Windows Update/PnP 샘플을 검증 없이 관측치로 보여주지 않게 수정. 기존 오프라인 JS/HTML + PS5.1 JSON 계약 유지.
2. 변경/근거: `ui/history_signals.js`에 update kind/eventId 19·20, 기록 UTC·시간기준 및 PnP 코드 1..55·비확정 표시 검사. 원본 `evidence:[{},{}]`, `samples:[{}]` 허위 건수 비교 결함을 V8 실행으로 재현하고 수정. 정상 빈 수집과 기존 비교 유지.
3. 테스트: 실제 GitHub source + 기존/변경 test source V8(Node test/assert adapter) **25 PASS / 0 FAIL**; 독립 악성·정상 fixture **12 PASS / 0 FAIL**; 소스 정적 12/12. Windows native PS5.1, real Node test runner, Python full, ZIP, 브라우저/USB/QR/A4/WinRE **NOT_RUN**.
4. 상태: GitHub 소스·회귀 fixture·증빙 반영, 실제 고객 기기 신뢰성은 추가 검증 필요. Release A/B 미출시.
5. 실패/대안: 기존 느슨한 샘플 건수 수용이 원인. 실제 필드 검증으로 fail-closed. 테스트 실행기(어댑터)는 네이티브 Node 및 Windows 결과라고 부르지 않음. 기존 runner 미배정 CI 반복 금지; Windows 전체 checkout 환경에서 재시험.
6. 저장소/브랜치/경로: `hibi89/AX_MART@feature/pc-care-usb`; `ui/history_signals.js`, `tests/test_history_signals.cjs`, `tests/test_package.py`, `tests/evidence/h08_normalized_sample_validation_20261031.json`. 롤백 기준 `209a3366ed841519c871be1aba3bdf84cf815d0b`; 최종 SHA는 GitHub HEAD 재조회.
7. 실행/Production: Windows 개발 전체 소스 `RUN_RELEASE_QA.cmd`, 이후 `RUN_SELF_TEST.cmd` opt-in. 공개 Cloudflare `https://ax-mart.pages.dev/`는 `main`이며 코드 배포하지 않음.
8. 원본/보안: 고객 REPORTS·시스템 파일·장치·복구·BitLocker·유료 결제·공개 다운로드 변경 없음. JS는 임시 로컬 파일 선택만, 식별자·원문 메시지·외부 전송 없음. Git 브랜치 SHA 복구 가능.
9. 다음: 전체 소스 Windows에서 Node/Python/ZIP/PS5.1 테스트, 실제 JSON 비교·한글 USB·Edge file://·QR/A4, 이후 별도 WinRE 격리 VM 검증. 판매/복사/고권한 복구 게이트 유지.
10. 확인: 2026-10-31 KST, 원격 blob readback 및 V8 두 시험 묶음/정적 검증만 확인. 증거 `tests/evidence/h08_normalized_sample_validation_20261031.json`, 최종 문서 커밋은 이후 실제 HEAD로 확인.

## 2026-10-31 KST — CUBE H08 System event E2E / 10항
1. 목표·스택: Win11/PS5.1 진단 결과의 오프라인 JSON → H08 이력 비교 → A4/PDF 요약. 기존 로컬 CMD/PS/JS, 최종 사양 v2 유지.
2. 구현·근거: 정규화 `eventEvidence` 미검증 상태에서 출력 배열 길이를 신뢰하던 실제 오류 재현. `ui/history_compare.js`는 종류·Event ID·UTC/timeBasis, collector provenance, 원본-표시 건수 동등 확인. 정상 no-match만 0, 불완전·비정상은 비교 불가. `tests/test_history_evidence_integration.cjs` 포함.
3. 테스트: GitHub 실소스+기존 JS 단위테스트 V8(노드 API 어댑터) 28 PASS, 추가 통합 V8 5 PASS, 정적 12 PASS, FAIL 0. **Native Node --test / Python 전체 / PowerShell5.1 / 진짜 ZIP·Windows·USB·QR·A4·WinRE NOT_RUN**.
4. 완료·차단: 코드와 회귀 소스 반영, 제품 E2E Windows 실행/출시 완료 아님. WinRE copy·고권한 수리·판매 별도 승인 게이트 유지.
5. 실패·재시도: 원인은 H08 displayed sample 개수만 비교한 검증 누락. 수집 실패/변조 입력 fail-closed. 과거 Actions `41034866482` (SHA `5c6c794d`) 실패, job 0 steps·runner 없음; 기존 문제가 현재 코드 실패를 입증하는 것은 아니며 무의미한 rerun 금지.
6. 저장소·브랜치·복구: `hibi89/AX_MART@feature/pc-care-usb`, 변경 전 SHA `a7843dd4983959d8e4d19d4ee85d567a82982c6a`. 주요 소스 `ui/history_compare.js`, `tests/test_history_compare.cjs`, `tests/test_history_evidence_integration.cjs`, `tools/preflight.py`, `tests/test_package.py`.
7. 운영·명령: `https://ax-mart.pages.dev/`는 `main`만, 이 기능 미배포. Windows 11/PS5.1 전체 개발 소스 `RUN_RELEASE_QA.cmd`, 이후 opt-in `RUN_SELF_TEST.cmd`와 로컬 Edge file:// UI.
8. 원본·보안: 고객 REPORTS/디스크/로그/BitLocker/복구/환경변수 변경 없음; 외부 전송·결제·공개 배포 없음. 기존 Git SHA로 복원. 유료 런타임/재설계 도입 안함.
9. 다음 우선순위: 전체 Windows checkout Native QA+읽기전용 실제 생성 보고서; eventEvidence→H08→private 인쇄 및 Edge/한글 USB 경로·QR/A4·SHA ZIP; 마지막 WinRE 격리 VM 안전검증 후 별도 출시 승인.
10. 2026-10-31 KST, 원격 readback/JS V8/정적 체크까지만. 증거 `tests/evidence/h08_system_evidence_integration_qa_20261031.json`; 최종 문서 HEAD는 이후 원격 확인.

## 2026-10-31 KST — CUBE provider contract 10항 최신화
1. 목표·기술: PC CARE Release A 진단→정규화→분석→JSON/HTML→오프라인 H08 비교·인쇄, PS5.1/CMD/JS/JSON 기존 스택.
2. 변경·이유: H08 System 이벤트 provider 검증 누락으로 임의 kind/ID/UTC 기록을 진짜 이벤트로 오판하던 문제 재현·수정. `history_compare.js`에서 실제 `event_analysis.ps1` provider 허용 목록 대조. 볼륨 수집 실패/중복 차단 및 비Windows QA `partial` 상태도 직전 `ㄱ`에서 반영.
3. 테스트: 커밋된 실제 JS 소스/단위·통합 3개 스위트 V8 어댑터 **38 PASS / 0 FAIL**. Native Node/Python/Windows PS5.1/실 ZIP/USB/QR/A4/WinRE **미실행**.
4. 단계: GitHub feature 코드·회귀 보강 완료. 전체 Release A 실기기 검증 대기, Release B 실제 백업/수리·고객 배포 차단.
5. 오류·대안: 별도 센서 모듈·ZIP allowlist 통합 도구 차단 및 패키지 불일치 우려로 새 fast-forward 복구 SHA `2112c95c11edfbaa1584e16f0c881a2848017c9e` 적용. 동일 위험한 편집 반복 금지; 기존 번들된 정상 소스 유지.
6. Git: `hibi89/AX_MART@feature/pc-care-usb`. 기존 베이스 `b568c942c00ee4cc32e24863e2608c93806df290`; 현 HEAD는 문서 갱신 후 조회. 주요 파일 `ui/history_compare.js`와 `tests/test_history_compare.cjs`, `tests/test_history_evidence_integration.cjs`, `tests/test_package.py`.
7. 실행·운영: `RUN_RELEASE_QA.cmd` Windows 11/PS5.1+Python 3.11+Node. Cloudflare `https://ax-mart.pages.dev/` 운영 `main` 기능 미배포.
8. 보존·보안: Git 베이스로 복원 가능; 고객 REPORTS·디스크·키·로그·OS/복구·환경변수·Cloudflare 설정 수정/접근 없음. 네트워크 업로드·자동 수리·지우기 없음.
9. 다음: Windows 전체 QA→실제 read-only 보고서 저장→H08/Edge file://·USB 한글 경로·QR 스마트폰/A4 인쇄→별도 WinRE VM 안전 검증. 고객 공개/실복사/승인형 수리 실행은 사전 승인.
10. 갱신: 2026-10-31 KST. 검증 근거 GitHub 원격 읽기·V8 실행 38/38; 외부·실기기 완주 여부 미확인. 문서 커밋 후 실제 feature SHA 별도 확인.

## 2026-10-31 KST — P0 disk provenance / 10항
1. 목표·용도·확정 기술: PC CARE Release A Windows PS5.1/CMD 진단→정규화→분석→로컬 JSON/HTML/H08·A4/QR. 기존 v2.0 설계와 Read-only/수동 승인 분리 유지.
2. 실제 구현·결정: `incident_analysis.ps1`의 디스크 Warning 표본을 소스 상태와 분리해 과거 조회 실패에도 경고 근거로 쓰던 결함 수정. `DiskCollectionStatus=collected/truncated`만 읽고 `unavailable/empty`면 잔존 배열 배제. 절단 수집의 관측 신호는 유지하되 불완전 판정.
3. 테스트: 코드·회귀 파일 GitHub readback 및 정적 계약 19 PASS/0 FAIL. `incident_analysis.tests.ps1` 경계 fixture, `test_package.py` 소스 계약 추가. **Windows PS5.1 실제 구문/fixture, native Python/Node·ZIP·실기기·USB·QR·A4·WinRE·CI NOT_RUN**.
4. 상태: 서버/배포가 없는 로컬 진단기 Release A 코드 보강 완료, 실사용품 검증 대기. Release B WinRE 파일 복사/수리·대외 배포 차단.
5. 오류·원인·재시도 금지: 기존 `$allDisks`를 `DiskCollectionStatus`와 무관하게 채운 것이 문제. 수집 실패의 잠재 경고를 사실로 단정하지 않게 제한. 과거 CI `41034866482`의 runner 미배정 실패는 현재 HEAD 기능 오류 증거 아님; 의미 없는 재실행 금지.
6. 저장소·SHA·경로: `hibi89/AX_MART@feature/pc-care-usb`, 이전 HEAD `009ac6b9fa1a81c313aae71b9d85190d4e036d16`; 핵심 `tools/incident_analysis.ps1`, `tests/incident_analysis.tests.ps1`, `tests/test_package.py`, 근거 `tests/evidence/incident_disk_provenance_static_qa_20261031.json`; 최종 HEAD는 이번 문서 커밋 뒤 재조회.
7. 환경·운영: Windows 11 x64, PS5.1, Node/Python (내부 QA). `RUN_RELEASE_QA.cmd`→`tests/windows_smoke.ps1`; `https://ax-mart.pages.dev/` 운영 main에는 미배포·미적용.
8. 원본·백업·인증: 사용자 고객 REPORTS/시스템 설정·파일/토큰·BitLocker 키 무접근·무수정. Git 이전 HEAD 복원점. 원본과 정상 기능·인증 설정 변경/외부 업로드 없음.
9. 다음 우선순위·절차·승인: Windows 전체 소스 QA/PS5.1 fixture → 명시적 read-only 실제 JSON/HTML 결과 → H08/Edge file://·한글 USB→QR/A4·해시 ZIP→WinRE 격리 VM 안전 증명. 실제 수리·WinRE 복사·고객 배포/유료화는 사전 승인.
10. 갱신: 2026-10-31 KST, GitHub 실제 원격 소스/정적 검사 19개까지만 확인. 정적 PASS를 native/E2E PASS라고 기록하지 않음. 최종 SHA 원격 확인 후 보고.

## 2026-10-31 KST — CUBE 저장 보고서/SMART QA 인수인계 10항
1. 목표·기술: 최종 v2.0 Release A의 오프라인 Windows PS5.1/CMD 진단 → 증거/상태 → JSON+HTML 저장 → H08/QR/A4; Release B WinRE 실제 백업은 별도 위험 게이트.
2. 변경·결정: 보고서 파일 기본이름을 쓰기 전에 `^[A-Za-z0-9][A-Za-z0-9_-]{0,79}$`로 검사해 경로 이탈 금지. 기존 보고서 충돌 보존·대체 저장 유지. 배포 allowlist에 이미 들어있는 `telemetry_analysis.ps1`에 순수 SMART 마모율/온도 정규화 추가하고 `diagnose.ps1` 조기 1회 소싱; 별도 모듈/새 의존성 없음.
3. 테스트: GitHub 원격 readback 및 보안·패키지 정적 계약 **24 PASS / 0 FAIL**. 별도 합성 PS fixture와 패키지 계약 테스트는 코드 반영만. **Windows PS5.1 실제 실행, native Python/Node, 실 ZIP/USB/QR/A4/WinRE/CI NOT_RUN**.
4. 상태: 피처 코드·회귀 테스트·정적 QA 근거 완료; Release A Windows 실기기 수용 검증 대기, 고객 배포와 Release B 실제 복사는 여전히 차단.
5. 실패·원인·재시도 금지·대안: 이전 코드 `FileBase` 경로 미검사와 저장장치 `Wear/Temperature`의 원시 정수 변환이 근본 원인. 과거 별도 센서 파일과 ZIP 변경 동기화 실패를 반복하지 않고 기존 배포 포함 텔레메트리 모듈 활용. Windows 실행이 검증되지 않았다는 사실을 정적 PASS로 대체하지 말 것.
6. 저장소·브랜치·경로·복구 SHA: `hibi89/AX_MART@feature/pc-care-usb`. 수정 전 `6d25db008c835ccf489940e9a3024f6b86c74ca9`; 파일 `tools/report_io.ps1`, `tools/telemetry_analysis.ps1`, `tools/diagnose.ps1`, `tests/report_io.tests.ps1`, `tests/telemetry_analysis.tests.ps1`, `tests/test_package.py`. 증거 `tests/evidence/report_persistence_smart_source_static_qa_20261031.json`.
7. Production·실행 환경: `https://ax-mart.pages.dev/` 운영 main은 무변경. Windows 11 x64 + PS5.1, Python 3.11+, Node; 전체 소스의 `RUN_RELEASE_QA.cmd`, 선택적 실제 read-only 검사는 `RUN_SELF_TEST.cmd` 사용자 명시 실행.
8. 원본·보안: 고객 REPORTS/원시 로그·개인 파일·OS/BitLocker·복구·환경변수/키·Cloudflare 인증 무접근·무수정. 이전 SHA로 복원. 외부 데이터 업로드/무인 파일 삭제·포맷·복사·수리 없음.
9. 다음 우선순위·절차·승인: Windows 개발 체크아웃 합성 PS 파싱/fixture 및 native Python/Node+ZIP→사용자 승인한 read-only 실제 진단 JSON/HTML 저장→H08/USB 한글 경로/QR 실스캔/A4→WinRE 격리 VM 백업 안전 시험. 실복사·고권한 수리/배포/비용 지출 시 별도 승인.
10. 기록: 2026-10-31 KST, GitHub 원격 소스·정적 24개 검증만 확인. 최종 SHA/CI 상태는 본문 작성 뒤 GitHub에서 재확인. 현재 문서를 제품 완성/판매 승인으로 간주하지 않는다.

## 2026-10-31 KST — CUBE 시간축 신뢰성 / 10항 인수인계
1. 목표·확정 기술: AXMART PC CARE USB Release A PS5.1/CMD/로컬 JSON·HTML, H08, 오프라인 QR·A4. WinRE Release B는 별도 허가와 물리 안전 시험.
2. 완료 기능: `recorded_timeline.ps1` 정규화 kind/ID/timeBasis/UTC 검증 실패 입력을 `rejectedCount`로 추적, `coverageComplete=false`·`status=incomplete` 처리. 정상 수집은 기존 UTC 근접/원인 미확정 처리 유지. `diagnose.ps1` JSON·HTML에서 비검증 기록 개수 표시 및 조회 실패와 구별.
3. 테스트 명령·결과: 원격 소스 계약 **25 PASS/0 FAIL**; `tests/driver_timeline.tests.ps1`/ `tests/windows_smoke.ps1`/ `tests/test_package.py` regression 소스 추가. **Native Windows PS5.1, Python/Node 전체, 실제 ZIP/USB/QR/A4/WinRE NOT_RUN**.
4. 단계: GitHub feature 코드·정적 안전 검사 완료; Release A 네이티브 수용검증 대기. 실제 WinRE 파일 복사/자동 수리/고객 배포 차단.
5. 오류·실패 근거·대안: 이전 코어가 invalid 입력을 조용히 버려 '기록 없음'·'완전 수집' 오판 가능. 유효 입력만 시간창 생성, 거부 여부 별도 노출. Windows PS5.1을 현재 비Windows/비공개 GitHub DNS 차단 환경에서 실행하지 못함; 정적 검사로 native PASS 대체 금지. 무의미한 CI 재시도 금지.
6. GitHub·브랜치·SHA·경로: `hibi89/AX_MART@feature/pc-care-usb`, 변경 전 `63ca3c8513d921bfa990dbdec813118f2372e9b2`. `tools/recorded_timeline.ps1`, `tools/diagnose.ps1`, `tests/driver_timeline.tests.ps1`, `tests/windows_smoke.ps1`, `tests/test_package.py`; 근거 `tests/evidence/timeline_rejected_evidence_static_qa_20261031.json`. 문서 최종 SHA는 커밋 후 확인.
7. 운영·실행 환경: `https://ax-mart.pages.dev/`은 운영 main 전용(이번 코드 미배포). 개발 Windows 11/PS5.1·Python≥3.11·Node; `RUN_RELEASE_QA.cmd` native QA, `RUN_SELF_TEST.cmd` 선택적 실제 read-only 수집.
8. 원본·백업·인증 관리: Git 작업 전 SHA 복구 가능. 개인 REPORTS·장치·BitLocker 키·자격증명·OS 설정·백업/복구 데이터 무접근/무변경; 자동 수리·외부 업로드·공개 없음.
9. 다음 우선순위·승인: Windows 전체 개발 checkout/합성 fixture→실기기 읽기전용 JSON·HTML/타임라인→H08/USB 한글/QR 실스캔/A4→WinRE 격리VM 위험검증. 실복사·복구·결제·운영 변경 시 사전 승인. 완료 기준은 Windows 정상 실행과 실제 기능 검증.
10. 갱신: 2026-10-31 KST. 원격 GitHub source/readback/정적 25개만 검증; 실제 Native/Windows 여부 미확인. 테스트 원본 SHA는 evidence, 기준 최종 커밋은 GitHub 재조회.

## 2026-10-31 KST — CUBE 네이티브 QA 영수증/Provider P0 인수인계 10항
1. 목표·기술: PC CARE Release A 오프라인 Windows PS5.1/CMD·HTML/JS·JSON 진단/보고서/H08·인쇄. WinRE Release B 실제 파일 백업/수리는 별도 안전 게이트.
2. 이번 기능·결정: Windows 개발 소스 `RUN_RELEASE_QA.cmd`가 `preflight.py --receipt-dir QA_RESULTS`를 이용해 자동으로 민감정보 배제된 단발성 JSON QA 영수증을 기록(오염 원본/기존 리포트 덮어쓰기 없음). 안전 저장·중복 방지·허용된 단계명·PASS와 부분 검증 구분. Windows Update 정규화 공급자를 정확한 `Microsoft-Windows-WindowsUpdateClient`로 제한; 이름 비슷한 가짜 공급자 차단.
3. 검증 명령·결과: 원격 소스 계약 **26 PASS/0 FAIL**, 동일 핵심 QA 영수증 함수 격리 로컬 Python 3.13 실행 **6 PASS/0 FAIL**. `tests/test_preflight.py`, `tests/telemetry_analysis.tests.ps1`, `tests/test_package.py` 회귀 소스 커밋. GitHub 전체 native Python/Node, Win PS5.1, 제품 ZIP, Windows/USB/QR/A4·WinRE/CI **NOT_RUN**.
4. 상태·차단: Release A 코드·테스트 등록/로컬 receipt 작성 준비 완료, 실제 Windows 수용 QA 대기. Release B 실제 백업/고권한 수리·고객 배포 차단.
5. 오류·원인·대안: 기존 Update normalizer 정규식 `(^|-)WindowsUpdateClient$`가 가짜 접두사 허용. 정확한 공급자 비교로 전환. 이전 Actions 41034866482 runner 미배정 0 steps, 무의미한 재시도 금지. Windows 실행은 본 환경에 PS5.1·비공개 repo checkout 연결이 없어 미검증.
6. 저장소/브랜치/SHA/경로: `hibi89/AX_MART@feature/pc-care-usb`, 이전 기준 `f604d2f4902dec82e3e58a0166f2dc94faa0e5ce`; `tools/preflight.py`, `tests/test_preflight.py`, `RUN_RELEASE_QA.cmd`, `tools/telemetry_analysis.ps1`, `tests/telemetry_analysis.tests.ps1`, `.github/workflows/pc-care-windows-synthetic.yml`, `tests/test_package.py`, `README.md`, 루트 `.gitignore`. 근거 `tests/evidence/native_qa_receipt_update_provider_static_20261031.json`.
7. 운영/환경: `https://ax-mart.pages.dev/` 운영 main/Cloudflare 미변경, 이 개발 기능 프로덕션 미적용. Windows 11 x64·PS5.1, Python≥3.11, Node; `RUN_RELEASE_QA.cmd`는 합성 테스트/임시 ZIP만, 실제 고객 진단·수리 시작 안 함.
8. 원본·백업·보안: Git 변경 전 SHA 복원점. 고객 REPORTS·OS·BitLocker·인증키·파일 무접근/무변경. `QA_RESULTS/` Git ignore 및 배포 ZIP 제외. 영수증에는 경로/원시 로그·시리얼/개인정보 없음. 별도 외부 전송 없음.
9. 다음 P0·승인: 전체 Windows 개발 체크아웃에서 `RUN_RELEASE_QA.cmd` 네이티브 1회 실행→`QA_RESULTS/pc-care-qa-*.json` 확인→명시적 read-only 진단 생성 JSON/HTML/H08·한글USB/QR/A4. WinRE 실제 복사·수리·출시/결제·권한 변경은 사전 승인 필수.
10. 시점·범위: 2026-10-31 KST. GitHub 원격 readback/정적 26건 + 복사된 isolated receipt smoke 6건까지만 확인. 진짜 Windows Native/CI/배포 미검증. 문서 커밋 후 feature SHA 별도 확인.

## 2026-10-31 KST — CUBE QA 4단계 근거 판정 / 10항
1. 목표/기술: PC CARE Release A PS5.1/CMD·로컬 JSON/HTML·H08, USB/QR/A4, Release B WinRE 격리.
2. 변경: QA 단계 일부만 PASS여도 전체 PASS가 가능했던 집계 취약점 해결; `classify_full_qa_stages`가 Python/Node/ZIP/WinPS5.1 4개 슬롯을 1회씩 요구. `run_qa`와 프라이빗 영수증 `safe_qa_receipt` 모두 동일 판정.
3. 검증: 원격 GitHub 코드·테스트 readback. GitHub 실소스의 두 함수만 복사하여 로컬 Python 3.13 **10 PASS/0 FAIL**(비통합 검사). 실제 전체 repo unittest, native Windows PS5.1/Node·ZIP·USB/QR/A4·WinRE/CI NOT_RUN.
4. 상태: QA 정확도 기능·합성 테스트 코드 반영, Windows 실제 acceptance 검증 대기. 배포와 WinRE 실제 복사·수리 차단.
5. 오류/대안: 누락/중복된 단계의 긍정 오판. 구형 상태 집계는 일반용으로 두고 통합 QA와 저장 영수증에 엄격한 matrix 적용. 같은 의미 없는 Actions runner 재시도 금지.
6. 저장소/브랜치/SHA: `hibi89/AX_MART@feature/pc-care-usb`, 작업 전 `c8ca0136a1ec65f2d3490e0d7245f2e6b97f81f3`, `tools/preflight.py`, `tests/test_preflight.py`, `tests/test_package.py`, 근거 `tests/evidence/qa_gate_matrix_20261031.json`; 최종 SHA는 재조회.
7. Production/환경: `https://ax-mart.pages.dev/` 운영 main 유지/미배포. Windows 11/PS5.1, Python≥3.11, Node, 개발용 `RUN_RELEASE_QA.cmd`.
8. 원본/백업/비밀: Git 작업 전 SHA 복원점, 고객 REPORTS·Windows/BitLocker·복구·계정·환경변수·실데이터 무접근/무수정. QA_RESULTS Git ignore 유지.
9. 다음 작업/승인: Windows 전체 체크아웃에서 네이티브 `RUN_RELEASE_QA.cmd` 실행 및 로컬 영수증 확인→별도 명시 승인한 실제 read-only JSON/HTML/H08→USB·QR/A4→WinRE 격리 안전 검증. 실수리·복사·공개·결제 사전 승인 필수.
10. 갱신: 2026-10-31 KST. 격리 Python 10케이스 외 전 범위 미검증. 문서 SHA 최종 GitHub 확인 필요.

## 2026-10-31 KST — ZIP 체크섬 원본 보호 10항 인수인계
1. 목표·기술: AXMART PC CARE USB Release A Windows PS5.1/HTML/JSON 진단·저장·H08 및 내부 Python ZIP 검증. Release B WinRE 백업/수리는 별도 위험 승인.
2. 완료·판단: 내부 ZIP 생성기가 `.sha256` 링크를 따라 다른 파일을 덮어쓰지 않도록 링크 거부, `xb/x` exclusive 임시 ZIP·해시 작성, `os.replace` 게시. 타 실행 소유의 `.tmp`는 삭제하지 않음. 결정적 ZIP 재빌드는 유지.
3. 테스트: `tests/test_release.py` 합성 보호 fixture + `tests/test_package.py` 코드 계약 등록. GitHub 원격 실소스 `build_internal` 함수 2561글자/FNV1a32 `21f4b696` 정확 일치, 격리 Python 3.13 합성 입력 **9 PASS/0 FAIL**. 전체 GitHub `test_release.py`/다른 제품 소스 및 native Windows PS5.1/Node·USB·QR/A4·WinRE·CI **NOT_RUN**.
4. 진행: 내부 아카이브 체크섬 안전 보강 완료, 전체 Windows/실 ZIP 및 Release A 실제 장치 QA 대기. 사용자 배포와 Release B 실행 차단.
5. 오류·재시도/대안: 원인 `Path(...'.sha256').write_text`가 symlink를 따름. 덮어쓰기 없는 exclusive 임시 파일 생성·원본 소유 파일만 정리. 변경 전에 인수인계된 base SHA로 복원 가능; 기존 원본 손상 근거 없음. 격리 fixture 통과를 전체 제품 ZIP PASS로 간주 금지.
6. GitHub·브랜치·SHA: `hibi89/AX_MART@feature/pc-care-usb`, 이전 HEAD `51ffdc2695e88a7491ff903653b8fab5b303aba5`, 주요 코드 `tools/release.py`, `tests/test_release.py`, `tests/test_package.py`, 증거 `tests/evidence/zip_sidecar_atomic_native_qa_20261031.json`. 최종 HEAD는 문서 갱신 후 원격 재조회.
7. 실행·운영: 전체 체크아웃 Windows 11/PS5.1·Python 3.11+·Node, `RUN_RELEASE_QA.cmd` 합성 QA 후 로컬 `QA_RESULTS` 확인. 운영 `https://ax-mart.pages.dev/` `main`에는 미반영.
8. 원본·백업·인증: Git 기준 SHA 복구 가능, 사용자 로컬 REPORTS·임의 원본 파일·OS·BitLocker·자격증명/토큰·Cloudflare 설정 무접근/무수정. 테스트는 격리 임시 폴더에서 합성 파일만 사용.
9. 다음 작업 우선순위/승인: Windows 개발 체크아웃의 `RUN_RELEASE_QA.cmd` 1회 실실행 → 전체 원본 ZIP/sha256·Python/Node/PS5.1 증빙 → 명시적 read-only 진단/JSON·HTML/H08/USB·QR/A4 → WinRE 격리 VM 안전성 검증. 실복사·수리·출시/비용 변경 시 사전 승인.
10. 갱신 KST: 2026-10-31, GitHub readback + 동일 원본 함수의 합성 ZIP 로컬 테스트 9/9만 실증. CI 및 실제 Windows/고객 사용 범위 미확인.

## 2026-10-31 KST — CUBE 원본 ZIP 네이티브 QA / 인수인계 10항
1. 목표: AXMART PC CARE USB Release A 읽기 전용 Windows 11/PS5.1 진단·JSON/HTML·H08·상담 출력. ZIP 안전/무결성 확인; WinRE 실제 복사는 별도 Release B 안전 게이트.
2. 완료·의사결정: 코드를 임의 재작성하지 않고 GitHub 원격 `tools/release.py`와 공식 `tests/test_release.py`를 로컬에 바이트 동일 복원해 네이티브 Python 테스트. 이번엔 정상 작동하는 기존 원본 파일을 수정하지 않음.
3. 테스트: `python -m unittest discover -s tests -p test_release.py -v` (Python 3.13.5 Linux) **15 PASS/0 FAIL/0 SKIP**. 별도 동일 실제 원본 코드 기반 사용자 정의 합성 14 PASS/0 FAIL(범위 중복). Git blob SHA가 원격과 정확히 일치: `df378a1a308089e5b7ccbf1d2dd3c1a6b9d24095`(release), `8758f0df5a1dbf46770b4376534d64397d42d05f`(test). 제품 실제 allowlist 소스 ZIP·전체 Python/Node·Windows PS5.1/실 PC/USB·QR/A4·WinRE/CI 미실행.
4. 단계: 합성 ZIP 처리 실제 네이티브 검증 완료. 실제 제품 콘텐츠 ZIP/Windows 디바이스/E2E 수용 시험은 대기. 실수리·복사·고객 공개 금지.
5. 실패 근거·방법: 로컬 `git ls-remote`는 비공개 GitHub DNS 불가. 같은 실패 반복하지 않고 GitHub 연결 실제 소스를 원격 blob 검증해 복원. 테스트 오류/제품 결함 이번엔 없었음. 합성 파일 QA를 실제 고객 패키지 합격으로 오판 금지.
6. 저장소·브랜치·SHA·경로: `hibi89/AX_MART@feature/pc-care-usb`; 본 시험 기준 HEAD `973faa92980e6c22e4748d2012ec346875f06872`. 무수정 원본 `tools/release.py`, `tests/test_release.py`; 증빙 `tests/evidence/release_actual_python_native_20261031.json`. 최종 문서 SHA 원격 재확인.
7. Production·환경: `https://ax-mart.pages.dev/`는 운영 main 유지. Python 3.13.5/Linux 합성 테스트, 사용자 실기기 목표 Windows 11/PS5.1/Python≥3.11/Node, `RUN_RELEASE_QA.cmd` 로컬 실행.
8. 원본/백업/민감정보: Git baseline `973faa92980e6c22e4748d2012ec346875f06872` 복구점. 테스트는 임시 합성 데이터만; 고객 REPORTS/OS·BitLocker·키/개인정보 접근·수정/외부 업로드·계정/배포/권한 변경 없음.
9. 다음 우선순위·승인: 전체 실제 소스 ZIP `release.py` 검증→Windows 전체 `RUN_RELEASE_QA.cmd` (native PS5.1+Python+Node+ZIP)→명시적 read-only 실제 진단/저장/H08→USB·QR/A4→격리 WinRE 안전성. 실제 수리/백업 복사/상품 배포/결제 시 사전 승인.
10. 갱신·근거: 2026-10-31 KST, 공식 네이티브 Python unittest 15/15 + 중복 합성 커스텀 14/14까지 확인. 그 외 NOT_RUN, 구형 runner 실패는 현 SHA 오류로 오판 금지.

## 2026-10-31 KST — CUBE 볼륨 수집 완전성/진단 연속성 인수인계 10항
1. 목표·기술: AXMART PC CARE USB Release A Windows 11 PS5.1/CMD·로컬 JSON/HTML·H08/오프라인 QR·A4. Release B WinRE 실제 복사/수리 별도 승인.
2. 완료 기능·근거: Win32_LogicalDisk에서 직접 double 변환 중 NaN/Infinity/변환 오류가 전체 보고서 저장을 중단할 수 있어 기존 배포 `tools/telemetry_analysis.ps1`에 순수 `ConvertTo-PcCareVolumeSample` 추가. 문자·숫자·범위를 검증하고 문제가 있는 볼륨만 제외. `diagnose.ps1`은 유효한 볼륨 계속 처리, `volumeRejectedCount` 기록, `collectionStatus.volumes=incomplete`로 H08 비교 자동 제외. 기존 정상 용량 경고 임계값 유지.
3. 테스트·검증: GitHub 변경 소스 원격 readback 계약 **23 PASS/0 FAIL**. 변경 PS 함수에 대한 native PowerShell 5.1 시험 및 전체 원본 Python/Node/실 ZIP·Windows/USB/QR/A4/WinRE/CI NOT_RUN. 기존 무변경 `release.py` 공식 local Python unittest 15/15 PASS(새 진단 코어 검증 아님). 테스트 소스 `tests/telemetry_analysis.tests.ps1`·`tests/test_package.py`와 evidence JSON.
4. 상태: 코드·합성 fixture/정적 계약 반영 완료. Native Windows Release A 수용검증 대기. 제품 공개·권한 상승·Release B 백업/복구 차단.
5. 오류·시도·대안: 원인 오류 가능성이 query 바깥 형변환과 비유한 수가 JSON/이력 판정까지 전파되는 구조. 로직을 기존 순수 helper로 격리, false-complete 표시 차단. PS5.1 없는 현 실행 환경에서는 정적 PASS를 네이티브 PASS로 대체 금지; CI runner 실패 같은 방식 반복 금지.
6. GitHub 브랜치/경로/SHA: `hibi89/AX_MART@feature/pc-care-usb`, 변경 전 `328bcf1611d588b3c4c285cf773ac6540decdc40`. `tools/telemetry_analysis.ps1`, `tools/diagnose.ps1`, `tests/telemetry_analysis.tests.ps1`, `tests/test_package.py`, 증거 `tests/evidence/volume_metric_failclosed_source_qa_20261031.json`. 문서 기준 커밋 SHA 원격 확인.
7. Production/환경: `https://ax-mart.pages.dev/`는 기존 Cloudflare main(이번 기능 미배포). 원본 Windows 11/PS5.1·Python≥3.11·Node. 개발용 `RUN_RELEASE_QA.cmd`는 합성 시험/임시 ZIP과 로컬 QA 영수증만 생성.
8. 원본/백업/인증: Git 기준 이전 SHA 복원점. 고객 REPORTS·개인 경로/볼륨명·OS 설정·BitLocker·인증 토큰/키·실복구 미접근·미수정. 외부 데이터 업로드 및 자동 수리 없음.
9. 후속 우선순위/승인·완료 기준: Windows checkout native `RUN_RELEASE_QA.cmd`→합성 PS5.1 오류 0건 확인→사용자가 명시 실행한 read-only 실제 진단 JSON·HTML/H08→USB 한글 폴더/Edge/QR·A4→WinRE 격리. 실복사·수리/배포·결제/권한 변경 사전 승인.
10. 시점·검증 범위: 2026-10-31 KST, GitHub 원격 실소스 정적 계약 23개와 이전 ZIP Python suite만 확인. PS5.1 native·현 SHA CI·실 Windows/USB/WinRE 미검증. 최종 SHA는 작업 종료 시 재조회.

## 2026-10-31 KST — H08 불완전 볼륨 경고의 허위 해소 차단 / 10항
1. 목표·기술: PC CARE Release A 오프라인 Windows 11 PS5.1 진단·JSON/HTML 생성·H08 이력 비교, USB/QR/A4; Release B WinRE 안전 게이트 분리.
2. 완료·근거: H08에서 최신 `collectionStatus.volumes=incomplete` 상태로 이전 디스크 공간 부족 경고가 `missing` 처리되는 오판 재현·수정. 기존 볼륨 검증 맵을 경고 비교 전에 사용하고 최신 정상 수집 미확인이면 디스크 공간 경고의 미관찰 판정만 보류. 명시적 한계 문구 노출, 다른 경고/신규 관찰 경고 유지, 필드 없는 레거시 보고서 하위호환.
3. 검증: 실제 GitHub `ui/history_compare.js`·`ui/history_signals.js`·`tests/test_history_compare.cjs`를 V8 호환 `node:test`·`assert` 래퍼에서 **26 PASS/0 FAIL**. 별도 직접 17/17(일부 중복), 원격 정적 계약 16/16. **Node 실제 러너·Windows PS5.1·실 브라우저·전체 Python/ZIP/USB·QR/A4·WinRE·현 CI NOT_RUN**.
4. 상태: H08 불완전 디스크 이력 오류의 코드·회귀 등록 완료. Windows/실제 보고서/E2E 수용 검증은 대기. 공개 판매·고권한 수리·WinRE 복사 금지.
5. 오류·원인·시도·대안: `codeSet` 비교가 `collectionStatus.volumes`를 보지 않고 `issues=[]`를 경고 미관찰로 해석. 데이터 공급 중 오류 시 정상 증거 없이 경고가 사라지는 문제. 공급자 검증 결과를 코드별로 적용. V8 실행기 최초에 `./history_signals.js` 모듈 라우팅 누락으로 실패했으나 래퍼 수정 후 26/26, 제품 코드 오류 아님. CI 이전 runner 미배정 상태 반복 호출하지 않음.
6. 저장소·브랜치·경로/SHA: `hibi89/AX_MART@feature/pc-care-usb` 작업 시작 SHA `d2eaf480df274ac21c0eb4470cf795b35cbe933d`; `ui/history_compare.js`, `tests/test_history_compare.cjs`, `tests/test_package.py`. 증거 `tests/evidence/h08_volume_warning_provenance_v8_20261031.json`; 최종 커밋 SHA는 GitHub readback.
7. Production/실행: `https://ax-mart.pages.dev/`은 운영 main 전용, 이번 H08 버그 수정 프로덕션 미적용. 개발 Windows 11/PowerShell5.1·Python 3.11+·Node; `RUN_RELEASE_QA.cmd`는 합성 테스트/임시 ZIP·로컬 영수증만 생성.
8. 원본/백업·인증: Git baseline SHA는 코드 복구점. 사용자 REPORTS·OS/저장장치·BitLocker·개인정보/토큰 미접근·무수정. 외부 API 호출/자동 수리·배포/권한 변경 없음.
9. 다음 작업/승인: 실제 전체 Windows 체크아웃 `RUN_RELEASE_QA.cmd`로 Node/PS5.1/Python/ZIP → 사용자 명시 read-only 로컬 JSON·HTML/H08 비교/한글 USB/QR·A4 → WinRE는 격리 실장치 안전성 검증. 실제 복사·복구·수리·공개 배포·비용/권한 변경 사전 승인.
10. 갱신: 2026-10-31 KST. 현재 검증은 원본 JS를 V8에서 실행한 호환 테스트와 원격 정적 검사까지. 실제 Windows·Node/CI 미검증이며 제품 출시 완료 아님.

## 2026-10-31 KST — PC CARE 상담표 수집 증거 fail-closed (CUBE)
- `tools/consultation_report.ps1`: 물리 디스크 조회 `unavailable/empty` 상태에서 남은 Warning 표본을 새 경고로 표시하던 오탐 차단. `collected/truncated`에서 실제 관측한 Warning은 유지, `collected` 전체 Healthy만 정상 신호로 허용.
- A4 상담표 사건 근거에 System/Update 수집 출처별 kind·ID 분리, System provider allowlist, `event_recorded_time`, 명시적 UTC/offset 및 유효 달력 검사 추가. 미검증·위장·로컬시각 입력은 상담표에서 제외.
- 합성 PowerShell 회귀 fixture 및 Python 소스 계약 보강. GitHub 원본 내용 기준 정적 연결/스키마 검사만 수행; **Windows PowerShell 5.1 실제 실행, 전체 Python/Node, 실 Windows·USB/QR/A4·WinRE, 제품 ZIP, CI = NOT_RUN/UNVERIFIED**. 증거 `tests/evidence/consultation_provenance_status_static_qa_20261031.json`.
- 원본 Git 시작 SHA `28a7828bff5f0279cd01b62368fbbfcc09a28672`; `main` `fbb32362455378b85bcdd0b5037d1f338055fb71`/Cloudflare Production·기존 사용자 파일·권한·수리·판매/공개 배포 불변. 다음 P0: 전체 Windows checkout `RUN_RELEASE_QA.cmd` 실행 후 읽기전용 JSON/HTML→상담표·H08→QR/A4/USB 실제 QA.

## 2026-10-31 KST — CUBE System/Update 이벤트 공급자 정합성 (복구 검증 완료)
- 구현 범위: `tools/telemetry_analysis.ps1` Windows Update 정규화 출력에 allowlist 확정 provider 토큰을 추가. `tools/recorded_timeline.ps1`의 System BugCheck/Kernel-Power/EventLog/Storage 증거, Update 시간축에 kind+ID+provider+event_recorded_time+UTC/offset 동시 검사. `tools/consultation_report.ps1`의 Update 기록도 공식 provider가 없거나 위장되면 제외.
- 회귀: `tests/telemetry_analysis.tests.ps1`, `tests/driver_timeline.tests.ps1`, `tests/consultation_report.tests.ps1`, `tests/test_package.py` 변경; 관련 static 계약 10/10 및 원격 7파일 BOM/함수/크기/핵심 문자열 검수. **실제 PS5.1 native 테스트 통과는 아님**.
- 사고/복구: 첫 커밋 `e08329de17edc4593ee1c6e614a40eabbc3dc3a6`에서 JavaScript `String.replace`의 문자열 `$'` 치환 확장으로 `recorded_timeline.ps1` 본문이 6,995→25,753자로 손상됨. 기능 성공 판정 철회. 이전 정상 `f445f3bbf898db6e5c64f9d99622652cb5b4bff6` 내용으로 정확히 재구성하고 **콜백 기반 치환**으로 provider gate만 삽입, 복구 커밋 `534061a712df3d48c48818e701405c2feb83a07d`. 원격 복구 본문 **8,149자**, 함수 정의 1개, 기존 본문 6,995자 동일 + gate 1,154자, PS5.1 BOM 유지. 해당 위험 치환 방식 재사용 금지.
- 상태: `feature/pc-care-usb` 한정; `main` SHA `fbb32362455378b85bcdd0b5037d1f338055fb71`/Cloudflare Production 및 고객 파일·장치·실수리/판매 공개 변경 없음. Windows PowerShell5.1, Node/Python 전체, 정식 내부 제품 ZIP, USB/QR/A4/WinRE, 최신 CI **NOT_RUN/UNVERIFIED**. 출시 HOLD.
- 다음 P0: Windows 전체 소스에서 `RUN_RELEASE_QA.cmd` → `QA_RESULTS` 확인 → `RUN_HEALTH_CHECK.cmd` 읽기 전용 JSON/HTML 생성 → H08·상담표·QR/PDF·USB 실기기 확인. WinRE/승인형 복구는 별도 격리/승인 게이트. 복구 기준 SHA `f445f3b`로 정상 기능 이전 상태 보존.

## 2026-10-31 KST — CUBE H08 Windows Update provider 신뢰성 + V8 E2E
- 실제 코드 결함: `ui/history_signals.js`가 Windows Update 증거의 ID/kind/UTC/count는 검증했지만 `provider`가 누락·위조되어도 비교 통계가 생성됐음. 원본 GitHub JS V8 실행으로 `Fake-Microsoft-Windows-WindowsUpdateClient`가 업데이트 감소/증가 분석에 사용되는 것을 재현.
- 수정: 업데이트 비교는 `item.provider==="Microsoft-Windows-WindowsUpdateClient"`를 요구. 신규 정규화 출력에는 정확한 provider 토큰이 포함되며 구형 provider 없는 보고서는 **비교 불가(안전 우선)**. 기존 정상 날짜/수집 상태/건수·PnP/Windows 비교 유지.
- 공식 `tests/test_history_signals.cjs` 정상 fixture+위조/누락 공급자 회귀, `tests/test_package.py` 정적 계약 추가. GitHub 원본 JS 모듈(`history_signals.js`, `history_compare.js`, `history_print.js`) 및 공식 Node test 파일 2개를 **V8 테스트 어댑터**로 실행해 단위·통합 **16 PASS/0 FAIL** 확인. 이는 네이티브 Node 테스트가 아니며 **Python 전체·Windows PowerShell5.1·실Windows/USB·QR/A4·WinRE·내부 ZIP·CI NOT_RUN**.
- 증빙: `products/pc-care/tests/evidence/h08_update_provider_v8_20261031.json`. 기준 정상 SHA `9df862d5d4ce5ee37041f95b3955641e328552ad`. `main`/Cloudflare·실제 보고서·수리/WinRE 파일 복사·출시/판매 무변경. 다음: 실제 Windows 전체 checkout의 `RUN_RELEASE_QA.cmd` 및 read-only 보고서/H08/QR/A4 실기기 확인.

## 2026-10-31 KST — CUBE H08 8종 경고 미관찰 수집 신뢰성 통합 게이트
- 기준 `4eb938bd56fad61c35637860a57d6faa0b6bb6ca`에서 재현한 실제 H08 오류: 수집 상태 `unavailable`이거나 동일 이벤트가 최신 보고서에도 있는데 `issues=[]`만으로 BUGCHECK/DISK_HEALTH/PNP_CONFIGURATION 등이 `missing`(미관찰 경고)로 표시됨. 이 출력은 수리 성공이 아니지만 오판 가능.
- `ui/history_compare.js` 수집 증거 기반 `sourceSupportsMissing`: BUGCHECK/UNEXPECTED_REBOOT/STORAGE_EVENTS는 양쪽 Event collection 완료+제한/기간·provider 검증+현재 해당 기록 0; UPDATE_FAILURE는 양쪽 완전한 Windows Update 비교+현재 실패 기록 0; PNP는 신뢰된 상태와 샘플에서 활성 구성 코드 0(22 사용 중지는 예외); DISK_HEALTH는 두 보고서의 완전/동일 장치 수+알려진 상태 및 신규 경고 0; DISK_SPACE는 기존 볼륨 유효성 검증 유지. 신규 실제 관측 경고는 보존, 차단 이유 주의 문구 추가. 표시값은 '관찰되지 않음'이지 수리 성공이 아님.
- 공식 Node 테스트 3파일(기존+합성 회귀 4건)을 GitHub 소스 V8 Node 호환 래퍼에서 **44/44 PASS**, 진짜 Node 런타임이 아닌 점 명시. `test_package.py` 소스 계약 보강. 증거 `tests/evidence/h08_multisource_missing_warning_v8_20261031.json`. Windows PS5.1·Native Node 전체·Python 전체·브라우저/USB/QR/A4/WinRE/ZIP/CI **NOT_RUN**.
- 기존 `main`/Cloudflare·사용자 원본 데이터/권한/수리/배포·판매 불변. 다음 P0: Windows 전체 checkout `RUN_RELEASE_QA.cmd`, 실제 보고서/H08 출력 검증, 제품 출시 HOLD.

## 2026-10-31 KST — CUBE 실제 진단 분석 이벤트 출처 필터 추가
- **원인/위험:** `tools/incident_analysis.ps1`가 System 및 Windows Update collector의 상태만 확인하고 `kind`에 일치하는 입력을 무검증으로 사용, 잘못된 ID/provider/recordedUtc/timeBasis·교차 출처가 BugCheck·종료·업데이트·저장장치 검토 항목을 만드는 위험. 보수적 "원인 확정 아님" 정책과 충돌.
- **개선:** `Test-PcCareIncidentEvidence` 순수 함수에서 ID·분류·공식 provider allowlist·기록 시각 `event_recorded_time`·오프셋 명시 ISO timestamp/실제 달력을 확인, System/Update 출처를 분리. 거부 건수를 `observedCounts.rejectedSystemEvidence/rejectedUpdateEvidence`에 기록하고 분석 `status=incomplete` 및 제한 문구. 정상 데이터·종료/버그체크/업데이트/스토리지 각각 기존 판단 정책은 유지. 개인정보·원본 이벤트 메시지/경로 출력·실 수리/장치 조작 없음.
- **검증:** 기존 합성 PowerShell fixtures에 공식 provider/UTC를 추가하고 위조 공급자·ID/종류 충돌·현지 시각·불가능한 날짜·교차 출처·일부 유효 데이터 회귀 추가. Python 정적 계약 추가. GitHub 원본 확인 기반 **9/9 SOURCE CONTRACT PASS**. 실제 WinPS 5.1/전체 Python/Node/Windows·USB·QR/A4·WinRE·ZIP·CI **NOT_RUN/UNVERIFIED**, 따라서 실제 기능 PASS 주장 금지. 증빙 `products/pc-care/tests/evidence/incident_provenance_guard_20261031.json`.
- **운영·복구:** 기준 SHA `6b17c88863bc035c266ac159b61e7ab3812b84e9`; `feature/pc-care-usb`만 수정. `main`/Cloudflare·실 사용자 데이터/파일·계정·BitLocker/복구·유료·배포 무변경, 출시 HOLD.
- **다음:** 실제 Windows 전체 checkout의 `RUN_RELEASE_QA.cmd` PowerShell/parser/fixture → Python/Node/ZIP → 읽기전용 JSON·HTML, H08/A4/QR 및 USB 실기기 검증. WinRE는 별도 승인/격리. 실패 시 해당 SHA로 복구, `STATUS/HANDOFF` 재최신화.

## 2026-10-31 KST — CUBE PC CARE 진단 보고서 자동 동기화 방지
- 주요 개인정보 결함: `tools/diagnose.ps1`의 `REPORTS` 및 `MyDocuments` 저장 후보가 사용자의 OneDrive 동기화 디렉터리일 수 있어, 앱이 직접 전송하지 않아도 OS 클라우드 동기화 위험. 외부 전송·데이터 유출 확인은 아니며 **잠재적 자동 동기화 경로** 발견.
- `tools/report_io.ps1`에 `Test-PcCarePrivateReportFolder` 추가: UNC, OneDrive/Dropbox/Google Drive/iCloud/Box 알려진 경로명·환경 루트, 기존 경로 조상 junction/reparse를 fail-closed. 부적합 후보에는 디렉터리나 파일을 만들지 않고 다른 후보로 진행. 원자적인 `CreateNew` 저장/충돌 보존·자기 소유 temp만 제거·사용자 원본 유지.
- USB `REPORTS`를 기본 후보로 유지. 보안 검증된 `LocalApplicationData\AXMART-PC-CARE-Reports`를 두 번째로 추가하고, 동기화되지 않는 구형 Documents는 세 번째로 유지. 기존 보고서 이동/삭제/덮어쓰기 없음. `tests/windows_smoke.ps1` 영수증 허용 경로도 갱신하고 잘못된 경로 거부. `tests/report_io.tests.ps1`에 합성 OneDrive/UNC, 정상 로컬 fallback, 클라우드 단독 후보 거부 회귀 추가. `tests/test_package.py` 소스 계약·README 안내 갱신.
- 정적 원본 검사 **10/10 PASS**, Windows PowerShell 5.1·실Windows/OneDrive/USB/QR/A4·Python/Node 네이티브 전체·ZIP·CI **NOT_RUN/UNVERIFIED**. 별도 사용자 클라우드·OS·기존 보고서 접근/수정 없음. **기타 동기화 클라이언트와 특이 사용자 설정은 완전 검출 보장하지 않으며 Windows 실기기 검증 전 공개 금지**.
- 기준 커밋 `69b8b8e84fc3ec4fa3863c945dceeb9790dc637b`, `main`/Cloudflare 운영 불변. 다음 실제 Windows `RUN_RELEASE_QA.cmd` → 폴더 동기화 경계·로컬 보고서 JSON/HTML/H08/상담/QR/USB 안전 확인, WinRE는 별도 승인 게이트.

### 2026-10-31 KST — CUBE 로컬 보고서 정책 QA 코드 순서 수정
- 직전 `6ae76d72c79691bfa70a899f1ae47c19e5ee76f7`의 `test_package.py`에서 `report_fixture`를 할당하기 전에 새 `assertIn`이 사용하는 순서 문제를 발견. 테스트 호출 시 `UnboundLocalError` 발생 가능. 해당 fixture 파일 읽기 할당을 최초 사용 앞에 이동하고 중복 할당 제거. 실행 중인 OS/사용자 원본 데이터·저장 경로 소스 변경 없음.
- 실제 소스에서 `assignment index < first assertion index`, 할당 1회 확인; 정적 3/3 PASS. 기존 검증 표기 정정: **직전 10/10은 원본 코드 계약의 표면 검사이며 전체 Python unittest 통과 증거가 아님.** 네이티브 Python/WinPS5.1/CI·실 OneDrive·USB **미실행**, RELEASE HOLD. `feature/pc-care-usb`만 변경, `main`/Production 유지.

### 2026-10-31 KST — CUBE REPORTS 네트워크 매핑 드라이브 차단 추가
- 이전 `Test-PcCarePrivateReportFolder`은 UNC(`\\server\share`)는 거부하지만 `X:\REPORTS`처럼 **매핑된 네트워크 드라이브**는 UNC 접두사가 없어 저장이 허용되는 결함 발견. 동기화/외부 데이터 전송 없는 기본 정책과 충돌.
- 파일 시스템의 실제 `[IO.DriveInfo].DriveType` 확인: `Fixed` 또는 `Removable`만 허용, `Network`/알 수 없는·광학 드라이브는 거부. 이름/환경변수/조상 reparse 검사는 그대로 유지. USB(제거식) 진단·LocalApplicationData(고정식) fallback은 보존.
- `tests/report_io.tests.ps1`에 DriveType 상태별 5건+로컬 경로 허용 회귀, `test_package.py` 원본 계약 추가. **소스 정적 12/12 PASS**, PowerShell5.1 네이티브·Windows·네트워크 매핑·USB·Python 전체·ZIP/CI **NOT_RUN/UNVERIFIED**. 보고서·사용자 데이터·OS/권한/판매/배포에 실제 변경 없음.
- baseline `bee6b09382fa960171a821f3c3e5ed7f08795f2a`, `feature/pc-care-usb` 한정. `main`/Cloudflare 유지, 출시 HOLD. Windows `RUN_RELEASE_QA.cmd` 우선, 정상 fixed/removable·mapped network·OneDrive/Junction E2E 테스트 후 공개 판단.
