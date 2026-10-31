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

## 2026-10-30 KST — AXMART CUBE 총괄 속도 운영 / PC CARE 기능 묶음
- 사용자 요청에 따라 반복 소규모 수정보다 **연관 기능 일괄 개발→Node/정적 검증→안전한 GitHub 커밋→CI 상태 별도 확인**을 원칙으로 채택. CI가 차단 조건이 아니면 다른 개발 계속, runner 미배정 반복 재시도 금지.
- PC CARE `feature/pc-care-usb` 이전 SHA `04d9979b89739c4dfaad336875489aaeca9b02c3`. 기존 진단 JSON을 활용한 H08 추가 비교(Windows 빌드/Windows Update 실패 이벤트/장치 구성 상태) 구현 및 패키지·CI 테스트 등록. Node22 독립 신호 테스트 **7/7 PASS**, GitHub 원본 통합 V8 비교 합성 PASS. Windows CI 새 실행 불가(연결 권한에 dispatch 없음, 이전 런 41034866482는 runner 이전 단계 실패)로 **미실행**.
- 운영 main `fbb32362455378b85bcdd0b5037d1f338055fb71` / Cloudflare https://ax-mart.pages.dev/ 그대로, 실제 Windows/USB/QR/A4/WinRE 미검증. 판매·무료 배포 보류.

## 2026-10-30 KST — PC CARE H08 이력 일괄 선택 개발
- AXMART CUBE 집중 개발: 읽기 전용 JSON을 사용자가 직접 최대 25건(총 12MB) 선택하면 안전한 날짜순 목록에서 과거/현재를 골라 기존 비교 엔진을 사용하도록 H08 UI를 확장. 기존 개별 2파일 선택도 유지.
- Linux Node22 전체 `node --test tests/test_history_*.cjs` **37/37 PASS (기존 29 + 신규 8)**. 일괄 수집 오류/파일명 비노출/총용량·개수 제한/경합·변경 인덱스 회귀 확인. 소스 Blob과 실제 실행 파일 SHA 일치. 증빙 `products/pc-care/tests/evidence/h08_batch_history_qa_20261030.json`.
- 작업 전 feature `b64635b25355963544303acd803c73f78db31d07`. 운영 main `fbb32362455378b85bcdd0b5037d1f338055fb71`, Cloudflare 배포 변경 없음. CI dispatch 권한 도구 없음/과거 runner 실패, Windows·USB·QR/PDF·WinRE·전체 Python/ZIP 미검증; 공개 및 판매 차단.

## 2026-10-30 — AXMART CUBE PC CARE 개발 QA 가속
- `feature/pc-care-usb` 기준 SHA `de5da50f851bfd18b75e9e78fa8b7dceef380f3d`. `tools/preflight.py`로 Python/Node/임시 ZIP 검증 병렬화, Windows CI에 내부 ZIP 확인 단계 추가. 고객 ZIP에는 개발 QA 제외.
- Linux 전용 테스트 `python -m unittest tests.test_preflight -v` **4 PASS, 0 FAIL**, Python 구문 PASS. 전체 원본 Python/Node/ZIP·CI·Windows 실장치 미실행·미검증.
- 운영 main/Cloudflare 및 기존 제품 기능 불변. 공개·판매 승인 보류. 상세 `products/pc-care/HANDOFF.md`.

## 2026-10-30 — PC CARE H08 비교 요약 A4/PDF 인쇄 지원
- `feature/pc-care-usb`(기준 `2a4a6bef056f9ffb1ba14b10a218d802cb98d9eb`) 사용자 화면에 유효한 비교 후만 활성화되는 명시적 인쇄/PDF 버튼과 개인정보 최소 A4 인쇄 요약 구현. 기존 2파일·25파일 비교 기능 유지, 인쇄용 스크립트 ZIP 포함/Node CI·QA 등록.
- V8 통합 6/6, 신규 9개 시나리오 V8 실행 9/9 PASS (Node API adapter, Native Node 미실행). 실제 Windows Edge/Chrome PDF 페이지 수, 이전 37개 Node 전체 회귀, Python/ZIP/CI 및 USB·WinRE·QR 실기기 **미검증**. 운영 main/Cloudflare 변경 없음; 판매·공개 금지 유지.

## 2026-10-30 KST — AXMART CUBE ZIP 검증 안전성 강화
- H08 기존 단위·DOM/인쇄 시나리오를 GitHub 현행 소스 V8 호환 환경에서 **46/46 PASS** 재검증(네이티브 Node/실 브라우저 대체 불가).
- PC CARE 개발용 내부 ZIP 검증기를 수정: 압축 해제 전 member 크기·암호화·symlink·manifest 크기 검사, stream bounded read 및 SHA256 스트리밍, 외부 `--verify`는 sha256 sidecar 필수, 패키지 source parent symlink 차단. 기존 허용 파일 목록/제품 기능 유지.
- 분리 Python 3.13.5 안전성 알고리즘 5/5 PASS; 저장소 신규 회귀 4건 + 정적 1건 추가. 전체 GitHub 원본 Python test_release/실제 ZIP·CI·Windows/USB/QR/PDF/WinRE **미실행**. 운영 main/Cloudflare 불변·공개/판매 금지. 이전 feature `a7bfc292fff36b4088698fb82440397cd7538388`; 자세한 증빙 `products/pc-care/tests/evidence/zip_bounded_security_qa_20261030.json`.

## 2026-10-30 KST — AXMART CUBE Release B WinRE 준비 검사 첫 단계
- `feature/pc-care-usb` 시작 SHA `b1ab5de8c4274b9b699fdc886a5b4d911c95ed9a`. 신규 `recovery/RESCUE_READINESS.cmd`는 접근 가능한 Windows 볼륨 후보/도구 파일 존재만 읽고, 물리 디스크 분리·BitLocker·용량·해시 증명 불가로 항상 종료코드 3 BLOCKED. 파일 복사·삭제·키 입력·로그 기록·설정 변경·수리 없음.
- 동일 기능을 내부 시험 ZIP allowlist·`WINRE_READ_ONLY.cmd`의 별도 수동 사용 안내에 연결. `tests/test_rescue_readiness.py` Linux Python 3.13.5 실제 정적 경계 **4 PASS / 0 FAIL**, Git blob SHA 원본 일치. Windows CMD/WinRE·실제 백업·전체 저장소 Python/Node·내부 ZIP/CI 미실행.
- Release B 실복사는 준비 검사/물리 분리 증명/실기기 안전 QA까지 미활성화. main `fbb32362455378b85bcdd0b5037d1f338055fb71`, Cloudflare Production 불변; 공개/판매 차단. 증빙 `products/pc-care/tests/evidence/rescue_readiness_static_qa_20261030.json`.

## 2026-10-31 KST — PC CARE 상담표 오탐 차단·관측 근거 검증
- `feature/pc-care-usb` 기준 `ad392a6d646f1e104c9ed20ba32ad43d26ed73c5`에서 Release A `consultation_report.ps1`의 수집 근거 검사 강화. 장치 정상 표시에는 `collectionStatus.physicalDisks=collected` + 비어 있지 않은 전체 Healthy 장치 목록 필수. 경고 신호는 수집 불완전해도 표시하되 불확실성 고지. 이벤트/업데이트 `unavailable` 상태의 잔류 로그는 상담표에 포함하지 않음.
- PS 합성 픽스처 `consultation_report.tests.ps1` 기대값 갱신 + 새 10개 안전 Assertion; Python 정적 테스트 계약 갱신. GitHub 원본을 사용한 V8 소스 계약 검사 7/7 PASS, **실제 PowerShell 5.1/Windows/전체 Python/ZIP/CI 미실행**. QA `products/pc-care/tests/evidence/consultation_provenance_qa_20261031.json`.
- Release B WinRE 실제 복사는 물리 디스크 분리 증명과 안전성 실기기 검증 전까지 계속 차단. main/Cloudflare·고객 파일·수리 코드 불변.

## 2026-10-31 KST — H08 경고코드 개인정보 유출 차단
- `feature/pc-care-usb` 기준 SHA `6db12369123a2902e55aad84809ee6ab5dc0c94d`에서 코드형식만 대문자인 사용자 입력값을 경고 코드로 노출할 위험 수정. `ui/history_compare.js`와 `ui/history_print.js`는 실제 diagnose.ps1의 8개 경고코드만 인식하며, 나머지 JSON 경고는 **비교 불가** 처리(잘못된 '없음' 판단 방지). 기존 화면·오프라인 A4 출력 기능 보존.
- Git Blob 일치 실제 Linux Node v22.16.0 H08 **45/45 PASS**, GitHub 원본 V8 합성 인쇄 포함 **54/54 PASS**, 진단기·JS·인쇄·CI whitelist 계약 8/8 PASS. Windows/WinRE·Python 전체·실제 ZIP·CI·Production 미검증. CI에 새 8건 테스트 등록.
- Release B 원본/대상 물리 디스크 분리 증명 부재로 WinRE 실제 복사는 계속 차단. GitHub main `fbb32362455378b85bcdd0b5037d1f338055fb71`·Cloudflare 변경 금지. QA `products/pc-care/tests/evidence/h08_issue_allowlist_qa_20261031.json`.

## 2026-10-31 KST — AXMART PC CARE native Python packaging validation
- GitHub feature baseline 728e5d96b36cc29e29c0057c0af758bc3da32dda. Four Git-blob-identical sources: tools/release.py, tests/test_release.py, tools/preflight.py, tests/test_preflight.py. Executed Python 3.13.5 unittest discover natively on Linux: **16 PASS, 0 FAIL, 0 SKIP** (12 release, 4 preflight).
- The actual remote repository tree has all 37 package allowlist members (none missing, empty or above 5MB; total 235361 bytes). All 20 PowerShell files in the allowlist have valid UTF-8 BOM.
- Synthetic source fixture used to create and verify ZIP, not a full original production ZIP build. Full repo Python/Node, Windows 11/PS5.1, Edge file://, USB, QR, A4, WinRE, CI and Production remain **UNVERIFIED**. No customer files or repair commands accessed.
- Evidence: products/pc-care/tests/evidence/native_package_preflight_qa_20261031.json. No changes to public main/Cloudflare; WinRE backup copying remains blocked.

## 2026-10-31 KST — PC CARE 원인 후보 분석 신뢰성 수정
- 기능 브랜치 기준 `3ef198b3266e7da7382db8fe9a36a4cccedbc5b7`. `tools/incident_analysis.ps1`이 조회 실패·빈 결과에도 남아 있을 수 있는 System/Windows Update/PnP 배열을 근거로 원인 후보를 생성하지 않도록 상태별 증거 게이트 적용.
- `tools/diagnose.ps1`에서 물리 저장장치 전체 수집 상태를 전달. 불완전 수집은 전체 정상으로 간주하지 않고 incomplete 및 고지; 실제 관측된 Warning은 유지. `tests/incident_analysis.tests.ps1` 새 15개 합성 Assertion, `tests/test_package.py` 원본 계약 추가.
- GitHub Blob 기반 **정적 계약 12/12 + 최종 10/10 PASS**. **Windows PowerShell 5.1/전체 Python/실제 ZIP·CI·실기기 실행은 아직 미실행**. QA `products/pc-care/tests/evidence/incident_provenance_qa_20261031.json`.
- Release B 파일 복사는 여전히 차단, main `fbb32362455378b85bcdd0b5037d1f338055fb71`·Cloudflare `https://ax-mart.pages.dev/` 미변경. 출시/판매 금지.

## 2026-10-31 — PC CARE collection provenance
- System/Update collector arrays now enter normalization only for collected/truncated status. Failed and no-match results cannot create incidents or timeline entries. PnP failed/no-match records similarly yield no samples.
- Changed: tools/diagnose.ps1, tools/pnp_analysis.ps1, tests/driver_timeline.tests.ps1 (+4 assertions), tests/test_package.py (+1 contract). GitHub source static checks 14/14 PASS; native Windows, full suite, original ZIP and CI not run.
- Evidence: tests/evidence/collector_provenance_qa_20261031.json. Source baseline a0548d62d18fbb7dd59c60399ccbe3290310c7d4. Feature only; main and deployment unchanged.

## 2026-10-31 KST — PC CARE native one-click release QA preparation
- Developer-only `products/pc-care/RUN_RELEASE_QA.cmd` added (excluded from internal customer ZIP). Python >=3.11 + existing preflight runs Python/Node/temporary real internal ZIP integrity/Windows PS5.1 synthetic, no live diagnostics/repair. Added `tests/test_qa_launcher.py` 8 native Python tests. Linux 8 PASS/0 FAIL; incomplete-source QA exits 1 as required.
- Verified Git source match; **full 37-file product ZIP, Windows CMD/PS5.1, CI, USB/QR/A4/WinRE remain unverified**. Prior HEAD `489f15a72e1581c68a708c2734cfe4fd0a840537`. New evidence `products/pc-care/tests/evidence/oneclick_qa_20261031.json`. Operating main unchanged.

## 2026-10-31 KST — CUBE 총괄 핵심 코어 시간축 근거 계약 보강
- 해총 48h 백엔드 우선 프로토콜 수신, 기존 PS5.1/CMD/HTML/JSON 모듈 유지(A안). 구성요소/스택/데이터 흐름 기준선: `products/pc-care/docs/PRODUCT_AND_INTEGRATION_BASELINE.md`.
- `recorded_timeline.ps1`: 수집 상태 실패·무결과 시 과거 잔류 배열 차단; System/Update 소스 분리, 이벤트 종류·ID 검증, 명시적 UTC 시차 요구, 수집 절단 여부 전달. `diagnose.ps1` 연결과 회귀 fixture 확장. 변경 전 Git SHA `dc53774703d1ea856599c599f3cf4b97418d885c` 복구점.
- 원격 재조회 후 정적 계약 **17/17 PASS**, 원본 치환 과정의 손상은 원본 SHA로 재구성 후 원격 재검증하여 복구. **Windows PowerShell5.1·전체 Python/Node·실제 ZIP·CI·USB·QR·A4·WinRE NOT_RUN**. `main`·Cloudflare·고객 데이터 무변경, 무료/유료 배포 금지.
- 다음: Windows 11 전체 소스 `RUN_RELEASE_QA.cmd` → PS5.1 합성/읽기 전용 보고서 확인 → USB·QR·PDF → 별도 WinRE VM 안전 게이트. CI 이전 runner 미배정 재시도 없음.

## 2026-10-31 KST — CUBE PC CARE Release A 시간축 완전성/근접 관측 반영
- 해총 Backend-first 지침에 따라 `feature/pc-care-usb`에서 수집 출처/실패/절단 상태를 근거 시간축까지 전달하고, 원인 미확정 근접 신호 3종을 JSON/오프라인 HTML에 표시. 회귀 fixture + 전체 Windows 저장 보고서 검증 계약 추가.
- GitHub 원격 소스 기준 32/32 정적 조건 PASS. **PowerShell5.1 native·Windows·USB·QR·PDF·WinRE·full ZIP·CI 미검증**. 기준 evidence `products/pc-care/tests/evidence/timeline_coverage_static_qa_20261031.json`. `main`/Cloudflare Production·사용자 파일 불변.
- 다음은 Windows 전체 소스 `RUN_RELEASE_QA.cmd` 실실행과 저장 보고서·프린트·QR 검증. Release B 파일 복사/공개·결제는 승인 전 금지.

## 2026-10-31 KST — AXMART CUBE PC CARE H08 데이터 무결성
- `feature/pc-care-usb`에 실제 반복 검사 비교 결함 수정: 업데이트 이벤트·PnP 샘플의 빈/허위 항목을 건수만으로 비교하는 오류 방지. 원래 정상 관측/실패·무결과 비교 의미 유지.
- GitHub 원본 JS+커밋된 단위 테스트 V8 어댑터 실행 **25/25 PASS**, 추가 V8 12/12, 정적 12/12. **네이티브 Node·Python·Windows·USB·QR·A4·WinRE·CI·제품 ZIP NOT_RUN**. 증거 `products/pc-care/tests/evidence/h08_normalized_sample_validation_20261031.json`.
- 기존 운영 `main`·Cloudflare, 고객 데이터, 수리/복구, 무료/유료 배포 변경 없음. 다음 Release A 실 Windows 진단→보고서→H08 비교의 실제 런타임 검증을 우선.

## 2026-10-31 KST — CUBE H08 정규화 이벤트 통합 검증
- `feature/pc-care-usb`: 진단 System 정규화 증거를 검사하지 않고 UI가 41/6008·BugCheck·Storage 건수를 비교하던 오류 수정. 실제 JSON 구조의 합성 통합 `eventEvidence → H08 → 로컬 인쇄 요약` 테스트 5개와 `preflight.py` 등록, 패키지 소스 계약 갱신.
- 기존 비교 테스트 V8 **28/28 PASS**, 신규 통합 V8 **5/5 PASS**, 정적 **12/12 PASS**. **Native Windows/PowerShell5.1/Node/Python/ZIP/QR/PDF/USB/WinRE 및 신규 CI NOT_RUN**. 증거 `products/pc-care/tests/evidence/h08_system_evidence_integration_qa_20261031.json`.
- 운영 main·Cloudflare·원본 고객 데이터 불변; 새 릴리스/결제/WinRE 복사 금지. 기존 CI 실패 `41034866482`는 과거 SHA의 job 0 steps로 현재 기능 불량 증거 아님. 다음 실제 Windows E2E 검증이 필수.

## 2026-10-31 KST — PC CARE H08 System provider 검증
- 기존 System 이벤트 이력 비교가 event ID·종류·UTC는 검증하지만 공급자 이름을 확인하지 않던 오류를 수정. `ui/history_compare.js`가 `event_analysis.ps1`와 동일한 BugCheck/Kernel-Power/EventLog/스토리지 provider 허용 목록을 사용. 누락·불일치는 비교 불가.
- `tests/test_history_compare.cjs`·`tests/test_history_evidence_integration.cjs`·`tests/test_package.py` 계약 갱신.
- GitHub 실제 JavaScript/커밋 테스트 V8 어댑터 38/38 통과. 네이티브 Node/Python/Windows PS5.1/실기기·USB·WinRE/QR/PDF·CI는 미검증. 기존 사용자 데이터·운영 main 변경 없음.
- 이번 작업 전 개발 기준 SHA `b568c942c00ee4cc32e24863e2608c93806df290`. 다음: Windows 전체 checkout `RUN_RELEASE_QA.cmd` → 읽기 전용 결과 저장/비교/인쇄 실제 테스트.

## 2026-10-31 KST — CUBE PC CARE 디스크 경고 근거 정합성
- `feature/pc-care-usb` 실제 `incident_analysis.ps1`: 물리 디스크 조회 실패·무결과에 남은 Warning 표본을 새로운 고장 징후로 분석하던 오류 차단. 수집 정상/상한 도달 시 관측 표본은 유효하되 절단은 불완전 표시. 합성 PS fixture와 Python 소스 계약 동기화.
- 원격 소스 계약 19/19 PASS. **Windows PS5.1/실장비/USB/ZIP/QR/PDF/WinRE/CI 및 native Python·Node NOT_RUN**. 증거 `products/pc-care/tests/evidence/incident_disk_provenance_static_qa_20261031.json`. 운영 main/Cloudflare/고객 파일·실제 수리 변경 없음.
- 다음 P0: 전체 Windows `RUN_RELEASE_QA.cmd` 및 read-only 보고서→H08 실제 기능 검증. WinRE 복사와 고객 공개 차단 유지.

## 2026-10-31 KST — CUBE PC CARE 보고서 쓰기 및 SMART 신뢰성
- `feature/pc-care-usb`에서 원시 `FileBase`로 보고서 저장 경로가 이탈할 수 있는 취약 경로 차단. 임의 점·슬래시·절대경로/긴 파일명 거부, 기존 출력 쌍/충돌/폴더 fallback 유지.
- `diagnose.ps1` 저장장치 Wear/Temperature 직접 `[int]` 변환을 기존 내부 배포 `telemetry_analysis.ps1`의 독립·범위 제한 정규화 함수로 교체. 잘못된 마모율과 유효한 온도 구분. 합성 PS 회귀·Python 패키지 소스 계약 추가.
- **GitHub 원격 정적 24/24 PASS**; native PowerShell5.1, Python·Node 전체, Windows 실기기·USB/QR/PDF/WinRE·실 ZIP·현재 CI **미검증**. 증빙 `products/pc-care/tests/evidence/report_persistence_smart_source_static_qa_20261031.json`.
- 운영 main·Cloudflare·고객 자료·복구/실제 수리/공개 불변. 다음 Windows 11 전체 소스 `RUN_RELEASE_QA.cmd` 및 실제 read-only 보고서 저장 경로 검증.

## 2026-10-31 KST — CUBE PC CARE 시간축 수집 완전성 보강
- `feature/pc-care-usb`: 비정규화된 이벤트를 버린 뒤에도 '정상 수집'·'일치 기록 없음'으로 표시할 수 있는 코어 오류 수정. `recorded_timeline.ps1`은 kind/ID/시각 근거·UTC를 확인하고 거부 건수를 출력; 정상 조회 중 거부 입력은 불완전 처리. `diagnose.ps1` JSON/HTML 및 Windows 스모크/PS fixture/Python 계약에 거부 내역 반영.
- 원격 정적 계약 **25/25 PASS**. `products/pc-care/tests/evidence/timeline_rejected_evidence_static_qa_20261031.json` 참조. **Native PowerShell5.1·Node/Python 전체·Windows/USB·QR/PDF·ZIP·WinRE·현재 CI NOT_RUN**.
- 개발 전 SHA `63ca3c8513d921bfa990dbdec813118f2372e9b2`; main/Cloudflare/사용자 파일/복구/자동 수리 무변경. 다음 Windows PS5.1 실제 synthetic QA + 읽기전용 보고서 생성 E2E.

## 2026-10-31 KST — CUBE PC CARE QA 영수증·공급자 안전 개선
- `feature/pc-care-usb`: 기존 개발용 `RUN_RELEASE_QA.cmd`에 로컬 `QA_RESULTS` JSON 영수증 추가. 합성 QA 단계명·상태·테스트 수·미검증 범위만 기록; 원시 로그/경로/개인정보 저장 및 기존 영수증 덮어쓰기 금지. Git ignore/고객 ZIP 제외. PC/수리 직접 실행 없음.
- WindowsUpdate 이벤트 공급자를 전체 이름으로 정확히 확인하도록 변경하고 위장 provider 회귀 추가. 기존 수동 Windows QA workflow 누락된 H08 System E2E JS 테스트 등록.
- GitHub 정적 계약 **26/26 PASS**; 분리된 동일 Python helper 로컬 스모크 **6/6 PASS**, **전체 GitHub native Python/Node 및 Windows/PS5.1/실 ZIP·USB·QR/A4·WinRE·CI NOT_RUN**. `products/pc-care/tests/evidence/native_qa_receipt_update_provider_static_20261031.json`.
- 운영 main/Cloudflare·고객 원본·OS/복구·인증 불변, 공개 배포 금지. 다음 Windows `RUN_RELEASE_QA.cmd` 1회 실제 검증 후 `QA_RESULTS` 검토.

## 2026-10-31 KST — AXMART CUBE QA 필수 단계 정합성
- `feature/pc-care-usb`: 일부 PASS만 있는 QA를 전체 PASS로 판정하던 `preflight.py` 경로 개선. Python/Node/내부 ZIP/Windows PS5.1 단계 4개 유일성 강제, 누락/중복은 FAIL, Windows 미실행은 PARTIAL. 개인 정보 없는 QA 영수증도 동일 검사 적용.
- `tests/test_preflight.py`·`tests/test_package.py` 회귀·계약 갱신. GitHub 코드 복사 격리 Python 3.13 **10/10 PASS**, 전체 native Python/Node·PS5.1/ZIP·실Windows·USB/QR/A4·WinRE·현재 CI 미실행. 증거 `products/pc-care/tests/evidence/qa_gate_matrix_20261031.json`.
- 운영 main·Cloudflare·사용자 파일/OS/복구·출시 불변. 다음 Windows 네이티브 `RUN_RELEASE_QA.cmd` 결과 영수증 확인.

## 2026-10-31 KST — CUBE ZIP checksum overwrite 방지
- `feature/pc-care-usb` 내부 개발 ZIP 저장 시 `.sha256` 링크/타 실행 임시 파일을 잘못 덮거나 삭제할 수 있는 결함 수정. 기존 결정적 ZIP/manifest 검증 유지하며 전용 exclusive 임시파일 + 안전 교체 적용. `tests/test_release.py`·`tests/test_package.py` 보강.
- 원격 GitHub `build_internal` 실소스 함수와 일치하는 격리 Python 3.13 테스트 **9/9 PASS**(합성 단일 파일 입력/대체 verifier). 실제 전체 Python suite/제품 allowlist ZIP/Windows PS5.1·Node·USB·QR/PDF·WinRE/CI는 미검증. `products/pc-care/tests/evidence/zip_sidecar_atomic_native_qa_20261031.json`.
- main/Cloudflare·고객 데이터·OS/복구·출시 불변. 다음 Windows 전체 checkout `RUN_RELEASE_QA.cmd`.

## 2026-10-31 KST — CUBE PC CARE 원본 ZIP Python 네이티브 QA
- `feature/pc-care-usb`: 원격 Git blob SHA까지 맞춰 복원한 `products/pc-care/tools/release.py` + `tests/test_release.py`를 실제 Python 3.13.5로 실행. 공식 unittest **15/15 PASS**, 별도 합성 ZIP 안전 시험 **14/14 PASS**(중복 항목 존재). `products/pc-care/tests/evidence/release_actual_python_native_20261031.json`.
- 실제 제품 파일 ZIP·전체 repo Python/Node·Windows PS5.1/실기기·USB/QR/A4·WinRE·CI는 여전히 **미검증**. 이번엔 코드 수정을 필요로 하는 오류가 발견되지 않아 증빙 및 상태만 갱신. main/Cloudflare/사용자 원본/OS·수리·출시 불변.
- 다음 P0: 실제 제품 전체 체크아웃 Windows `RUN_RELEASE_QA.cmd` 및 생성 결과 `QA_RESULTS` 확인.

## 2026-10-31 KST — AXMART CUBE 논리 드라이브 데이터 실패 격리
- `feature/pc-care-usb`: Windows 디스크 여유 공간 조회의 `NaN`·무한대·변환 오류/비정상 드라이브 문자 때문에 전체 진단이 중단되거나 부정확한 보고서가 생성될 수 있는 문제 수정. 기존 배포 `telemetry_analysis.ps1` 순수 helper에서 값을 검증, 잘못된 항목만 제외.
- 수집 일부 제외 시 `collectionStatus.volumes=incomplete`·`volumeRejectedCount`로 명시해 H08가 수집 불완전 데이터를 비교하지 않도록 연결. 합성 PS fixture와 Python 소스 계약 추가. GitHub 정적 23/23 PASS, **변경 코드 PS5.1 native·전체 Python/Node/실 ZIP·Windows/USB·QR/A4/WinRE/CI NOT_RUN**. 증거 `products/pc-care/tests/evidence/volume_metric_failclosed_source_qa_20261031.json`.
- 운영 main/Cloudflare, 사용자 원본 파일·OS·실수리/배포 불변. 다음 Windows 개발 체크아웃 `RUN_RELEASE_QA.cmd`→실제 읽기전용 진단 보고서 E2E.

## 2026-10-31 KST — AXMART CUBE PC CARE H08 경고 허위 미관찰 차단
- `feature/pc-care-usb`: 신규 드라이브 수집 `incomplete`이거나 `volumeRejectedCount`가 잘못됐는데도 과거 `DISK_SPACE_LOW/CRITICAL`을 `missing`으로 비교하던 H08 결함 수정. 신규 관측 경고와 다른 경고 비교는 유지. 공식 JS 회귀 4건 등록.
- GitHub 원본 코드 V8 호환 시험 공식 **26/26 PASS**+별도 17/17(중복), 원격 정적 16/16. **실제 Node test runner/Windows PS5.1/전체 제품 ZIP·브라우저·USB/QR/A4·WinRE·현 CI 미검증**. `products/pc-care/tests/evidence/h08_volume_warning_provenance_v8_20261031.json`.
- 운영 main/Cloudflare·사용자 파일/OS·수리/출시 불변. 다음 실제 Windows `RUN_RELEASE_QA.cmd` 및 read-only 보고서/H08 수용 시험.

## 2026-10-31 KST — PC CARE 상담표 수집 증거 fail-closed (CUBE)
- `tools/consultation_report.ps1`: 물리 디스크 조회 `unavailable/empty` 상태에서 남은 Warning 표본을 새 경고로 표시하던 오탐 차단. `collected/truncated`에서 실제 관측한 Warning은 유지, `collected` 전체 Healthy만 정상 신호로 허용.
- A4 상담표 사건 근거에 System/Update 수집 출처별 kind·ID 분리, System provider allowlist, `event_recorded_time`, 명시적 UTC/offset 및 유효 달력 검사 추가. 미검증·위장·로컬시각 입력은 상담표에서 제외.
- 합성 PowerShell 회귀 fixture 및 Python 소스 계약 보강. GitHub 원본 내용 기준 정적 연결/스키마 검사만 수행; **Windows PowerShell 5.1 실제 실행, 전체 Python/Node, 실 Windows·USB/QR/A4·WinRE, 제품 ZIP, CI = NOT_RUN/UNVERIFIED**. 증거 `tests/evidence/consultation_provenance_status_static_qa_20261031.json`.
- 원본 Git 시작 SHA `28a7828bff5f0279cd01b62368fbbfcc09a28672`; `main` `fbb32362455378b85bcdd0b5037d1f338055fb71`/Cloudflare Production·기존 사용자 파일·권한·수리·판매/공개 배포 불변. 다음 P0: 전체 Windows checkout `RUN_RELEASE_QA.cmd` 실행 후 읽기전용 JSON/HTML→상담표·H08→QR/A4/USB 실제 QA.

## 2026-10-31 KST — CUBE System/Update 이벤트 공급자 정합성 (복구 검증 완료)
- 구현 범위: `tools/telemetry_analysis.ps1` Windows Update 정규화 출력에 allowlist 확정 provider 토큰을 추가. `tools/recorded_timeline.ps1`의 System BugCheck/Kernel-Power/EventLog/Storage 증거, Update 시간축에 kind+ID+provider+event_recorded_time+UTC/offset 동시 검사. `tools/consultation_report.ps1`의 Update 기록도 공식 provider가 없거나 위장되면 제외.
- 회귀: `tests/telemetry_analysis.tests.ps1`, `tests/driver_timeline.tests.ps1`, `tests/consultation_report.tests.ps1`, `tests/test_package.py` 변경; 관련 static 계약 10/10 및 원격 7파일 BOM/함수/크기/핵심 문자열 검수. **실제 PS5.1 native 테스트 통과는 아님**.
- 사고/복구: 첫 커밋 `e08329de17edc4593ee1c6e614a40eabbc3dc3a6`에서 JavaScript `String.replace`의 문자열 `$'` 치환 확장으로 `recorded_timeline.ps1` 본문이 6,995→25,753자로 손상됨. 기능 성공 판정 철회. 이전 정상 `f445f3bbf898db6e5c64f9d99622652cb5b4bff6` 내용으로 정확히 재구성하고 **콜백 기반 치환**으로 provider gate만 삽입, 복구 커밋 `534061a712df3d48c48818e701405c2feb83a07d`. 원격 복구 본문 **8,149자**, 함수 정의 1개, 기존 본문 6,995자 동일 + gate 1,154자, PS5.1 BOM 유지. 해당 위험 치환 방식 재사용 금지.
- 상태: `feature/pc-care-usb` 한정; `main` SHA `fbb32362455378b85bcdd0b5037d1f338055fb71`/Cloudflare Production 및 고객 파일·장치·실수리/판매 공개 변경 없음. Windows PowerShell5.1, Node/Python 전체, 정식 내부 제품 ZIP, USB/QR/A4/WinRE, 최신 CI **NOT_RUN/UNVERIFIED**. 출시 HOLD.
- 다음 P0: Windows 전체 소스에서 `RUN_RELEASE_QA.cmd` → `QA_RESULTS` 확인 → `RUN_HEALTH_CHECK.cmd` 읽기 전용 JSON/HTML 생성 → H08·상담표·QR/PDF·USB 실기기 확인. WinRE/승인형 복구는 별도 격리/승인 게이트. 복구 기준 SHA `f445f3b`로 정상 기능 이전 상태 보존.

## 2026-10-31 KST — CUBE H08 Windows Update provider 신뢰성 + V8 E2E
- 실제 코드 결함: `ui/history_signals.js`가 Windows Update 증거의 ID/kind/UTC/count는 검증했지만 `provider`가 누락·위조되어도 비교 통계가 생성됐음. 원본 GitHub JS V8 실행으로 `Fake-Microsoft-Windows-WindowsUpdateClient`가 업데이트 감소/증가 분석에 사용되는 것을 재현.
- 수정: 업데이트 비교는 `item.provider==="Microsoft-Windows-WindowsUpdateClient"`를 요구. 신규 정규화 출력에는 정확한 provider 토큰이 포함되며 구형 provider 없는 보고서는 **비교 불가(안전 우선)**. 기존 정상 날짜/수집 상태/건수·PnP/Windows 비교 유지.
- 공식 `tests/test_history_signals.cjs` 정상 fixture+위조/누락 공급자 회귀, `tests/test_package.py` 정적 계약 추가. GitHub 원본 JS 모듈(`history_signals.js`, `history_compare.js`, `history_print.js`) 및 공식 Node test 파일 2개를 **V8 테스트 어댑터**로 실행해 단위·통합 **16 PASS/0 FAIL** 확인. 이는 네이티브 Node 테스트가 아니며 **Python 전체·Windows PowerShell5.1·실Windows/USB·QR/A4·WinRE·내부 ZIP·CI NOT_RUN**.
- 증빙: `products/pc-care/tests/evidence/h08_update_provider_v8_20261031.json`. 기준 정상 SHA `9df862d5d4ce5ee37041f95b3955641e328552ad`. `main`/Cloudflare·실제 보고서·수리/WinRE 파일 복사·출시/판매 무변경. 다음: 실제 Windows 전체 checkout의 `RUN_RELEASE_QA.cmd` 및 read-only 보고서/H08/QR/A4 실기기 확인.

## 2026-10-31 KST — CUBE H08 8종 경고 미관찰 수집 신뢰성 통합 게이트
- 기준 `4eb938bd56fad61c35637860a57d6faa0b6bb6ca`에서 재현한 실제 H08 오류: 수집 상태 `unavailable`이거나 동일 이벤트가 최신 보고서에도 있는데 `issues=[]`만으로 BUGCHECK/DISK_HEALTH/PNP_CONFIGURATION 등이 `missing`(미관찰 경고)로 표시됨. 이 출력은 수리 성공이 아니지만 오판 가능.
- `ui/history_compare.js` 수집 증거 기반 `sourceSupportsMissing`: BUGCHECK/UNEXPECTED_REBOOT/STORAGE_EVENTS는 양쪽 Event collection 완료+제한/기간·provider 검증+현재 해당 기록 0; UPDATE_FAILURE는 양쪽 완전한 Windows Update 비교+현재 실패 기록 0; PNP는 신뢰된 상태와 샘플에서 활성 구성 코드 0(22 사용 중지는 예외); DISK_HEALTH는 두 보고서의 완전/동일 장치 수+알려진 상태 및 신규 경고 0; DISK_SPACE는 기존 볼륨 유효성 검증 유지. 신규 실제 관측 경고는 보존, 차단 이유 주의 문구 추가. 표시값은 '관찰되지 않음'이지 수리 성공이 아님.
- 공식 Node 테스트 3파일(기존+합성 회귀 4건)을 GitHub 소스 V8 Node 호환 래퍼에서 **44/44 PASS**, 진짜 Node 런타임이 아닌 점 명시. `test_package.py` 소스 계약 보강. 증거 `tests/evidence/h08_multisource_missing_warning_v8_20261031.json`. Windows PS5.1·Native Node 전체·Python 전체·브라우저/USB/QR/A4/WinRE/ZIP/CI **NOT_RUN**.
- 기존 `main`/Cloudflare·사용자 원본 데이터/권한/수리/배포·판매 불변. 다음 P0: Windows 전체 checkout `RUN_RELEASE_QA.cmd`, 실제 보고서/H08 출력 검증, 제품 출시 HOLD.

## 2026-10-31 KST — CUBE 실제 진단 분석 이벤트 출처 필터 추가
- **원인/위험:** `tools/incident_analysis.ps1`가 System 및 Windows Update collector의 상태만 확인하고 `kind`에 일치하는 입력을 무검증으로 사용, 잘못된 ID/provider/recordedUtc/timeBasis·교차 출처가 BugCheck·종료·업데이트·저장장치 검토 항목을 만드는 위험. 보수적 "원인 확정 아님" 정책과 충돌.
- **개선:** `Test-PcCareIncidentEvidence` 순수 함수에서 ID·분류·공식 provider allowlist·기록 시각 `event_recorded_time`·오프셋 명시 ISO timestamp/실제 달력을 확인, System/Update 출처를 분리. 거부 건수를 `observedCounts.rejectedSystemEvidence/rejectedUpdateEvidence`에 기록하고 분석 `status=incomplete` 및 제한 문구. 정상 데이터·종료/버그체크/업데이트/스토리지 각각 기존 판단 정책은 유지. 개인정보·원본 이벤트 메시지/경로 출력·실 수리/장치 조작 없음.
- **검증:** 기존 합성 PowerShell fixtures에 공식 provider/UTC를 추가하고 위조 공급자·ID/종류 충돌·현지 시각·불가능한 날짜·교차 출처·일부 유효 데이터 회귀 추가. Python 정적 계약 추가. GitHub 원본 확인 기반 **9/9 SOURCE CONTRACT PASS**. 실제 WinPS 5.1/전체 Python/Node/Windows·USB·QR/A4·WinRE·ZIP·CI **NOT_RUN/UNVERIFIED**, 따라서 실제 기능 PASS 주장 금지. 증빙 `products/pc-care/tests/evidence/incident_provenance_guard_20261031.json`.
- **운영·복구:** 기준 SHA `6b17c88863bc035c266ac159b61e7ab3812b84e9`; `feature/pc-care-usb`만 수정. `main`/Cloudflare·실 사용자 데이터/파일·계정·BitLocker/복구·유료·배포 무변경, 출시 HOLD.
- **다음:** 실제 Windows 전체 checkout의 `RUN_RELEASE_QA.cmd` PowerShell/parser/fixture → Python/Node/ZIP → 읽기전용 JSON·HTML, H08/A4/QR 및 USB 실기기 검증. WinRE는 별도 승인/격리. 실패 시 해당 SHA로 복구, `STATUS/HANDOFF` 재최신화.

## 2026-10-31 KST — CUBE PC CARE 진단 보고서 자동 동기화 방지
- 주요 개인정보 결함: `tools/diagnose.ps1`의 `REPORTS` 및 `MyDocuments` 저장 후보가 사용자의 OneDrive 동기화 디렉터리일 수 있어, 앱이 직접 전송하지 않아도 OS 클라우드 동기화 위험. 외부 전송·데이터 유출 확인은 아니며 **잠재적 자동 동기화 경로** 발견.
- `tools/report_io.ps1`에 `Test-PcCarePrivateReportFolder` 추가: UNC, OneDrive/Dropbox/Google Drive/iCloud/Box 알려진 경로명·환경 루트, 기존 경로 조상 junction/reparse를 fail-closed. 부적합 후보에는 디렉터리나 파일을 만들지 않고 다른 후보로 진행. 원자적인 `CreateNew` 저장/충돌 보존·자기 소유 temp만 제거·사용자 원본 유지.
- USB `REPORTS`를 기본 후보로 유지. 보안 검증된 `LocalApplicationData\AXMART-PC-CARE-Reports`를 두 번째로 추가하고, 동기화되지 않는 구형 Documents는 세 번째로 유지. 기존 보고서 이동/삭제/덮어쓰기 없음. `tests/windows_smoke.ps1` 영수증 허용 경로도 갱신하고 잘못된 경로 거부. `tests/report_io.tests.ps1`에 합성 OneDrive/UNC, 정상 로컬 fallback, 클라우드 단독 후보 거부 회귀 추가. `tests/test_package.py` 소스 계약·README 안내 갱신.
- 정적 원본 검사 **10/10 PASS**, Windows PowerShell 5.1·실Windows/OneDrive/USB/QR/A4·Python/Node 네이티브 전체·ZIP·CI **NOT_RUN/UNVERIFIED**. 별도 사용자 클라우드·OS·기존 보고서 접근/수정 없음. **기타 동기화 클라이언트와 특이 사용자 설정은 완전 검출 보장하지 않으며 Windows 실기기 검증 전 공개 금지**.
- 기준 커밋 `69b8b8e84fc3ec4fa3863c945dceeb9790dc637b`, `main`/Cloudflare 운영 불변. 다음 실제 Windows `RUN_RELEASE_QA.cmd` → 폴더 동기화 경계·로컬 보고서 JSON/HTML/H08/상담/QR/USB 안전 확인, WinRE는 별도 승인 게이트.

### 2026-10-31 KST — CUBE 로컬 보고서 정책 QA 코드 순서 수정
- 직전 `6ae76d72c79691bfa70a899f1ae47c19e5ee76f7`의 `test_package.py`에서 `report_fixture`를 할당하기 전에 새 `assertIn`이 사용하는 순서 문제를 발견. 테스트 호출 시 `UnboundLocalError` 발생 가능. 해당 fixture 파일 읽기 할당을 최초 사용 앞에 이동하고 중복 할당 제거. 실행 중인 OS/사용자 원본 데이터·저장 경로 소스 변경 없음.
- 실제 소스에서 `assignment index < first assertion index`, 할당 1회 확인; 정적 3/3 PASS. 기존 검증 표기 정정: **직전 10/10은 원본 코드 계약의 표면 검사이며 전체 Python unittest 통과 증거가 아님.** 네이티브 Python/WinPS5.1/CI·실 OneDrive·USB **미실행**, RELEASE HOLD. `feature/pc-care-usb`만 변경, `main`/Production 유지.

### 2026-10-31 KST — CUBE REPORTS 네트워크 매핑 드라이브 차단 추가
- 이전 `Test-PcCarePrivateReportFolder`은 UNC(`\\server\share`)는 거부하지만 `X:\REPORTS`처럼 **매핑된 네트워크 드라이브**는 UNC 접두사가 없어 저장이 허용되는 결함 발견. 동기화/외부 데이터 전송 없는 기본 정책과 충돌.
- 파일 시스템의 실제 `[IO.DriveInfo].DriveType` 확인: `Fixed` 또는 `Removable`만 허용, `Network`/알 수 없는·광학 드라이브는 거부. 이름/환경변수/조상 reparse 검사는 그대로 유지. USB(제거식) 진단·LocalApplicationData(고정식) fallback은 보존.
- `tests/report_io.tests.ps1`에 DriveType 상태별 5건+로컬 경로 허용 회귀, `test_package.py` 원본 계약 추가. **소스 정적 12/12 PASS**, PowerShell5.1 네이티브·Windows·네트워크 매핑·USB·Python 전체·ZIP/CI **NOT_RUN/UNVERIFIED**. 보고서·사용자 데이터·OS/권한/판매/배포에 실제 변경 없음.
- baseline `bee6b09382fa960171a821f3c3e5ed7f08795f2a`, `feature/pc-care-usb` 한정. `main`/Cloudflare 유지, 출시 HOLD. Windows `RUN_RELEASE_QA.cmd` 우선, 정상 fixed/removable·mapped network·OneDrive/Junction E2E 테스트 후 공개 판단.

## 2026-10-31 KST — CUBE H08 볼륨 교체·경고 악화 미관찰 오판 수정
- **재현:** 이전 C: 경고가 있던 보고서와 최신 D:만 수집한 보고서를 비교해도 `currentVolumesComparable=volumeMap(b).size>0` 조건으로 과거 디스크 공간 경고가 `missing` 처리됨. `LOW→CRITICAL` 악화 시에도 LOW가 사라진 경고로 출력됨. '미관찰'은 수리 성공이 아니지만 사용자의 개선 오해를 유발할 수 있음.
- **변경:** `ui/history_compare.js`는 이전/최신 각각 수집 상태·거부 건수·중복/비정상 값이 유효한 볼륨 목록이고 **같은 드라이브 문자 집합/개수 및 5% 이내 용량 일치**할 때에만 과거 디스크 공간 경고의 미관찰 비교를 허용. 새 CRITICAL이 있으면 과거 LOW를 별도 미관찰로 표시하지 않음. 신규 CRITICAL은 그대로 표시. 정상 동일 볼륨·실제 경고 해소 사례는 이전 기능 유지.
- **검증:** GitHub 원본 JS + 공식 `test_history_signals.cjs`, `test_history_compare.cjs`, `test_history_issue_allowlist.cjs`, `test_history_evidence_integration.cjs`를 V8 Node 호환 어댑터로 실행 **57/57 PASS**(신규 테스트 3개, 재현은 여러 변형). 자체 JS 원본/정적 계약 7/7. 네이티브 Node 실행과 Windows PowerShell5.1/USB/H08 실 브라우저/QA ZIP/CI는 **NOT_RUN/UNVERIFIED**, 제품 출시 HOLD. 증빙 `products/pc-care/tests/evidence/h08_drive_identity_and_escalation_v8_20261031.json`.
- **복구/운영:** 기준 SHA `5431b28ca2ddd46bb1622685d9d908618b3ba1ee`, 작업 브랜치 `feature/pc-care-usb`만 수정. `main`/Cloudflare Production/고객 파일·OS/권한/수리/유료 배포 변화 없음. 원본 커밋으로 복구 가능. 다음 P0: Windows에서 `RUN_RELEASE_QA.cmd` 내부 합성 QA → `RUN_HEALTH_CHECK.cmd` 실기기 읽기 전용 보고서/H08→QR/A4/USB 실수용→WinRE 격리 안전성 시험.

## 2026-10-31 KST — CUBE 대표 판정/근거 수집 일관성
- **확인한 위험:** `tools/diagnose.ps1`의 대표 판정은 `issues` 및 `limits`만 보고, 바로 위에서 산출한 `Get-PcCareIncidentAssessment.status`가 `incomplete`여도 그 사실을 반영하지 않는 구조. 이론상 정규화 거부·부분 증거 누락 시 `analysis.status=incomplete`와 대표 문구 `관찰 범위 내 특이사항 없음`이 모순될 수 있음(실기기 재현은 미실행).
- **수정:** `tools/incident_analysis.ps1`에 부작용 없는 `Get-PcCareAssessmentLabel` 함수 추가. 우선순위 `high > medium > (explicit limitations OR null/incomplete analysis) > limited_observations`. `diagnose.ps1` 대표 판정에 연결하고 `analysis.incomplete`인데 수집 한계 설명이 전혀 없다면 사용자-facing 제한 문구를 하나 추가. 기존 수집기·로컬 JSON/HTML·안전·승인/복구 동작 불변.
- **검증:** PowerShell 합성 fixture에서 `incomplete→확인 불완전`, `high/medium` 보존, 정상 제한 관측, analysis 누락, 명시 한계 6종. Windows 읽기 전용 스모크에서 JSON의 `analysis.status`·대표 `assessment`·`limitations` 일관성 검사 추가. Python source-contract 보강. 원본 소스 정적 확인 **11/11 PASS**. **Windows PowerShell5.1 네이티브·실PC 진단·Python/Node 종합·USB/QR/A4·ZIP·CI NOT_RUN**, 출시 HOLD; 정적 검사를 실행 검증으로 표현 금지.
- **운영:** 기준 SHA `0782902848f736ea43d4530b2a1ef9fb717a3396`, `feature/pc-care-usb`만 수정. `main`/Cloudflare 무변경, 원본/고객 데이터 읽기·변경/실 수리/외부 전송 없음. 추가 검증은 Windows `RUN_RELEASE_QA.cmd` 및 실기기 읽기 전용 `RUN_HEALTH_CHECK.cmd`; WinRE·수리는 별도 게이트.

## 2026-10-31 KST — CUBE H08 신규 장애 오판 차단
- **V8 재현(이전 SHA `bbe120757799e3826d0b0ab3b43d97b0e72bc4f6`):** System 로그가 `unavailable`, 검증된 BugCheck 이벤트 0건인 최신 JSON에 `issues:[{code:BUGCHECK}]`만 기록하면 `compareReports().added=["BUGCHECK"]` 출력. 기존 H08는 '경고 미관찰'의 출처만 검증하고 신규 경고를 코드 allowlist만으로 승인하는 문제.
- **구현:** `ui/history_compare.js`에서 신규 경고 8종의 **실제 수집 증거**를 검증하여 없으면 `added`에서 제외, 불완전 경고에 대한 주의 문구. System 이벤트는 collection 상태와 정상화된 provider/kind/EventID/UTC, Windows Update는 검증된 19/20 이벤트와 합계, PnP는 1~55 유효 구성 코드와 일치 수집 상태, 물리 디스크는 최신 Warning/Unhealthy 관측, 볼륨은 유효 드라이브·수치·경고 임계치를 확인. 일부 볼륨만 유효하게 수집된 `incomplete` 상황에서도 **관측된 위험 신호**는 보존하고 실패한 `unavailable` 수집을 증거로 사용하지 않음.
- **검증:** 공식 Node 테스트 4개 파일을 V8에서 Node:test/assert 호환 shim으로 실제 JavaScript 실행 **61/61 PASS**. 신규 회귀 4건, 과거 fixture의 증거 불일치(C: 정상 여유에 CRITICAL 임의 주장) 교정. Python 패키지 정적 계약 추가. 자체 소스 검증 8/8. **Node native/PowerShell5.1/Windows·USB·실브라우저·QR·A4·ZIP·CI 미실행**, 릴리스 HOLD.
- **운영:** 수정 브랜치 `feature/pc-care-usb` 한정, `main`/Cloudflare 운영·원본 보고서·유저 PC 미변경. 로컬 파일/개인정보 전송·설정·복구·결제 없음. 합성 결과를 실제 Windows 합격으로 표시하지 않음. 다음 단계 Windows native `RUN_RELEASE_QA.cmd` → 읽기 전용 실진단 및 H08(실 보고서) → QR·A4·USB 검증.

## 2026-10-31 KST — CUBE 저장장치 식별 가능 이름 제거
- `diagnose.ps1`는 `Get-PhysicalDisk.FriendlyName`을 진단 JSON 모델, HTML 및 위험/한계 문구에 그대로 기록. 사용자 지정 디스크명이 포함된 경우 식별 정보 노출 위험 확인. 원본 파일/실제 디스크 수정 없음.
- `telemetry_analysis.ps1`의 `ConvertTo-PcCarePrivateDiskObservation`: 장치 이름 대신 이번 검사에서만 유효한 `물리 저장장치 N`, HealthStatus 네 종류 및 OperationalStatus 예상 상태만 allowlist. SMART 마모/온도·건강 경고 우선순위 및 JSON 구조 유지. 검사 간 번호가 같은 물리디스크를 보증하지 않는다고 문서화.
- `telemetry_analysis.tests.ps1` 합성 개인정보·복수 디스크·미확인 상태 회귀, `windows_smoke.ps1` 생성 JSON 안전 레이블 검사, `test_package.py` 코드 계약. **정적 소스 14/14 PASS**. WinPS5.1/Windows/정식 Python·Node/USB·QR·A4·WinRE/CI는 **NOT_RUN/UNVERIFIED**, 출시 HOLD. 증빙 `products/pc-care/tests/evidence/private_disk_observation_20261031.json`.
- 경합 대응: 처음 기준 SHA `bbe1207`에서 푸시 전 HEAD가 `6e85e521ddfe6489e5ff9ddcfccae6d82213cd09`로 변경되어 선행 작업 중단 후 새로운 HEAD에서 재적용. 타 작업 H08 변경 보존. `main`/Cloudflare Production, 데이터·설정·권한·배포 불변.

## 2026-10-31 05:23 KST — 사용자 요청 야간 마감 / 진행률·인수인계
- **전체 약 50% (추정, Release A+B와 실기기/출시 QA 포함)**; Release A 코어 소스 약 80~85%, Release A 출시 준비 약 60~65%, Release B WinRE 실제 파일 백업 약 20%. 점수/측정값 아님. 실제 Windows 수용검사 통과 없음.
- 소스 마감 SHA `9eddda6477b3a5e4eba9aadf1b471a122f35c949` (`feature/pc-care-usb`); `main` `fbb32362455378b85bcdd0b5037d1f338055fb71` 불변. 새로운 문서 기준 `products/pc-care/docs/CLOSEOUT_20261031_KST.md`의 10개 항목을 다음 채팅 첫 읽기로 지정. Docs 커밋은 기능 변경 아님.
- 최신 QA: 디스크 이름 비식별화 14/14 SOURCE STATIC PASS; PS5.1/USB·QR·A4·WinRE 최신 실제 실행 NOT_RUN, Release HOLD. 최근 CI 이전 SHA failure, 재시도 없음. Python/JS 과거 합성 테스트는 독립 증빙으로만 기록.
- **다음 우선순위:** Windows `RUN_RELEASE_QA.cmd` native→격리된 로컬 읽기 전용 E2E→USB·QR·A4→WinRE/복구 안전 검증. 사용자 수면 중 자동 작업, 변경, 배포 없음.

## 2026-10-31 KST — CUBE QA fixture 초기화 순서 복구 (본 채팅)
- 대상: `hibi89/AX_MART@feature/pc-care-usb`; 작업 시작 SHA `2f933fc5d1dd6673df9f55fdba72f720d204d732`. 기존 `main=fbb32362455378b85bcdd0b5037d1f338055fb71` 불변.
- 원인/수정: `products/pc-care/tests/report_io.tests.ps1`는 `$normal` 경로를 할당하기 전 `Test-PcCarePrivateReportFolder -Folder $normal`을 호출해 정상 QA가 실패할 수 있었음. 경로 할당을 테스트 호출 앞으로 이동. `tests/test_package.py`에 순서 회귀 가드 추가.
- 코드 커밋: `41d2b807e610ac9f107b4014bc017fcccaf09fbd` (PowerShell fixture 순서 수정), `48bad4cc6fd477e7e217fda45ff06279652b6b2d` (Python source-contract 회귀 가드). 원본 `report_io.ps1`의 보고서 생성/삭제 정책, 진단 및 사용자 데이터는 변경하지 않음.
- 검증: 이전 코드의 잘못된 순서 재현 + 최신 파일의 수정된 순서·단일 할당·BOM·Python 가드·Git HEAD를 GitHub 원본으로 정적 확인 **6/6 PASS**. 실제 Python 전체 실행/Windows PowerShell 5.1/USB·QR·A4·WinRE·ZIP·CI는 **NOT_RUN/UNVERIFIED**. 6/6은 Windows 기능 테스트가 아님.
- CI: 과거 run `41034866482`의 job `123993114299`는 `failure`, step=0; 로그 다운로드 404 BlobNotFound. 최신 커밋의 성공한 CI 기록 없음. 실패 원인을 코드 실패/runner 문제 중 하나로 확정할 수 없음. 무의미한 재실행 금지.
- 출시·복구: Release A/B 완성률 이전 추정치 그대로, 정식/무료 공개 HOLD. `main`/Cloudflare Production/수리/복구/OS 권한·사용자 데이터 변경 없음. 코드 수정 전 SHA `2f933fc5`로 안전한 비교/복구 가능.
- 다음: Windows 전체 체크아웃 `RUN_RELEASE_QA.cmd` 실행 결과 확보 → 읽기전용 실 Windows 진단 → H08/QR/A4/USB → WinRE 별도 격리/승인 게이트. 현재 환경에서 WinPS5.1 네이티브 실행 불가. 문서 갱신은 기능 추가나 검증 합격으로 간주하지 않음.

## 2026-10-31 KST — CUBE QA 완전성·수리 로그 개인정보 경계 보강
- 범위: `hibi89/AX_MART@feature/pc-care-usb`, 기준 `a687b7be242dd9b88023f488733363dce1e04c81`; 작업 본문 최종 코드 SHA `7054447240658a1cd510f0f9d7c40d91b94020b0`. `main`/Cloudflare Production/실기기·판매 불변.
- QA 판정: `tools/preflight.py`의 `classify_full_qa_stages`에서 `node-syntax:*:pass` 또는 `internal-zip-build/verify:pass`만으로 단계 PASS 인정 가능했던 계약 오류 수정. 완전한 `node-tests`, `internal-zip` 성공만 완성 단계로 인정. 중간 단계 fail/blocked는 그대로 fail/blocked. `tests/test_preflight.py`에 우회·부분·차단 회귀 추가.
- 수리 로그: `tools/repair.ps1`의 Documents 폴더 fallback은 OneDrive 동기화 위험. `tools/report_io.ps1`의 private local path/drive/reparse 검증으로 수리용 로그 생성, `CreateNew + FileShare.None` 스트림 선확보 및 기록 실패시 수리 중단. 두 번의 사용자 승인·저장장치 건강 가드·DISM 성공 시에만 SFC 실행 유지. `report_io.tests.ps1` 합성 스트림/클라우드 거부, `test_package.py` 소스 계약 추가.
- 검증: **현재 GitHub 원본 정적 16/16 PASS**; 동일 판정 함수의 소규모 독립 Python 재현 테스트 **11/11 PASS**. 로컬 Python은 GitHub 전체 소스/원본 테스트 러너가 아닌 재현용이므로 **전체 native QA PASS 아님**. WinPS5.1/실 Windows 진단·DISM/SFC/USB/QR/A4/WinRE/ZIP/실브라우저/CI **미실행**.
- CI: 이전 Windows runner run `41034866482` failure, steps 0, logs 404 BlobNotFound. 최신 기능 코드의 새 CI 없음. 원인 미확정; 무의미한 재실행/false PASS 금지.
- 정책: Release A/B 출시 HOLD, 사용자 원본·REPORTS·장치·관리자권한·복구키·고객 데이터 변경 없음. 코드는 안전성 향상 목표이나 실제 Windows 검증 전 수리 기능 실행/공개 금지. 작업 전 커밋 `a687b7be`는 비교/복구 기준.
- 다음: Windows 소스 체크아웃 `RUN_RELEASE_QA.cmd`의 PS5.1·Python·Node·ZIP 네 게이트 결과 확보 → 읽기 전용 진단/H08·QR/A4·USB QA → WinRE/수리 격리 테스트 후 출시 승인 검토.

## 2026-10-31 KST — CUBE 후속 H08 실행 검증 / REPORTS 폴더 사후 확인
- 기준 HEAD `a5b7b4900388d8fc6925b2486d2dc0aceb0faf90`에서 시작; 제품 대상 `products/pc-care/`만 변경. GitHub `main=fbb32362455378b85bcdd0b5037d1f338055fb71`, Cloudflare Production 배포 변경 없음.
- **실제 V8 실행(원본 JS/공식 테스트 4개): 61/61 PASS**, `tests/evidence/h08_original_source_v8_followup_20261031.json`에 원본 blob SHA·커버리지·한계·재현 명령 기록. Node:test/assert/structuredClone 호환 shim 사용; **네이티브 Node/실브라우저/Windows PASS 아님**.
- 개인정보 보호 변경: `tools/report_io.ps1`의 `Save-PcCareReportPair`는 `New-Item` 직후 폴더를 다시 검사하여 reparse/비공개 경로가 되면 첫 JSON/HTML 기록 전에 거부. `tests/test_package.py`에서 순서를 계약으로 고정. 기존 CreateNew/무덮어쓰기/자기 생성 파일만 정리/복구 로직 유지. 코드 커밋 `51d647ae303d7cbe6faa421d53a6bf383cbc40d8` 및 `d0204ffa66e1c732bc3b98a6229c8d82f87febd7`; GitHub readback **정적 9/9 PASS**.
- 실행 환경: Linux Python 3.13/Node 22 존재, WinPS5.1 미설치. 연결된 사설 GitHub 원본 전체 checkout/네이티브 Python 통합·ZIP·Windows/USB/QR/A4/WinRE/실수리 CI는 **NOT_RUN/UNVERIFIED**. 원본 report/고객 데이터·시스템 수정·수리·유료 제품 게시 없음. TOCTOU 완전 제거를 보증하지 않음.
- 다음 우선순위: Windows 전체 checkout `RUN_RELEASE_QA.cmd` 네 게이트 → 읽기 전용 `RUN_HEALTH_CHECK.cmd` 생성 결과 → H08/QR/A4/USB → WinRE/수리 격리 검증. Release A/B 공개·판매 **HOLD**, 전체 추정 완성률 약 50% 유지.

## 2026-10-31 18:16 KST — CUBE 내부 QA ZIP 원본보존 보강
- 범위: `hibi89/AX_MART@feature/pc-care-usb`; 작업 전 기준 `415809121a039891a5e4a446060741fe902cfc72`, 실제 기능·테스트 HEAD `5799e74143b442529416b86806bc2a8c19e46584`. `main`/Cloudflare/고객 장치·데이터 무변경.
- 결함: `tools/release.py:build_internal`의 `os.replace(pending, zip_path)`와 체크섬 `os.replace`가 **기존 파일을 자동 덮어쓸 수 있음**. 단일 ZIP·SHA256 파일·출처 변경된 구형 산출물 보존 정책 위반 우려.
- 수정: 기존 ZIP+SHA256 두 파일이 정식 검증되고 새 아카이브와 SHA256 동일할 때에만 재사용. 다르거나 불완전하면 실패. 신규 파일은 `xb/x` 배타적 생성과 flush/fsync 후 아카이브/체크섬 검증, 해당 호출이 생성한 출력만 실패 시 정리. 임시 파일 충돌·symlink 거부·내부 테스트 전용 ZIP 정책 유지. `tests/test_release.py` 기존 파일·단독 파일·소스 변경 충돌 3개 회귀 테스트 추가.
- 검증: GitHub 원본 소스·테스트 readback **정적 12/12 PASS**. 실제 Linux Python 3.13에서 `build_internal` 게시 제어 흐름을 원본 GitHub에서 옮겨오고 간소화한 ZIP/검증 helper를 사용하는 **격리 테스트 8/8 PASS**; 이 시험은 GitHub 전체 원본을 clone하거나 official `test_release.py`를 실행한 결과가 아님. 검증 수준을 제품 전체 PASS로 확대하지 말 것.
- 장애·대안: 현재 컨테이너에서 private GitHub 원격 DNS/자격증명 접근 불가(`Could not resolve host: github.com`). GitHub connector로 원본 파일 열람/수정만 가능. Windows PowerShell 5.1 부재. 차기: GitHub checkout 가능한 실제 Windows 환경에서 `RUN_RELEASE_QA.cmd` 원본 Python+Node+PS5.1+ZIP 네 게이트 실측, 이후 읽기 전용 현장 진단·H08/QR/A4/USB/WinRE 별도 검증. 기존 CI 실패 run 41034866482 재시도하지 않음.
- 출시 상태: Release A/B **HOLD**, 전체 완성률 종전 약 50%(가늠값) 유지, WinRE 파일 복사/실수리는 미검증. 작업 전 원본 SHA `41580912...`로 비교 가능하며 forced update 없음.

## 2026-10-31 KST — CUBE 진단 코어 디스크 공간 경계값 수정
- 기준: `hibi89/AX_MART@feature/pc-care-usb`, 시작 SHA `1582b208a366559bb51278e8e580bb419086e4d5`, 코어·회귀 소스 최종 SHA `bb716c9e9fb092619d65e2ed96be13979bc30025`; `main`/Cloudflare Production 미변경.
- 발견 결함: `tools/diagnose.ps1`가 `ConvertTo-PcCareVolumeSample`에서 1자리로 반올림한 `remainingGB/freePercent`로 5GiB/5%/15% 위험도를 판정. 100GiB 용량에 4.96GiB 남은 경우 화면값 5.0GB·5.0%로 반올림되어 중대 경고를 놓칠 수 있었음.
- 수정: `telemetry_analysis.ps1` 정규화 결과에 내부 원시 `remainingBytes` 추가, 순수 `Get-PcCareVolumeRisk`가 원시 `capacityBytes/remainingBytes`와 유효성/20GiB 대상 기준으로 `high/medium/none/unavailable` 결정. `diagnose.ps1` 경고 코드는 해당 판정을 사용하고, 사용자에게 표시 숫자 반올림과 판정의 구별을 알림. 기존 JSON 공개 볼륨 스키마·파일/장치 동작 유지.
- 검증: Linux Python3.13에서 **독립 동일수식 경계값 재현 8/8 PASS**, GitHub 정적 원본 확인 **12/12 PASS**. `tests/telemetry_analysis.tests.ps1`에 9개 PowerShell 합성 assertion과 `tests/test_package.py`에 소스 계약 회귀 추가. **WinPS5.1 합성 테스트/전체 native Python/Node/내부 ZIP/실Windows/USB/QR/A4/WinRE/CI 미실행·미검증**.
- 블로커: 컨테이너의 private GitHub clone 불가(DNS `github.com` 해석 실패), PowerShell5.1 실행기 없음. 기존 Windows CI run 41034866482는 실패/step=0 로그 없음으로 원인 미확정. 무의미한 재시도 금지; 다음은 Windows 체크아웃에서 QA 명령 실행.
- 상태: Release A 실 Windows 검증 대기, Release B WinRE 파일 복사 별도 미완·승인 요구. 전체 완성률 기존 추정 약 50% 유지(실측 아님). 판매/무료 출시 HOLD. 소스 복구 기준 `1582b208...`, 고객 데이터·실 시스템·원본 파일 변경 없음.


## 2026-10-31 KST — PC CARE Release A 후속 QA
- 수정 커밋 f7b60d22f1efccbec0215065650fa478612314d9 on feature/pc-care-usb (base f2304b7f95ec939d973094a1f1a958caed08294f): PowerShell 5.1에서 실행되던 // 주석 오류 수정, 현행 evidence provenance/secure ZIP/report path 구현에 맞게 contract test와 synthetic fixtures 정정/강화.
- 수정 후 직접 실행: Python **74 PASS / 3 SKIP (77 total)**, Node **113 PASS / 0 FAIL**, Windows PowerShell 5.1 기본 합성 smoke **19 parsers + 7 fixtures PASS**. Internal ZIP **build + manifest/SHA256 verify PASS**, 동일 경로 재실행 checksum 불변 PASS.
- RUN_RELEASE_QA.cmd 전체는 총 2회 실행했고 둘 다 exit 1. 마지막 전체 실행 당시 Python/Node/PS 실패와 ZIP PASS 확인. 수정 후 관련 구성요소는 직접 재실행했으나 전체 runner는 재실행하지 않음(최대 1회 재시도 제한). 따라서 **full aggregate = NOT RUN after fixes**.
- Python symlink 관련 3개는 OS sandbox capability 미지원으로 SKIP. 브라우저/QR 카메라/A4/USB 실물/WinRE/실사용 진단은 미검증. Release A HOLD.
- main, Cloudflare Production, 원본 checkout, 사용자 PC 및 고객 파일/설정/권한/BitLocker/WinRE 불변. 개인 데이터, 실진단 결과는 수집·업로드하지 않음.

## 2026-10-31 KST — PC CARE 보고서 파일쌍 E2E 추가
- synthetic `Save-PcCareReportPair` 실제 JSON/HTML 저장·UTF-8 재읽기 회귀 추가. WinPS 5.1 smoke **19 parsers + 7 fixtures PASS**, JSON/HTML 주요 결과 동일·기록시각·상담 요약 개인정보·escaping 확인. Python 재실행 **74 PASS / 3 SKIP (77 total)**.
- 전체 RUN_RELEASE_QA 수정 후 재실행은 미실시(허용 재시도 소진). 실제 진단, 브라우저/USB/QR/A4/WinRE 미검증, Release A HOLD.


## 2026-10-31 19:02 KST — H08/QR/ZIP 테스트 추가 실행
- 최신 feature 소스의 9개 Node H08/인쇄/QR 파일 **113/113 PASS**. QR UTF-8 제한·실제 vendored encoder 합성 조합 검증 포함. `tests.test_release` **16 PASS / 2 SKIP** (symlink capability unavailable).
- Edge/file:// 실제 흐름은 Computer Use가 URL 판별 실패로 시작 전 중단되어 BLOCKED/UNVERIFIED. UI 안전 장벽 우회 안 함. QR 카메라/A4/USB/실기기/WinRE도 미검증. Release A HOLD.


## 2026-10-31 19:11 KST — 최신 상담 fixture를 포함한 내부 ZIP 확인
- 원격 허용목록 **37/37 Git blob SHA 일치**. 내부 ZIP 생성 + `--verify` PASS; checksum `5829af28d9e26309aafc7f0fd614b330186df39d93024be026675ffac6a4f4d9`. 동일 입력 재실행 동일 SHA, 38 members, MANIFEST 포함, REPORTS/QA_RESULTS/log/secret 항목 없음.
- Release A HOLD 유지: 실제 Windows/browser/USB/QR camera/A4/WinRE acceptance 미완료.


## 2026-10-31 19:13 KST — 오프라인 QR 브라우저 테스트 환경 확인
- `tests/qr_browser_smoke.py` 선택 실행 전 의존성 확인: Playwright 있음, OpenCV(cv2) 없음, Chromium 명령 PATH에 없음. 테스트 미실행, 설치/다운로드하지 않음. Computer Use URL 판별 차단도 있어 실제 file:///카메라 검증은 **UNVERIFIED**.


## 2026-10-31 19:29 KST — PC CARE 수정본 전체 QA 최종 재확인
- 원인/수정: Node 24의 기본 spec reporter는 `ℹ tests N`을 출력하지만 preflight가 `# tests N`만 찾아 전체 runner의 Node 단계를 실패 처리. `tools/preflight.py`에서 TAP reporter를 명시하고 `tests/test_preflight.py` 회귀 추가.
- `cmd.exe /d /c products\pc-care\RUN_RELEASE_QA.cmd`: **exit 0**; Python **75 PASS / 3 SKIP (78 total)**, Node **113 PASS**, internal ZIP PASS, Windows PowerShell 5.1 synthetic PASS. 최신 receipt status=pass.
- 앞선 전체 runner 실패는 수정본 통합 재검증으로 해소. QA는 synthetic/source only이며, 실PC 진단/수리·브라우저 file:///USB·QR 카메라·A4/PDF·WinRE/배포는 미검증. Release A 공개 **HOLD**.
- 작업은 `feature/pc-care-usb`에서만. `main`/Cloudflare Production, 원본 로컬 프로젝트 및 고객 데이터 변경 없음.


Node 18 compatibility follow-up: removed the Node 18.15+ TAP reporter option; both TAP and SPEC summaries are tested. Targeted preflight tests: 10 PASS, 1 SKIP. Full aggregate QA not rerun after this follow-up. Real device/browser/camera/WinRE validation remains unverified.

## 2026-10-31 KST — CUBE Codex post-review QA skip accounting
- Codex delivered baseline 5c7e9ea1d636cafbc255959e38560037427490ca, nine commits vs previous branch base. Reviewed concrete changes: PowerShell // comment fix, consultation JSON/HTML saved pair fixture, history fixtures, preflight Node 18/24 output parsing. These source changes are confirmed in GitHub; Codex-reported full QA pass applies to earlier 71779d45, NOT latest 5c7e9ea1 or this review's changes.
- Review found sanitized QA receipts lacked skipped test counts despite Python 3 symlink-capability skips. Updated tools/preflight.py to parse Python unittest skipped=N and Node TAP/SPEC skipped N, emit bounded sanitized skipped fields and console note. All-tests-skipped suites now fail closed instead of claiming coverage. Added two synthetic unittest regression methods to tests/test_preflight.py including malformed skip values and Node 18/24 formats.
- During implementation detected unintended Python source text duplication from programmatic replacement; immediately restored from verified Codex baseline and reapplied changes using literal-safe replacement. Latest source readback: one module main and one import section; fix verified by static review only.
- Native Windows QA is NOT RUN after this review. No user device read/repair, no main/Cloudflare change. Release A/B HOLD; full product readiness still requires browser/file://, USB Unicode, camera QR, A4/PDF, actual read-only diagnosis, WinRE testing. Re-run cmd.exe /d /c products\\pc-care\\RUN_RELEASE_QA.cmd from complete Windows checkout.


## 2026-10-31 KST — PC CARE Release A P0–P7 QA update
- Verified branch feature/pc-care-usb source baseline 689428717a2ee0c67244fd83b64700414fce7234; functional QA/runner fixes committed as 3e3278a98b94abd7f419bfe1b2c7402bdbd2d5a4. main remains fbb32362455378b85bcdd0b5037d1f338055fb71.
- Final cmd.exe /d /c products\pc-care\RUN_RELEASE_QA.cmd: exit 0. Python 81 total (78 PASS/3 SKIP), Node 113 PASS, internal ZIP verification PASS, Windows PowerShell 5.1 synthetic PASS. Python ZIP suite 18 total (16 PASS/2 SKIP). Skips are symlink/rename capabilities unavailable in this Windows sandbox.
- Direct Windows smoke: 19 PowerShell parse checks and event, incident, telemetry, timeline, JSON/HTML report pair, consultation, share, report-I/O fixtures PASS. Repeated with the isolated product snapshot under a Korean directory containing spaces.
- Report JSON/HTML save/readback and existing-file preservation are verified synthetically. Storage, event provenance/uncertainty, PnP/updates, stale evidence protections and ZIP allowlist integrity have synthetic regression coverage.
- Edge + Playwright file:// attempt timed out without page output and was stopped; QR browser smoke not run (OpenCV unavailable). Actual camera, A4/PDF print, physical USB, live Windows diagnosis, WinRE and release/distribution acceptance remain UNVERIFIED. No deployment or live repair. Release A remains HOLD.
- Estimated readiness ~70% (rough engineering estimate, not a release certification). Next: dedicated Windows 11 read-only acceptance; approved browser/QR/PDF validation; removable USB/unplug test. Updated 2026-10-31 KST.


## 2026-10-31 KST — QR/H08 independent hardening
- Current source baseline 04b3782285b9b56b8388613013b6c4174b915775; code commit 7607a15ae22411bf6efe8698a091abc0fd1f1787 on feature/pc-care-usb.
- QR UI now rejects omission counts outside 1–4 and requires exactly two displayed signals when an omission marker is present. PowerShell producer test asserts the six-category maximum and exact “two shown + four omitted” output.
- H08 tests now cover 25 JSON files at exactly 12 MB, +1 byte aggregate rejection before read, 2 MB individual-file acceptance, and +1 byte rejection before read. Report-pair E2E asserts saved HTML has no external network resource references.
- All Node suites: 117 PASS. Full Release QA: exit 0; Python 81 total / 78 PASS / 3 SKIP; Node 117 PASS; internal ZIP verification PASS; Windows PowerShell 5.1 synthetic PASS.
- Actual Edge/file:// interaction, QR camera decode, printed A4/PDF, physical USB and real-device diagnosis remain UNVERIFIED. Release A HOLD. main/production unchanged. Updated 2026-10-31 KST.


## 2026-10-31 KST — Additional independent Release A work
- QR UI now accepts only truthful omission counts 1–4, paired with two displayed distinct allowlisted signals. Share payload fixture verifies six unique categories, duplicate storage aliases, and four omitted signals.
- H08 file selection tests cover 2,000,000 bytes/file and 12,000,000 bytes total at boundary, 25-file batch, and +1-byte rejection before reading.
- Saved consultation HTML is checked for external network resource references.
- Full runner exit 0: Python 81 (78 PASS/3 SKIP), Node 117 PASS, ZIP PASS, Windows PowerShell 5.1 synthetic PASS. Standalone share fixture passed after the final wording-only test update.
- Commits: QR/H08 fix 7607a15ae22411bf6efe8698a091abc0fd1f1787; alias dedupe fixture 17114e572342d84596f023e5e00ece5a53674ffd. main/production unchanged.
- Browser/camera/A4-PDF/USB hardware/live diagnosis/WinRE remain UNVERIFIED. Release A HOLD. Updated 2026-10-31 KST.


## 2026-10-31 KST — Latest independent QA
- Fixed receipt path console output to use safe host-encoding escaping; regression test runs with strict CP949 output and an emoji-named result folder.
- Korean+space path copy ran the CMD full QA launcher: all 4 stages PASS. Receipt JSON was present and parsed (Python 81, 3 SKIP; Node 117).
- After receipt-output fix: Python suite 82 total / 79 PASS / 3 SKIP. Full runner exit 0: Node 117 PASS, internal ZIP PASS, Windows PowerShell 5.1 synthetic PASS.
- Code commit: 54f92ced99796f3791d9ed28d0d4d8f3916c1b9f on feature/pc-care-usb. main unchanged.
- Real browser/file://, QR camera, A4/PDF, removable USB, live diagnosis, WinRE and distribution remain UNVERIFIED. Release A HOLD.


## 2026-10-31 KST — latest PC CARE independent work
- Feature branch functional head `ff4042b27ec5b43839518b85fe977479d635da2b` before final documentation update. Changes reject malformed event IDs, invalid RecordIds and boolean/fractional telemetry coercions. main remains `fbb32362455378b85bcdd0b5037d1f338055fb71`.
- Latest complete-source full QA before final focused follow-ups: Python 82/79 PASS/3 SKIP; Node 117 PASS; internal ZIP verification PASS; PowerShell 5.1 synthetic PASS. After final code, targeted event + telemetry PS fixtures PASS. Later aggregate attempts used incomplete recreated source trees and failed Python only for omitted workflow/`.gitignore`; do not count as current full QA PASS. Full QA must run from complete Windows checkout.
- No original local project, device, user data, permissions, production or customer data altered. Task-owned temp copies removed; pre-existing work items preserved.
- Real browser, QR camera, PDF/A4, removable USB, live diagnosis and WinRE/repair remain UNVERIFIED. Release A stays HOLD. Updated 2026-10-31 KST.
