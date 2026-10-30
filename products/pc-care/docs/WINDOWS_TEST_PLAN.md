# Windows 실기기 / WinRE 검증 계획 (2026-10-30, 미실행)

**이 문서는 검증 절차이지 테스트 성공 증거가 아니다.** GitHub 브랜치 작업만으로 Windows 테스트 완료 처리 금지.

## 선택안 비교
- A (채택): Windows 10/11 읽기 전용 진단 + 독립 승인형 DISM/SFC + Microsoft 공식 WinRE에서 수동 인벤토리. 코드·라이선스·장애 범위가 작고, 물리 장애에서는 쓰기 작업 차단.
- B (보류): 자체 부팅 ISO/WinPE와 원클릭 복구. 운영체제 이미지 배포 권리·다양한 저장장치 드라이버·BitLocker·데이터 손실 검증 부담 큼. 출시 전 구현 불가.

## 테스트 환경
1. Windows 11 최신 지원 빌드 VM 스냅샷 및 실제 PC 1대, Windows 10 22H2 격리 VM(지원 종료 사실과 별개로 호환성 검증). PowerShell 5.1 기본, 관리자/표준 사용자 계정 각각.
2. USB FAT32/NTFS, 정상 쓰기/쓰기 금지, 드라이브 문자 변경, 보고서 저장 권한 거부 → Documents 폴백.
3. 일반 계정에서 `powershell.exe -NoProfile -File .\tests\windows_smoke.ps1`로 두 ps1 문법 확인. 출력과 종료 코드를 기록한다.
4. 중요 자료 백업 후 `powershell.exe -NoProfile -File .\tests\windows_smoke.ps1 -RunReadOnly` 실행. 새 HTML/JSON 둘 다 있는지, JSON이 파싱되는지, eventCollection이 unavailable인 경우 HTML에서 0건 대신 확인 불가인지 확인.
5. 재실행 3회: 보고서 충돌/누락 없음, 누적 개인정보/외부 통신 없음, 일반 사용자와 관리자 차이 명시. 시스템 이벤트 없는 VM, 저장소 API 미지원, 접근 거부 각각의 실패 표시 점검.
6. MS 공식 복구 매체로 테스트용 VM의 WinRE 명령 프롬프트에 진입해 `recovery\WINRE_READ_ONLY.cmd` 수동 실행. OS 드라이브 식별, 잠긴 BitLocker, 쓰기 불가능 USB, 존재하지 않는 Windows 볼륨 점검. 키 입력·볼륨 해제 기능 수행 금지.
7. **승인형 수리는 백업·VM 스냅샷 복구가 확인된 전용 시험 VM에서만** 수행. `BACKUP`/ `REPAIR` 외 입력은 취소, 관리자 미승인/디스크 건강 Unknown/Warning/조회 실패는 차단, 정상 Healthy 조건에서만 별도 승인 후 DISM/SFC 종료 코드와 로그 검증.
8. 이벤트 41 단독은 BSOD가 아님, 1001 + BugCheck 공급자일 때만 BSOD, 1,500건 절단은 수집분으로 표시되는지 수동/합성 로그로 대조.

## 합격 증거
- OS 버전, PowerShell 버전, 기기/VM(개인정보 제외), 명령, 시작/종료 코드, 예상/실제 결과, 화면 캡처(민감정보 제거), 실패 복구 방법을 테스트별로 기록한다.
- 하드웨어 고장·BitLocker 잠김·불명확한 증상에서 자동 수리 및 위험 변경이 실행되지 않아야 한다.
- GitHub SHA/릴리스 ZIP SHA256, SmartScreen/코드 서명 확인, 백업/복구 시나리오 통과 후에만 무료 공개 여부 판단.
- 현재 결과: **Windows/WinRE/실제 복구 미검증**. Linux 정적 검사와 코드 리뷰는 합격 증거로 대체 불가.

## P0 추가 검증 매트릭스 — 2026-10-30 (미실행)

**첫 실행(Windows 11 x64, 표준 사용자):** 제품 폴더를 로컬 또는 USB에 정상 압축 해제한 뒤 PowerShell 5.1에서 'RUN_SELF_TEST.cmd' 실행. 해당 런처는 PowerShell 파서, synthetic fixture, 1일간의 읽기 전용 진단만 수행. 절대 RUN_SAFE_REPAIR.cmd를 실행하지 말 것. 검사 결과는 REPORTS 또는 Documents/AXMART-PC-CARE-Reports에 저장.

| 경로 | 테스트 방법 | 기대 판정 | 실제 |
|---|---|---|---|
| Parse/BOM | RUN_SELF_TEST.cmd -> Parser.ParseFile | diagnose, repair, event_analysis, synthetic tests 문법 오류 0 | 미실행 |
| 사건 분류 | synthetic fixture 자동 실행 | 1001 잘못된 공급자 제외, 원문 미저장, 41/6008 중복 가능 그룹만 | 미실행 |
| 시간대·기록 지연 | UTC synthetic fixture | 같은 순간 다른 시간대를 동일 UTC로 정규화, 1001 시각은 recorded time | 미실행 |
| 이벤트 조회 결과 | synthetic fixture | empty / access denied / collected / truncated 구분 | 미실행 |
| 이벤트 상한 | synthetic fixture 5건 + max=3 | 반환 3건, truncated | 미실행 |
| 일반 계정 | 기본 읽기 전용 1일 진단 | OS/권한 state, 볼륨/장치/Defender collectionStatus, JSON/HTML 쌍 | 미실행 |
| 이벤트 조회 실패 | 테스트 VM에서 의도적 권한 거부 재현 | unavailable, '0건 정상' 주장 없음 | 미실행 |
| 이벤트 미발견 | 테스트 VM의 로그 없음 | no matching events (접근 거부와 구별) | 미실행 |
| 장치 API 미지원 | StorageReliabilityCounter 미지원 VM | reliabilityStatus unavailable/empty, Wear/온도 모르는 값으로 취급 | 미실행 |
| 잘못된 용량 | synthetic/mock VM에서 Size/FreeSpace null/비정상 | 비정상 볼륨 제외, limitation 명시 | 미실행 |
| USB REPORTS 쓰기 거부 | 테스트 전용 USB 또는 VM에서 경로 권한 제한 | Documents 대체 경로에 JSON/HTML 모두 생성 | 미실행 |
| 양쪽 저장 불가 | VM에서 USB·Documents 쓰기 거부 | 파일 저장 실패, 성공 안내 없음, 시스템 변경 없음 | 미실행 |
| 반복/고유성 | 읽기 전용 실행 3회 | 고유 이름/JSON-HTML 쌍 일치, 이전 보고서 보존 | 미실행 |

주의: 접근 거부·Read-only·로그 임의 삭제와 같은 고위험 실패 재현은 **테스트 전용 VM/USB에만** 적용한다. 평소 쓰는 PC의 시스템 로그·권한·디스크 구성을 수정해서 시험하지 않는다.

**기록 항목:** Windows 빌드/PowerShell 버전, 표준·관리자 여부, 비식별 환경, 명령, 종료 코드, 결과 JSON의 collectionStatus/eventCollection, HTML-JSON 파일 쌍 존재 여부, 실패 원인. 개인 이름/경로/실디스크 일련번호/BitLocker 키/원문 이벤트는 커밋 금지.

**출시 판정:** 위 표는 실행 전 계획이며 합격 결과가 아니다. GitHub 내 소스 검토와 CI 상태는 Windows 실측·WinRE/BitLocker·위험 수리 VM 게이트를 대신할 수 없다.

## 2026-10-30 P0 report persistence fixture (not yet run)

- The Windows smoke suite now includes a synthetic report persistence fixture.
- It uses an isolated temporary directory and has four cases: successful JSON/HTML pair, existing-name collision preservation, fallback from an unusable first destination, and explicit failure when all destinations are unusable.
- The fixture is read/write within only its own temporary directory; it does not run system repair or modify real diagnostic reports.
- Actual Windows PowerShell 5.1 execution, error codes, and output evidence remain unverified.

## P1 initial incident interpretation acceptance cases (2026-10-30, not executed)

The standalone incident_analysis.tests.ps1 fixture is invoked by tests/windows_smoke.ps1 after syntax checks. It makes no operating-system changes.

- Empty/unavailable System log and no physical disk data: incomplete evidence, not a normal health assessment.
- Event 41 alone: possible unexpected shutdown signal, not confirmed BugCheck.
- Valid BugCheck event without storage warning: review needed, but the root cause is not confirmed.
- Storage Warning alongside BugCheck and a truncated event window: storage-first backup guidance, incomplete evidence, no causal or chronological claim.
- Unknown storage health: remains incomplete even when no matching events were observed.
- Data minimization: no model or raw source messages copied into the generated incident findings.

Windows 11 x64 / PowerShell 5.1 parser and fixture execution must pass before considering these checks verified. This does not replace WinRE/repair safety validation.

## 2026-10-30 P1 battery / Windows Update acceptance matrix (not executed)

Scope: Win32_Battery CIM observation and only the Microsoft-Windows-WindowsUpdateClient System event log with IDs 19 (installation success) and 20 (installation failure). Neither proves hardware health or a crash cause. Based on Microsoft Win32_Battery and Windows Update event documentation.

| Scenario | Expected | Evidence |
|---|---|---|
| Desktop with no Win32_Battery instances | battery.status=not_present, batteryCount=0, not an error | Pending Windows 11 |
| CIM access denied or unsupported | battery.status=unavailable, count null; not mistaken for no battery | Pending isolated VM |
| Portable device with supported charge data | chargeRemainingPercent 0-100; explicitly current charge, not battery life | Pending Windows laptop |
| Null, zero, invalid design/full capacity | capacities null, no health percentage fabricated | Synthetic fixture written; runtime pending |
| Battery serial/device identity from CIM | no DeviceID, Name, serial or raw device output in JSON | Synthetic fixture written; runtime pending |
| System WindowsUpdateClient ID 19 or 20 | whitelist provider and ID; recorded timestamp, no raw event Message | Synthetic fixture written; runtime pending |
| WindowsUpdateClient log empty vs denied | status 'no matching events' vs 'unavailable'; never claim an installed update succeeded | Pending Windows VM |
| 300-record event limit | status 'truncated'; bounded output; incomplete evidence | Pending Windows VM |
| Update failure alongside BugCheck | independent review finding; chronological/cause relation NOT proven | Synthetic fixture written; runtime pending |

Windows test entrypoint: tests/windows_smoke.ps1 (default runs parser + event/incident/telemetry/report_io fixtures). The explicit -RunReadOnly switch additionally runs the one-day actual Windows diagnostics; it writes only local report files. Do not run repair as part of these tests.

No Windows 10/11, PowerShell 5.1, USB filesystem, OS log permission or actual battery device verification has been performed for this change.

