# AXMART PC CARE v0.1-alpha — Windows PC·USB 포터블 진단·복구 보조 도구

**상태: 초기 시험용, 판매 불가. 실제 Windows PC에서 실행 검증 전.**

## 구성

| 파일 | 실행 위치 | 기능 | 시스템 수정 |
|---|---|---|---|
| `RUN_HEALTH_CHECK.cmd` | 정상 부팅한 Windows 10/11 | OS·저장장치 여유 공간·일부 저장장치 상태·최근 30일 BugCheck(1001)·예기치 않은 종료(41/6008)·스토리지 이벤트 점검, HTML/JSON 보고서 | 없음 (보고서 파일만 생성) |
| `RUN_SAFE_REPAIR.cmd` | 정상 부팅한 Windows, 관리자 실행 | 백업/승인 확인 후 DISM RestoreHealth + SFC Scannow | **있음** |
| `recovery/WINRE_READ_ONLY.cmd` | Windows RE 명령 프롬프트 | 설치 Windows 후보·BitLocker 보호 상태·부트 항목 확인, 로컬 텍스트 로그 | 없음 (보고서 파일만 생성) |

## 사용

1. USB 또는 일반 폴더에 이 전체 폴더를 **압축 해제**한다. 원래 폴더 구조를 유지한다.
2. Windows가 시작되면 `RUN_HEALTH_CHECK.cmd`를 더블클릭한다. 완료 후 `REPORTS`의 `.html`을 연다. 관리자 권한이 없으면 일부 데이터가 누락될 수 있다.
3. 보고서에 이상이 나왔다고 바로 수리하지 않는다. 중요 파일은 먼저 별도 드라이브에 백업한다.
4. Microsoft 시스템 파일 복구가 필요하다고 판단될 때만, 백업한 후 `RUN_SAFE_REPAIR.cmd`를 **관리자 권한으로 실행**한다. 확인 문구를 직접 입력해야 수리한다.
5. Windows가 부팅되지 않으면 [Microsoft 정식 Windows 복구 미디어](https://support.microsoft.com/windows/create-installation-media-for-windows)로 Windows RE에 진입한다. 명령 프롬프트에서 USB 드라이브 문자를 확인하고 `E:\AXMART_PC_CARE_USB_v0.1\recovery\WINRE_READ_ONLY.cmd`처럼 실행한다. (예시 E:는 실제 USB 문자로 바꾼다.)

> **중요:** 이 ZIP 자체는 부팅용 USB 이미지가 아니다. Microsoft의 Windows 설치/복구 USB를 별도 준비해야 한다. 자체 WinPE 이미지의 번들·상용 재배포는 별도 권리 확인 대상이다.

## 개인 정보

서버 없음, 계정 없음, 외부 AI API 없음, 자동 업로드 없음. 사용자 이름·디스크 시리얼·이벤트 원문은 진단 JSON에 의도적으로 저장하지 않는다. 복구 모드의 `bcdedit` 출력은 환경 식별 정보를 포함할 수 있으므로 **REPORTS 공유 전 검토**한다.

## 한계

- '특이사항 없음'은 모든 부품의 정상·무고장 보증이 아니다. BugCheck 정보는 이벤트 로그가 삭제되었거나 접근 권한이 없으면 확인할 수 없다.
- BSOD가 계속되면 하드웨어, 온도, 드라이버, SSD, RAM 등의 추가 테스트가 필요하다.
- EFI/BCD 수정, 파일시스템 쓰기 복구, 파티션 수정, Windows 초기화는 자동화하지 않는다.
- 정식 판매용 기능·품질/지원 약관·Win10/Win11 실기기 검증·코드 서명은 미완료.

## 개발자 검증

`python3 tests/test_package.py` 실행. 이 테스트는 정적 패키지 구성과 위험 명령 미포함 여부만 점검한다. Windows 실행 성공을 증명하지 않는다.

상품 가칭: **AXMART PC CARE**. 예상 소비자가 **₩5,000**, 실제 상품 판매·결제 연결 전.

## 내부 검증용 패키지 (배포 금지)
- `python3 tests/test_package.py` — 제품의 정적 안전성/구조 검사. 실제 Windows 작동을 증명하지 않음.
- `python3 tests/test_release.py` — 내부 ZIP 생성 알고리즘/해시/기밀 보고서 미포함 테스트 (6개).
- `python3 tools/release.py --internal-testing` — `dist-internal/`에 **INTERNAL_TEST_ONLY** ZIP 및 SHA256 파일 생성. 외부 업로드·배포 없음.
- `python3 tools/release.py --verify dist-internal/AXMART_PC_CARE_USB_v0.1-alpha_INTERNAL_TEST_ONLY.zip` — 허용 파일 목록·내부 SHA256·ZIP 무결성 재확인.
- ZIP은 내부 개발·Windows 검증용으로만 사용한다. 사용자 파일/이벤트 로그는 패키지에 포함하지 않는다.
- 실제 Windows 검사: 관리자 아닌 PowerShell 5.1에서 `powershell.exe -NoProfile -File tests/windows_smoke.ps1` (문법만), `-RunReadOnly` 추가 시 진단 실행. 디스크 수리는 실행하지 않는다.

## Windows 초보자용 안전 시험 (공개 전 내부 전용)
압축 해제한 USB 폴더에서 `RUN_SELF_TEST.cmd`를 더블클릭한다. PowerShell 문법 검사 후 **최근 1일에 대한 읽기 전용 검사**와 로컬 HTML/JSON 생성 여부만 검증한다. 시스템 파일 수리는 실행하지 않는다. 완료 화면의 PASS/FAILED와 종료 코드를 확인한다. 시험 중인 Windows 10/11에서만 사용하며, 개인정보가 포함될 수 있는 보고서를 그대로 외부에 공유하지 않는다. 결과가 PASS여도 WinRE·복구 기능 안전성은 별도 검증이 필요하다.

## 브랜드 및 배포 이름 (2026-10-30)
- 플랫폼/사이트: **AXMART³** (읽기: AXMART CUBE), 제품: **AXMART PC CARE**. 'USB'는 포터블 구동 매체/내부 ZIP 명명일 뿐 판매명 아님.
- GitHub 폴더와 내부 시험 ZIP 경로에는 하위 호환을 위해 `pc-care`·`USB`를 유지한다. 공개 제품 패키지명은 Windows 검증 후 별도 최종 결정.
- Windows 실행(PC 폴더/USB)은 설치 없이 동일한 스크립트 경로로 시작하도록 설계. WinRE는 별도 공식 복구 환경 필요.
