# AXMART HANDOFF — 2026-10-30 KST

1. 목표/요구/기술: 선택된 귀여운 다크 해커 AXMART 사이트를 Cloudflare Pages Git 연동 가능하게 준비. 정적 HTML/CSS/JS, Node 18+ 외부 의존성 없는 build, 실제 결제 제외.
2. 완료/결정: 사용자 확정된 index.html 원본 미수정. package.json, scripts/build.mjs, cloudflare/_headers, tests/site.test.mjs, CLOUDFLARE_DEPLOY.md 추가. Vercel Hobby 상업 이용 제한에 따라 Cloudflare Pages 선택.
3. 테스트: npm test PASS 1/1; npm run build PASS(로컬 dist/index.html 104,502 bytes); Playwright set_content PASS: 상품 5개/필터/상세/검색/모바일 390px/JS 오류 0. 실제 Cloudflare Production 테스트 미검증.
4. 단계: 코드/정적 빌드 완료. Cloudflare 계정 Git 인증·프로젝트 생성·실 URL/E2E 미완료. 백엔드·결제·계정은 후속.
5. 오류/원인/시도·대안: 이전 Vercel 프로젝트 생성 403, 재시도 금지. 현재 Cloudflare 커넥터 없음; 사용자 Cloudflare 대시보드에서 GitHub repo 최소 범위 승인. 로컬 localhost 접근 네트워크 정책 차단, Playwright HTML 직접 주입 테스트로 전환.
6. 저장소·브랜치·SHA·경로: hibi89/AX_MART/main. 이전 SHA f4cbf5b3c3c1e609af18c0d368ea5b98cea7caa9. 이번 변경은 GitHub 새 커밋; index.html 원본 유지. build script scripts/build.mjs, 설정 cloudflare/_headers.
7. Production·명령·환경: Cloudflare Pages 희망 project ax-mart, https://ax-mart.pages.dev (미할당). root /, branch main, preset None, Build npm run build, output dist, Node >=18.
8. 백업·인증·보안: 이전 SHA로 복귀 가능, GitHub private 유지, 원본은 레이어 없는 래스터 히어로 포함. API/Cloudflare 토큰·민감 데이터 정적 파일/commit 금지.
9. 다음 우선순위/승인/완료 조건: 소유자가 Cloudflare dashboard에서 GitHub hibi89/AX_MART 접근 승인→Pages 프로젝트 생성→URL 및 배포 SHA 확인→익명 HTTP·desktop/mobile·이미지·Console/Network·UI 동작 검증→문서에 실제 URL 반영. 유료 결제·도메인 구매·범위 확대는 별도 승인.
10. 확인·갱신: 2026-10-30 KST. 문서 기준은 이번 Cloudflare 준비 GitHub 커밋, Live Production 상태는 아직 대기.
