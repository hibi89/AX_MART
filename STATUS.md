# AXMART 현황 — 2026-10-30 KST

## 완료
- GitHub 기존 index.html의 다크 해커 디자인 원본 보존.
- Cloudflare Pages 무의존성 Build npm run build, dist/index.html 복사 및 _headers 보안 헤더 추가.
- Node 22.16.0: npm test **PASS 1/1**, npm run build **PASS**, 결과 파일 104,502 bytes(로컬 기준).
- Playwright Chromium 직접 HTML 주입 테스트 PASS: 상품 5개, 필터 1개, 상세 모달, 검색 결과 1개, 390px 모바일 메뉴 및 가로 넘침 0, JS 오류 0.
- CLOUDFLARE_DEPLOY.md 절차 문서화. 예시 상품 가격 실제 판매 아님.

## 미완료·차단
- Cloudflare Pages 계정/저장소 연결 가능 도구 없음. 사용자의 1회 OAuth 승인·대시보드 Git import 필요.
- 희망 ax-mart.pages.dev는 **미할당/미검증**. 실제 Production URL, Cloudflare 배포 SHA, HTTPS·브라우저 기능은 미검증.
- localhost 브라우저 직접 접근은 관리자 네트워크 정책 차단으로 HTML 직접 주입으로 전환하여 검증. 로컬 HTTP 확인은 미검증.
- 실제 결제·로그인·DB·SMAX² 연동 미적용.

## 소스
- repo: hibi89/AX_MART, branch main; 이전 기준 HEAD f4cbf5b3c3c1e609af18c0d368ea5b98cea7caa9.
- Cloudflare 배포 기준 커밋은 본 변경 커밋 SHA (GitHub 결과 확인).

## 배포 상태 확인 — 2026-10-30 약 14:39 KST
- 사용자 제공 Cloudflare Pages Deployments 화면에서 project **ax-mart**, Production domain **https://ax-mart.pages.dev**, branch **main**, deployed source short SHA **1ad0772** 확인. 녹색 체크 및 자동 배포 Enabled 표시. 사용자 화면 기준 빌드와 배포 완료.
- 이 상태는 위의 'Cloudflare 미연동/주소 미할당' 기록보다 최신이며 해당 차단을 **해소**한 상태임.
- 외부에서 https://ax-mart.pages.dev 요청 시도했으나 웹 접근 및 실행환경 DNS 제한으로 본문/정적 자산 HTTP 응답 검증 불가. 따라서 Production 페이지 UI/Console/Network/익명 접속은 **미검증**. Cloudflare 녹색 상태만으로 서비스 정상 판정하지 않음.
- 다음: 실제 URL을 사용자 브라우저에서 열어 시각적 화면·이미지·검색·필터 확인, 가능하면 독립 HTTP/브라우저 검사. 결제·로그인·DB·SMAX² 연동은 미구현 유지.
- 확인 근거: 사용자 업로드 Cloudflare Deployment 대시보드 화면(2026-10-30 KST). 배포 기준 GitHub SHA는 기존 `1ad0772` (화면에는 7자 단축).


## Production 실서비스 화면 확인 — 2026-10-30 14:43 KST (최신)
- 사용자 실제 Chrome 화면에서 `https://ax-mart.pages.dev/?utm_source=chatgpt.com#top` 접속, AXMART 헤더/네비게이션/히어로 텍스트/네온 다크 디자인/후드 해커 이미지/첫 상품 섹션이 정상 렌더링된 것을 시각적으로 확인. 이전 'Production 렌더링 미검증' 표기는 이 최신 결과로 **메인 데스크톱 화면에 한하여 해소**.
- 연결된 Browser 읽기 기능으로 같은 공개 탭 제목 `AXMART — 수상할 정도로 일을 잘하는 도구들`, 5개 예시 상품과 카테고리, 특징·사용법·가격·푸터, 데모 장바구니 및 실제 거래 미지원 공지를 텍스트상 확인. 해당 기능 버튼을 실제 클릭하거나 결제를 수행한 것은 아님.
- Cloudflare Deployment 대시보드 앞선 확인: `ax-mart` / Production / `main` / 소스 SHA `1ad0772` / 자동 배포 활성화 / 녹색 상태.
- 아직 미검증: 독립 HTTP/정적 파일 응답, 페이지 모든 이미지·반응형 모바일 실서비스 브라우저, Console/Network, 인터랙션 실제 클릭, 외부 익명 사용자 접속. 별도 웹 수집기에서는 URL 접근 실패했으나 사용자 Chrome 정상 노출 확인으로 사이트 장애로 판단하지 않음.
- 백엔드·회원가입·결제·실상품은 미구현. 문서 업데이트는 정상 기능 소스 `index.html` 변경 없이 수행.


## 2026-10-30 실상품 정책 변경 및 배포 대기
- 사용자 확정: 가상 상품 5개·예시 가격·장바구니/로그인 모형 제거, 실제 코드가 있는 프로젝트만 노출.
- 첫 프로젝트: **AXMART PC CARE USB v0.1-alpha**, 상태 **개발 중/Windows 실기기 미검증**, **다운로드·결제 미제공**.
- 원본 다크 해커 디자인·제품 검색/분류/상세·모바일 레이아웃 유지. 정적 빌드 가드·회귀 테스트 갱신.
- 제품 안전성: 로컬 Windows 진단/WinRE/수리 실제 작동 **미검증**. 읽기 전용/수리 스크립트 사용 전 실기기 테스트 필요. 자동 수리는 정식 제품으로 주장하지 않음.
- 제품 코드 로컬 작업본은 유료 출시 전까지 비공개 관리, 미검증 무료 ZIP을 사이트에 배포하지 않음.
- 배포 계통: Cloudflare Pages https://ax-mart.pages.dev 자동 배포(main); 새로운 소스 커밋은 별도 GitHub SHA로 확인, 최종 Production 동일 SHA·익명 접근/브라우저 렌더는 추가 확인.
- 이전 정상 Production 소스 복구점: GitHub main 이전 HEAD d37a005354f925b1e261e8c278ca082249e3b8cc.

## 2026-10-30 15:35 KST — PC CARE USB 작업 브랜치
- USB 소스 작업: `feature/pc-care-usb`; 기존 `main` Cloudflare 사이트 수정 없음. PowerShell BOM/이벤트 표시/복구 안전 차단/WinRE 로그 및 테스트 스크립트 보강.
- 제품 세부 근거: `products/pc-care/STATUS.md`, `products/pc-care/HANDOFF.md`; 실제 Windows 검증 전 공개 다운로드·유료 판매 계속 금지.

## 2026-10-30 KST — 제품 브랜치 시험 ZIP 작업
- `feature/pc-care-usb`: 내부 시험 ZIP 제작·검증 파이프라인 및 실제 보고서 세부항목 개선. 제품의 GitHub 소스만 변경.
- `main` Cloudflare 무료 다운로드/유료 결제는 계속 비활성. Windows 실기기 검증 전 상품 공개 금지.

## 2026-10-30 KST — 최종 USB 사용자 검증 준비
- 제품 브랜치에 `RUN_SELF_TEST.cmd` 추가: Windows에서 문법 검사+읽기 전용 1일 진단/HTML·JSON 생성 확인. 설치/서버/수리 작업 없음.
- `tools/release.py` 내부 시험 ZIP 허용 파일 11개+manifest, 보고서 자동 제외, SHA256 무결성 검증.
- 실기기 Windows 10/11, WinRE, BitLocker, 승인형 수리는 **미검증/검증 대기**. `main` 사이트 무료 다운로드는 계속 차단.

## 2026-10-30 KST — 브랜드 정합
- 사이트명 AXMART³, 첫 Windows PC/USB 도구명 AXMART PC CARE로 통일. 본 제품 브랜치는 기존 ZIP/스크립트 경로를 변경하지 않음.

## 2026-10-30 KST — AXMART PC CARE 통합 스펙 v2.0 확정
- 상세 요구사항과 기능 범위는 products/pc-care/docs/FINAL_SPEC_V2.md를 기준으로 한다. Gemini 제안 두 개 결합: HEALTH, ANALYZE, REPORT(1페이지/PDF/QR), RESCUE(WinRE 조건부 파일 백업), RECOVER.
- Release A(진단+보고서+WinRE 읽기전용)와 Release B(복사 안전 검증 통과 후)를 분리. BitLocker 자동 해제·무인 전체 파일복사·DDU 자동화·하드웨어/사기판단 보증 금지.
- 이번 턴은 사양만 기록, 기존 Windows 코드 변경/테스트/홈페이지 판매 개시는 수행하지 않았다.

## 2026-10-30 KST (PC CARE 메뉴 구현, 실기기 미검증) — PC CARE 기능 브랜치
- PC CARE `feature/pc-care-usb`에 `START_PC_CARE.cmd` 비관리자 메뉴 소스 추가. 패키지 allowlist/회귀 테스트 및 제품 문서 업데이트.
- 운영 `main`/Cloudflare 변경 없음, 실제 Windows/WinRE/QR 스캔/인쇄/ZIP 전체 테스트·무료 다운로드·판매 미검증/비활성.
- 변경 전 feature HEAD `92294f15486e63d08c4b707024c0409779e1ba92`, 세부 내용은 `products/pc-care/HANDOFF.md` 참조.

## 2026-10-30 KST — P0 원자적 신규 파일 생성·타 실행 결과 보존 (기능 브랜치만)
- PC CARE `feature/pc-care-usb` 보고서 저장기의 임시 파일 경쟁 조건 수정, 기존 결과 보존 테스트 추가. 최신 코드 확인은 제품 `STATUS.md` 참조.
- `main`/Cloudflare 운영 사이트 미수정. Windows PS5.1/실기기·동시성·QR·USB·WinRE는 검증 대기, 다운로드/유료 판매 차단.
- 변경 전 SHA `9087a3bc3b72c14e3b8730d6f4709b9dbdc50056`.

## 2026-10-30 KST — PC CARE feature 자가검사 경로 결정성 보강
- `feature/pc-care-usb`: 진단 완료 파일 receipt를 직접 사용하도록 Windows 자가검사 변경. 기존 가장 최근 파일 추정 방식 제거, 정적 테스트 추가. 상세 제품 STATUS/HANDOFF 참고.
- 기준 변경 전 SHA `3da0c5bb236064328e1c506143a48ce9f20dadea`, main/Cloudflare/결제/상품 다운로드 불변. 실제 Windows PowerShell5.1·USB/WinRE 및 QR/A4 검증 대기.

## 2026-10-30 KST — 자가검사 receipt 블록 구문 복구
- 이전 2c83634 커밋의 windows_smoke.ps1에 중복된 JSON 검사와 잘린 정규식 문장이 발견되어 정상 실행을 방해할 위험이 있었다. 해당 블록을 단일 유효 구조로 교체, [.]json filename 매칭 및 경로/파일 검증 보강, 정적 테스트 동기화.
- 실제 Windows PowerShell 5.1 실행·VM/USB/WinRE/QR/A4 검증 여전히 대기. 2c83634 이전 소스 기준 복구 가능. 운영 main/Cloudflare 미변경.

## 2026-10-30 KST — PC CARE P0 이벤트 공급자 근거 개선
- feature/pc-care-usb only: ID 1001/41/6008/storage events의 공급자명을 엄격한 allowlist로 제한, 루트 보고서 schemaVersion=1 추가 및 음성 fixture 5개·스모크 검증 강화.
- 이전 잘못된 코드 치환 커밋 a7b6c4d는 롤백 e39f345에서 복구 완료. 새 변경은 Base64 Git blob 읽기 검증 후 반영. Windows PS5.1/USB/QR/A4/WinRE 미검증, main/Cloudflare/판매 미변경.

## 2026-10-30 KST — PC CARE H08 Node 실제 검증 및 경합 수정
- feature/pc-care-usb: 새 이력 비교 UI의 선택 변경 비동기 경합 수정, Node 가상 DOM fixture 5개 추가. 정확한 GitHub JS 원본/fixture SHA를 로컬 Node 22에 확인 후 `node --test tests/test_history_compare.cjs tests/test_history_dom.cjs` 실행 **14/14 PASS**.
- Linux Chromium 144: file://와 localhost 모두 `ERR_BLOCKED_BY_ADMINISTRATOR` 환경 차단. 브라우저/Windows/USB/QR/PDF/WinRE 실기기 동작 미검증; 관리자 정책 우회·동일 환경 재시도 금지.
- 운영 main/Cloudflare 및 수리·원본 데이터 불변; H08 자동 이력 삭제 미구현. 공개/유료 배포 차단. 변경 전 GitHub `518413d3def107633b1215eeddf5f30be067e4e8`; 세부 제품 HANDOFF/STATUS 기록.

## 2026-10-30 KST — PC CARE H08 불완전 데이터 비교 차단
- `feature/pc-care-usb`: 누락된 경고 목록·저장장치 조회 실패·장치 수 변화가 정상/경고 0으로 오인되지 않도록 JS 판정 가드 및 DOM 회귀 보강. 로컬 Node v22 `node --test tests/test_history_compare.cjs tests/test_history_dom.cjs` **18/18 PASS**, GitHub blob·실행 파일 SHA 일치.
- 시작 SHA `712db3ab8d70dda8f3ad61604668747d816dcb98`; 수정 범위 제품 JS/tests/문서 및 QA 증빙만. 운영 main/Cloudflare, 제품 공개·유료 결제/시스템 수리 변경 없음. Windows PS5.1/USB/QR/PDF/WinRE/실제 브라우저 QA 미검증.

## 2026-10-30 22:27 KST — PC CARE H08 엄격한 날짜 검증·민감 출력 최소화
- `feature/pc-care-usb`에서 비표준 브라우저 `Date.parse` 기반 비교를 Windows PS5.1 진단 형식 `yyyy-MM-dd HH:mm:ss zzz`의 캘린더+UTC 오프셋 엄격 검증으로 교체. 유효하지 않은 날짜·시간·시차 및 예상 외 진단 상태 문자열을 fail-closed 처리.
- 개발 환경 Node v22.16.0에서 `node --check`, `node --test tests/test_history_compare.cjs tests/test_history_dom.cjs` **22/22 PASS**, 원격 Git blob SHA=로컬 실행 파일 확인. 제품 문서·회귀/evidence 최신화. Windows/USB/QR/PDF/WinRE 전체 실기기 미검증, H08 자동 이력관리 미구현.
- 운영 main/Cloudflare/사이트/원본 사용자 데이터/수리·WinRE 코드·상품 다운로드/결제 변경 없음. 기준 HEAD `4af8e8b0ffaccf78fb5d90898d19017d8b8c9dc7`.
