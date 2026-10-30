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
