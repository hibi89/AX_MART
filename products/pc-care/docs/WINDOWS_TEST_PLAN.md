# Windows 실기기 / WinRE 검증 계획 (2026-10-30, 미실행)

**이 문서는 검증 절차이지 테스트 성공 증거가 아니다.** GitHub 브랜치 작업만으로 Windows 테스트 완료 처리 금지.

## 선택안 비교
- A (채택): Windows 10/11 읽기 전용 진단 + 독립 승인형 DISM/SFC + Microsoft 공식 WinRE에서 수동 인벤토리. 코드·라이선스·장애 범위가 작고, 물리 장애에서는 쓰기 작업 차단.
- B (보류): 자체 부팅 ISO/WinPE와 원클릭 복구. 운영체제 이미지 배포 권리·다양한 저장장치 드라이버·BitLocker·데이터 손실 검증 부담 큼. 출시 전 구현 불가.

## 테스트 환경
1. Windows 11 최신 지원 빌드 VM 스냅샷 및 실제 PC 1대, Windows 10 22H2 격리 VM(지원 종료 사실과 별개로 호환성 검증). PowerShell 5.1 기본, 관리자/표준 사용자 계정 각각.
2. USB FAT32/NTFS, 정상 쓰기/쓰기 금지, 드라이브 문자 변경, 보고서 저장 권한 거부 → Documents 폴백.
3. 일반 계정에서 `powershell.exe -NoProfile -File .\tests\windows_smoke.ps1`로 두 ps1 문법 확인. 출력과 종료 코드를 기록한다.
4. 중요 자료 백업 후 `powershell.exe -NoProfile -File .\tests\windows_smoke.ps1 -RunReadOnly` 실행. 새 HTML/JSON 둘 다 있는지, JSON이 파싱되는지, eventCollection이 unavailable인 경우 HTML에서 0건 대신 확인 불가인지 확인.
5. 재실행 3회: 보고서 충돌/누락 없음, 누적 개인정보/외부 통신 없음, 일반 사용자와 관리자 차이 명시. 시스템 이벤트 없는 VM, 저장소 API 미지원, 접근 거부 각각의 실패 표시 점검.
6. MS 공식 복구 매체로 테스트용 VM의 WinRE 명령 프롬프트에 진입해 `recovery\WINRE_READ_ONLY.cmd` 수동 실행. OS 드라이브 식별, 잠긴 BitLocker, 쓰기 불가능 USB, 존재하지 않는 Windows 볼륨 점검. 키 입력·볼륨 해제 기능 수행 금지.
7. **승인형 수리는 백업·VM 스냅샷 복구가 확인된 전용 시험 VM에서만** 수행. `BACKUP`/ `REPAIR` 외 입력은 취소, 관리자 미승인/디스크 건강 Unknown/Warning/조회 실패는 차단, 정상 Healthy 조건에서만 별도 승인 후 DISM/SFC 종료 코드와 로그 검증.
8. 이벤트 41 단독은 BSOD가 아님, 1001 + BugCheck 공급자일 때만 BSOD, 1,500건 절단은 수집분으로 표시되는지 수동/합성 로그로 대조.

## 합격 증거
- OS 버전, PowerShell 버전, 기기/VM(개인정보 제외), 명령, 시작/종료 코드, 예상/실제 결과, 화면 캡처(민감정보 제거), 실패 복구 방법을 테스트별로 기록한다.
- 하드웨어 고장·BitLocker 잠김·불명확한 증상에서 자동 수리 및 위험 변경이 실행되지 않아야 한다.
- GitHub SHA/릴리스 ZIP SHA256, SmartScreen/코드 서명 확인, 백업/복구 시나리오 통과 후에만 무료 공개 여부 판단.
- 현재 결과: **Windows/WinRE/실제 복구 미검증**. Linux 정적 검사와 코드 리뷰는 합격 증거로 대체 불가.

## P0 추가 검증 매트릭스 — 2026-10-30 (미실행)

**첫 실행(Windows 11 x64, 표준 사용자):** 제품 폴더를 로컬 또는 USB에 정상 압축 해제한 뒤 PowerShell 5.1에서 'RUN_SELF_TEST.cmd' 실행. 해당 런처는 PowerShell 파서, synthetic fixture, 1일간의 읽기 전용 진단만 수행. 절대 RUN_SAFE_REPAIR.cmd를 실행하지 말 것. 검사 결과는 REPORTS 또는 Documents/AXMART-PC-CARE-Reports에 저장.

| 경로 | 테스트 방법 | 기대 판정 | 실제 |
|---|---|---|---|
| Parse/BOM | RUN_SELF_TEST.cmd -> Parser.ParseFile | diagnose, repair, event_analysis, synthetic tests 문법 오류 0 | 미실행 |
| 사건 분류 | synthetic fixture 자동 실행 | 1001 잘못된 공급자 제외, 원문 미저장, 41/6008 중복 가능 그룹만 | 미실행 |
| 시간대·기록 지연 | UTC synthetic fixture | 같은 순간 다른 시간대를 동일 UTC로 정규화, 1001 시각은 recorded time | 미실행 |
| 이벤트 조회 결과 | synthetic fixture | empty / access denied / collected / truncated 구분 | 미실행 |
| 이벤트 상한 | synthetic fixture 5건 + max=3 | 반환 3건, truncated | 미실행 |
| 일반 계정 | 기본 읽기 전용 1일 진단 | OS/권한 state, 볼륨/장치/Defender collectionStatus, JSON/HTML 쌍 | 미실행 |
| 이벤트 조회 실패 | 테스트 VM에서 의도적 권한 거부 재현 | unavailable, '0건 정상' 주장 없음 | 미실행 |
| 이벤트 미발견 | 테스트 VM의 로그 없음 | no matching events (접근 거부와 구별) | 미실행 |
| 장치 API 미지원 | StorageReliabilityCounter 미지원 VM | reliabilityStatus unavailable/empty, Wear/온도 모르는 값으로 취급 | 미실행 |
| 잘못된 용량 | synthetic/mock VM에서 Size/FreeSpace null/비정상 | 비정상 볼륨 제외, limitation 명시 | 미실행 |
| USB REPORTS 쓰기 거부 | 테스트 전용 USB 또는 VM에서 경로 권한 제한 | Documents 대체 경로에 JSON/HTML 모두 생성 | 미실행 |
| 양쪽 저장 불가 | VM에서 USB·Documents 쓰기 거부 | 파일 저장 실패, 성공 안내 없음, 시스템 변경 없음 | 미실행 |
| 반복/고유성 | 읽기 전용 실행 3회 | 고유 이름/JSON-HTML 쌍 일치, 이전 보고서 보존 | 미실행 |

주의: 접근 거부·Read-only·로그 임의 삭제와 같은 고위험 실패 재현은 **테스트 전용 VM/USB에만** 적용한다. 평소 쓰는 PC의 시스템 로그·권한·디스크 구성을 수정해서 시험하지 않는다.

**기록 항목:** Windows 빌드/PowerShell 버전, 표준·관리자 여부, 비식별 환경, 명령, 종료 코드, 결과 JSON의 collectionStatus/eventCollection, HTML-JSON 파일 쌍 존재 여부, 실패 원인. 개인 이름/경로/실디스크 일련번호/BitLocker 키/원문 이벤트는 커밋 금지.

**출시 판정:** 위 표는 실행 전 계획이며 합격 결과가 아니다. GitHub 내 소스 검토와 CI 상태는 Windows 실측·WinRE/BitLocker·위험 수리 VM 게이트를 대신할 수 없다.

## 2026-10-30 P0 report persistence fixture (not yet run)

- The Windows smoke suite now includes a synthetic report persistence fixture.
- It uses an isolated temporary directory and has four cases: successful JSON/HTML pair, existing-name collision preservation, fallback from an unusable first destination, and explicit failure when all destinations are unusable.
- The fixture is read/write within only its own temporary directory; it does not run system repair or modify real diagnostic reports.
- Actual Windows PowerShell 5.1 execution, error codes, and output evidence remain unverified.

## P1 initial incident interpretation acceptance cases (2026-10-30, not executed)

The standalone incident_analysis.tests.ps1 fixture is invoked by tests/windows_smoke.ps1 after syntax checks. It makes no operating-system changes.

- Empty/unavailable System log and no physical disk data: incomplete evidence, not a normal health assessment.
- Event 41 alone: possible unexpected shutdown signal, not confirmed BugCheck.
- Valid BugCheck event without storage warning: review needed, but the root cause is not confirmed.
- Storage Warning alongside BugCheck and a truncated event window: storage-first backup guidance, incomplete evidence, no causal or chronological claim.
- Unknown storage health: remains incomplete even when no matching events were observed.
- Data minimization: no model or raw source messages copied into the generated incident findings.

Windows 11 x64 / PowerShell 5.1 parser and fixture execution must pass before considering these checks verified. This does not replace WinRE/repair safety validation.

## 2026-10-30 P1 battery / Windows Update acceptance matrix (not executed)

Scope: Win32_Battery CIM observation and only the Microsoft-Windows-WindowsUpdateClient System event log with IDs 19 (installation success) and 20 (installation failure). Neither proves hardware health or a crash cause. Based on Microsoft Win32_Battery and Windows Update event documentation.

| Scenario | Expected | Evidence |
|---|---|---|
| Desktop with no Win32_Battery instances | battery.status=not_present, batteryCount=0, not an error | Pending Windows 11 |
| CIM access denied or unsupported | battery.status=unavailable, count null; not mistaken for no battery | Pending isolated VM |
| Portable device with supported charge data | chargeRemainingPercent 0-100; explicitly current charge, not battery life | Pending Windows laptop |
| Null, zero, invalid design/full capacity | capacities null, no health percentage fabricated | Synthetic fixture written; runtime pending |
| Battery serial/device identity from CIM | no DeviceID, Name, serial or raw device output in JSON | Synthetic fixture written; runtime pending |
| System WindowsUpdateClient ID 19 or 20 | whitelist provider and ID; recorded timestamp, no raw event Message | Synthetic fixture written; runtime pending |
| WindowsUpdateClient log empty vs denied | status 'no matching events' vs 'unavailable'; never claim an installed update succeeded | Pending Windows VM |
| 300-record event limit | status 'truncated'; bounded output; incomplete evidence | Pending Windows VM |
| Update failure alongside BugCheck | independent review finding; chronological/cause relation NOT proven | Synthetic fixture written; runtime pending |

Windows test entrypoint: tests/windows_smoke.ps1 (default runs parser + event/incident/telemetry/report_io fixtures). The explicit -RunReadOnly switch additionally runs the one-day actual Windows diagnostics; it writes only local report files. Do not run repair as part of these tests.

No Windows 10/11, PowerShell 5.1, USB filesystem, OS log permission or actual battery device verification has been performed for this change.

## P1 driver status + recorded-time timeline acceptance (2026-10-30, unexecuted)

Scope: Win32_PnPEntity.ConfigManagerErrorCode, optional whitelisted PNPClass category; recorded System / WindowsUpdateClient events. Official background: https://learn.microsoft.com/en-us/windows/win32/cimwin32prov/win32-pnpentity and https://support.microsoft.com/en-us/windows/hardware/drivers/error-codes-in-device-manager-in-windows.

| Fixture / Windows condition | Required result | Run status |
|---|---|---|
| CIM device query fails or access denied | unavailable; never claim zero faults | Not run |
| No matching nonzero PnP codes | no matching devices, scoped only | Not run |
| Code 22 intentionally disabled | device_disabled, not active driver failure | Synthetic fixture written, not run |
| Code 28 / 10 | missing-driver / cannot-start records only; not root cause | Synthetic fixture written, not run |
| Raw Name/DeviceID/SerialNumber on sample | excluded from JSON and HTML; class category allowlisted | Synthetic fixture written, not run |
| More than display sample cap | truncated and no false completeness claim | Synthetic fixture written, not run |
| Equivalent timestamps with UTC / +09:00 | sorted/grouped using UTC | Synthetic fixture written, not run |
| BugCheck, update failure and shutdown records near in time | recorded-only proximity, never causal claim | Synthetic fixture written, not run |
| Distant records (>15 minutes from first of window) | separate recording windows | Synthetic fixture written, not run |
| More than 80 accepted event records | only latest 80, timeline.status truncated | Synthetic fixture written, not run |
| Invalid timestamps and unknown event kinds | ignored, no raw messages/paths in timeline | Synthetic fixture written, not run |

Windows entrypoint: PowerShell 5.1 `tests/windows_smoke.ps1` for parser+synthetic fixtures. `RUN_SELF_TEST.cmd` additionally executes read-only diagnostics and creates local JSON/HTML. Never run repair functions as part of read-only verification. No current Windows runtime result exists.

## P2 A4 consultation print / PDF acceptance (2026-10-30; not executed)

Implementation: `tools/consultation_report.ps1` builds a bounded, privacy-minimized consultation object from existing observations, and `tools/consultation_render.ps1` HTML-encodes a dedicated `#consultation-print` section. `tools/diagnose.ps1` adds print-only CSS (`@page` A4 and `@media print`). The browser's Ctrl+P → Save as PDF is the only PDF route. No cloud calls, fonts, printing scripts, or third-party QR engine.

Required Windows 11 / edge cases (all pending):
1. Windows PowerShell 5.1 parses both modules and `tests/consultation_report.tests.ps1` executes successfully without elevated privilege.
2. Windows Edge/Chrome Ctrl+P print preview selects ONLY the consultation summary, not raw disk inventory, full report, detailed issues, or root HTML footer.
3. Korean A4 portrait 100% scale with default Windows fonts: one page, no clipping or overlap; repeat with longer text, browser margins, and PDF output. CSS alone does NOT prove one-page fit.
4. Saved PDF preserves Korean glyphs, Event IDs, UTC recording-time warning, issue categories, 3 repair consultation questions, and non-certification disclaimer.
5. Files containing untrusted HTML characters from synthetic event/issue data do not inject markup or scripts into the consultation section; raw user/device paths and event messages are absent.
6. Missing System/Update logs, zero evidence and Unknown disk health are explicitly incomplete rather than normal/healthy.
7. The consultation model retains at most 4 incident codes and 4 recorded event rows; event dates are only recorded timestamps, never confirmed crash times.
8. Printing, opening or saving the report does not contact any remote service. Any sharing of the complete diagnostic JSON/HTML is a separate explicit user action.
9. Offline USB FAT32 and NTFS paths with spaces/non-ASCII characters, read-only USB → My Documents fallback and printer unavailable should not destroy previous saved reports.

P2 NOT completed: QR encoding and scanning, opt-in QR preview, polished home UI, actual Windows A4/PDF screenshot evidence. Do not approve public release, free download or paid service until Windows/WinRE/repair acceptance gates are satisfied.

## P2 QR-compatible share TEXT acceptance (2026-10-30; no bitmap yet)

Scope: `tools/share_payload.ps1` (pure whitelist/UTF-8 payload builder) and `tools/share_preview.ps1` (local, opt-in expanded text preview). This stage does **not** encode a QR bitmap. Never describe it as scan-ready.

| Case | Required result | Status |
|---|---|---|
| All four assessment labels | Only fixed known Korean labels, no raw source text | Synthetic fixture written; Windows not run |
| Issue codes and source messages with untrusted strings | Only fixed signal categories, never device names, serials, paths, username, raw messages | Synthetic fixture written; Windows not run |
| >2 distinct signal categories | First two categories plus visible 'other N kinds' disclosure | Synthetic fixture written; Windows not run |
| EventId unsupported / malformed UTC timestamp | Excluded, date shown as unavailable | Synthetic fixture written; Windows not run |
| 250 UTF-8 byte boundary | Actual `Encoding.UTF8.GetByteCount`, reject over limit, no silent truncation | Synthetic fixture written; Windows not run |
| Too large | `too_large`, no share payload or textarea | Synthetic fixture written; Windows not run |
| HTML special characters in text/disclosure | Encoded; no injected tags/script | Synthetic fixture written; Windows not run |
| Opt-in | User must expand `details` to view text; explicit select + Ctrl+C, no auto-copy/upload | Synthetic fixture written; browser not run |
| Offline Windows USB / fallback Documents | All references inline, no network, no remote fonts/libs, available after USB removal once HTML saved | Windows browser not run |
| Browser PDF printing | Share panel not included in A4 print; only consultation section prints | Windows browser not run |
| JSON | `sharePreview` stores status/byte count, not payload text | Static source check only |

**Still blocking full QR acceptance:** choose license-compatible local encoder; package it for offline use; user explicitly requests image generation; independently verify actual QR pixels decode UTF-8 without corruption; scan on Android/iOS with Korean and long content; verify quiet zone, error correction, printer and phone camera; assert no unintended telemetry or automatic upload. Until then, share text only. No public ZIP/Kmong offer.

## 2026-10-30 P2 offline QR bitmap implementation acceptance (pending)

Implementation now includes the vendored MIT library `ui/qrcode.min.js`, license `ui/QR_CODE_LICENSE.txt`, opt-in click handler `ui/qr_ui.js`, and `diagnose.ps1` embedding both JavaScript files and the complete MIT license into the saved local HTML. The `share_payload.ps1` 250-byte privacy filter remains mandatory. Code is implemented; **NOT yet a tested/scannable QR feature**.

| Required acceptance test | Current evidence |
|---|---|
| Windows 11 x64 PowerShell 5.1 syntax, fixture + real read-only diagnostics | Not run |
| Open saved HTML from local disk, USB drive, and Documents fallback without network | Not run |
| Before user clicks, QR image/canvas element remains empty | Synthetic fixture written; browser not run |
| Click in expanded preview generates QR using only allowlisted 250-byte text | Static source assertions only |
| Chrome/Edge render an image with proper quiet zone, correct byte count and no clipping | Browser/visual tests not run |
| Android and iOS QR scanner recover exact Korean UTF-8 bytes (including spaces, date, Unicode) | Not run |
| QR scan with a 250-byte boundary payload and several status/signal permutations | Not run |
| Unsupported browser or absent local library switches to text-only mode, diagnostics still persist | Synthetic fixture written; Windows not run |
| Browser print/PDF hides QR/share section, includes only consultation A4 | CSS source inspected; visual test not run |
| QR library includes MIT license in internal ZIP and saved HTML, network transactions remain zero | Static source assertions only |
| Verify copies of generated QR are explicitly treated as user-shareable information | Text warning present; human review pending |

No remote QR encoder, CDN, public upload, user identifier, automatic bitmap on page load, clipboard write or automatic network call was added. The local inline JS is read from the product folder when producing the report. No claim that QR scans successfully until real Windows browser/phone scans demonstrate it.

## 2026-10-30 — launcher hijack protection / QR unit and offline HTML QA (not Windows-tested)

Security change: all three double-click entrypoints `RUN_HEALTH_CHECK.cmd`, `RUN_SELF_TEST.cmd`, `RUN_SAFE_REPAIR.cmd` must call only `%SystemRoot%\\System32\\WindowsPowerShell\\v1.0\\powershell.exe` under quotes and fail closed if it is absent. Running `powershell.exe` via PATH after changing current directory to the USB could otherwise resolve an unexpected local executable. Keep the repair launcher approval gates unchanged. Validation: GitHub source review; Windows CMD execution and path-with-spaces test pending.

Executable independent Node check performed on Linux Node v22.16.0 against a locally exact-matching GitHub `ui/qr_ui.js` source (FNV32 **3087562328**): **6/6** mocked DOM/constructor cases passed (no auto-generation; valid Korean payload generated only after click; 250-byte rejection; bad prefix; absent encoder/library; render failure). Also `node --check` passed. This is **not** a real QR bitmap scan, real Chromium/Edge session, or full GitHub test-suite execution.

New `tests/test_qr_ui.cjs` in repo contains isolated Node built-in `node:test` cases for click-only behavior, UTF-8 limits, malformed/empty input, missing vendors and renderer fallback; it has NOT been executed through the GitHub runner. `tests/test_package.py` now checks all CMD launchers for trusted absolute execution, non-elevation, and the Node fixture. Manual-only `.github/workflows/pc-care-windows-synthetic.yml` includes a Node test step. Windows runners were unassigned in previous run 41034866482; no new Windows QA passed.

`tests/windows_smoke.ps1 -RunReadOnly` now validates the **saved** HTML contract, consultation `@page`, QR capability vs bundled MIT copyright, metadata-only JSON, and no remote `script src` or `link href` dependencies. This reads a locally generated report pair. Confirm no user report contents or private path are uploaded to GitHub or shared with others.

Pending manual tests:
1. Windows 11 standard user, run `RUN_SELF_TEST.cmd` from folder name containing Korean text/spaces and from USB; confirm CMD selects system PowerShell and does not elevate.
2. Simulate USB read-only/inaccessible location and confirm fallback to Documents, never overwrites an existing report.
3. With an inert same-named `powershell.exe` in the USB folder, ensure launchers still call the trusted system path (do not run untrusted programs).
4. Run PowerShell parser, existing synthetic fixtures, read-only report generation. Verify new HTML/JSON contract and no external assets.
5. Open report in offline Edge/Chrome, compare printed A4 PDF and manually generated QR with source text in Android/iOS scanner; check Korean UTF-8 250-byte boundary and quiet zone.
6. Test repair launcher **only inside explicitly authorized disposable VM**; approval gates, backup, error reporting, and no automatic elevation. WinRE requires separate isolated environment. Do not perform disk-changing verification on a real customer PC.


## 2026-10-30 P2 QR stale-image prevention & strict-schema acceptance

- Fixed: `ui/qr_ui.js` now clears any previous QR on `input` and before each attempted generation. Previously an invalid regenerated payload could leave a stale image that no longer matched the visible text.
- QR generation is allowed only for exact seven-line records produced by the whitelist-based PowerShell payload model. Allowed diagnosis levels/signals, recorded UTC timestamp shape, 'incident time not verified', 'cause not confirmed' and backup advice are verified again in the browser. Extra lines or unknown diagnostic/source strings are rejected.
- Updated `tests/test_qr_ui.cjs` to 17 synthetic Node cases. `tests/test_package.py` now checks the schema, stale QR prevention, and optional browser scanner harness.
- **Local runtime evidence:** Linux Chromium via Playwright with the exact committed `ui/qr_ui.js` checked 13/13 synthetic DOM/QR-constructor behaviors (no onload QR, click Korean payload, 250 bytes, invalid regeneration clearing, input edit clearing, strict schema, no external HTTP requests). No vendor bitmap or phone scanner involved in those 13 checks; source identity confirmed by Git blob SHA. Browser script `tests/qr_browser_smoke.py` newly committed but not run with the real vendored QR code due unavailable source in this container.
- **Required acceptance:** Run `python tests/qr_browser_smoke.py` in an offline developer environment with local Chromium, `playwright`, `opencv-python` installed; verify strict QR text round trip from the real vendored QR library, exact Korean UTF-8 hash, quiet zone, no network, generated image clearing on edit, no extra free text. Next run on actual Windows 11/Edge/Chrome then Android/iOS camera scanner.
- Continue to prohibit public beta/QR-verified claim/paid listing until all real Windows/USB/Print/WinRE gates are passed.
  
## 2026-10-30 — QR 기록시각 실달력 검증

- 발견: 기존 QR JS 유효성은 시각 문자열 형식만 검사해 2026-02-30 03:10 또는 평년 2월 29일 같은 **실제로 존재하지 않는 날짜**가 QR로 처리될 수 있었음.
- 수정: `ui/qr_ui.js`에서 날짜/시간 문자열을 파싱한 뒤 `Date.UTC` 및 UTC 연·월·일 재비교로 실달력 유효성 검사. `미확인`은 명시적 누락 상태로 유지. 임의 사용자 장치 이름과 7줄 이외 문장은 여전히 차단.
- **실제 실행 증거:** GitHub 최신 `ui/qr_ui.js` Git blob `13faebe44753b73f2a1cf9c99308aab220745276`에 일치하는 파일로 Chromium headless에서 기존 QA 13/13, 날짜 경계 7/7 = **20/20** 가짜 QR 생성자/브라우저 DOM 실측 통과. Node `--check` 통과.
- `tests/test_qr_ui.cjs`: 총 21개 synthetic Node 회귀 테스트 작성(이 네 가지는 GitHub CI에서 미실행). `tests/qr_browser_smoke.py`에도 실제 QR vendor + OpenCV 디코딩 이후 날짜 5종 acceptance checks 코드 추가(스크립트 미실행).
- **미해결:** Windows 11 PS5.1/브라우저 실제 QR 이미지/UTF-8 한글 디코딩/스마트폰 스캔, Windows USB, A4 인쇄, 실제 ZIP 테스트. 라이브러리 직접 로컬 복사가 이번 컨테이너에서 불가능해 벤더 스캔 성공 주장 금지. 개발자 PC에서 `python tests/qr_browser_smoke.py --chromium <설치경로>` 실행하도록 후속.

## 2026-10-30 — UTF-8 BOM/QR payload scanning gate

- Bundled qrcodejs source inspection: its UTF-8 encoding code prepends EF BB BF when the text contains non-ASCII characters. Thus a QR generated from Korean text can decode to a string beginning with Unicode U+FEFF, rather than a byte-exact copy of the seven-line visible text. This is not personal data, but it changes the raw bytes and may affect scanning or sharing on some devices.
- Independent Linux Python `qrcode` + OpenCV `QRCodeDetector` reference experiment using synthetic Korean text (not the bundled JS): without BOM, encoded string decoded exactly; with BOM inserted, OpenCV returned a leading U+FEFF and raw string comparison failed. This demonstrates the *decoder behavior*, NOT actual bundled qrcodejs scanner performance.
- `tests/qr_browser_smoke.py` now reports `leading_utf8_bom_detected`, explicitly accepts only zero or exactly one leading U+FEFF for canonical text equality, compares normalized content SHA-256, and rejects all other prefixes/suffixes. Do not silently strip arbitrary characters or present BOM-aware canonical equality as byte-identical raw encoding.
- Required before release: run the actual bundled library in offline Chromium, capture the PNG, decode and compare canonical text, record whether BOM is present and check smartphone camera behavior. If BOM causes customer-visible artifacts, consider an alternative standards-compliant ECI/UTF-8 QR encoder and retest license/bytes/scan; do not patch the vendored minified library without its own regression tests.
- Actual QR scanner script not yet executed, no Windows/PowerShell/WinRE tests. Local Chromium QR *UI mocked* checks 20/20 on the exact GitHub JS blob 13faebe44753b73f2a1cf9c99308aab220745276. GitHub runner still not assigned and workflow remains manual-only.


## 2026-10-30 — actual bundled QR engine bugfix: Korean/ASCII byte-buffer overflow

**Reproduced failure:** the *original, exact* `products/pc-care/ui/qrcode.min.js` GitHub blob `993e88f396640f881b69f98db7a4d17401ef83ca` executed in a sandboxed JavaScript VM with an inert DOM. The 7-line Korean consultation payload (195 UTF-8 bytes, which is below our 250-byte sharing limit) threw **`Error: code length overflow. (2180>1728)`**. UI-only/mocked-QR tests could not detect this.

**Root cause:** the minified upstream qrcodejs UTF-8 encoder reuses its per-character `b` array. After a Korean character populates 3 bytes, a later ASCII character overwrites only `b[0]` and mistakenly retains the previous `b[1],b[2]`, artificially inflating the data. It is *not* a 250-byte limit bug or a legitimate QR capacity failure.

**Minimal reversible patch:** only one 5-character insertion `b=[];` at the start of that character loop in `ui/qrcode.min.js`, while preserving the original MIT license/attribution `ui/QR_CODE_LICENSE.txt` and offline no-network behavior. No server, QR provider, model, or architecture change.

**Executed runtime verification** (no Windows/phone):
- Evaluated the actual patched vendor minified JavaScript in an isolated V8 environment, not a fake QR constructor. Six cases including the Korean 7-line payload, `한A`, `한A1한B`, `테스트2026-10-30`, `AXMART 제품 v1`, and ASCII-only were **6/6 byte-for-byte** against the expected UTF-8 byte stream (including the vendor's documented 3-byte BOM for non-ASCII). The reference QR matrix for the main 195-byte text was **57x57 modules**; all three 7x7 finder patterns were validated.
- Transferred the actual vendor-generated QR module bit matrix to a local Python OpenCV `QRCodeDetector` fixture, rendered with a 4-module quiet zone and nearest-neighbor scaling. QR was **detected and decoded**, and the exact decoded string was **U+FEFF + original seven-line Korean text**; removing exactly one *reported* leading BOM restored text equality. This proves the encoding algorithm/QR matrix is decodable by OpenCV, but not real Chromium/Windows display or Android/iOS camera scanning.
- Added `tests/test_qr_vendor.cjs` (six Node built-in test cases using the *actual* vendor and a mock DOM, covering buffer reset, UTF-8 bytes/BOM, QR matrix and ASCII/Korean transitions); wired it into the existing **manual-only** Windows CI alongside `tests/test_qr_ui.cjs`. These newly committed CI Node cases have **not** run in GitHub Actions because the previous workflow runner was never allocated. `tests/test_package.py` adds source/approval regression.

**Remaining acceptance:** run `node --test tests/test_qr_ui.cjs tests/test_qr_vendor.cjs` on a normal developer machine, the local `tests/qr_browser_smoke.py` against actual saved offline HTML and Chromium canvas, confirm exact Korean decoded text with reported BOM, and manually scan on Android+iOS before any public release. Windows PowerShell 5.1 diagnostic/report/USB/WinRE and A4 single-page PDF tests remain separate release blockers.


## 2026-10-30 — QR matrix compatibility 252 cases and real file URL gate

- **Executed:** patched vendored MIT `ui/qrcode.min.js` under isolated V8 (not a mocked QR constructor) encoded 252 valid synthetic combinations. Four assessment statuses × 21 signal one/two-type choices × three omission markers, all valid and within the 250 UTF-8-byte sharing boundary. 252/252 PASS; max source payload 228 UTF-8 bytes, QR module widths 53–61. No code-length overflow regression. The vendor inserts 3 extra BOM bytes when Korean is present.
- **Committed:** `tests/test_qr_vendor.cjs` now contains a deterministic 252-case regression that tests actual vendor parsed bytes against `Buffer.from(text, "utf8")` and checks QR matrix size. This new file/CI suite is committed but was not itself run by an assigned GitHub Actions worker.
- **Improved browser scanner gate:** `tests/qr_browser_smoke.py` saves complete inline HTML/JS to a Korean-named local file and opens it using `page.goto(file://...)`, rather than inserting content into an artificial page. Routes abort external HTTP/HTTPS requests; the test checks no HTTP requests/JS exceptions for the whole session, QR PNG/OpenCV decoding, explicit leading-BOM handling, stale symbol clearing, impossible/leap-day dates, and malformed regeneration.
- **Blocker / attempts:** Tried to fetch publicly available pristine MIT vendor into the local Chromium container for direct comparison with the GitHub patched blob, but raw hosting/download access was restricted or unsuccessful. No private GitHub source was published to external hosting and no fake runtime result was reported. Since two retrieval approaches failed without usable download progress, stop the same attempts; instead execute the already committed offline browser scanner where source checkout and Chromium coexist.
- **Required next:** Windows 11/Edge+Chrome `RUN_SELF_TEST.cmd` and local saved report HTML/JSON; actual QR full vendor render/UTF-8 OpenCV round-trip; camera scan iOS/Android; A4 print one-page, USB removal/permission failures, WinRE read-only/B-safe release separately. Never equate 252 V8 QR encoding checks with a real phone scan.


## 2026-10-30: START_PC_CARE.cmd 비관리자 메뉴 수용조건 (코드 추가, Windows 미검증)

- Windows 11 x64 CMD에서 정상 실행; 사용자 권한 자동 상승/복구/네트워크 작업 없음.
- 메뉴 [1]은 기존 RUN_HEALTH_CHECK.cmd를, [2]는 RUN_SELF_TEST.cmd를 호출. 둘 다 완료 후 메뉴로 돌아오며 실제 진단 오류코드가 표시되는지 확인.
- 메뉴 [3]은 로컬 REPORTS/문서 폴백 경로만 안내하며 보고서 자동 업로드·열람·삭제 없음.
- 메뉴 [4]는 WinRE와 백업/수리 분리 안내만 표시하고 repair.ps1 또는 RUN_SAFE_REPAIR.cmd를 호출하지 않는다.
- 메뉴 [0], 비정상 입력, 누락된 진단/자가검사 실행기, 신뢰 경로 choice.exe 부재 시 fail-closed.
- USB 경로에 공백/한글/괄호/앰퍼샌드가 포함된 경우, 표준 사용자·Windows 10 22H2·USB 읽기 전용 여부를 별도 테스트. CMD CALL 경로 특수문자 및 종료 코드 전파는 실기기 확인 전 PASS 선언 금지.
- 내부 ZIP에 START_PC_CARE.cmd 포함, 정적 보안 회귀는 test_package.py 및 test_release.py로 검사. 현재 Windows 실제 실행 결과는 **미검증**.
