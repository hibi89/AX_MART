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
