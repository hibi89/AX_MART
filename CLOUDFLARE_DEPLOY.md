# AXMART³ (AXMART CUBE) — Cloudflare Pages 운영 인계 (2026-10-30 KST)

## 현재 운영 구성
- Private repo: `hibi89/AX_MART`, Production branch: `main`.
- Cloudflare Pages project: `ax-mart`, 공개 URL: https://ax-mart.pages.dev/.
- 사용자 확인된 과거 Production: Git main 자동 배포 Enabled, 녹색 성공 상태(당시 SHA `1ad0772`). 실제 사용자 Chrome 데스크톱에서 기본 화면 렌더 확인.
- **새 브랜드 변경 소스:** `6fb4fd8e5f088645eae6050cb0fc3607ea8520f0` — 이 SHA의 Cloudflare Production 실제 배포 성공 및 운영 페이지 최신 화면은 **별도 확인 필요**. 사이트 주소와 Cloudflare 프로젝트 자체는 변경하지 않는다.
- Build: Node >=18, `npm run build`, output `dist`, no environment variables required.

## 소스 변경 후 검증
1. `npm test`, `npm run build` 실행 (제품 자체 Windows 테스트가 아님).
2. Cloudflare Pages dashboard → `ax-mart` → Deployments → Production의 source SHA 및 성공 결과 확인.
3. https://ax-mart.pages.dev/ 접속 후 제목 AXMART³ (AXMART CUBE), 헤더·푸터 로고의 ³, PC CARE (USB 단어 제외) 단일 제품 카드 확인.
4. `#care-concept` 디자인 프리뷰가 **가상 화면**이라고 표시되는지 확인하고, 데스크톱/모바일 가로 스크롤, 자산 로딩, 검색/필터/상세 모달과 Console 오류 점검.
5. 판매·다운로드 링크 없는 상태 보존. 결제·로그인·실배포 제품 링크는 안전성 검증·별도 승인 전 만들지 않는다.

## 오류 및 롤백
- 빌드 실패 → Node 버전과 `scripts/build.mjs`·`tests/site.test.mjs`를 점검.
- 운영 화면 이전 버전 → Cloudflare Production SHA 대조 후 배포 경로 확인. 브라우저 탭 캐시/새로고침과 배포 반영을 혼동하지 않는다.
- 정상 작동 이전 Git 소스: `af2996965691e4e9e318cd843de758c10baa7d23` (사용자 브랜드 변경 승인 전 main).
- 사용자 Chrome의 기존 탭 콘텐츠는 새 소스 배포 확인의 근거가 아니다.

## 안전·제품 상태
- 플랫폼: AXMART³, 제품: AXMART PC CARE.
- 첫 제품은 알파, Windows 10/11 및 WinRE·복구 안전성 실기기 미검증. '이동식 USB 자체 부팅'을 주장하지 않는다.
- 가상 상품/가격/후기/구매/로그인 등 미구현 요소 제거 유지. 외부 사용자 로그 수집 없음.
- Cloudflare 토큰·계정 ID·비밀키를 저장소나 HTML에 넣지 않는다.
