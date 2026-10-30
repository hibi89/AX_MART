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

## 2026-10-30 15:35 KST — PC CARE 제품 변경(작업 브랜치 전용)
- GitHub: `hibi89/AX_MART` / `feature/pc-care-usb`. 변경 전 `4d48eb5f3078e1442410205923f89fc5b4a77207` (복구 기준). `main`/Cloudflare 사이트는 변경하지 않음.
- 제품: PowerShell 5.1 BOM 보정, 로그 조회 실패·절단 수 표시 개선, 디스크 상태 불확실 시 승인형 수리 차단, WinRE 로그 안전 개선, Windows 실행 검증 스크립트·매트릭스 추가.
- 로컬 Windows/VM/WinRE 및 실제 Production 재검증은 미완료. 판매/다운로드/자동 복구 해제 조건 불충족. 세부 10항: `products/pc-care/HANDOFF.md`.

## 2026-10-30 KST — USB ZIP 개발 최신화
- `hibi89/AX_MART` / `feature/pc-care-usb`, 이전 SHA `5a0eb2d904c7877a149f04c3f99084ee2a1ed0e3`, 소스 `products/pc-care/`.
- 내부 시험 패키징 도구 `tools/release.py` 및 `tests/test_release.py` 추가. REPORTS 자동 제외 및 무결성 검사, Linux fixture 6/6 PASS.
- Windows 10/11/WinRE·수리 실증 미검증, Cloudflare main과 배포 파일 미수정. 다음은 Windows 실기기/VM 확인 후 출시에 대한 별도 판단.

## 2026-10-30 KST — 새 채팅/테스트 인수인계 확정
- 대상 `hibi89/AX_MART` / `feature/pc-care-usb`; 변경 전 소스 SHA `9a0edbdc33d36a02af11552e8f2cb95e8176651a`. 관련 변경은 `products/pc-care/`에 저장, Cloudflare `main` 변경 없음.
- 구현: 실제 보고서에 디스크 상태·일부 SMART 표시·BugCheck 상세 추가, 승인형 수리 fail-closed, WinRE 로그 개선, 내부 ZIP/무결성/개인정보 제외, 초보자 `RUN_SELF_TEST.cmd` 제공.
- 검증: Python 임시 fixture 패키징 테스트 6/6 PASS, GitHub 소스 조건 17/17 확인; Windows 런타임·BSOD 원인 검증·WinRE·수리·배포는 미검증. 코드가 있어도 무료 공개/판매 불가.
- 다음: Windows 실제 PC에서 `RUN_SELF_TEST.cmd`를 실행해 화면 종료 코드 확인(고객의 원본 리포트 외부 공유 금지) → 문제 보정 → WinRE/BitLocker 및 별도 스냅샷 복구 VM에서 승인형 수리 검증 → 최종 릴리스 승인.
- 보안: 제품 ZIP은 내부 시험용이며 공개 링크 없음. 원본 보존·로그 로컬, ZIP 결정적 허용 목록. KST 기준 2026-10-30.

## 2026-10-30 KST — 네이밍 주의
- 플랫폼 AXMART³ (CUBE) / 제품 AXMART PC CARE. 제품 코드와 내부 USB ZIP 명명은 호환성 때문에 유지. 실사용 검증 전 상품 판매/배포 차단.

## 2026-10-30 KST — AXMART PC CARE 통합 스펙 v2.0 확정
- 상세 요구사항과 기능 범위는 products/pc-care/docs/FINAL_SPEC_V2.md를 기준으로 한다. Gemini 제안 두 개 결합: HEALTH, ANALYZE, REPORT(1페이지/PDF/QR), RESCUE(WinRE 조건부 파일 백업), RECOVER.
- Release A(진단+보고서+WinRE 읽기전용)와 Release B(복사 안전 검증 통과 후)를 분리. BitLocker 자동 해제·무인 전체 파일복사·DDU 자동화·하드웨어/사기판단 보증 금지.
- 이번 턴은 사양만 기록, 기존 Windows 코드 변경/테스트/홈페이지 판매 개시는 수행하지 않았다.

## 2026-10-30 KST (PC CARE 메뉴 구현, 실기기 미검증) — feature 브랜치 인수인계
- AXMART³ Production은 `main`/`https://ax-mart.pages.dev/` 불변. AXMART PC CARE는 `feature/pc-care-usb`, 변경 전 SHA `92294f15486e63d08c4b707024c0409779e1ba92`.
- `products/pc-care/START_PC_CARE.cmd` 시작 메뉴(진단/자가검사/로컬 보고서 위치/안전 안내/종료), 시험 ZIP allowlist 및 회귀 테스트 추가. 자동 수리, 관리자 상승, 삭제, 외부 통신 연결 금지 유지.
- 코드 정적 계약 점검. Windows CMD·PS5.1, USB 경로, Python unittest, QR 실제 스캔/A4 출력, WinRE/VM 복구 실행 **미검증**. GitHub Actions runner 미배정 문제는 재시도하지 않고 기록 유지.
- 다음: Windows11 사용자 환경에서 메뉴/읽기 전용 보고서·QR/PDF 실검증, 별도 격리 VM 복구 시험 및 정식 출시 승인. 제품 상세 `products/pc-care/HANDOFF.md`/STATUS 참조. 기존 제품 기능 SHA `92294f1` 복구점.

## 2026-10-30 KST — P0 원자적 신규 파일 생성·타 실행 결과 보존 — 최상위 인수인계
- PC CARE 보고서 JSON/HTML 저장기에 원자적 신규 파일 생성(FileMode.CreateNew)·기존 파일 덮어쓰기 방지·본 실행 소유 파일만 정리 로직 추가, synthetic fixture·정적 테스트·제품 문서 동기화.
- 대상 `hibi89/AX_MART` `feature/pc-care-usb`, 시작 SHA `9087a3bc3b72c14e3b8730d6f4709b9dbdc50056`, Cloudflare `main`/사이트 변경 없음.
- 실제 Windows/PowerShell5.1/경합 스트레스/USB/WinRE/QR·A4 PDF **미검증**. 이전 runner 미배정 실패 재시도 금지. 신뢰 가능한 Windows 시험 후 Beta 재평가.

## 2026-10-30 KST — PC CARE 자가검사 실제 저장 경로 receipt 인계
- feature 브랜치 `feature/pc-care-usb`, 변경 전 SHA `3da0c5bb236064328e1c506143a48ce9f20dadea`. `tools/diagnose.ps1`는 `-PassThru/-NoOpenReport`을, `tests/windows_smoke.ps1`는 반환된 파일 경로 직접 검증을 사용. 타 실행 최신 리포트를 오인하는 경합 완화.
- 일반 실행기, 기존 JSON/HTML 내용, 관리자 수리, 사이트 운영 main 소스 변경 없음. 정적 회귀 소스 갱신, 실제 Windows·동시성·QR·PDF/WinRE와 전체 CI **미검증**. 무료 공개/판매 계속 차단.

## 2026-10-30 KST — 자가검사 receipt 블록 구문 복구
- 이전 2c83634 커밋의 windows_smoke.ps1에 중복된 JSON 검사와 잘린 정규식 문장이 발견되어 정상 실행을 방해할 위험이 있었다. 해당 블록을 단일 유효 구조로 교체, [.]json filename 매칭 및 경로/파일 검증 보강, 정적 테스트 동기화.
- 실제 Windows PowerShell 5.1 실행·VM/USB/WinRE/QR/A4 검증 여전히 대기. 2c83634 이전 소스 기준 복구 가능. 운영 main/Cloudflare 미변경.

## 2026-10-30 KST — PC CARE P0 증거 검증 인수인계
- `hibi89/AX_MART` `feature/pc-care-usb`, 기준 e39f345a88d8f03d3cfb1432ca7cee0e2b9b9dc3. 1001/41/6008/스토리지 공급자 이름 앵커 allowlist, root JSON schemaVersion=1, synthetic spoofed providers 5개 및 Python/Windows smoke 관련 소스 추가.
- 오작동 커밋 a7b6c4d는 JS replace의 $ 특수 치환으로 인해 원격 코드 손상, 즉시 e39f345 롤백 완료. 새 소스는 함수형 치환과 Base64 blob readback 검증. 동일 오류 방식 금지.
- 운영 `main`, Cloudflare https://ax-mart.pages.dev/, 무료/유료 다운로드 및 수리 코드 불변. Windows PowerShell5.1/USB/OEM 공급자·QR/A4 PDF·WinRE/전체 테스트 미검증. 제품 상세 `products/pc-care/HANDOFF.md` 및 STATUS.md 기준.

## 2026-10-30 KST — H08 Node 실제 검증/비동기 안전성 인계
- 저장소/브랜치: hibi89/AX_MART feature/pc-care-usb, 시작 SHA `518413d3def107633b1215eeddf5f30be067e4e8`. H08 `ui/history_compare.js` 읽는 중 파일 선택 변경 시 stale 결과/오류 무시(`selectionRevision`), `tests/test_history_dom.cjs` 가상 DOM 5개 새로 추가, 수동 CI·정적 테스트 갱신.
- 검증: GitHub 소스 blob SHA와 로컬 복제본 일치. Linux Node v22.16.0 `node --test tests/test_history_compare.cjs tests/test_history_dom.cjs` **14 PASS, 0 FAIL**. Chromium 144 file:// 및 localhost 모두 환경 관리자 정책 `ERR_BLOCKED_BY_ADMINISTRATOR`: 실제 브라우저 결과 불명, 접근 우회 금지.
- Production https://ax-mart.pages.dev/ main 불변/기능 배포 미적용, 사용자 시스템/원본 리포트 수정·삭제 없음. 실제 Windows Edge/Chrome 파일 선택/USB, PowerShell5.1, QR 스캔/A4, WinRE 미검증. 새 H08 자동 저장·삭제 미구현, 무료/유료 출시 차단. 상세 products/pc-care/HANDOFF.md 최신 단락 참고.

## 2026-10-30 KST — PC CARE H08 증거 누락 fail-closed 인계
- 저장소 `hibi89/AX_MART`, 브랜치 `feature/pc-care-usb`, 이전 SHA `712db3ab8d70dda8f3ad61604668747d816dcb98`. H08 JSON 비교에서 `issues` 미수집과 `physicalDisks` 누락/빈배열/조회 실패/수량 변경을 '경고 없음' 아닌 비교 불가로 처리. 사용자 개인정보 수집·원본 저장·무인 삭제/수리 추가하지 않음.
- Linux Node 22 실제 단위 및 가상 DOM 테스트 **18 PASS/0 FAIL**, 소스 SHA `56ecd3f0`, 회귀 `d94edc31`/`958b5a68`. 증빙 `products/pc-care/tests/evidence/history_fail_closed_qa_20261030.json`. Windows/USB/WinRE/QR/A4/브라우저 실제 환경과 전체 Python/ZIP 미검증, Cloudflare main 무변경, 공개/판매 차단.
- 다음은 사용자 Windows 11 표준권한 진단/Edge file:// 로컬 두 보고서 비교/USB 한글 경로·네트워크 0 검사; 이후 QR/A4/VM WinRE 별도 게이트. 상세 제품 `products/pc-care/HANDOFF.md` / STATUS 기준.

## 2026-10-30 22:27 KST — PC CARE H08 브라우저 날짜 안전성 인수인계
- 저장소 `hibi89/AX_MART`, 브랜치 `feature/pc-care-usb`, 기준 SHA `4af8e8b0ffaccf78fb5d90898d19017d8b8c9dc7`. HTML 로컬 두-JSON 비교 JS에서 PowerShell `yyyy-MM-dd HH:mm:ss zzz`을 캘린더/시차 엄격 검사, 임의 `assessment` 텍스트는 허용 상태 외 `확인 불가`. 기존 수동 파일 선택·조회 상태 차단·경합 가드 유지.
- Git 원본과 로컬 SHA 일치한 Node 22 `node --check` + `node --test tests/test_history_compare.cjs tests/test_history_dom.cjs` **22 PASS/0 FAIL**, 테스트 증빙 `products/pc-care/tests/evidence/history_date_offset_qa_20261030.json`. 실 Windows PowerShell 5.1, 브라우저 file://, USB, QR 스캔/A4, WinRE, 내부 ZIP/전체 Python 미검증.
- 복구는 baseline feature HEAD로 가능. 생산 `main`·Cloudflare `https://ax-mart.pages.dev/` 미수정, 코드 서명/정식 출시 미승인, 고객 데이터 저장/전송·자동 수리/삭제 없음. 다음은 Windows 현장 읽기진단 및 H08 실브라우저 검증, 이어 QR/A4/USB/WinRE 안전 QA. 상세 인계는 `products/pc-care/HANDOFF.md` 기준.

## 2026-10-30 KST — AXMART CUBE 총괄 H08 핵심 변화 비교 기능 인수인계
- 저장소 `hibi89/AX_MART`, 기능 브랜치 `feature/pc-care-usb`, 변경 전 SHA `04d9979b89739c4dfaad336875489aaeca9b02c3`. 운영 main/Cloudflare 불변.
- 구현: `ui/history_signals.js`를 `history_compare.js/html`에 연결. 양쪽 JSON의 Windows 빌드, 동일 이동 조회기간의 WindowsUpdateClient 19/20 설치 실패 건수, PnP 구성 코드 관측 개수. 사용자 파일 자동 검색·삭제·계정·네트워크·추가 Windows 권한 없음. 불완전 데이터·캡·상태 불일치는 비교 불가.
- 검증: Linux Node v22.16.0 `node --test tests/test_history_signals.cjs` **7/7 PASS**. 기존 compareReports와 new module을 GitHub 소스로 결합한 순수 V8 통합 합성 PASS. 새 JS 원본 Blob `f4d47bd2f0bb9850019b0fd3feb81a0dfd50c1fe`, 테스트 Blob `5b0d3a4db182314371c56d0aa9fcc0db2426a316` 및 Blob readback 확인. 이전 22개 Node 회귀 테스트는 이 변경에 대해 **재실행하지 않음**.
- CI: workflow_dispatch-only `.github/workflows/pc-care-windows-synthetic.yml`에 새 Node 테스트 등록. 기존 Actions 41034866482는 failed/테스트 단계·runner 기록 없음. GitHub 연결에 신규 workflow dispatch 권한·도구가 없어 **이번 CI 실행 미수행**, 성공이라 표기 금지. 불필요한 기존 실패 러너 재시도 금지.
- 검증 대기: 전체 Python/ZIP, Windows PS5.1/11, Edge/Chrome file:// USB, QR 실제 스캔/A4 PDF, WinRE VM/복구. 제품별 `products/pc-care/HANDOFF.md` 참조. 사용자 승인 없는 공개 다운로드·유료 판매 금지.

## 2026-10-30 KST — H08 일괄 검사 기록 선택 / 빠른 기능 묶음 인수인계
- 목표: AXMART PC CARE Release A H08 반복 진단 사용성 확보. 저장소 `hibi89/AX_MART`, `feature/pc-care-usb`, 시작 SHA `b64635b25355963544303acd803c73f78db31d07`.
- 구현: `ui/history_compare.html/js`에서 수동 최대 25개·총 12MB(각 2MB) JSON 일괄 선택, 날짜순 허용 상태명만 표시, 과거/현재 드롭다운 선택 후 기존 비교 버튼. 실패 batch 전체 거부, stale 비동기 응답 폐기, 개별 2파일 방식 보존. 자동 파일검색·저장·삭제·외부 업로드 없음.
- 실행 검증: Linux Node v22.16.0 `node --check ui/history_compare.js && node --test tests/test_history_*.cjs` **37 PASS, 0 FAIL**, git blob SHA `f5e7a98438aaf37b22ae30196c02ed013c72c526` JS/`c4c68175819b3bee2589baf372e3ffe5a9cceabd` HTML/`c70dd298f9515ca603243745e43ca3059412c802` 테스트. 증빙 `products/pc-care/tests/evidence/h08_batch_history_qa_20261030.json`.
- CI/배포: 수동 Windows workflow에 batch Node fixture 등록, 원격 신규 CI 실행은 연결 도구에 dispatch 없음; 이전 runner 실패 41034866482 반복 재시도 안 함. Production https://ax-mart.pages.dev/ main 미변경·기능 배포 미적용.
- 차단·다음: 실제 Windows PS5.1 진단 JSON 생성 및 Edge file:// 실제 batch 입력/USB 한글 경로/QR A4/WinRE 검증 필요. H08 자동 보관·삭제 기능 미구현. 고객 파일/BitLocker/수리 설정 불변, 강제 푸시 금지. 출시·유료 판매 사용자 승인 전 금지.

## 2026-10-30 — AXMART CUBE 병렬 QA 인수인계
- 목표/기술: PC CARE 기능 유지, 개발 QA 가속. Python/Node/임시 ZIP 병렬.
- 완료: `tools/preflight.py`, `tests/test_preflight.py`, CI ZIP 확인 단계·안전 테스트.
- 검증: Python 전용 4 PASS/0 FAIL 및 구문 PASS. 전체 suite·실 ZIP·CI·Windows 미실행.
- 대기/원인: 비공개 전체 원본 로컬 미확보. 이전 Actions 41034866482 실패, 재실행 반복 금지.
- 저장소: `hibi89/AX_MART`, `feature/pc-care-usb`, 복구 SHA `de5da50f851bfd18b75e9e78fa8b7dceef380f3d`.
- 운영: `https://ax-mart.pages.dev/` 기존 main 불변; 개발 실행 `python tools/preflight.py`.
- 보존: 고객 보고서·수리·WinRE 및 공개 배포 불변, QA 실행기 제품 ZIP 제외.
- 다음: 전체 소스 있는 PC에서 통합 QA 후 Windows/USB/QR/A4/WinRE 테스트 및 출시 승인.
- 2026-10-30 KST 기준 범위: 로컬 QA 전용 테스트만 확인, 나머지 미검증.

## 2026-10-30 — AXMART CUBE H08 인쇄 지원 인계
- 목적/기술: PC CARE Release A 반복 진단 비교 결과를 오프라인 브라우저 A4 인쇄/PDF로 전달. 기존 보고서·복구 원칙은 변경하지 않음.
- 구현: `ui/history_print.js` 순수 요약기, `ui/history_compare.html/js` 인쇄 버튼(성공한 비교에서만 활성), 인쇄 전용 DOM/CSS, 파일 변경 즉시 초기화. 파일명·경로·시리얼·원본 이벤트 제외. `tools/release.py` ZIP allowlist, `tools/preflight.py`/Windows CI Node 테스트, README·정적 테스트 갱신.
- 실제 검증: GitHub 원본 V8 통합 6/6 PASS, 신규 `tests/test_history_print.cjs`의 9개 회귀 시나리오 V8 어댑터 9/9 PASS; 기존 Node 37개/네이티브 Node·전체 Python·ZIP·CI **이번 턴 미실행**. QA 증빙 `tests/evidence/history_print_qa_20261030.json`.
- 상태/오류: 인쇄 내용 보안/명시적 승인 동작 확인, Windows 실제 프린트/A4 PDF 1페이지 검증 전. 이전 CI 41034866482 러너 실패, 신규 dispatch 미지원·재시도 반복 금지.
- 코드 저장소: `hibi89/AX_MART`, `feature/pc-care-usb`, 복구 기준 `2a4a6bef056f9ffb1ba14b10a218d802cb98d9eb`. Cloudflare `https://ax-mart.pages.dev/`와 운영 main 변경 없음. 개인정보 파일·수리/WinRE/권한 변경 없음.
- 다음: 실제 Windows 11 표준권한 2회 JSON→Edge USB/file:// 비교→인쇄 PDF 페이지·한글 렌더링→QR 실스캔/WinRE VM→정식 공개 별도 승인. 갱신 2026-10-30 KST, 검증 범위 V8·Git blob, Production 미적용.

## 2026-10-30 KST — AXMART CUBE ZIP 안전 검증 인수인계
- 목적: 기존 PC CARE 기능/비용/품질을 유지하면서 외부 ZIP 검증에서 과다 압축 해제·체크섬 누락·경로 symlink 위험을 차단.
- 구현: `products/pc-care/tools/release.py`에서 manifest/ZIP 엔트리 metadata size/암호화/심볼릭 링크 검사 후 제한된 읽기 및 CRC+manifest 검증; ZIP SHA streaming; 명시적 `--verify`에 sidecar 필수; source 디렉터리 symlink 거부. `tests/test_release.py` 신규 4개·`tests/test_package.py` 정적 1개·QA 증빙·문서 갱신.
- 테스트: GitHub 소스 H08 5개 JS suite **46/46 V8 호환 실행 통과**, 로컬 Python 3.13.5 별도 ZIP 안전 알고리즘 **5/5 통과**. 전체 GitHub 저장소 Python/네이티브 Node/실제 ZIP·Windows CI는 **미검증**.
- 문제/대안: ZIP 검증기가 `testzip()`으로 크기 검증 전 전체 해제하던 위험을 제거; 외부 ZIP metadata 상한 우선. CI 과거 `41034866482` 테스트 단계 실패, 신규 dispatch 도구 없음, 동일 실패 반복 금지. 전체 소스가 있는 Windows 개발기/runner에서 `python tools/preflight.py`로 일괄 회귀.
- GitHub: `hibi89/AX_MART` `feature/pc-care-usb`, 기준 `a7bfc292fff36b4088698fb82440397cd7538388`; 운영 main과 `https://ax-mart.pages.dev/` 그대로, 제품 배포 미적용. Git 기존 SHA로 복구, force push 금지.
- 데이터·안전: 실제 고객 데이터/REPORTS/Windows 설정/수리/WinRE와 비밀정보 불변; 내부 시험용 ZIP만 테스트, 자동 공개 불가.
- 다음: 네이티브 Python 전체 회귀+실제 내부 ZIP 생성/재검증, Node QA → Windows 11 기본 진단/한글 USB/Edge file://·QR 실스캔/A4 PDF→WinRE VM, 출시 전 별도 승인.
- 갱신 2026-10-30 KST. 이번 검증은 V8 호환 JS + 로컬 ZIP 알고리즘만. 커밋 후 최종 SHA 확인.

## 2026-10-30 — AXMART CUBE WinRE Rescue 준비 단계 인수인계
- 목표/기술: Release B WinRE 비상 파일 백업의 첫 안전 상태 확인. CMD 기반 오프라인 프리뷰로 PowerShell·Python 요구 없음. 검증 전 파일 복사 사용 금지.
- 구현: `products/pc-care/recovery/RESCUE_READINESS.cmd`(WinRE 드라이브 후보·robocopy/manage-bde 파일 존재만 조사, 사용자 이름/파일내용/비밀번호 미수집, 종료 3 BLOCKED), 기존 `WINRE_READ_ONLY.cmd`에서 별도 실행 안내만, ZIP allowlist·정적 안전 테스트·README/SAFETY/QA 갱신. 상태기계의 물리디스크·BitLocker·용량·FAT32·검증 단계는 모두 미검증 표시.
- 테스트: Linux Python 3.13.5 `python -m unittest discover -s /mnt/data/axmart_rescue/tests -p test_rescue_readiness.py -v` **4/4 PASS**, py_compile PASS. 로컬 파일 SHA `b3f3bc7c1b2cc049381f1f6b3c27061a2c038106` CMD, `f205d6ca625f7eacb5e5916123ae3af9e8bc0315` Python 테스트가 Git Blob과 일치. GitHub 전체 Python/Node/ZIP·실 CMD·WinRE 미실행.
- 상태: Release B 프리뷰 정적 계약만 구현, **실제 백업·사후 해시·전원중단·BitLocker/다중 디스크 테스트 미구현·미검증**. 공개 금지. 설계 대안: PS5.1 기반은 WinRE 기본 탑재 미보장, CMD 접근만 선행; 물리 분리 증명 불가면 복사 절대 금지.
- GitHub: `hibi89/AX_MART` `feature/pc-care-usb`, 변경 전 `b1ab5de8c4274b9b699fdc886a5b4d911c95ed9a`(복원 가능). Production `https://ax-mart.pages.dev/` main 불변. Git commit author/committer 신원·remote SHA 및 CI 마지막 실행 별도 확인.
- 다음: Windows 11 VM/WinRE에서 이 스크립트의 탐지·종료 3 확인, 무단 쓰기·명령 실행 0회; 물리적으로 다른 장치 증명, FAT32·BitLocker·EFS/OneDrive·용량·USB 중단 테스트. 보안/실기기 전체 통과 전 실제 복사 코드를 패키징/노출하지 않는다. 고객 데이터/BitLocker 키/시스템 설정 미변경. 2026-10-30 KST, 실제 테스트 4개는 구조적 Python QA만.

## 2026-10-31 — AXMART CUBE 상담표 fail-closed 업데이트 인수인계
- 목표: PC CARE Release A 진단 상담표의 과도한 정상 표시/로그 출처 오인 방지; 설계/라이선스/출시 기준 불변.
- 완료: `products/pc-care/tools/consultation_report.ps1` 저장장치 정상 표시에 전체 수집 상태 필수, 경고 보존·불확실성 고지; System/Windows Update 수집 실패·비매칭 로그 미표시. `tests/consultation_report.tests.ps1` 상태변형 합성 테스트 10개 신규, 기존 오류 기대값 교정, `tests/test_package.py` 정적 계약 추가.
- 테스트: 현재 GitHub Blob에 대한 V8 소스 안전 계약 7/7 PASS. Windows PowerShell 5.1 합성 픽스처, Python 전체/ZIP, CI·실기기 모두 미실행/미검증. 과거 runner 41034866482 실패 반복 재시도 금지.
- Repo: `hibi89/AX_MART`, `feature/pc-care-usb`, 복원 기준 `ad392a6d646f1e104c9ed20ba32ad43d26ed73c5`; QA `products/pc-care/tests/evidence/consultation_provenance_qa_20261031.json`.
- 서비스: `https://ax-mart.pages.dev/` main/Cloudflare 무변경·미배포. 고객 REPORTS/개인 파일/BitLocker/WinRE/수리 수정 없음.
- 다음: Windows 11 PowerShell 5.1 `tests/windows_smoke.ps1` 기본 합성 실행 → 전체 Python·Node·ZIP → 실제 표준 권한 진단 및 보고서 UI/USB/QR/PDF 검증 → Release B 별도 안전 승인. 확인일 2026-10-31 KST. 완료 판정 금지.

## 2026-10-31 KST — AXMART CUBE H08 개인정보 안전성 개선 인계
1. 목표: Release A JSON 비교 결과와 A4/PDF에 임의 대문자 코드가 그대로 노출되는 문제 차단; 오프라인 진단 기능 유지.
2. 완료: `products/pc-care/ui/history_compare.js`·`ui/history_print.js`의 경고코드를 실제 `diagnose.ps1` 생성 8종으로 제한, 알 수 없는 값은 ‘비교 불가’로 fail-closed. 새 8개 Node 테스트와 기존 인쇄 1개 기대값 수정, Python whitelist 일치 계약, 개발 QA/Windows CI 목록 등록.
3. 테스트: 로컬 원본 SHA 동일 Linux Node22 `node --test tests/test_history_*.cjs` **45 PASS/0 FAIL** + 구문 검사; V8 기존 인쇄 포함 총 **54 PASS/0 FAIL**, 진단기 소스 목록 대조 8/8. 전체 Python·ZIP·PowerShell5.1·Windows CI는 미실행.
4. 상태: H08 비교·인쇄 코드 개선 완료, Windows USB/QR/A4 실제 확인 전 제품 미완료. WinRE 복사 비활성.
5. 오류·원인/대안: 대문자 정규식만 허용하던 로직에서 공격자가 임의 코드로 식별정보를 표시 가능. allowlist 및 비교 불가 처리로 수정. 기존 Windows CI run 41034866482 runner 전 단계 실패, 동일 실행 반복 금지. 실제 Windows runner 가용 시 재검증.
6. Git: `hibi89/AX_MART`, `feature/pc-care-usb`, 이전 복구 SHA `6db12369123a2902e55aad84809ee6ab5dc0c94d`. 새 `tests/test_history_issue_allowlist.cjs`, `tests/evidence/h08_issue_allowlist_qa_20261031.json` 및 기존 source/tests/docs.
7. Production: Cloudflare `https://ax-mart.pages.dev/`, main `fbb32362455378b85bcdd0b5037d1f338055fb71`, 기능 브랜치 개발 상태·미배포. 개발 `node --test tests/test_history_*.cjs`.
8. 보안/백업: 고객 파일·REPORTS/WinRE/BitLocker/복구 기능 변경 없음, Git SHA 복구 가능; 외부 API 비용·전송 없음, 승인 없는 제품 출시/판매 금지.
9. 다음 작업/완료 조건: 전체 Python·내부 ZIP 검증, Windows 11 PowerShell5.1 합성 → USB 한글 경로·Edge file://·QR 실스캔·A4 PDF 인쇄 → WinRE VM 및 소스/대상 물리 디스크 분리 증명. 물리 분리 확인 전 실제 복사 코드 노출 금지.
10. 갱신: 2026-10-31 KST, 네이티브 Node 45/45·V8 54/54·정적 계약 8/8 검증만 완료. Windows/CI/Production 미검증, 최종 feature SHA 푸시 후 확인.

## 2026-10-31 KST — AXMART PC CARE native Python packaging validation
- GitHub feature baseline 728e5d96b36cc29e29c0057c0af758bc3da32dda. Four Git-blob-identical sources: tools/release.py, tests/test_release.py, tools/preflight.py, tests/test_preflight.py. Executed Python 3.13.5 unittest discover natively on Linux: **16 PASS, 0 FAIL, 0 SKIP** (12 release, 4 preflight).
- The actual remote repository tree has all 37 package allowlist members (none missing, empty or above 5MB; total 235361 bytes). All 20 PowerShell files in the allowlist have valid UTF-8 BOM.
- Synthetic source fixture used to create and verify ZIP, not a full original production ZIP build. Full repo Python/Node, Windows 11/PS5.1, Edge file://, USB, QR, A4, WinRE, CI and Production remain **UNVERIFIED**. No customer files or repair commands accessed.
- Evidence: products/pc-care/tests/evidence/native_package_preflight_qa_20261031.json. No changes to public main/Cloudflare; WinRE backup copying remains blocked.

## [2026-10-31 KST] Native packaging QA handoff (10 requirements)
1. Goal/technology: Validate Release A internal-only ZIP packaging with actual Python 3.13.5 rather than synthetic JS simulation.
2. Done/why: Retrieved four source files from GitHub branch at exact Git blob SHA, rebuilt sources byte for byte, ran native unit suites. Product code left intact.
3. Tests: python -m unittest discover -s tests -p 'test_*.py' -v => 16 PASS, 0 FAIL, 0 SKIP. GitHub tree 37/37 ZIP allowlist present, 20/20 PowerShell UTF-8 BOM.
4. Status: Unit-test verified; full actual-source ZIP and native Windows workflow remain pending.
5. Failure/alternative: git clone blocked by DNS; used GitHub connector per-file retrieval, Git blob verification, local native Python. Do not rerun old failed Actions 41034866482 without environment fix.
6. Repo/branch/SHA: hibi89/AX_MART, feature/pc-care-usb, source benchmark 728e5d96b36cc29e29c0057c0af758bc3da32dda. Evidence at products/pc-care/tests/evidence/native_package_preflight_qa_20261031.json.
7. Production/runtime: https://ax-mart.pages.dev/ main fbb32362455378b85bcdd0b5037d1f338055fb71 unchanged. Linux Python 3.13.5 unit QA only.
8. Preservation: No user REPORTS, system settings, BitLocker, repair/WinRE, secrets, public deployment or billing modified; previous feature commit is rollback source.
9. Next: Actual full repository Python/Node and ZIP build/verify in available PC/runner, then Windows PS5.1 + USB/Edge/QR/A4 validation; Release B physical disk identity and WinRE VM needed before any real copy or release.
10. Checked at 2026-10-31 KST: 16 native unit tests + source inventory/BOM checks verified, all real Windows/production checks unverified; confirm updated SHA after push.

## [2026-10-31 KST] AXMART CUBE incident evidence provenance handoff
1. **Objective/architecture:** Make Release A read-only incident interpretation fail closed for collection errors while preserving offline PowerShell 5.1 report contract and historical finding names.
2. **Implemented/decision:** `tools/incident_analysis.ps1` accepts optional `DiskCollectionStatus`, requires collected/truncated provenance for System events, Update events and PnP samples; unreadable/no-match arrays not used as incident observations. `tools/diagnose.ps1` passes Safe-Collect physical disk status. Incomplete inventory is flagged; actual observed disk warning retained with caveat.
3. **Tests:** New 15 PowerShell synthetic assertions in `tests/incident_analysis.tests.ps1`, 1 Python static package-contract method. Executed GitHub-source V8 static checks **12/12 + final 10/10 PASS**. Native PowerShell 5.1/whole Python suite/real ZIP/CI NOT RUN, do not claim feature runtime acceptance.
4. **Status:** Source and fixtures updated; real Windows runtime verification waiting. Release A and B product release gates not passed; Release B backup copy disabled.
5. **Failure/alternatives:** Previously stale incident/update/PnP arrays could contribute to findings during unavailable/no-match status. Fixed provenance guards. Old GitHub CI run `41034866482` failed before test steps; avoid no-op retries. Validate in real Windows PS5.1 runner or local VM when available; browser/USB checks separate.
6. **Repo/branch/SHA/paths:** `hibi89/AX_MART` / `feature/pc-care-usb`, starting SHA `3ef198b3266e7da7382db8fe9a36a4cccedbc5b7`. `products/pc-care/tools/incident_analysis.ps1`, `tools/diagnose.ps1`, `tests/incident_analysis.tests.ps1`, `tests/test_package.py`, `tests/evidence/incident_provenance_qa_20261031.json`.
7. **Production/runtime:** `https://ax-mart.pages.dev/` main unchanged, this branch not released. Native PS5.1 acceptance command: `powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File tests/windows_smoke.ps1` from product folder. Source inspection is not Win11 verification.
8. **Originals/backups/security:** No customer REPORTS, BitLocker settings, device data, WinRE scripts, OS repairs, secrets or production code changed. Git source SHA is rollback point, no force push.
9. **Next/criteria/approvals:** Real PS5.1 synthetic regression -> all Python/Node/real product ZIP QA -> Windows/USB Unicode/QR camera/A4 PDF -> separate WinRE/physical-disk gate. Never enable actual backup copy until independent media proof and user approval; no public or paid release without acceptance.
10. **Updated/checkpoint:** 2026-10-31 KST, exact remote source static checks 22, native PowerShell/CI/Windows/Production unverified. Verify GitHub final HEAD after push.
