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
