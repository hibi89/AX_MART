# AXMART Cloudflare Pages Git 배포 안내 (2026-10-30 KST)

**기존 GitHub**: hibi89/AX_MART (private), production branch main
**희망 Pages 프로젝트**: ax-mart → https://ax-mart.pages.dev (현재 미할당·미검증)
**디자인 원본**: 기존 루트 index.html 유지. 프론트엔드 전용.

## 소유자 Cloudflare 계정에서 최초 1회
1. https://dash.cloudflare.com/ 열기 → Workers & Pages → Create application → Pages → Import an existing Git repository.
2. GitHub 연결/설치/권한 승인이 뜨면 **hibi89/AX_MART 저장소만** 허용하여 인증한다. 인증 토큰을 채팅이나 GitHub에 공개하지 않는다.
3. Git repo hibi89/AX_MART, Project name ax-mart (선점되어 있으면 다른 이름), Production branch main 선택.
4. Framework preset None, Root directory /, Build command **npm run build**, Build output directory **dist**. 별도 환경변수 없음.
5. Save and Deploy. Cloudflare가 확정한 실제 pages.dev URL 및 배포 SHA를 확인한다.
6. 공개 HTTPS 접속·이미지 로드·데스크톱/모바일·상품 카드·필터·검색·상세·장바구니 미리보기·Console/Network 오류를 확인한다.

Git 연동 이후 main에 push하면 자동으로 다시 배포된다. Cloudflare API/로그인 연결은 현재 ChatGPT 도구에 없어 **실제 프로젝트 생성 및 배포는 아직 완료되지 않음**.

## 확인 명령
- npm test
- npm run build
- python -m http.server 4173 --directory dist

## 배포 오류
- 저장소 미표시 → Cloudflare GitHub 앱의 접근 가능한 저장소 목록을 확인(권한 무단 확대 금지).
- 404 → Build output dist 안에 index.html이 있는지, build 명령과 루트 / 설정 확인.
- Pages 이름 중복 → 가용 이름으로 수정하고 실제 할당 주소 기록.
- 성공 배포와 실제 서비스 정상은 다름: Production 렌더링 및 SHA 확인 필요.

## 안전
실제 로그인·결제·DB·SMAX² 연동은 없음. 다섯 상품과 가격은 데모이며 판매 기능은 제공하지 않는다.
Cloudflare 정적 자산에 API 비밀·세션·고객 데이터를 넣지 않는다. 소스 비공개 저장소는 그대로 유지한다.
