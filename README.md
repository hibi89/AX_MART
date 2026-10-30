# AXMART — 귀여운 다크 해커 자동화 마켓

확정된 검정·네온 보라·민트색 디자인의 **정적 프론트엔드**. 기존 index.html을 변경하지 않고 Cloudflare Pages로 배포하기 위한 도구를 추가한 버전.

## 로컬 검증
- Node 18+ (외부 npm 의존성 없음)
- npm test
- npm run build
- python -m http.server 4173 --directory dist

## Cloudflare Pages 설정
Git repo hibi89/AX_MART / branch main / preset None / Build npm run build / output dist / root /.
연결 상세 및 남은 사용자 인증 작업: CLOUDFLARE_DEPLOY.md.

기능: 상품 예시 5개, 반응형 UI, 상품 검색, 카테고리 필터, 상세 보기, 데모 장바구니.
**실제 구매·결제·로그인·백엔드는 아직 없다.** 허위 통계나 판매가 발생한 것으로 오인되지 않도록 데모 표시를 유지한다.
