# AXMART / PC CARE USB — 새 채팅방 시작점


## [최신] 새 채팅방 USB 개발 인수인계 — 2026-10-30 KST
- **프로젝트 정체성:** AXMART는 무료/저가 Windows/AI 자동화 도구를 제공하는 자체 마켓. 사용자가 승인한 다크 해커 디자인 보존. 홈페이지 https://ax-mart.pages.dev/; GitHub 비공개 `hibi89/AX_MART`, Production `main`, Cloudflare Pages 자동배포.
- **사이트 현재 상태:** 2026-10-30 `ca6c312bf69216b19a4235166edd2695ec81aa98` 커밋에서 가상 상품 5개·예시 가격·가상 결제/로그인/요금제 제거. 실제 소스 있는 `AXMART PC CARE USB v0.1-alpha` 한 상품만 **개발 중 / 무료 다운로드 비활성** 표시. 원본 디자인과 반응형 레이아웃 보존. 로컬 빌드·테스트 PASS 보고됨. 이 커밋의 Cloudflare Production **실제 반영/렌더는 아직 별도 확인 필요**.
- **USB 제품 소스 저장소:** 같은 repo의 **`feature/pc-care-usb` 브랜치**, 경로 `products/pc-care/`. 정확한 최초 전체 소스 15파일 업로드 커밋 `5bd374badbb63b1c6bb0aa911f9e2fd1412d36d1`; 해당 브랜치 `STATUS.md`, `HANDOFF.md`가 업데이트되어 있음. 이 파일들이 실코드의 기준이며 별도 신규 레포 생성 불필요. 사용자는 새 채팅에서 'USB 완성 가자'고 할 예정.
- **고객 요구:** (A) 정상 Windows에서 USB/폴더 실행 → PC 건강 상태·SSD/드라이브 용량/최근 Windows 로그·블루스크린 흔적·비정상 종료·저장장치 오류 탐지 → 로컬 HTML/JSON 보고서; 정기 재실행 가능. (B) Windows 부팅 장애·블루스크린 반복 → 외부 Microsoft 정식 복구 환경(WinRE)에서 USB 활용하여 읽기 전용 장애 정보 점검. (C) 사용자의 백업·명시적 승인 후 수리가 가능한 Windows 시스템 파일만 DISM/SFC 등 안전한 공식 방법으로 복구; 데이터 삭제·부트/파티션 무인 수정·하드웨어 고장 완전 수리 금지.
- **USB 구현 범위:** `RUN_HEALTH_CHECK.cmd` + `tools/diagnose.ps1`, `RUN_SAFE_REPAIR.cmd` + `tools/repair.ps1`, `recovery/WINRE_READ_ONLY.cmd`, 설명서·샘플 HTML·정적 테스트. PowerShell 5.1/CMD, Windows 10/11, 기본 오프라인/로컬 보고서, 외부 API·서버·자동 원격 전송 없음. ZIP 자체는 **부팅 USB 이미지가 아니며** Microsoft 공식 WinRE/설치 미디어 별도 필요. 자체 WinPE 번들은 라이선스 확인 전 보류.
- **검증 사실/제약:** Linux에서 정적 구성 5/5 PASS, 데스크톱/모바일 HTML 보고서 렌더 확인(샘플 가상 데이터). **Windows 실제 PC, PowerShell 실행, WinRE, BSOD/복구 VM, 승인형 수리, 개인정보·보안·SmartScreen 검증 모두 미완료**. 사용자 PC 안전 테스트 및 오류 복구/중단 처리를 먼저 마쳐야 한다. 5,000원 유료판매나 무료 공개 다운로드도 현재 불가.
- **무료 베타 배포 계획:** 안전 검증 후 AXMART에서만 실제 제품 링크 활성화. 다운로드 시 '무료 제공, 편리/불편/오류/개선 의견 모두 환영'을 명확하게 안내하고, 다운로드/의견 제출은 별개(피드백 강제 금지). 익명 선택적 피드백, 초기엔 Google Forms 등 외부 수집 도구 검토; 진단 로그/장치 정보 동의 없는 전송 금지. 제품 업데이트 기록 공개.
- **가격 방향:** 첫 공개는 무료. 정식 유료 단계에서는 AXMART 자체 목표 ₩5,000, 크몽 판매시 카테고리 최소가격 확인 후 ₩10,000 검토. 사업자등록·결제·정산·소프트웨어 라이선스 정책 필요. 현재 어떤 결제도 연결되지 않음.
- **최우선 다음 작업:** GitHub feature 브랜치 실제 코드 전체 검사 → Windows 지원 환경 수집/오류 처리·진단 정확도 테스트 → Windows 10/11 가상머신 및 실기기 런 실행 → 복구 안전성 테스트(스냅샷·백업·고장 시나리오) → 정식 릴리스 패키징과 코드 서명/체크섬 → 무료 사용자 피드백 시스템 → 사이트 상품 다운로드 연결. 작업 결과와 미검증 사항을 `products/pc-care/STATUS.md`, `products/pc-care/HANDOFF.md`에 업데이트. Production은 사용자 승인 및 안전성 검증 후 변경.
- **주의:** 기존 이전 섹션에서 'PC CARE GitHub 미반영'이나 '가상 상품 5개 유지'라고 적힌 내용은 과거 이력이며, **이 최신 섹션과 브랜치 실측 결과가 우선**한다. GitHub `main`의 사이트 내용과 `feature/pc-care-usb` 소스 코드를 구분.
