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
