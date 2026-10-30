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
