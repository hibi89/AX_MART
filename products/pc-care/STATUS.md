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

## 2026-10-30 KST — Windows 실행기 하이재킹 위험 완화·QR Node 실행검증·저장 HTML QA (최신)

- **보안 취약점 수정:** `RUN_HEALTH_CHECK.cmd`, `RUN_SELF_TEST.cmd`, `RUN_SAFE_REPAIR.cmd` 모두 호출 실행 파일 검색을 PATH/`powershell.exe` 이름 호출에 의존하지 않도록 `%SystemRoot%\\System32\\WindowsPowerShell\\v1.0\\powershell.exe` 절대경로와 존재 확인(없으면 exit 2)으로 교체. USB 작업 폴더에 같은 이름의 실행 파일이 놓여도 프로그램이 이를 우연히 실행하는 경로 검색 위험을 줄임. 기존 승인형 복구의 관리자/백업/명시 승인 게이트는 변경하지 않음. 자가 테스트/진단 모두 `DisableDelayedExpansion` 사용; 실제 Windows CMD의 경로·공백·USB 검증은 대기.
- **실행한 JS 검증:** GitHub `ui/qr_ui.js` 소스와 동일함을 FNV32 `3087562328`으로 대조한 로컬 복사본을 Node.js v22.16.0 `vm`+가짜 DOM/QR 생성자로 **6/6 실제 실행 성공**, `node --check` 구문검사 성공. 성공 영역: 초기 자동 생성 금지, 한국어 정상 입력 클릭, 250바이트 초과 차단, 잘못된 접두부 차단, TextEncoder/QR 라이브러리 없음 시 폴백, 생성 실패 시 안전 표시. 이는 실제 QR 비트맵 렌더/브라우저/카메라 스캔 결과가 아님.
- **추가 테스트 코드:** `tests/test_qr_ui.cjs` Node 내장 `node:test`의 10개 QR UI 모의 시나리오, GitHub workflow 수동 단계에 `node --test tests/test_qr_ui.cjs` 연결(새 파일의 GitHub runner 실제 실행 대기). `tests/test_package.py`에 CMD 절대경로/실패 시 fail-closed/안전 명령·Node 테스트 파일 검증. `tests/windows_smoke.ps1 -RunReadOnly`에는 생성된 JSON/HTML 내용에 대하여 A4 #consultation-print/QR 자산 라이선스/QR 지원 여부/QR 페이로드 미저장/외부 <script src>/<link href> 부재 검사를 추가.
- **GitHub 정적 검사:** 변경된 세 CMD, JS fixture, workflow, PS smoke, Python 테스트 및 문서 소스 8종의 **교차 조건 21/21 충족**. 실제 Windows PowerShell 5.1 fixture/자가 검사, Python unittest/ZIP 빌드, Chrome/Edge QR 렌더·PDF 1페이지, 스마트폰 QR 스캔, WinRE 테스트 **미실행**. GitHub Windows Actions 최초 run 41034866482는 runner_id=0/steps=[] 인프라 실패였으며 자동 트리거를 수동 전용으로 유지. 해당 러너 테스트를 PASS로 간주하면 안 됨.
- **제품/출시:** AXMART³ main/Cloudflare 미변경. 무료 공개/크몽 유료 서비스/사용자 다운로드 미실시. 전체 최종 설계 진척률 기존 약 30% 수준 추정(실제 장치·복구 QA 비중 큼); 테스트 산출물을 중복으로 완성률에 과도하게 더하지 않음.
- **향후:** Windows 11 x64 PS5.1 실기기에서 CMD 실행기/USB 경로 스푸핑/표준 사용자 권한/저장된 JSON+HTML/한글 A4 및 QR 스캔 확인. 운영 환경에서 테스트/드라이버 설치/복구를 자동으로 시작하지 않음. WinRE 백업/안전 복구는 별도 VM + 승인 게이트 뒤 진행. `docs/WINDOWS_TEST_PLAN.md` 최신 수용조건 참조.

## 2026-10-30 KST — P2 QR 공유 무효화·엄격한 증거 형식·Chromium 13조건 실측 (최신)

- **결함 발견·해결:** 기존 QR UI에서 잘못된 재생성 입력(250바이트 초과 등)이 들어오면 QR 생성은 거부해도 이전 QR 이미지가 남아 실제 공유 문구와 QR 내용이 달라질 위험이 있었음. `ui/qr_ui.js`에 기존 이미지 clear 함수, input 수정 시 이미지 무효화 및 상태 안내, 모든 생성 시도 전 초기화 추가. 사용자 변경 뒤 오래된 QR 오인 공유 방지.
- **개인정보·증거 무결성 강화:** QR 버튼 클릭 시 원래 250 UTF8 bytes+접두어만 검사하던 것을 고정된 **7줄** 공유 양식, 허용 평가 4종, 허용 위험 범주 6종(최대 2개+생략 개수), 검증된 기록 UTC 형식, '사고시간 아님', '원인 미확정', '백업후추가점검'으로 제한. 임의 추가 문장·장치명·원인 확정 문구를 QR 코드로 처리하지 않음. PowerShell 원본 비식별 모델과 같은 범주 유지.
- **테스트 코드:** `tests/test_qr_ui.cjs` Node synthetic fixture를 **17개**로 늘려 이전 QR 클리어, 사용자 입력 변형, 부정확한 인과 메시지, unknown issue, 추가 문장, 허용 생략 문구 검증. `tests/test_package.py`에 데이터 필드 구조·클리어·오프라인 브라우저 test fixture 정적 의존성 추가.
- **브라우저 실제 실행:** GitHub `ui/qr_ui.js`와 로컬 Chromium 테스트 입력 소스 Git blob **b0b06f527bed53f147e05e6512ee289608048de1** 일치 확인. Linux headless Chromium(Playwright)에서 **가짜 QR 생성자**를 사용해 클릭 전 미생성, 한국어 문구, UI 상태, 250 바이트 차단, 과거 이미지 클리어, 수정 시 안내, 변조 문구 차단, 허용 신호 생략, 외부 HTTP 요청 없음 등 **13/13 조건 실제 통과**. 이 테스트는 JS 버튼/상태/검증 로직 실측이며 MIT QR 라이브러리의 실제 심볼 렌더·실제 핸드폰/QR 디코더 스캔을 검증한 것이 아님.
- **QR 실제 픽셀 검증 도구 추가:** `tests/qr_browser_smoke.py` (개발자 선택 실행, 사용자 ZIP 제외): 실제 `ui/qrcode.min.js`와 `qr_ui.js`를 로컬 Chromium에 로드해 QR bitmap 스크린샷→OpenCV QRCodeDetector로 디코딩→한글 UTF-8 원문 SHA256 정확 일치, 무네트워크, 수정 후 QR 제거·변조 차단 검증하도록 작성. `playwright`, `opencv-python`, Chromium 필요. 해당 스크립트는 **아직 미실행**; 스캐너 결과를 성공으로 표기 금지.
- **검증 상태:** GitHub 관련 7파일 소스 cross-contract **21/21 정적 조건 충족**. 실제 Windows 11/PowerShell5.1/USB/WinRE·Edge/Chrome 실제 제품 HTML·QR 실픽셀/스마트폰 스캔·Python unittest·ZIP 빌드·A4 PDF 출력 **미검증**. GitHub Actions runner 미배정 문제는 그대로, 자동 재시도 금지/수동 workflow 유지.
- **브랜치·배포:** hibi89/AX_MART feature/pc-care-usb만 변경. AXMART³ 무료판 출시/크몽 판매·Cloudflare main 배포 없음. 전체 예상 완성률 기존 약 30% 유지(테스트·Windows QA 큰 비중).

## 2026-10-30 KST — QR 실제 날짜 검증 및 BOM 스캐너 규칙 보강 (최신)

- **재발 방지:** `ui/qr_ui.js`의 QR UTC 기록 시각 검증을 문자열 모양만 검사하던 방식에서 실달력 검증(`Date.UTC` + UTC 연월일 역대조)으로 보강. 평년 2/29, 2/30, 잘못된 월/시간은 QR 생성 차단, 윤년 정상 날짜·`미확인` 허용. 이전 QR 초기화 및 7줄 화이트리스트/250 UTF-8 byte 제한/오프라인 보존.
- **실제 수행 증거:** GitHub 해당 JS Git blob `13faebe44753b73f2a1cf9c99308aab220745276`과 로컬 소스 Git blob SHA-1 일치 검증, Linux headless Chromium Playwright 가짜 QR 생성자 기존 13개 조건 + 날짜 7개 조건 **20/20 실제 실행 통과**; Node `--check` 성공. 이들은 QR 버튼/데이터 보호 UI 검증이지 벤더 라이브러리 실제 QR bitmap/scanner 검증이 아님.
- **테스트 추가:** `tests/test_qr_ui.cjs` 합성 Node fixture 17→21개, 날짜/윤년/시간 미확인 경계 추가. `tests/qr_browser_smoke.py` 실제 QR+OpenCV 스캐너 대기 코드에 5개 날짜 사례 추가, UTF-8 BOM 감지 및 명시적 정규화/원문 SHA 비교 추가. `tests/test_package.py` QR 달력+스캐너 BOM 테스트 연결 회귀 조건 추가.
- **발견한 QR 벤더 특성:** qrcodejs 최소화 JS에서 비ASCII 데이터에 BOM(EF BB BF)을 선행하는 코드 확인. 독립 Python `qrcode`+OpenCV QR 해독(실제 벤더와 별개)을 실행해 BOM 포함 QR은 선행 U+FEFF가 문자열에 나타나 원문과 직접 비교 시 다르다는 것을 확인. 이는 벤더 라이브러리 실제 동작 성공 증거가 아님. QR 스캐너 시험에서는 0개 또는 정확히 선행 BOM 한 개만 명시적으로 허용/보고, 임의 문자 차이는 실패 처리.
- **지속 차단:** 실제 `qrcode.min.js` QR 이미지 생성·OpenCV 디코딩, Android/iOS 스캔, Windows 11/PowerShell 5.1, 내부 ZIP/테스트, A4 PDF 한 페이지, WinRE/USB 검증은 미수행. GitHub Actions runner 미배정으로 수동 workflow만. 무료 배포/크몽 제품 판매/운영 main 변경 없음. 전체 완성률 약 30% 보수적 유지.

## 2026-10-30 KST — P2 동봉 QR 인코더 실제 실패 재현·5바이트 수정·OpenCV 디코딩 성공 (최신)

- **시작 상태:** 브랜치 `feature/pc-care-usb`, 기능 작업 전 HEAD `f775961a0e8a6bb840fa9af1be8c472c8be3b48d`. 운영 main `fbb32362455378b85bcdd0b5037d1f338055fb71` 변경 금지. 기존 Chromium 20/20은 QR 생성자 mock으로 실제 인코더 오류를 놓치고 있었음.
- **실제로 재현한 버그:** GitHub의 *원본 동봉 MIT qrcodejs* `ui/qrcode.min.js` blob `993e88f396640f881b69f98db7a4d17401ef83ca`를 V8 모의 DOM에서 실행. **195 UTF-8 바이트의 정상 한글 7줄 상담 공유 문구**에서 `Error: code length overflow. (2180>1728)` 재현. 원인은 qrcodejs UTF-8 변환 중 문자별 byte 배열 재사용으로, 한글(3bytes) 뒤 ASCII(1byte)에서 뒤쪽 byte들이 남아 payload를 과대 계측하던 원본 라이브러리 버그.
- **최소 수정:** `ui/qrcode.min.js` 한 곳에 `b=[];` 5문자를 추가해 각 코드 유닛 처리 전 버퍼를 초기화. 원본 외부 SDK의 최소 패치만 적용, MIT 원문 `ui/QR_CODE_LICENSE.txt` 보존, 오프라인/명시 QR 생성/개인정보 최소화 흐름 유지, main/Cloudflare/사용자 리포트 수정 없음.
- **실행 검증:** 수정된 *실제 qrcodejs 인코딩 로직*을 제한된 V8 DOM에서 실행, 정상 한글 상담 195 bytes와 `한A`, `한A1한B`, `테스트2026-10-30`, `AXMART 제품 v1`, 영문 ASCII-only **6/6 UTF-8 바이트 일치**(한글 있는 경우 BOM EF BB BF 3 bytes 별도 계산). 상담 QR 행렬 **57×57** 모듈 생성, 7×7 finder patterns **3/3** 정상. 실제 vendor가 생성한 모듈 행렬을 Python OpenCV `QRCodeDetector`에서 **검출·디코딩 성공**, 디코딩 값 `U+FEFF + 원래 7줄 한글 문구`, 단일 선행 BOM을 명시적으로 제거한 뒤 내용 정확 일치. 이는 *QR 인코딩/해독 알고리즘 검증*이지 Chromium의 벤더 캔버스 렌더·스마트폰 카메라/Windows 실기기 검증은 아님.
- **회귀:** `tests/test_qr_vendor.cjs` 실제 벤더 JS 6개 Node built-in regression 작성, `.github/workflows/pc-care-windows-synthetic.yml` 수동 테스트에 `node --test tests/test_qr_ui.cjs tests/test_qr_vendor.cjs` 연결. `tests/test_package.py`에서 벤더 5문자 패치/라이선스/테스트 참조 고정. 실제 GitHub Actions 작업은 러너 미배정으로 수행하지 못함; 수동 workflow 유지.
- **미검증/출시 차단:** Windows11 PowerShell5.1, 일반 Windows/Edge·Chrome 저장 HTML의 캔버스 실제 이미지, QR 휴대전화 한글 스캔·BOM UX, USB·저장/프린터/A4 PDF 1장, WinRE/BitLocker 안전성, Python 전체 unittest/ZIP 빌드 **미검증**. Release A/B 공개/크몽 등록 금지. 제품 진척률은 종합 설계 기준 보수적으로 **약 30%** 수준 유지(Windows/WinRE 검증 비중 큼).
- **다음:** Node vendor+UI 테스트 실행 증거 → `tests/qr_browser_smoke.py` 실제 Chromium/QR decoder → Windows 실기기 `RUN_SELF_TEST.cmd`와 저장 HTML/JSON/A4 QR 스캔 → 안전 테스트/승인 기반 Release B. QA가 준비되지 않은 상태에서 운영 사이트 연결·유료 출시 금지.


## 2026-10-30 KST — P2 실제 QR 인코더 252건 조합 검증·로컬 파일 브라우저 QA 보강 (최신)

- **대상:** hibi89/AX_MART `feature/pc-care-usb`. 이전 기능 SHA `f4e494dc716000c1ad0b845342cacf3e6e50183b`. main/Cloudflare/WinRE/고객 원본 변경 없음.
- **실행 성과:** 동봉 QR 인코더 `ui/qrcode.min.js` 수정본(소스 blob `f7e18fb3c1be406dca4a1aef5269cddf5d13c561`) 자체를 V8에서 실행해 유효한 상담 QR 문구 **252건/252건**에서 정확한 UTF-8 데이터 크기(+선행 BOM 3bytes), QR 인코딩과 모듈 생성 정상 확인. 사용 상태 4 × 신호 유형(1~2) 21 × 생략형 3. 본문 최대 228 UTF-8 bytes, QR 모듈 53~61칸. 새 스모크 실행을 통해 한글 버퍼 오류 재발 부재 확인.
- **GitHub 회귀 구현:** `tests/test_qr_vendor.cjs`에 252 조합을 반복 확인하는 실제 라이브러리 Node test 추가(기존 6개 case→7개 테스트 블록, 마지막 블록 252회). QR 엔진의 5자 버그 패치 유지. 실제 GitHub Actions에서 새 Node 테스트 실행은 러너 미배정으로 대기. 테스트 소스 추가만으로 Node suite PASS 단정 금지.
- **브라우저 QA 강화:** `tests/qr_browser_smoke.py`가 오프라인 한글 파일명 HTML을 실제 `file://`로 열고, HTTP(S) 외부 요청을 명시적 차단, 전 세션 요청/JS 예외 확인, OpenCV QR 디코딩·한글/BOM 비교·날짜 변조·이전 QR 소거를 검사하도록 수정. 기능 자체는 사용자 ZIP 제외한 개발자 검증 도구이며 실행 환경에서 실제 Chromium vendor 렌더 테스트는 **미수행**.
- **현실적인 차단:** 공개 상류 라이브러리의 로컬 컨테이너 다운로드가 접근 제한으로 실패했으며, GitHub 연결 소스를 로컬 Chromium 실행 환경에 안전하게 동일 파일로 가져오는 경로를 확보하지 못함. 동일 방식 반복 대신 Windows 또는 코드 체크아웃 가능한 개발자 환경에서 `python tests/qr_browser_smoke.py --chromium <경로>`를 실행해야 함. CI Actions 41034866482는 runner 배정 이전 실패. Windows PowerShell5.1, 실제 Edge/Chrome 제품 HTML/QR 스캔, Android/iOS, ZIP·A4 PDF·USB/WinRE 안전 검증 미완료.
- **정적 연결 검증:** GitHub 6개 관련 파일 cross-check **17/17 조건 충족**. V8 252/252은 실행된 인코더 결과이며, 브라우저 조건 17/17은 정적 계약 검사일 뿐 별개. 제품 출시/무료 다운로드/크몽 판매·운영 main 변경 금지. 최종 설계 포함 완성률 **약 31% 추정**, 실기기 검증 우선.
- **다음:** 별도 리포트 파일/USB/한글 경로에서 실제 Windows smoke → Edge·Chrome 로컬 QR 이미지/PDF 인쇄 → 스마트폰 카메라 확인 → Release B 승인형 백업 및 WinRE 안전성. 반복 구현 대신 장치 QA와 진단 UX 검증 확보.


## 2026-10-30 KST (PC CARE 메뉴 구현, 실기기 미검증)
- 새 `START_PC_CARE.cmd` 비관리자 오프라인 시작 메뉴: 1 읽기 전용 진단, 2 자가검사, 3 보고서 위치/보안, 4 복구 안전 안내, 0 종료. 수리 실행기/승격/WinRE 호출 없음.
- 내부 시험 ZIP 허용목록 및 정적 회귀 검사에 신규 파일 포함. 기존 진단·수리/QR·Production main 소스 미변경.
- GitHub 소스 정적 검증만 진행; **Windows CMD/PowerShell 실제 실행, Python 전체 suite, ZIP 생성, Cloudflare 배포 미실행**. 무료 베타/크몽 판매/다운로드 차단 유지.
- 복구 기준: 기능 변경 전 `92294f15486e63d08c4b707024c0409779e1ba92`. 다음은 Windows 11 표준 사용자에서 메뉴 1/2/0 및 특수문자 USB 경로 검증, 이후 실제 QR 및 한 페이지 PDF 검사.

## 2026-10-30 KST — P0 원자적 신규 파일 생성·타 실행 결과 보존
- `tools/report_io.ps1`: FileMode.CreateNew 전용쓰기/덮어쓰기 거부형 File.Move, 실행별 .partial 소유권 기반 정리. 다른 실행이 만든 부분 파일/기존 HTML·JSON 무단 변경 방어.
- `tests/report_io.tests.ps1`: stale partial 및 한쪽 최종 HTML 존재 시 바이트 보존 fixture 추가; `tests/test_package.py` 교차 정적 가드 갱신.
- Windows 11/PowerShell 5.1 실제 fixture 실행, 동시 실행/전원 강제 중단 실험, 전체 Python suite, USB 경로·QR·PDF·WinRE **미검증**. 실제 런타임 성공 주장 불가.
- 복구 기준 이전 feature HEAD `9087a3bc3b72c14e3b8730d6f4709b9dbdc50056`. main 및 Cloudflare 다운로드/판매 변경 없음.

## 2026-10-30 KST — P0 단일 실행 보고서 receipt 경합 제거
- 기존 `tests/windows_smoke.ps1`가 REPORTS/문서 폴더의 '가장 최신 JSON'을 선정하던 방식은 동시 진단이 발생할 때 타 실행의 보고서를 검증할 수 있었다.
- `tools/diagnose.ps1`에 `-PassThru` (이번 실행 저장 경로만 출력), `-NoOpenReport` (자가검사에서 브라우저 자동 실행 억제) 옵션을 추가, 일반 Windows 실행기는 변경 없음.
- Windows 스모크는 receipt 정확히 1개, 절대경로·동일 부모·동일 파일 기본명·허용 보고서 폴더·실제 2개 파일 존재를 검사. 타 실행 결과 탐색 제거. `tests/test_package.py` 정적 회귀 추가.
- 확인 범위: GitHub 소스 정적 대조. PowerShell 5.1 실제 실행·USB/한글 경로·동시 실행·HTML/PDF/QR 동작은 **미검증**. GitHub main/Cloudflare/수리 파일 미변경. 복구기준 커밋 `3da0c5bb236064328e1c506143a48ce9f20dadea`.

## 2026-10-30 KST — 자가검사 receipt 블록 구문 복구
- 이전 2c83634 커밋의 windows_smoke.ps1에 중복된 JSON 검사와 잘린 정규식 문장이 발견되어 정상 실행을 방해할 위험이 있었다. 해당 블록을 단일 유효 구조로 교체, [.]json filename 매칭 및 경로/파일 검증 보강, 정적 테스트 동기화.
- 실제 Windows PowerShell 5.1 실행·VM/USB/WinRE/QR/A4 검증 여전히 대기. 2c83634 이전 소스 기준 복구 가능. 운영 main/Cloudflare 미변경.

## 2026-10-30 KST — P0 이벤트 공급자 오탐/스키마
- 이전 source 부분 문자열 매칭은 FakeBugCheck/InventoryStore 같은 유사 공급자를 Windows 오류 근거로 잘못 분류할 위험. BugCheck/Kernel-Power/EventLog/저장장치 이벤트에 앵커된 공급자 화이트리스트 적용.
- JSON root schemaVersion=1, Windows smoke 스키마 검사, 부정 fixture 5종·Python 정적 가드 추가. 기존 수리·USB·QR·HTML/보고서 필드는 보존.
- 저장 전 Git Blob Base64 생성/바이트 재조회 확인. 실제 Windows PowerShell5.1/지원 장치 OEM 공급자 범위·전체 unittest/USB/QR/A4/WinRE는 미검증. 정식 배포/크몽 판매 차단.
- 이전 정상 SHA e39f345a88d8f03d3cfb1432ca7cee0e2b9b9dc3. 운영 main/Cloudflare 미변경.

## 2026-10-30 KST — H08 수동 반복 검사 비교
- 동일 PC의 과거/현재 읽기 전용 JSON 두 개를 수동 선택하고 신규·미관찰 경고/디스크 여유/조건부 이벤트 수/저장장치 경고 합계를 브라우저 오프라인에서 비교. 자동 업로드·파일 탐색·삭제 없음.
- 메뉴 5번, ui/history_compare.html/js, JS 합성 16/16 통과, Node 테스트 9개 작성, 내부 ZIP/수동 CI·문서 연결. 실제 Node 실행/Windows Edge file:// /USB/QR/PDF/WinRE **미검증**.
- H08 자동 저장/보존기간/삭제 UI 미구현. 무료/판매 배포 차단, 운영 main 불변. 변경 전 SHA 789a831f0e21f52071f642effafee94ca0a89141.

## 2026-10-30 KST — H08 실제 Node 실행·파일선택 경합 보강
- GitHub 원본 JS `65bfb8995676babaf36fa4c3f62dbfec18094805` 및 Node 회귀 fixture `831f738b9029556d21a4a01bbda2dab5c61819d4`를 SHA 검증해 Linux Node 22에서 **9/9 PASS** 실행.
- 비교 중 파일 선택 변경시 이전 결과·오류가 뒤늦게 덮어쓰는 문제 예방: `ui/history_compare.js` selectionRevision 가드. 가상 DOM Node fixture 5개 추가, 수정된 JS 정확한 Blob SHA `bd793bb5cf1dabbbb82ba4210faade3b7f22994a`, 테스트 Blob `93679760ea7e090bb33af0e07846e9040d7c3605`. 통합 **14/14 PASS**.
- Chromium 144의 file:// 및 127.0.0.1 로컬 테스트 URL 모두 관리자 정책 `ERR_BLOCKED_BY_ADMINISTRATOR`에 차단: 브라우저 정상/장애 판정 불가, 추가 우회 시도 금지. Windows PS5.1, Edge/Chrome/USB 실제 기능·QR/A4/WinRE **미검증**.
- 수동 CI workflow에 5개 UI 회귀 추가; runner 미배정으로 workflow dispatch는 하지 않음. 운영 main/Cloudflare 변경 없음, 출시 차단 유지. QA 시작 HEAD 518413d3def107633b1215eeddf5f30be067e4e8.

## 2026-10-30 KST — H08 불완전한 관측값 오판 방지 (18/18 Node PASS)
- `ui/history_compare.js`: JSON `issues` 누락 시 신규/미관찰 경고를 '없음'이 아닌 '비교 불가'로 표시. `physicalDisks` 조회 실패·빈 결과·미확인 상태·장치 수 변화는 0→0 경고라고 표기하지 않고 비교 불가 처리. 알려진 장치 수/수집상태가 일치할 때도 같은 물리 디스크라는 보장은 하지 않음.
- Node 합성 회귀 기존 14개 + 보강 4개 = **18/18 PASS**, fail 0. 실제 로컬 Node v22.16.0 실행 및 Git blob SHA 교차검증. 테스트 파일 `test_history_compare.cjs`·`test_history_dom.cjs`, 정적 계약 `test_package.py` 갱신. 증빙 `tests/evidence/history_fail_closed_qa_20261030.json`.
- 기준 브랜치 SHA `712db3ab8d70dda8f3ad61604668747d816dcb98`. Windows11 PowerShell5.1/USB, Edge 실제 `file://`/QR/A4/WinRE/전체 Python·ZIP **미검증**. 기존 main/Cloudflare·수리·사용자 보고서 불변, 무료·유료 공개 차단 유지.

## 2026-10-30 22:27 KST — H08 날짜·시간대 결정적 파싱 / 상태값 유출 방어
- 브라우저별 비표준 `Date.parse('yyyy-MM-dd HH:mm:ss +09:00')` 관대한 파싱을 제거하고, Windows PowerShell 5.1의 현재 JSON 형식 `yyyy-MM-dd HH:mm:ss zzz`을 캘린더 실제 날짜/윤년/시간/UTC 오프셋 검증 후 UTC ms로 변환하도록 수정. 다른 표기·불가능한 날짜·잘못된 시차는 fail-closed.
- `assessment`에 예상 외 문자열이 포함되면 내용을 화면에 그대로 반영하지 않고 `확인 불가`로 표시. 기존 비교/선택 경합/개인정보 보호 동작 유지.
- 실제 로컬 Node v22.16.0 `node --check` PASS; `node --test tests/test_history_compare.cjs tests/test_history_dom.cjs` **22 PASS/0 FAIL**. GitHub blob SHA `c57d4fd2`(JS), `5c533efe`(unit) 및 DOM `958b5a68`이 로컬 테스트 복제본과 일치. 증빙 `tests/evidence/history_date_offset_qa_20261030.json`.
- Windows 11 PowerShell5.1 실제 JSON·Edge/Chrome `file://`·USB·QR/A4 PDF·WinRE·전체 Python/ZIP 실검증 **대기**. 운영 main, 수리 코드 및 고객 실제 보고서 미변경. 이전 feature HEAD `4af8e8b0ffaccf78fb5d90898d19017d8b8c9dc7`. 무료 공개/유료 판매 불가 유지.
