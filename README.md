> **2026-11-10 KST — AXMART³ CUBE 상품 등록 보안 기반 P1/P2** (비공개 `feature/cube-commerce-core`; **Cloudflare 운영 `main` 변경 없음**): 실제 1호 제품 AXMART PC CARE의 `commerce/catalog.json`·출시 증거 체크/정적 공개 JSON 생성 검증·결제/다운로드 차단을 구현했고, 소유자 로컬에서 ZIP 후보 바이트/크기/SHA를 읽기 전용으로 확인하는 `audit:package`를 추가. 새 기능 Native Node22.16 합성 회귀 **36/36 PASS/0 FAIL**, 실제 사이트 전체 원본 `npm test`/Production/Windows/실 ZIP은 **NOT_RUN**. [P1 설계](docs/CUBE_COMMERCE_P1_20261110.md) · [P2 설계](docs/CUBE_COMMERCE_P2_20261110.md), 정확 기능 소스 SHA `656fb945ac0b2ea6ec20fe9d58eb65e8bd2efe0c`. 사업자·결제·보안·실제품 검증 전 판매/다운로드/계정 기능 **HOLD**. 최종상품 잠정 **48%**, 50%까지 2%p.

# AXMART³ (AXMART CUBE)

소프트웨어 플랫폼 공식 브랜드는 AXMART³, 읽기는 AXMART CUBE입니다. 제품 AXMART PC CARE는 PC·USB 포터블 Windows 진단 및 안전복구 지원 프로젝트입니다.

- 공식 URL: https://ax-mart.pages.dev/
- Cloudflare Pages: GitHub main 자동 빌드, `npm run build`, 출력 `dist`
- 설치: 의존성 없음, `npm test`와 `npm run build`
- 실제 공개 프로젝트: AXMART PC CARE v0.1-alpha (개발 중, Windows 실기기 검증 전)
- 무료 다운로드·실거래·회원가입·피드백 접수: 미구현
- 가상 판매 카드/가격/후기/장바구니/모형 요금제 제거
- PC CARE 실기기 테스트 및 정식 안전 판정 완료 후 무료 베타 공개 여부 결정

관련 현재 상태는 STATUS.md 및 HANDOFF.md 참조.

- 화면의 PC CARE 대시보드는 사용자가 승인한 퍼플·민트 콘셉트의 디자인 목표 시안이며, 실측·작동 결과가 아니다.
