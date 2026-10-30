# AXMART PC CARE USB — 상태 기록 (2026-10-30 KST)

## 대상
- AXMART 마켓 첫 판매 후보 제품. Windows 10/11용 USB 휴대형 PC 진단, 승인형 일부 Windows 시스템 복구, 부팅 장애시 WinRE 진단 보조.
- 상품가 제안 ₩5,000, 확정된 실판매 상품 아님.

## 확인된 완료
- v0.1-alpha 프로토타입: `RUN_HEALTH_CHECK.cmd`, `tools/diagnose.ps1` (읽기 전용 점검), `RUN_SAFE_REPAIR.cmd`, `tools/repair.ps1` (관리자·백업·명시적 승인 후 DISM/SFC), `recovery/WINRE_READ_ONLY.cmd` (오프라인 읽기 전용 인벤토리).
- Windows 출력 보고서 HTML/JSON 생성 기능 코드 작성, 예시 보고서 HTML에 가상 데이터 명시.
- 로컬 정적 테스트 5/5 PASS; Chromium 직접 콘텐츠 삽입으로 UI 1280px/390px overflow 0, JS 오류 0. 예시 보고서 화면 검사에 한정.
- 정식 Windows 바이너리/WinPE 포함하지 않음. 외부 API/서버/계정/설치기 없음. Windows 데이터 수정 가능 명령은 별도 명시적 승인 단계에만 존재.

## 미검증·진행 필요
- Windows 10/11 실기기 및 PowerShell 5.1에서 `diagnose.ps1` 동작: **미검증**. 특히 OS 정보, SMART 접근, Get-WinEvent 권한·로그 없는 PC, Defender, 수리 명령 실행.
- WinRE 수동 모드에서 `WINRE_READ_ONLY.cmd` 및 BitLocker 잠금 처리: **미검증**.
- 위험 분석 정확도·민감도/특이도 및 기기별 False positives: **미검증**.
- Windows 코드 서명/SmartScreen/백신 오탐, 데이터 보호, 상용 고객지원/환불/라이선스: **미검증**.
- USB 자체 부팅, 오프라인 자동 수리, 실판매·결제·AXMART 상품 등록: **미구현**.
- GitHub 프로젝트 브랜치 반영·Cloudflare 배포: **미반영**. 이 ZIP은 로컬 시험용으로만 제공, 기존 `hibi89/AX_MART` live Production 변경하지 않음.

## 기술적 제약과 선택
- 자체 WinPE/WinRE 포함 상용 판매는 권리 확인 필요. 대신 제품은 자체 PowerShell/CMD 스크립트만 배포하고 Windows 복구 미디어는 Microsoft 공식 경로를 별도 사용.
- 디스크 물리 오류 때 데이터 보호 우선. `chkdsk /f /r`, 부트 파티션 쓰기, 자동 리셋/재설치·강제 재부팅 미포함.
- PDF·계정 수집·클라우드 추론 없는 오프라인 결과. 출력 보고서는 로컬에만 저장.

## 다음 우선순위
1. 실제 Windows PC에서 읽기 전용 `RUN_HEALTH_CHECK.cmd` 검증 후 버그 보정.
2. 장애 유형별 테스트 시나리오(블루스크린, 비정상 종료, 부팅 실패, BitLocker 잠김)·복원 스냅샷 VM로 반복 검증.
3. 사용자 승인 후 비공개 GitHub 제품 브랜치 저장·체계화. 판매 품질 목표 달성 전 `AXMART` 상품 실제 구매 페이지 공개 금지.
4. 수리 단계 실기기·VM 테스트, 서명·설치 편의성·판매 정책 확정 후 5,000원 출시 판단.


## GitHub 저장 확정 — 2026-10-30 KST (이전 '미반영' 기록을 대체)
- **현재 15개 소스 파일 GitHub 저장 완료:** `hibi89/AX_MART` / `feature/pc-care-usb` / `products/pc-care/`.
- 최초 원본 업로드 커밋: `5bd374badbb63b1c6bb0aa911f9e2fd1412d36d1`. 기존 홈페이지 Production `main`과 분리했다.
- 파일 구성: `RUN_HEALTH_CHECK.cmd`, `RUN_SAFE_REPAIR.cmd`, `tools/diagnose.ps1`, `tools/repair.ps1`, `recovery/WINRE_READ_ONLY.cmd`, `tests/test_package.py`, `docs/*`, `examples/SAMPLE_REPORT_DEMO.html`, `REPORTS/README.txt`, `README.md`, `STATUS.md`, `HANDOFF.md`.
- 저장은 **소스 버전 관리 완료**를 뜻하며 Windows 실기기 작동 검증/복구 안전성/배포 가능 판정이 아니다. 파일은 비공개 GitHub 브랜치에만 존재하며 홈페이지에서 다운로드되지 않는다.
- 사용자 최신 제품화 요구: 정상 부팅 PC에서 반복적으로 상태 점검, 블루스크린 이력 원인 진단 보조, 부팅 실패 시 USB를 활용한 안전한 장애 분석, 수리가 가능한 일부 경우에만 **명시적 동의 + 백업 후** 제한적 복구. 물리 고장과 BitLocker 문제를 만능 자동 수리라고 표현하지 않는다.
- 가격/출시: 초기 무료 베타+익명 선택적 피드백. 이후 유료 판매 검토시 자체 AXMART 예상 ₩5,000, 크몽 예상 ₩10,000. 실제 판매·사업자·결제는 아직 없음.
- 다음 채팅방 첫 작업: 본 브랜치 HEAD와 실제 코드 검사 → Windows 10/11 읽기 전용 진단 로직 수정·확장 → Windows VM/실기기 검증 계획 및 실행 → WinRE / BitLocker / 장애 상황 재현 → 위험 복구 절차 분리 검증 → 배포·피드백·상점 등록.
- 업로드 원본 `AXMART_PC_CARE_USB_v0.1-alpha.zip` SHA-256: `27350aa7245e2b9d2ea48b360d96f69022caef29e286cef179063b22cbb02dad`. ZIP은 테스트용 별도 산출물로서 홈페이지 배포 불가.


## 2026-10-30 15:35 KST — 진단/수리 안전성 보강
- PowerShell 5.1 대응: GitHub 파일의 UTF-8 BOM 누락 확인 후 진단/수리 ps1에 BOM 부여. 기존 패키지 테스트는 BOM을 요구했으나 GitHub 반영본이 불일치하던 문제 수정.
- 이벤트 로그 접근 실패 시 HTML 요약에 0건으로 표시하지 않고 '확인 불가' 표시. 1,500건 최대 조회에 걸리면 '수집분'으로 표시하며 JSON eventCollection=truncated 기록.
- 저장장치 조회 실패/0건/Healthy 이외 상태에서는 DISM/SFC 경로 차단(fail closed). 백업과 이중 명시적 승인 순서 유지.
- WinRE 보고서 생성 실패 시 화면 표시로 전환; stderr 로그 리디렉션 순서 수정; BitLocker/BCD 식별정보 공유 주의문구 추가.
- 신규 Python 정적 회귀 테스트 4개, Windows PS 5.1 전용 파서/읽기 전용 opt-in smoke 및 검증 매트릭스 추가.
- 테스트 상태: 도구 실행 환경에 Windows PowerShell/WinRE 없음. Windows 실제 작동/문법 파서 결과/수리 복구 **미검증**. 사이트 main 및 Cloudflare Production 미변경.

## 2026-10-30 KST — HTML 보고서 실제 진단 정보 확대
- 기존 숫자 요약 외에 물리 저장장치 상태/마모율/온도(기기 지원 시) 및 최근 BugCheck STOP 코드와 시각 최대 15건을 HTML에 표시.
- 모든 동적 텍스트는 HTML encode 처리. 로그 접근 실패는 '확인 불가', 상태 미지원도 '확인 불가'로 표시하여 정상 오인 방지.
- Windows 5.1/WinRE 런타임 및 실제 PC 사용성 검증은 아직 미완료. 정적 계약 검사는 추가했으며 실제 실행 테스트로 대체 불가.

## 2026-10-30 KST — 안전한 시험용 ZIP 구성
- `tools/release.py`: 고정 허용 파일 9개+SHA256 manifest만 ZIP에 포함, 진단 REPORTS·테스트·덤프·개인정보 자동 제외.
- 별도 `--internal-testing` 실행이 있어야 ZIP 생성. ZIP은 INTERNAL_TEST_ONLY로 명명하고 기본 공개 배포 기능 없음. 출력물 SHA256 별도 생성·검증.
- `tests/test_release.py`: 임시 가상 소스 기반 로컬 Python 6/6 PASS (결정적 ZIP, checksum, 누락/BOM 차단, 보고서 미포함, 기본 공개 기능 없음).
- 실제 Windows 파일 묶음 전체에 대한 패키징/실기기 실행/WinRE·DISM/SFC·SmartScreen 검증은 미완료. ZIP을 홈페이지에서 배포하지 않음.

## 2026-10-30 KST — 초보자용 Windows 수동 검증 진입점
- `RUN_SELF_TEST.cmd` 추가: 1일 읽기 전용 진단 + PowerShell 파서/JSON 생성 체크를 간단히 실행하고 종료 코드 표시, DISM/SFC 실행 경로 없음.
- 내부 시험 ZIP에 `RUN_SELF_TEST.cmd`, `tests/windows_smoke.ps1` 포함. 허용 목록 **11개 파일** + MANIFEST. 가짜 결과/고객 로그는 포함하지 않음.
- `tests/test_package.py`에 self-test 연결 안전 조건 1개 추가. Linux fixture 압축/무결성 테스트는 6/6 통과; 실제 Windows 실행은 여전히 **검증 대기**.

## 2026-10-30 KST — 플랫폼·제품명 분리
- 사이트 브랜드 AXMART³ (AXMART CUBE), 제품명 AXMART PC CARE로 합의. 기존 내부 USB 이름은 구현 파일명으로 보존.
- 메인 GitHub 사이트 브랜드는 `main` 브랜치에서 반영; 이 브랜치는 PC CARE 실제 Windows 코드 개발용이며 Windows 실기기/WinRE/수리 검증 대기.

## 2026-10-30 KST — AXMART PC CARE 통합 스펙 v2.0 확정
- 상세 요구사항과 기능 범위는 products/pc-care/docs/FINAL_SPEC_V2.md를 기준으로 한다. Gemini 제안 두 개 결합: HEALTH, ANALYZE, REPORT(1페이지/PDF/QR), RESCUE(WinRE 조건부 파일 백업), RECOVER.
- Release A(진단+보고서+WinRE 읽기전용)와 Release B(복사 안전 검증 통과 후)를 분리. BitLocker 자동 해제·무인 전체 파일복사·DDU 자동화·하드웨어/사기판단 보증 금지.
- 이번 턴은 사양만 기록, 기존 Windows 코드 변경/테스트/홈페이지 판매 개시는 수행하지 않았다.

## 2026-10-30 KST — 새 채팅 인수인계 확정
- 루트 `NEXT_CHAT_PC_CARE.md`에 사용자 최종 합의, Gemini 통합 v2 설계, Release A/B 범위, 구현과 미검증 구분, 다음 P0 우선순위, 복구 금지조건, 현재 GitHub/Cloudflare 범위를 정리했다.
- 실작동 Windows/WinRE 검증이나 제품 코드 변경은 이번 작업에서 하지 않았음.

## 2026-10-30 KST — FINAL_SPEC_V2 P0 구현 1차 / 정적 검토 완료 (최신)

- **기준:** 루트 NEXT_CHAT_PC_CARE.md + docs/FINAL_SPEC_V2.md. 제품 개발은 feature/pc-care-usb에만 수행. Cloudflare main 및 공개 다운로드/결제 변경 없음.
- **실제 코드 변경:** tools/event_analysis.ps1 신규(PS5.1 UTF-8 BOM, 사건 공통 스키마, BugCheck 1001 공급자 검증, STOP 코드 추출, RecordId 중복 제외, Kernel-Power 41 및 EventLog 6008 근접 신호는 중복 가능 그룹으로만 처리, UTC 정렬). tools/diagnose.ps1 연동. 이벤트 기록 시각은 실제 장애 시각과 다를 수 있음을 표시. 원문 로그는 JSON에 저장하지 않음.
- **수집 실패:** 이벤트 collected/no matching events/truncated/unavailable 분리. OS·볼륨·물리 디스크·Defender는 collected/empty/unavailable을 observations.collectionStatus에 기록. 누락되거나 잘못된 FreeSpace 값은 공간 부족으로 오인하지 않음.
- **보고서:** JSON + HTML 쌍이 모두 저장된 뒤에만 성공 처리. USB 경로에 쓰기 실패 시 Documents 폴백. 부분 파일 정리, 전체 실패는 명시적 오류 처리.
- **테스트 코드:** tests/event_analysis.tests.ps1 신규(중복·1001 공급자·기록 시각·로그 원문 비저장·거부·빈 로그·상한·정상). tests/windows_smoke.ps1에 파서+fixture 및 읽기 전용 검사시 HTML/JSON 쌍 확인. tools/release.py 내부 시험 ZIP에 모듈 포함(공개 ZIP 불가). tests/test_package.py 계약 검사를 보강.
- **실제 수행 검증:** GitHub 관련 파일을 다시 읽고 문자열/BOM/참조/금지 경로/내부 ZIP 연결 정적 소스 점검 **17/17 조건 충족**. 이는 PowerShell 파서/실행, Python unittest 실행과 다름. GitHub 커밋 작성자/커미터 hibi89 확인. 문서 작성 전 코드 기준 SHA cad89a644dd18e3a267fda842e3da22c841f9b95.
- **미실행/미검증:** Python unittest, Windows PowerShell 5.1 파서/fixture/실제 진단, WinRE·BitLocker·복구, 실제 보고서 저장 실패 재현, 실제 UI 렌더. GitHub CI 상태 체크 0개(통과 의미 아님). 이 작업 환경에는 Windows/PowerShell 없고 비공개 GitHub에 대한 외부 컨테이너 DNS 불가.
- **P0 잔여 게이트:** ①Python 테스트 ②Win11 표준 사용자 RUN_SELF_TEST.cmd ③VM에서 관리자/로그 없음/접근 거부/읽기 전용 USB·Documents 폴백 ④Win10 제한 대상 ⑤실패 수정 및 재검증. 무료 베타/판매/공개 ZIP·자동 수리는 계속 차단.

## 2026-10-30 KST — P0 후속 진행: 내부 시험 ZIP / 회귀 계약 보정 (최신)

- 기존 내부 ZIP에서 Windows smoke가 호출하는 tests/event_analysis.tests.ps1을 빠뜨려 실제 실행이 실패할 수 있던 결함을 수정했고, 해당 의존성을 test_release.py에서 검사하도록 추가했다.
- 기존 Python 정적 테스트가 NoMatchingEventsFound를 옛 diagnose.ps1에서 찾던 오류를 새로운 event_analysis.ps1 기준으로 수정했다. 진단기의 Remove-Item은 자체 생성 임시/보고서 파일의 실패 롤백에만 사용되므로 삭제 범위·단 1회 사용을 검증하도록 수정했다.
- 이벤트 조회 helper에 Select-Object -First MaxEvents 상한을 적용, 합성 fixture에 조회 상한 초과·UTC 정규화 사례 추가.
- 관리자 자동승격 없이 현재 권한 상태 기록; 물리 저장장치별 ReliabilityCounter collected/empty/unavailable 상태 명시.
- Windows 검증 계획서에 표준 계정·빈/거부 로그·이벤트 상한·USB/문서 폴백·저장 실패 13개 시나리오 추가(실행 전).
- 실제 수행: GitHub 소스 9개 파일에 대한 교차 정적 계약 검사 35/35 조건 충족. PowerShell 파서·Python unittest·Windows/WinRE 런타임·실제 ZIP 생성/검증 테스트는 미실행. GitHub 체크 상태 0개는 CI PASS가 아니다.
- 제품 개발 브랜치 feature/pc-care-usb, 문서 작성 직전 기능 커밋 5dd651ab0d713780bbaac5c730394a141df2ae59. main/Cloudflare Production 및 공개 다운로드·판매 기능은 변경하지 않음.
- 다음 게이트: Windows 11 x64 PS5.1 파서+fixture → 기본 사용자 1일 read-only 진단 → USB/로그/파일 실패 VM 재현 → Windows 10 제한 대상 호환성. 그 전까지 P0 완성 및 무료 배포 주장 금지.

## 2026-10-30 KST — P0 로컬 보고서 안전성 보강 (최신)

- **원인:** 기존 보고서 저장 함수의 실패 정리 루프가 실행 시 새로 만든 파일인지 구별하지 않고 최종 JSON/HTML 경로까지 삭제할 수 있었다. 파일명 충돌 등 예외 환경에서 기존 보고서 보존 보장이 부족했다.
- **해결:** 보고서 저장 함수를 tools/report_io.ps1로 격리, 기존 임시/최종 파일 이름이 존재하면 덮어쓰기 없이 중단. 임시 파일은 정리하되 최종 파일은 이번 실행에서 이동 완료한 파일만 제거하도록 상태 플래그 추가. 보고서 생성은 로컬 기능만 수행하고 시스템 원본은 변경하지 않음.
- **새 검증 코드:** tests/report_io.tests.ps1는 독립 임시 폴더에서 정상 JSON/HTML 저장, 기존 이름 충돌 보존, 첫 저장 후보 실패 후 폴백, 전부 실패한 경우의 명시적 오류를 검사한다. tests/windows_smoke.ps1 연결 및 내부 시험 ZIP 파일/의존 테스트 반영.
- **실측 범위:** GitHub 반영 파일 10개에 대해 소스/BOM/호출 관계/충돌 가드/ZIP 구성 **정적 계약 16/16 조건 충족**. Python 단위 테스트 및 Windows PowerShell 파서·새 fixture는 실제 실행되지 않았으므로 PASS로 표시하지 않는다.
- **개발 브랜치:** hibi89/AX_MART feature/pc-care-usb. main 및 Cloudflare 운영 사이트 미변경. 공개 다운로드·결제·승인형 복구 테스트/실사용 모두 차단.
- **다음 게이트:** Windows 11 x64 비관리자 PS5.1 Parser 및 event/report fixtures 실제 실행, 내부 ZIP에서 self-test 재실행, 읽기 전용 진단의 데이터/권한/쓰기 실패 시나리오 실측. P0 전체 완료는 검증 후 결정.

## 2026-10-30 KST — P1 장애 증거 해설 엔진 첫 구현 (최신)

- 기존 feature/pc-care-usb P0 코드는 보존. 신규 tools/incident_analysis.ps1에 PowerShell 5.1용 순수 규칙 함수를 구현. 인풋은 정규화된 System 이벤트, 장치 상태, 이벤트 수집 상태; 출력은 versioned findings/observedCounts/limitations이며 진단 확정 여부는 false.
- 관측 기반 규칙: 저장장치 오류·Warning/Unhealthy 시 백업 우선, BugCheck(정상 공급자) 기록 시 STOP 코드 검토 안내, 이벤트 41/6008은 비정상 종료 신호만으로 취급. 저장장치+BugCheck 동시 관측은 인과/시간적 근접성이 확인되지 않았음을 명시.
- 미수집·로그 상한·상태 Unknown·장치 0건은 incomplete. 건강점수·고장원인 확정·메인보드/SSD 수리 보증 및 자동복구 금지 유지. 장치 이름/원문 이벤트 내용을 findings로 복제하지 않음.
- tools/diagnose.ps1 JSON analysis 필드와 HTML의 원인 후보/한계 섹션에 연동. HTML 동적 문구는 Esc 인코딩 처리. tests/incident_analysis.tests.ps1 신규: 로그 없음, 41 단독, BugCheck, 저장장치 우선, truncation, 원인 비확정·기기 이름 비노출.
- Windows tests/windows_smoke.ps1 파서·fixture 연결, 내부 시험 ZIP ALLOWLIST와 Python packaging/static 테스트에 필수 파일 추가. 실제 제품 구매/다운로드 페이지, WinRE/수리 변경 없음.
- **실행/검증:** GitHub 9개 소스 대상 교차 구조·BOM·보안·배포 의존성을 검사한 **32/32 정적 조건 충족**. Windows PowerShell 5.1/pwsh 런타임 없음; private GitHub 컨테이너 네트워크 DNS 접근도 불가. Windows 실제 Parser/fixture, Python unittest/ZIP 실제 패키징, WinRE·안전성 QA는 **미실행**. 합격 주장 금지.
- **단계:** P1 원인 후보 규칙 초기 구현, P1 배터리/업데이트·분석 정확도·이력 기능 미완료. P0도 Windows QA 대기로 부분 완료. P2 인쇄/QR 및 Release B 미구현. docs/WINDOWS_TEST_PLAN.md에 P1 실행 수용조건 추가.
- **참고:** Cloudflare Pages main/배포·판매/다운로드 정책 변경 없음. 변경 전 작업 브랜치 HEAD ec065d00f031d3e1689ece951945c2a58d9bda63으로 복구 가능. 다음은 실제 Windows PS5.1 테스트와 회귀 실패 수정, 이후 Windows Update/배터리/인쇄 요약 순서.

## 2026-10-30 KST — P1 배터리·Windows 업데이트 관측값 초기 구현 (최신)

- 기준: FINAL_SPEC_V2.md H05/H06, hibi89/AX_MART feature/pc-care-usb. Production main과 공개 배포는 미변경.
- **추가 기능:** tools/telemetry_analysis.ps1 신규(PowerShell 5.1/UTF-8 BOM, 순수 정규화). 배터리는 Win32_Battery의 조회 결과를 unavailable/not_present/collected로 분리. 현재 충전량(0–100%), 제공되는 설계/완충 용량(mWh)만 숫자로 기록. 값 0·잘못된 수치·미지원은 null. 배터리 건강도·남은 수명 퍼센트 추정 금지. 이름/일련번호/DeviceID 미수집.
- **Windows 업데이트:** System의 Microsoft-Windows-WindowsUpdateClient 이벤트 19/20만 최대 300개 수집. 설치 성공/실패 '기록'으로 표시, 실제 최신 설치·해결 여부 단정 금지. 시간은 이벤트 기록시각. provider/ID whitelist 및 RecordId 중복 처리, 원문 Message/KB 제목 미저장. 접근 실패/no matching/truncated 구분.
- **연동:** tools/diagnose.ps1이 observations.battery/observations.windowsUpdate/collectionStatus와 이슈·HTML 보기에 반영. 장애 규칙 도구 tools/incident_analysis.ps1이 Update 실패 기록을 별도 검토 항목으로 처리하고, BugCheck와 함께 있어도 원인 관계를 확정하지 않음.
- **테스트 코드:** tests/telemetry_analysis.tests.ps1(배터리 없음·거부·잘못된 수치·민감정보 누출, 업데이트 ID/provider/중복/원문 제한); tests/incident_analysis.tests.ps1(업데이트 장애 인과 비확정/조회 잘림) 확장. Windows smoke 구문검사 및 fixture 연결, 내부 시험 ZIP ALLOWLIST/파이썬 패키징 정적 테스트에도 의존성 추가. docs/WINDOWS_TEST_PLAN.md 실행 매트릭스 작성.
- **현재 검증:** GitHub 원격 소스 9개 파일의 BOM·참조·출력 모델·오프라인·시험 ZIP·표현 안전성을 대상으로 한 JS 정적 계약 검사 **39/39 조건 충족**. 실제 PowerShell Parser·fixture 실행, Python unittest·ZIP 빌드/Windows 10·11/USB/WinRE QA **미실행**; 테스트 성공이라고 표기 금지.
- **잔여 P1:** 업데이트/드라이버 오류 범위 확장, 배터리 설계·완충 용량 공급자 호환성 실기기 조사, 실제 사건 간 시각 연결·오탐 QA. P0 Windows/WinRE 안전 게이트와 P2 단일 인쇄 보고서/QR 미완료. 공개 ZIP·결제·강제 복구 없음.
- **기준 커밋:** 시작 SHA 9ca1bca478bed6ffb90ba7c1c67e52ee8cef99e3. 작업 문서 반영 후 feature HEAD를 재확인할 것.

## 2026-10-30 KST — P1 드라이버 구성 관측·기록 시간축 초기 구현 (최신)

- 기준: `FINAL_SPEC_V2.md` H05/ANALYZE. 제품은 AXMART PC CARE, 운영 플랫폼은 AXMART³. 이번 구현은 feature/pc-care-usb만, main/Cloudflare 미변경.
- **드라이버 관측:** `tools/pnp_analysis.ps1` 신규. 읽기 전용 `Get-CimInstance Win32_PnPEntity`에서 비정상 Configuration Manager 코드 및 제한된 PNPClass 범주만 관찰. 드라이버 이름/장치 ID/시리얼 번호 저장 금지. code 22는 의도적 비활성화 가능으로 구분하고 오류 코드만으로 고장/재설치 필요를 단정하지 않음. query 실패/비어 있음/제한 초과를 별도 상태로 기록.
- **시간축:** `tools/recorded_timeline.ps1` 신규. BugCheck 1001, 41/6008, 스토리지 이벤트와 Windows Update 19/20의 기록 시각을 UTC로 정렬. 최신 80개를 15분 윈도우에 묶어 사건 종류/건수만 출력. 기록 시각은 실제 충돌 시각과 다르며 관찰 시점 근접은 원인/영향/동일 사고의 증명이 아님. 실시간 수집이나 네트워크 없음.
- **연동:** `tools/diagnose.ps1`에 read-only PnP CIM 및 timeline 호출을 추가하고 JSON의 observations.driverDevices/recordedTimeline과 HTML의 범주/코드/시간축 테이블로 출력. 사용자 식별 문구는 HTML 인코딩, 자동 드라이버 설치/수리 없음. `tools/incident_analysis.ps1`에 PNP_CONFIG_REVIEW 보수적 후보, code 22 제외, 불완전 수집 caveat 추가.
- **테스트:** `tests/driver_timeline.tests.ps1` 새 합성 fixture(코드 0/10/22/28/이상값, 누출 방지, UTC+09 동치, 15분 그룹, 80건 제한, 인과 부정). `windows_smoke.ps1` 파서·fixture 목록, `tools/release.py` 내부 테스트 ZIP ALLOWLIST, `test_package.py`·`test_release.py` 참조 업데이트. `docs/WINDOWS_TEST_PLAN.md`에 수용 조건 추가.
- **실제 검증 범위:** GitHub의 9개 코드 소스에서 참조·정적 계약 검사를 **37/37 조건 충족**으로 확인. 컨테이너 Python 버전 3.13.5 확인, 그러나 비공개 원본을 직접 클론/실행하지 않았으므로 **Python unittest/Powershell/parser/Windows/실제 ZIP 생성 결과 0회**. Windows 11 x64 실기기·USB/WinRE/VM 실패주입·SmartScreen 검증 전 P0/P1 완료 및 무료 공개/판매 주장 금지.
- **잔여:** Windows 실제 실행 QA 우선. P1의 추가 사건 상관 오탐 검증, P2 수리점 1페이지 인쇄/PDF+개인정보 최소 오프라인 QR, P3 Rescue 독립 안전 검증은 미완료. 시작 feature SHA 46db07771cdb45bbd733ef766919672801c2dc47, 문서 변경 후 HEAD 확인.

## 2026-10-30 KST — P2 상담표 A4 인쇄/PDF UI 초기 구현 (최신)

- **개발 기준:** FINAL_SPEC_V2.md REPORT R01/R02/R03/R05/R07. P1까지의 진단·분석 원본을 보존하고 feature/pc-care-usb만 변경. main/Cloudflare/공개 ZIP·유료 결제 건드리지 않음.
- **신규 도구:** `tools/consultation_report.ps1`가 기존 report 내 보수적 원인·상태 데이터로 개인정보 최소 상담표 모델을 생성. Windows build·검사 기록 시각·검사 판단·저장장치 상태·화이트리스트 이슈 최대 4개·최근 이벤트 기록 최대 4건·추가 확인 질문 3개·조회 한계·백업 권고. 원본 이벤트 Message, 장치/사용자 식별 이름·경로·디스크 시리얼을 새 상담표에 포함하지 않음. 이벤트 1001/41/6008/스토리지/업데이트 19/20의 분류·ID·UTC 기록시각만 담고 고장 발생 시각·원인 확정 금지.
- **인쇄 UI:** `tools/consultation_render.ps1`가 모든 동적 텍스트 HTML 인코딩하여 `#consultation-print` HTML 섹션 생성. `tools/diagnose.ps1` 기존 전체 JSON에 `consultation` 필드 추가, 화면에서 요약표 확인 가능, `@page{size:A4 portrait}` 및 `@media print`로 브라우저 Ctrl+P 시 상담표만 출력하도록 설계. PDF는 브라우저 'PDF로 저장'만 사용, 설치형 PDF 엔진·CDN·서버·원격 전송 없음. 증상 메모는 출력 후 직접 작성, 무단 개인 증상 수집 없음.
- **안전 경계:** CSS 인쇄 1장 실증되지 않았으므로 'A4 한 페이지 검증 완료' 주장 불가. QR 인코더·실제 스캔 미구현. 원본 JSON/전체 HTML을 제3자에게 공유하는 것은 별도 검토 필요.
- **테스트 추가:** `tests/consultation_report.tests.ps1` - 장치명·시리얼·원문 이벤트/이슈 제목 탈락, whitelist 4건 한도, 날짜·빌드 값 필터, UTC 4건 제한, 조회 실패/미지원, renderer의 악성 HTML 문자열 인코딩을 합성 검증하도록 작성. `tests/windows_smoke.ps1` PowerShell parser/fixture 연결, `tools/release.py` 내부 시험 ZIP의 module/fixture 포함, `tests/test_package.py`, `test_release.py` 회귀 검증 경로 추가. `docs/WINDOWS_TEST_PLAN.md` 실제 프린트·PDF·오프라인/한글/USB/한 장 출력 수용조건 기재.
- **수행 검증:** GitHub 파일 8개에 대해 파일·UTF8 BOM·HTML 인코딩/비식별·시간/이슈 상한·@media print·내부 ZIP 연결 **정적 계약 37/37 조건 충족**. Windows 10/11 PowerShell 5.1 parser/fixture 실제 실행, Python unittest, ZIP 생성/검증, Edge/Chrome A4 출력·PDF/콘솔 오류·실기기·WinRE QA는 모두 **미수행**. 정적 통과를 동작 PASS로 간주하지 않는다.
- **제품 상용화:** AXMART³ 프로그램 무료 제공 가정 / 크몽은 소프트웨어 파일 판매가 아니라 유료 결과 해석·상담 서비스 별도 검토. `README.md`의 과거 소프트웨어 5천원 판매 가정 수정. 실제 검증 전 무료/유료 배포·서비스 등록 금지.
- **다음:** Windows PS5.1 파서와 합성 fixture 실제 실행 → 1일 읽기 전용 출력 → Edge/Chrome A4 PDF 검증(한글/긴 텍스트/폰트/무전송) → P2 QR 텍스트 payload 미리보기/명시 선택과 오프라인 생성·스캔 검증 → 전체 Release A QA. 사용자 파일 데이터 복사/WinRE Release B는 독립 안전 게이트 후만.

## 2026-10-30 KST — P2 오프라인 QR용 개인정보 최소 공유 문구·명시 미리보기 (최신)

- **목표/분리:** FINAL_SPEC_V2.md R04-R07의 QR 공유 준비 단계. QR 비트맵 생성기는 **아직 없음**; QR 이미지/실제 스캔 완료 판정 금지. 기존 A4 인쇄와 read-only diagnostics/analysis 기능 보존. AXMART³ 운영 main/Cloudflare·크몽/무료 공개 없음.
- **신규 share payload:** `tools/share_payload.ps1` (PS5.1 UTF8 BOM) pure function `Get-PcCareSharePayload`; 기존 비식별 consultation 모델의 assessment/화이트리스트 신호 두 종류(추가 종류 수 표기)/허용 Event ID에 해당하는 UTC 기록 시각만 사용. 로그 원문, 장치/사용자 ID·이름·경로·키, 자유 입력 문구 복사 금지. '로그 기록 시각'·'원인 미확정'·'백업 후 추가 점검' 명시. 정확한 UTF-8 byteCount 계산, 목표 상한 **250 bytes**, 초과 시 payloadText=null/too_large (무단 절단 없음). 실제 QR 비트맵 없음.
- **신규 opt-in 미리보기:** `tools/share_preview.ps1`는 local `<details><summary>` 클릭으로만 보이도록 공유 문구를 HTML-encode 후 readonly textarea에 삽입. '전체 선택' 버튼 클릭은 텍스트 select만 하고 실제 Ctrl+C/공유는 사용자 판단. 외부 CDN/QR 서비스·자동 clipboard/upload/fetch 없음. 만료/과다 길이 차단 표시. 브라우저 프린트에서는 기존 `#consultation-print` 외 섹션 숨김 유지.
- **진단 연동:** `tools/diagnose.ps1`에 공유 payload·미리보기 모듈을 연결. JSON에는 `sharePreview`의 상태/바이트 수/비트맵 미생성/문자열 미저장 메타만 추가; 실제 문구는 진단 JSON에 넣지 않음. HTML 문서에는 펼치기 전에도 텍스트가 포함될 수 있어 전체 HTML 파일 공유 시 검토 필요(README 경고 추가).
- **테스트 코드:** `tests/share_payload.tests.ps1`에 malicious Message/DeviceID/경로 유출 금지, 허용 신호/ID·UTC 시간, 사용자 입력 배제, UTF-8 250바이트 상한/의도적 실패, HTML escape·클릭 펼치기·QR 미생성 테스트. `tests/windows_smoke.ps1` parser/fixture 및 JSON schema, `tools/release.py` internal-test ZIP ALLOWLIST, `test_release.py`와 `test_package.py` 의존성을 일괄 업데이트. docs/WINDOWS_TEST_PLAN.md에 후속 실제 QR 독립 검증 게이트 작성.
- **검증 구분:** GitHub 소스 8개 파일의 모듈·BOM·whitelist·250바이트 검증·미리보기·출시 차단 의존성 **정적 계약 40/40 조건 충족**. 실제 PowerShell 5.1 parser/fixture, Python unittest/ZIP, Windows Edge/Chrome, 화면, 스마트폰 QR 스캔, WinRE **미실행/미검증**. 40/40은 제품 사용성·동작 테스트 통과가 아님.
- **남은 기능:** 실제 로컬 QR 인코더/오픈소스 라이선스 검토·스캔 검증, P2 홈 UI/인쇄 1장 실증, Windows/USB/권한/파일 저장 QA, Release B WinRE 파일 복사 및 승인형 수리 안전 검증. 베타·판매·다운로드 여전히 차단.
- **코드 기준:** feature/pc-care-usb 작업 시작 HEAD 2684cd3b55f9186921e630fe4a672be4c27ad1e6. 최종 문서 반영 후 HEAD 검증 필요.

## 2026-10-30 KST — P2 오프라인 QR 이미지 명시 생성 및 MIT 내장 (최신)

- **변경 배경:** 이전 P2에서는 250바이트 이하 개인정보 최소 공유 텍스트·클릭 미리보기만 코드 구현되어 QR 비트맵이 없었음. R04-R07의 사용자 선택형 로컬 QR 생성 동작을 코드로 추가하되 실기기 스캔 QA 전에는 완료품으로 표기하지 않음.
- **신규 QR 라이브러리:** `products/pc-care/ui/qrcode.min.js` (davidshimjs/qrcodejs), `ui/QR_CODE_LICENSE.txt` MIT 원문, `ui/qr_ui.js` 자체 오프라인 UI. GitHub 공개 프로젝트의 정식 MIT 라이선스/저작권 고지 보존. QR 로직은 외부 서비스/CDN 네트워크 호출 없이 브라우저 DOM에서 처리. `tools/diagnose.ps1`은 QR 자산을 로컬에서 읽고 전체 MIT 고지를 포함해 생성하는 HTML에 함께 삽입하여 원래 USB가 없어도 HTML만으로 QR 실행 가능하도록 구성. 라이브러리/고지가 없거나 유효성 검사를 통과하지 못하면 기존 로컬 보고서 생성은 계속하고 텍스트-only로 폴백.
- **명시적 생성:** `tools/share_preview.ps1`에 `-QrSupported` 인자와 '오프라인 QR 이미지 만들기(선택)' 버튼, 상태/이미지 컨테이너 추가. 초기 이미지 비어 있음. 사용자가 `<details>`로 공유 문구를 먼저 확인한 후 버튼 클릭 시 `ui/qr_ui.js`가 UTF-8 바이트 수 250 이하·지정 접두부를 재검증하고 `QRCode`를 실행. 별도 QR 자동 복사/파일 업로드/전송 없음. QR 사진 또는 공유 문구를 가진 제3자는 내용을 읽을 수 있음. HTML 동적 데이터는 계속 HTML encode.
- **데이터 상태:** `diagnose.ps1`의 JSON `sharePreview`에 `qrImageSupported` capability와 `qrImageGenerated=false`, `payloadStoredInJson=false`만 저장. QR 생성은 사용자 브라우저에서 나중에 이루어지므로 JSON에 QR 이미지/텍스트가 자동 저장되지는 않음. A4 프린트에는 `#consultation-print` 외 UI가 숨겨져 QR 패널은 제외하도록 CSS 유지.
- **검증/수정:** tests/share_payload.tests.ps1에 QR-enabled/disabled·이미지 생성 전 비어 있음·명시 버튼 fixture 추가. tools/release.py 내부 ZIP ALLOWLIST에 JS 2개 + MIT 라이선스 추가, tests/test_release.py·test_package.py에 의존성·MIT·250바이트/클릭-only·오프라인 보안 정적 검사 확장, tests/windows_smoke.ps1에 JSON capability 검사. GitHub 11개 파일의 cross-file **정적 40/40 조건 충족**; 실제 PS5.1, Windows 브라우저, QR 이미지 생성/한글 디코딩/폰카 스캔·Python unittest·내부 ZIP 실제 빌드·WinRE/QA는 **전부 미실행**.
- **출시 게이트:** QR 코드가 스마트폰으로 정확히 읽히는지, QR quiet zone/에러 정정/UTF-8 한글, USB 분리된 HTML, 긴 데이터/250바이트, Edge/Chrome·iOS/Android 및 PDF 인쇄를 실제 확인하기 전 Release A 통과·QR 완성·무료/크몽 배포 주장 금지. QR 외 P0/P1 및 Release B 실제 Windows 검증도 계속 대기.
- **운영/브랜치:** hibi89/AX_MART `feature/pc-care-usb`만 변경, Cloudflare AXMART³ 운영 main `fbb32362455378b85bcdd0b5037d1f338055fb71` 불변. 이번 QR 기능 추가 전 기능 SHA `c5a2251a5edf33d3a9cab94eae97b2913bbd1803`, 최종 HEAD는 문서 커밋 뒤 확인.


## 2026-10-30 KST — Windows synthetic QA 시도·CI 러너 미배정 및 P2 보고서 탐색 개선 (최신)

- **실제 GitHub Actions CI 구축:** `.github/workflows/pc-care-windows-synthetic.yml` 추가. Windows-latest에서 PowerShell 5.1 `tests/windows_smoke.ps1`(파서+합성 fixture만; `-RunReadOnly` 생략)과 Python `unittest discover`/내부 ZIP 회귀를 실행하도록 구성. GitHub Actions `contents:read`, 12분 타임아웃, 실제 OS 진단·수리·WinRE·외부 업로드 없음.
- **실행 기록:** Run ID **41034866482**, 최초 feature push SHA `5c6c794d0ac59615e28726051d2751e0f065e4c9`. 결과 `completed/failure`, job `windows-powershell-51`에는 `steps=[]`, runner_id=0/runner_name 빈 값, 로그 다운로드는 404 BlobNotFound. 즉 **러너 배정 이전의 CI 인프라 실패**로, 코드의 PowerShell·Python 테스트 성공/실패 원인은 판단 불가. 비용/실패 반복 방지를 위해 workflow 트리거를 **workflow_dispatch 수동 전용**으로 변경, 자동 push 실행 차단.
- **사용성 개선:** `tools/diagnose.ps1`의 기존 로컬 HTML에 키보드 focus 가능한 스킵 링크, ARIA 보고서 내비게이션, 일곱 개 바로가기(수리 상담표/원인 해설/저장장치/업데이트/장치 상태/시간축/검사 한계), 모바일 반응형 CSS 및 section 앵커 ID 추가. 새 코드에서 외부 네트워크 통신/자동 복구 없음. `@media print`은 상담표만 출력하게 그대로 유지.
- **테스트 코드:** `tests/test_package.py`에 정적 내비게이션 앵커·출력 분리·오프라인/키보드 검사 추가. 렌더러의 `#consultation-print` ID가 별도 `consultation_render.ps1`에 위치하므로 두 파일을 함께 검사하도록 수정. 원격 GitHub 소스 **정적 9/9 조건 확인**, Windows 브라우저 실제 작동·출력·QR 스캔 테스트는 아직 0회.
- **게이트:** GitHub CI 미검증, Python unittest/ZIP 실빌드 미실행, Win11·USB·WinRE·안전 복구 QA 미완료. 제품 무료 공개/크몽 서비스 등록/다운로드 활성화 불가. 계정 GitHub Actions 러너/청구/권한 문제는 추가 확인 필요; 실패 원인 확정 불가.

