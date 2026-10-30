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
