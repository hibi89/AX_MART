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

