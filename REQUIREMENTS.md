> **2026-11-10 KST — 개발 기능 범위 갱신:** 기존 확정 요구(실제품만 표시, 검증 전 다운로드/유료 결제 차단, Cloudflare `main`과 디자인 보존)는 변경 없음. 별도 `feature/cube-commerce-core`에서 P1 source-backed 상품 카탈로그, public-safe `catalog.json`, build fail-closed 판매/다운로드 가드; P2 read-only SHA/size/ZIP-header candidate inspection 기능 추가. 실제 판매/결제/회원가입/다운로드 권한 및 Windows/WinRE PC CARE 테스트는 **미완/HOLD**. Node22 신규 suite 36/36 PASS, 원본 site·production full E2E 미검증. [상세 P1](docs/CUBE_COMMERCE_P1_20261110.md) · [P2](docs/CUBE_COMMERCE_P2_20261110.md).

# AXMART 확정 요구 — 2026-10-30
- 실제 제작·검증 중인 프로젝트만 공개하고, 가짜 상품명·가격·리뷰·거래 기록 제거.
- 채택된 다크 해커 마스코트·보라/민트 네온 디자인 유지.
- 실제 첫 프로젝트 AXMART PC CARE USB v0.1-alpha는 제품 카드 1개로 개발 중만 표시. Windows 실기기 미검증, 무료 다운로드·결제 미제공.
- PC CARE 제품 완성 기준: 실제 Windows/WinRE 및 복구 안전성 검증. 검증 전 자동 수리·무료판 공개 불가.
- 후속 출시 전 피드백 창구 구축, 진단 로그/개인정보 자동 업로드 금지.
- Cloudflare Pages https://ax-mart.pages.dev, GitHub hibi89/AX_MART main 자동 배포 유지.
- 웹 UI의 검색·카테고리·상세·모바일 반응형은 유지하고 유료 기능과 사용자 계정은 명시적 승인 전까지 미구현.


## [최신 사용자 확정] 2026-10-30 우선 적용
- 예시 상품 5개 및 가상 가격·고객 후기·로그인/결제·요금제 모형 제거. 실제 개발 코드가 있는 제품만 노출. 미검증 상품은 개발 중 / 다운로드 비활성 명시. 이전 '예시 상품 5개' 요구는 **철회**.
- 1호 상품 `AXMART PC CARE USB`: 정상 부팅 시 로컬 건강검진, 블루스크린 흔적 및 비정상 종료 진단, 부팅 실패 시 Windows 공식 복구 환경과 USB로 수동 진단, 사용자 사전 승인·백업 후 제한적 Windows 시스템 파일 수리. 완전 자동 복구·부팅형 USB·모든 PC 고장 해결 보장은 미완성/검토 대상.
- 안전 검증 후 무료 체험판 공개, 다운로드 화면의 부담 없는 의견 요청, 익명·선택적 피드백, 개선 기록 공유. 진단 로그/개인정보 자동 전송 금지.
- 별도 제품 개발 브랜치 `feature/pc-care-usb`에 15개 원본 소스 저장. `main`은 Cloudflare Pages 운영용이며 다운로드 미노출. 가격 가설: 직접 판매 ₩5,000 / 크몽 ₩10,000(검토), **현재 판매/결제 없음**.
