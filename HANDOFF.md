## AXMART³ CUBE P4-P8 milestone — 2026-11-11 KST
1. Source: hibi89/AX_MART feature/cube-commerce-core, baseline bb37b754c8e6b1fa9e208ae08209f3015b5e462d.
2. Scope: P4 local support metadata queue; P5 offline interest/transaction HOLD receipts; P6 ZIP deep structural and CRC audit; P7 no-script support FAQ; P8 SHA-bound owner CLI and static build integration.
3. Verified: Node 22.16 Linux targeted new code+tests 26/26 PASS, 0 FAIL, 0 SKIP. Ten code/test Git blob SHAs match source-exact local working files; catalog JSON blob 3414c25fe818367a526a2a4132a03c832e672ec6. Previous P1-P3 46 PASS belongs to prior code SHA.
4. NOT_RUN: original full npm test, 105KB homepage npm run build, changed build fixtures, real Chromium/Edge and Windows, real customer ZIP, real cloud Production, authentication/payment/entitlement/delivery.
5. Release: HOLD. Current PC CARE Windows/WinRE repair, license/security/owner approvals incomplete. No real customer support intake, checkout, member accounts, payments, or files delivered.
6. Estimated completion: previous 50 + P4 4 + P5 4 + P6 5 + P7 3 + P8 4 = 70% provisional engineering scope only. P8 full native build remains unverified; remaining 30% substantial customer/production flows.
7. Preservation: main fbb32362455378b85bcdd0b5037d1f338055fb71 and PC CARE feature b8706e0a77ec245acc7bc0672f121364c851f910 not modified; original index.html blob d8fca85669e73008f55a6eaf93c1c493f8ed707d intact; no secrets/PII/permissions/billing/deploy changes.
8. Errors: support-page first fixture missing explicit 미검증 and one FAIL, corrected; synthetic ZIP Unix mode signed shift led 7 RangeError, corrected using >>>0; later 26 PASS. No claim all repository tests pass.
9. Next: full exact branch Node native npm test/build, real browser/Win safety customer acceptance, owner-approved payments/account/entitlement/real inquiry system; central kmong score sync. No automatic cross-chat watcher.
10. Timestamp: 2026-11-11 KST; local new code exact test evidence, final published branch HEAD to be checked after GitHub commit.

---

# AXMART³ CUBE — P1/P2/P3 인수인계 (2026-11-10 KST)

1. **목표·확정 요구·기술:** 크몽 상품 관리 기준 AXMART³ CUBE 소프트웨어 플랫폼 최종상품 개발. `hibi89/AX_MART`, Node>=18 zero-deps static Cloudflare Pages. 기존 사용자 승인 다크 퍼플·민트 `index.html`/제품만 노출 정책 보존, 상품/출시·안전/계정/구매/다운로드를 구분. 운영 Production Git은 `main`이므로 무단 배포 없이 `feature/cube-commerce-core` 분리.
2. **완료·기능/설계 결정 근거:** A 즉시 결제·계정·다운로드/Cloudflare backend 활성화 vs B read-only source-backed catalog/검증/고객 안내 비교: B 선택(비용 0, 사고 가능성↓, 유지보수 재사용↑). P1 SHA 고정 원본 제품 등록·8개 출시 증거 미완·가짜 가격/다운로드/출시 차단·공개용 `dist/catalog.json` 생성. P2 사용자 선택 로컬 ZIP의 읽기 전용 sha256/파일 크기/ZIP magic 사전감사. P3 `commerce/catalog-page.mjs` 정적 접근성·CSP 고객 페이지 `dist/products/index.html` 생성, 기존 홈페이지 원본 수정 없이. PC CARE `feature/pc-care-usb` 실제 개발 브랜치 증거 참조만.
3. **테스트 명령·PASS/FAIL·미검증:** 새 코드 로컬 Node22.16.0 `node --test tests/catalog.test.mjs tests/build-catalog.test.mjs tests/package-audit.test.mjs tests/catalog-page.test.mjs` **46 PASS/0 FAIL/0 SKIP**, 단독 new-module 원본 SHA와 GitHub blob 동일. `tests/catalog` 19, `tests/build-catalog` 4(축약 HTML fixture, 새 products 페이지 출력 확인), `tests/package-audit` 13, `tests/catalog-page` 10. `npm test` (기존 `tests/site.test.mjs` 포함) **미실행**, 실제 GitHub Actions main 0건, Cloudflare Production/브라우저/고객/Windows 검증 미실행.
4. **완료/진행/대기/차단:** P1 +2%p, P2 +1%p, P3 +2%p = 최초 전체 상품 45→**50% 잠정**, RELEASE HOLD. 구현된 상품 홈페이지/상태 안내 ≠ 실제 회원·문의·주문·결제·인증·라이선스·상품 배포. 실제 PC CARE Windows10/11/WinRE·수리 안전·바이러스·서명 미검증이므로 다운로드/판매 차단 필수.
5. **오류/근거/시도/재시도 금지/대안:** P1 GitHub blob 압축 LZ 전송 디코더 1회 실패, 이후 원본 UTF-8 전송과 `git hash-object` SHA exact 비교로 전환. P2 최초 2개 테스트 실패 원인: 가변 ZIP header length 루프 경계; 고정값으로 수정해 36/36 PASS. P3 첫 시나리오에서 실제 미검증 문구와 테스트 기대 간 불일치 + build fixture에 새 파일 누락, 재설계/fixture 수정 후 46/46 PASS. 동일 실패 절차 반복/근거 없는 성능·안전 인증 금지.
6. **저장소/브랜치/SHA/경로:** `hibi89/AX_MART@feature/cube-commerce-core` **검증 기능+테스트 SHA `c0263f1d0d7f92aec219f5c547a86c380492b779`**; `main` baseline `fbb32362455378b85bcdd0b5037d1f338055fb71` 변경 금지, `feature/pc-care-usb` `b8706e0a77ec245acc7bc0672f121364c851f910` 보존. 주요 `commerce/catalog.mjs`, `commerce/catalog.json`, `commerce/package-audit.mjs`, `commerce/catalog-page.mjs`, `scripts/build.mjs`, 두 audit CLI, `tests/*catalog*.test.mjs`, `tests/package-audit.test.mjs`, `docs/CUBE_COMMERCE_P1-P3_20261110.md`.
7. **Production URL·실행 환경:** `https://ax-mart.pages.dev/` Cloudflare `ax-mart`, `main` 자동배포; 이번 새 feature branch **미배포**, 따라서 `/products` 실제 운영 URL은 현재 존재한다고 주장 금지. Run `npm test`, `npm run test:commerce`, `npm run audit:catalog`, `npm run audit:package -- --manifest <owner.json>`, `npm run build`. Linux Node22.16.0에서 신규 46 tests 확인, 전체 기존+신규/실 브라우저/Windows 미검증.
8. **원본·백업·인증 관리·수정 금지:** `main` SHA `fbb323...` 백업 복구점, `index.html` Blob `d8fca85669e73008f55a6eaf93c1c493f8ed707d` 동일; 기존 브랜드/이미지/Cloudflare 프로젝트·권한·도메인·고객 파일/토큰/결제/USB repair 스크립트 전부 수정하지 않음. 공개용 catalog/page에 비공개 source branch/SHA/checklist 없음. 고객 데이터/키/원본 ZIP GitHub 업로드 금지.
9. **다음 작업·완료 기준·승인:** 동일 GitHub feature SHA 실제 전체 `npm test`, `npm run build`+원본 홈페이지 데스크톱/390px/mobile 상품/필터 E2E/Console/Network; 고객 문의/지원·개인정보 최소수집/보존/계정·license/다운로드 entitlement, 실제 결제 provider/API/DB는 비용·권한·데이터 외부 전송·상용화 승인 뒤 별도 개발. 원본 site 검증/브랜치 비교 후에만 `main` merge 승인 요청, Cloudflare Production SHA/URL/접근·안전 확인. PC CARE 출시 Windows 실기기/WinRE·기밀보호/라이선스 게이트 필수.
10. **기준시점·범위·문서커밋:** 2026-11-10 KST, 검증된 source/test HEAD `c0263f1d0d7f92aec219f5c547a86c380492b779`, README/STATUS/HANDOFF 문서-only 추가 커밋은 push 후 SHA 확인. 검증은 신규 46 테스트 Native Node22, 기존 실제 105KB index/Production/고객/Windows/상용 release 미검증. 이력보다 실제 HEAD 우선.

---

# AXMART³ CUBE — P1/P2 개발 인수인계, 2026-11-10 KST

1. **목표·용도·확정 요구·기술:** 비공개 `hibi89/AX_MART`를 독립 소프트웨어 상품 플랫폼으로 발전. 기존 `main`은 Cloudflare Pages `ax-mart` 자동 Production 연결이며, 다크 퍼플·민트 히어로 원본/하나의 실상품 PC CARE 설명을 보존. 개발은 새 `feature/cube-commerce-core` 브랜치, Node >=18 zero-dependency 모듈. 소비자 결제/로그인/다운로드는 아직 소유자 승인 전 HOLD.
2. **완료 기능·근거:** A 즉시 Cloudflare 결제/계정/API 활성화 vs B 별도 브랜치의 fail-closed 상품 카탈로그/검증 프리플라이트 비교. 비용·계정·개인정보·미검증 제품 위험 때문에 B. P1 `commerce/catalog.mjs`, `commerce/catalog.json`, `scripts/audit-catalog.mjs`, 변경 `scripts/build.mjs` (원본 index byte-preserve, 유출 방지 `dist/catalog.json` 발행). 제품 1개 실 소스 참조 GitHub SHA 고정, 8개 출시 필수 증거 false, 가격/구매/다운로드 모두 거부. P2 `commerce/package-audit.mjs`, `scripts/audit-package.mjs`, 로컬 ZIP 크기/바이트 SHA/signature 사전검사. hash MATCH라도 윈도우/악성코드/라이선스 안전 인증은 아님, 승인/배포 금지.
3. **테스트·검증·미검증:** `node --test tests/catalog.test.mjs tests/build-catalog.test.mjs tests/package-audit.test.mjs` **36/36 PASS, 0 FAIL, 0 SKIP** (실제 컨테이너 Node22.16, 실행한 정확 원본과 GitHub Blob SHA 매칭). P1 첫 23/23 PASS, P2 첫 실행 13건 중 2 FAIL 발생 후 ZIP 첫 4바이트 검사 경계 수정해 총 36/36 PASS. Build 4개 테스트는 임시 축약 HTML fixture. `npm test`는 기존 `tests/site.test.mjs`를 포함하도록 등록했으나 **원본 105KB index 통합 테스트 NOT_RUN**, GitHub Actions 기준 main 0 runs. 실제 운영/Windows/결제 미검증. Audit CLI는 로컬 일회성 SHA evidence/8 missing gate를 출력.
4. **완료/진행/대기·차단:** P1/P2 기능+정적 빌드 시큐리티 정책+샘플 카탈로그 구현; 제품 잠정 45→48%(P1 +2,P2 +1). 기능이 쇼핑몰 결제나 실제 회원/고객지원 완성을 뜻하지 않는다. 50%까지 2%p, 전체상용 100%와 별도. RELEASE HOLD, 사용자 유료 결제·권한 조정·데이터 전송·실제품/원본 변경 없음.
5. **오류 근거·중단·전환:** 기능 코드를 GitHub Blob으로 전달할 때 원시 압축 전송 1회 디코딩 오류(Invalid LZ77 distance); 그 방식 중단, 원본 UTF-8 코드/정확 `git hash-object` SHA 확인으로 전환 성공. P2 첫 로컬 ZIP 검사 테스트 2 FAIL 원인: 반복 중 바뀌는 `header.length`을 경계식에 직접 사용. 경계 고정 후 전체 36 PASS. 동일 실패 방식 반복 금지. Production public 웹 도구의 접근 실패는 서비스 장애 단정 금지.
6. **저장소·브랜치·SHA·경로:** `hibi89/AX_MART@feature/cube-commerce-core` 기능/테스트 최종 SHA **`656fb945ac0b2ea6ec20fe9d58eb65e8bd2efe0c`**. 기존 `main` SHA `fbb32362455378b85bcdd0b5037d1f338055fb71` 보존. `feature/pc-care-usb` SHA `b8706e0a77ec245acc7bc0672f121364c851f910` 보존. `commerce/catalog.mjs`, `commerce/catalog.json`, `commerce/package-audit.mjs`, `scripts/{build,audit-catalog,audit-package}.mjs`, `tests/{catalog,build-catalog,package-audit}.test.mjs`, `docs/CUBE_COMMERCE_P{1,2}_20261110.md`.
7. **Production URL·Vercel/Cloudflare·명령:** Cloudflare Pages `https://ax-mart.pages.dev/`, `main` Git source; 이번 브랜치는 **미배포**. Node >=18 `npm test` (기존+신규 전부), `npm run test:commerce`, `npm run audit:catalog`, `npm run audit:package -- --manifest <local.json>`, `npm run build`. Cloudflare/Vercel project/settings/secret/domain 수정 없음.
8. **원본·백업·인증·수정금지:** `main` 부모 SHA `fbb323...`로 기능 브랜치를 버리거나 복원 가능; 원본 `index.html` 및 CSS/이미지/사용자 승인 디자인, 고객정보, `.env`/token/계정, Windows PC CARE USB ZIP/스크립트, 개발 제품 branch 전부 미수정. 공개 카탈로그에는 사설 branch SHA/검증 체크리스트를 포함하지 않는다.
9. **다음 작업·완료 기준·승인:** 우선 실제 전체 소스 체크아웃에서 `npm test` + `npm run build` (기존 105KB index) 검증하고 필요시 fixture mismatch 최소 수정. 다음 실사용 가치: 허가된 문의/지원/고객 데이터 보존 정책, 무료 베타 전달 자격과 ZIP 구조/악성코드/서명 검사, 결제/권한/정산 설계; 계정 연결/유료 API/배포 main 수정은 사전 승인 후. 완료 기준은 code/CI/native/full browser/Production SHA·안전 모두 일치. PC CARE Windows10/11/WinRE 실기기와 license 확인 전 다운로드 금지.
10. **갱신시점(KST)·확인 범위·문서 기준 커밋:** 2026-11-10 KST, 정확 기능 소스 SHA `656fb945ac0b2ea6ec20fe9d58eb65e8bd2efe0c`; 로컬 Node22 new-suite PASS 36/36과 GitHub blob 해시/브랜치 상태 검증. 문서-only 추가 커밋은 GitHub 반영 후 확인. Linux/native 실운영 전체, Production SHA·Console/Network, 상용출시는 미검증·HOLD.

---

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

## 배포 직후 인수인계 갱신 — 2026-10-30 KST
- 최종 확인 원본: 사용자 제공 Cloudflare Pages 프로젝트 Deployments 화면에서 `ax-mart`, Production 도메인 `https://ax-mart.pages.dev`, GitHub `main` 소스 단축 SHA `1ad0772`, 녹색 배포 체크, Automatic deployments enabled 확인. 이 사항은 기존 'Cloudflare 프로젝트 미생성' 기록을 대체.
- GitHub 소스: `hibi89/AX_MART`/`main`, 배포 SHA `1ad0772` (Cloudflare 화면의 단축 SHA), 이 기록에 따른 문서-only 추가 커밋 존재. 기능 소스 `index.html` 미수정.
- 실제 Production 정상 여부: Cloudflare 빌드·업로드·배포 상태는 확인. 외부 HTML/정적 자산 응답은 해당 도구의 웹 액세스 및 DNS 제한으로 **미검증**, 화면 렌더·콘솔·네트워크·익명 접근·모바일·검색은 여전히 Production 검증 필요. 사용자 브라우저에서 https://ax-mart.pages.dev 접속해 확인하면 된다.
- 중단지점: Cloudflare Git 연결 및 Production 배포 성공. 기능 소스 추가 변경 필요 없음. 현재 남은 작업은 URL 실환경 시연 검수, 그 다음 사용자 승인된 범위에서 실제 판매 백엔드·결제·상품 등록 설계.
- 인증·보안: 사용자의 Cloudflare 화면에 계정이 표시되지만 문서에는 계정 식별 정보·토큰 미기록. 상업용 호스팅 약관·결제는 별도 검증.
- 확인 시점 2026-10-30 KST, 근거 범위 Cloudflare UI 스크린샷 및 GitHub 문서, 문서 기준 최초 SHA `1ad0772`; `STATUS.md`와 동기화.


## 11. 실제 공개 페이지 검증 추가 — 2026-10-30 14:43 KST (최신)
- 프로젝트: `hibi89/AX_MART`, `main`; Cloudflare Pages `ax-mart` Production URL `https://ax-mart.pages.dev/`. 배포된 UI 원본 commit은 `1ad0772`; 후속 커밋은 문서 갱신. 사이트 Git 자동 배포 설정 활성.
- **실제 확인 완료:** 사용자 Chrome에서 공개 URL 열림, 선택된 다크·보라·민트 UI와 후드 해커 이미지·메인 타이포·네비게이션·인기 상품 섹션 시각적 정상 표시. Browser 탭 읽기에서 제목, 예시 상품 5개, 분류, 상품·서비스 소개, 미지원 거래 안내까지 콘텐츠 확인.
- **미확인:** 독립 HTTP/정적 자산 상태 코드, Production 모바일 렌더 및 모든 인터랙션 실제 조작, Console/Network, 제3자 익명 접속. 이전 로컬 HTML 브라우저 테스트와 현재 실제 Production 브라우저 읽기는 서로 다른 검증 범위임.
- **배포 정책/미구현:** 클라우드 정적 프론트엔드 단계. 결제·로그인·DB·실판매·SMAX² API는 미구현. 실제 판매와 보안·약관·정산 설계는 별도 승인 후.
- **다음 우선순위:** ①운영 URL 모바일·상품 검색·필터·장바구니 실조작 점검 ②실제 제품/가격 검수 ③서비스 상용화 설계 시 결제·데이터 보안·판매/환불 정책 검토. 소스 수정 없이 문서만 최신화했으며 직전 정상 소스로 롤백 가능.
- **검증 기준:** 2026-10-30 14:43 KST 사용자 제공 Chrome 스크린샷과 연결된 Browser 읽기 결과; 현재 문서 커밋은 이 업데이트 이후 변경된 SHA를 기준으로 함.


## 2026-10-30 사이트 실제 제품 전환 인수인계 (최신)
1. 목표/요구/기술: AXMART에 허위 상품/가격을 없애고 실제 개발 소프트웨어만 노출. 기존 정적 HTML+JS/CSS, Node 정적 빌드, Cloudflare Pages 유지.
2. 완료/근거: 5개 예시 카드를 제거하고 AXMART PC CARE USB v0.1-alpha 카드 1개로 대체. 상태를 '개발 중, Windows 실기기 미검증'으로 표시. 가짜 플랜/결제·로그인 모형을 삭제. 기존 마스코트 보존.
3. 검증: 로컬 npm test 3/3 PASS 및 npm run build PASS; Playwright 브라우저에서 데스크톱·390px 모바일 제품 1개/검색/상세/모바일 메뉴/가로 넘침 0/JS 오류 0. USB 정적 패키지 테스트 5/5 PASS. 실제 Windows 작동은 미검증.
4. 상태: 사이트 소스 구현·로컬 테스트 완료; Cloudflare Git 자동 배포 트리거 후 배포 SHA/실운영 콘텐츠 재확인 필요. PC CARE 기능은 알파이며 미완료.
5. 장애: Windows 실기기 부재 및 복구 검증 없음. 결제·다운로드 제공 금지, 무인 수리 금지. 브라우저 테스트는 시스템 Chromium 경로를 사용해 로컬 검증, Production 검증으로 대체 불가.
6. 저장소/브랜치/SHA/경로: hibi89/AX_MART main, 이번 커밋에서 index.html, scripts/build.mjs, tests/site.test.mjs 및 문서 변경. 이전 HEAD d37a005354f925b1e261e8c278ca082249e3b8cc 복구 가능.
7. 운영: Cloudflare Pages ax-mart / https://ax-mart.pages.dev ; build 'npm run build', output dist, GitHub main 자동 배포. 실제 Production SHA 검증 대기.
8. 원본/보안: 기존 원본 index.html 이전 커밋에 보존. 히어로 이미지 base64 인라인 유지; 토큰·개인정보·고객 로그 없음. 실기기 수리 명령/부트 파티션 변경은 공개하지 않음.
9. 다음 작업: PC CARE 실기기 진단 검증→WinRE·복구 VM 안전성 검증→무료 베타 다운로드 승인→익명 피드백 채널 구축. 완료 조건은 실제 기능 동작 및 회귀 테스트.
10. 갱신: 2026-10-30 KST, 문서 기준 커밋은 실제 GitHub 생성 커밋으로 판단. Cloudflare Production 실환경 화면 미검증 항목은 분리 유지.


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

## 2026-10-30 KST — AXMART 로고 간격
- 브랜드명은 AXMART 유지(AXMART³는 미채택 후보). 기존 디자인·기능 보호하면서 `index.html`의 `.brand-ax`에 `margin-right:.12em`만 추가.
- 변경 전 GitHub main SHA: `cdd3c6e182387d452da41aa98980d572d559715a`; Cloudflare 실제 배포/렌더/콘솔 검증은 수행되지 않음. PC CARE USB 제품 개발은 `feature/pc-care-usb`에서 별도로 진행 중.

## 2026-10-30 KST — 사이트 AXMART³ 브랜드 확정
- 사용자 확정: **AXMART³ (AXMART CUBE)** = 플랫폼·사이트명; **AXMART PC CARE** = 첫 제품명. USB는 이용 방식.
- `main` 사이트의 title/meta/OG, 상단·푸터 로고와 favicon, 제품명·설명, 반응형 PC CARE 콘셉트 화면, 테스트와 빌드 명칭 정리.
- 사용자가 선택한 다크 퍼플·민트 포스터 감성을 CSS/HTML 프리뷰로 반영. 프리뷰는 **가상 UI**로 표시하고 실제 코드는 아직 Windows 기기·WinRE 미검증 상태 유지.
- 기존 Cloudflare URL과 GitHub 레포명, 다운로드/판매 차단 정책 유지.
- 변경 전 main SHA: `af2996965691e4e9e318cd843de758c10baa7d23`. 커밋 후 Cloudflare 새 Production SHA·브라우저 UI 별도 확인 필요.

## 2026-10-30 KST — 운영 문서 정정
- AXMART³ 브랜드 기준, PC CARE 제품 분리, Cloudflare 기존 프로젝트/도메인 유지. 과거 'Cloudflare 미연결/미할당' 시점의 이력은 최신 운영 상태로 오해하지 말 것. 최신 검증 절차는 `CLOUDFLARE_DEPLOY.md` 참고.
