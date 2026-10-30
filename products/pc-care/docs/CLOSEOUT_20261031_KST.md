# AXMART PC CARE — 2026-10-31 KST 작업 마감 / 다음 채팅 인수인계

> **수치 기준:** 전체 예상 완성률 **약 50%** (Release A+B + 출시 필수 실증 포함; 실측 KPI가 아닌 범위/미완 항목에 따른 보수적 작업량 추정).
> Release A 핵심 기능 소스 약 **80~85%**, Release A 출시 준비 전체 약 **60~65%**, Release B WinRE 파일 백업 약 **20%**.
> 퍼센트는 합격률·실기기 성공률·배포 준비 완료를 뜻하지 않는다.

## ① 목표·확정 기술·기능
- 정본: `docs/FINAL_SPEC_V2.md`, `docs/PRODUCT_AND_INTEGRATION_BASELINE.md`, root `AGENTS.md`/`REQUIREMENTS.md`.
- Windows 11 x64에서 설치 없이 동작하는 PC CARE: 로컬 읽기 전용 HEALTH → 증거 ANALYZE → JSON/HTML 및 A4/QR 상담 REPORT → WinRE 상태 확인(Release A), 제한 승인형 복구 안내/실행 게이트.
- Release B의 실제 사용자 파일 WinRE 백업은 **미구현/미검증**. 판매·무료 공개 승인 없음.
- Windows PowerShell 5.1/CMD/HTML/JS, 로컬 파일, 서버·로그 업로드·유료 API 없음.

## ② 현재 소스 완료 기능·중요 결정
- 실코드 파일 확인: `tools/diagnose.ps1`, `event_analysis.ps1`, `incident_analysis.ps1`, `telemetry_analysis.ps1`, `pnp_analysis.ps1`, `recorded_timeline.ps1`; `consultation_report.ps1`, `consultation_render.ps1`, `share_payload.ps1`, `report_io.ps1`; `ui/history_compare.js`, `history_print.js`, `qr_ui.js`; `tools/repair.ps1`, `tools/release.py`, `tools/preflight.py`, `RUN_RELEASE_QA.cmd`, `recovery/RESCUE_READINESS.cmd`.
- 최근 수정: H08 경고의 수집 출처 검증과 볼륨/위험도 비교; 분석 incomplete의 대표 판정 반영; 보고서 동기화·네트워크 공유 경로 차단; 물리디스크 이름/식별 텍스트 대신 검사용 순서 번호.
- UI 화면·마케팅보다 실제 Collector → Normalizer → Analyzer → Report 경로 및 안전을 우선. 정상 기능·원본 보존, USB에서 별도 관리자 자동 승격 없음.

## ③ 테스트 명령·결과·미검증
- Windows 개발 체크아웃: `cd products\pc-care` → `RUN_RELEASE_QA.cmd` (합성 PS5.1 + Python/Node + 내부 ZIP). **최신 소스에서는 미실행**.
- 실제 읽기 전용 실행은 별개: `powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File tests\windows_smoke.ps1 -RunReadOnly`; 이 명령은 해당 Windows에서 실제 로컬 JSON/HTML을 생성하므로 테스트 환경·보안/저장위치 확인 후 수행. 수리/WinRE는 실행하지 않음.
- 최신 소스 `9eddda6477b3a5e4eba9aadf1b471a122f35c949`: report disk privacy 원본 검사 14/14 PASS, PowerShell 합성 테스트는 작성만 하고 **NOT_RUN**.
- 이전 소스 `6e85e521ddfe6489e5ff9ddcfccae6d82213cd09`: H08 공식 JS 61/61 V8 Node 호환 어댑터 PASS (native Node 아님).
- 이전 별도 SHA들의 Linux Python release/preflight 합성 native 테스트 PASS 증빙 `tests/evidence/native_package_preflight_qa_20261031.json`, `release_actual_python_native_20261031.json`. **최신 전체 소스의 full native QA PASS는 아님**.
- GitHub Actions: 마지막 조회한 PC CARE Windows run SHA `5c6c794d0ac59615e28726051d2751e0f065e4c9` = failure; 현재 SHA 새 CI 없음. 러너/로그 확인 한계 때문에 소스 실패 또는 PASS 단정 금지.
- 실제 Windows 11, FAT32/NTFS USB, OneDrive·junction, 로컬 Edge/Chrome file://, QR 카메라, A4 PDF 출력, 복구·WinRE·BitLocker·물리 장치 백업: **UNVERIFIED**.

## ④ 완료/진행/대기/차단
- 코드/테스트 fixtures: 상당 부분 작성. 위 완료율은 **추정**이고 최종 기능별 수용검사는 미완료.
- Release A: 실제 WinPS5.1 parser/fixtures → 안전한 읽기 전용 현장 JSON/HTML → H08·QR·A4 UI → USB·데이터 보호 수용검사 대기.
- Release B: WinRE 실제 선택 파일 복사/검증 상태기계와 하드웨어/BitLocker/VM 안전성 증명 전 개발 및 출시 보류.
- 고객/Production 배포: HOLD. `main`/Cloudflare 운영 수정하지 않음.

## ⑤ 장애·시도·재시도 금지·대안
- 문제: 현재 ChatGPT 실행 환경에 Windows PowerShell 5.1 실행 경로 없음. 기존 GitHub Actions Windows runner는 이전 SHA에서 실패했고 유효한 최신 로그 없음.
- 시도: GitHub 소스 계약 검사 및 제한된 V8/이전 Python 네이티브 합성 테스트; 최신 변경 시 원격 Git blob readback.
- **금지:** CI 러너 실패에 대한 무의미한 반복 dispatch, Windows 미실행을 PASS 처리, Release B 복구/파일 복사 무단 실장, `main` 병합·Production 배포·가짜 성공률·프로덕션에 고객 데이터 게시.
- 대안: (1) Windows PS5.1 환경의 합성 QA, (2) 사전격리 Windows VM의 읽기 전용 E2E, (3) GitHub Actions 러너 가용성 회복 후 동일 SHA CI. 우선순위는 1→2→3.

## ⑥ 저장소·브랜치·SHA·주요 경로
- Private repo: `hibi89/AX_MART`, branch `feature/pc-care-usb`.
- **기능 소스 마감 기준 SHA**: `9eddda6477b3a5e4eba9aadf1b471a122f35c949` (`fix(pc-care): redact device-provided names in local diagnostic reports`).
- 당시 `main` SHA: `fbb32362455378b85bcdd0b5037d1f338055fb71`; `main` 변경 없음.
- 이 문서는 소스 마감 이후 **문서 정리 커밋**에서 생성되므로, 문서 commit SHA와 기능 소스 SHA가 다름. 재개 시 HEAD와 이 SHA를 비교하고 새 커밋이 있으면 우선 확인.

## ⑦ Production·실행·환경
- AXMART 기존 운영 URL: `https://ax-mart.pages.dev/` (Cloudflare Pages); 현재 PC CARE 기능 브랜치 **운영 배포 미적용**.
- 실행: `START_PC_CARE.cmd` / `RUN_HEALTH_CHECK.cmd` (제품, Windows), `RUN_RELEASE_QA.cmd` (내부 QA).
- 코드서명·SmartScreen·정식 ZIP 사용자 배포는 아직 수용검사 미완료.
- Production URL의 제품 변경 사항은 없어 검증 대상 아님. 기능 브랜치의 실제 Windows 기능은 검증 대기.

## ⑧ 원본·백업·비밀·수정 금지
- 기존 코드/데이터의 복구 기준은 기능 SHA `9eddda6477b3a5e4eba9aadf1b471a122f35c949`. 강제 푸시·이력 덮어쓰기·계정/권한/키/유료 연동 변경 없음.
- 사용자 생성 `REPORTS`, `QA_RESULTS`, Windows 원본 로그·계정/디스크 시리얼·BitLocker 복구키를 GitHub나 사용자 배포 ZIP에 포함하지 말 것.
- 진단 보고서의 로컬 저장만 승인된 기본 동작. 출력물의 개인정보는 공유 전 검토. 자동 업로드 금지.
- `main`, Cloudflare 배포 설정, WinRE 복구/백업, 실 디스크 쓰기 명령은 별도 검토/승인까지 보호.

## ⑨ 다음 시작 순서·완료 기준·필요 승인
1. GitHub `feature/pc-care-usb` HEAD 확인 → 이 문서 → `HANDOFF.md`/`STATUS.md` → `AGENTS.md`/`REQUIREMENTS.md` → 핵심 소스 (기존 테스트 반복 최소화).
2. 실행 가능한 Windows PS5.1 환경에서 `RUN_RELEASE_QA.cmd` 전체 결과 확보. 최신 SHA와 테스트 영수증 일치, Python/Node/PS/ZIP 각각 PASS/FAIL/BLOCKED 기록.
3. Windows 11 격리 환경의 **읽기 전용** 보고서/JSON·HTML/개인정보·H08/QR/A4/USB 시험. 진단은 로컬 파일 작성 수반.
4. Release A 수용검사가 합격한 뒤에만 출시 논의. Release B WinRE 실제 사용자 파일 백업과 위험 복구는 별도 설계·사용자 승인·VM/물리 분리·BitLocker/해시 검증 필수.
5. 테스트/코드 주요 변경 후만 `HANDOFF.md`/`STATUS.md` 최신화. 모든 미검증은 그대로 명시.

## ⑩ 갱신 시간(KST)·검증 범위·문서 기준
- 2026-10-31 05:23 KST, 사용자 요청에 따라 오늘 작업 종료.
- 검증 범위: GitHub 현재 HEAD/tree, 코드·문서·기존 증빙·Actions 최근 상태 읽기. **현재 HEAD에서 Windows 실행/실 브라우저/새 CI 수행 없음**.
- 문서 정리 커밋의 부모 SHA = `9eddda6477b3a5e4eba9aadf1b471a122f35c949`; 최종 문서 커밋 SHA는 GitHub push 이후 실제 HEAD로 확정.
