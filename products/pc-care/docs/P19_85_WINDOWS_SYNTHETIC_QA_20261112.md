# AXMART PC CARE P19 — 85% 잠정 엔지니어링 합격 근거 (2026-11-12 KST)

## 1. 정확 검증 대상과 결과
- PRIVATE GitHub: `hibi89/AX_MART`, 기능 브랜치 `feature/pc-care-p15-p18-85-20261112`, 정확 tested source SHA `0ba167682c848056c5717c717b3b0d1ca98a9f3c`, [Draft PR #1](https://github.com/hibi89/AX_MART/pull/1) 미병합.
- **[GitHub Actions run #43131173581](https://github.com/hibi89/AX_MART/actions/runs/43131173581) — completed/SUCCESS**, job `windows-pc-care-p19` **SUCCESS**, Windows-hosted runner, Python 3.11.9, Node 22, Windows PowerShell 5.1 fixture executor, current source SHA matched.
- Python `python -B -m unittest discover -s tests -p 'test_*.py' -v`: **101 tests / 101 PASS / 0 FAIL / 0 SKIP**, including new offline owner readiness/static ZIP membership/duplicate JSON/negative privacy tests. One argparse invalid-option error string in test log is *expected negative test*; overall unittest status OK.
- Node `node --test` all 10 existing case/history/QR suites: **130 tests / 130 PASS / 0 FAIL / 0 SKIP**. Browser DOM is simulated; actual Edge/Chrome file:// not verified.
- Windows `powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File tests/windows_smoke.ps1` **PASS**: 20 PS 5.1 parser targets, synthetic event, incident, storage/telemetry, PnP/timeline, report JSON/HTML/privacy, shared QR, private IO, forced unavailable collector and mocked diagnose E2E; ***without*** `-RunReadOnly` and without actual user PC health scan or repair.
- Deterministic **internal-only** ZIP `AXMART_PC_CARE_USB_v0.1-alpha_INTERNAL_TEST_ONLY.zip` built via `tools/release.py --internal-testing` and independently `--verify` **PASS**; exact ZIP SHA-256 `489483d4805dfa13e7156b1a9c066b1d5271ea6e543277c62150e20894b5d9d3`. This is an ephemeral CI-only artifact, deleted with runner; not a public download or signed installer.
- All four `tools/preflight.py --root .` stages independently re-executed, final reported **status=pass**: `python-tests`, `node-tests`, `internal-zip`, `windows-powershell-51-synthetic`. The script prints no complete-user-scan claim, and explicitly lists real Windows/USB/QR/A4/WinRE/Production as unverified.
- New CI `.github/workflows/pc-care-p19-qa.yml` is feature-branch-only, GitHub hosted, bounded 8min, checkout `persist-credentials:false`, permission `contents:read`, no secrets, no external APIs/customer files/paid marketplace API, no artifact publication.

## 2. 이전 실패 원인·재시도 전환
- First feature CI [#43130988265](https://github.com/hibi89/AX_MART/actions/runs/43130988265) was **FAILURE with zero jobs**, not a code/test fail. Found unquoted colon in YAML step name; local PyYAML rejected it with `mapping values are not allowed here`. Changed the specific step label to quoted YAML. Second action [#43131173581] succeeded with a real Windows runner, test outputs and exact commit. **Do not repeat the original broken YAML or classify first failure as a Windows device failure**.
- Historical repo run [#41034866482](https://github.com/hibi89/AX_MART/actions/runs/41034866482) previously failed before useful Windows logs. This prior failure is not reused as current evidence.
- GitHub hosted test minutes might count against plan quotas; no billing account/payment plan/permission changes performed. No unbounded CI retries or existing production workflow changes.

## 3. Internal final-design percentage rubric
Baseline 70 provisional, target 85 from the **unchanged** `FINAL_SPEC_V2.md` full design. P15 opt-in local customer menu/recovery static card +3pp; P16 fail-closed missing/contradictory storage assessment in existing browser/Python reporter +3pp; P17 developer-only consent path/JSON ambiguity safeguards +2pp; P18 existing internal ZIP/QA wiring and negative tests +2pp; **P19 Windows exact-SHA Python/Node/PS5.1 synthetic/actual internal ZIP SHA verification +5pp**. Total **85% provisional *engineering design coverage*** (70+3+3+2+2+5). No change in 100% scope: no invention of safe full-file backup, physical rescue, or commercial readiness.

## 4. Explicit RELEASE HOLD and 85% boundary
- No testing on owner's physical Windows 10/11 PC, Windows Edge/Chrome `file://`, real removable USB paths (spaces/Hangul/NTFS/FAT32), QR phone camera, actual A4 print/PDF, genuine SMART/Defender source, SmartScreen/Defender signing, licensing/privacy/support/customer pilot.
- **Release B WinRE file copy** remains **not implemented/approved**: no verification of independent physical target, BitLocker unlocked owner permission, cloud-only/EFS/symlinks, partial Robocopy, checksum of real files, damaged-disk handling; only read-only readiness notice.
- No real DISM/SFC mutations or OS/system restore, bootloader changes, partition writes, BitLocker key retrieval or external network/source upload. Production Cloudflare `https://ax-mart.pages.dev` on `main` unchanged, no AXMART³ CUBE deployment.
- SHA256 is integrity aid, **not code-signing or source authenticity proof**. Report `REVIEW_HOLD` is consultation draft, not official diagnosis/repair authorization. Real customer sale, paid distribution and backup/repair release **NO-GO**.

## 5. Reproduction and next owner acceptance
```powershell
# Owner's existing, trusted, complete Windows checkout; synthetic only
git checkout feature/pc-care-p15-p18-85-20261112
cd products/pc-care
RUN_RELEASE_QA.cmd
# Alternatively run each stage:
python -m unittest discover -s tests -p "test_*.py" -v
node --test tests/test_qr_ui.cjs tests/test_qr_vendor.cjs tests/test_history_compare.cjs tests/test_history_dom.cjs tests/test_history_signals.cjs tests/test_history_batch.cjs tests/test_history_print.cjs tests/test_history_issue_allowlist.cjs tests/test_history_evidence_integration.cjs tests/test_case_review.cjs
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File tests/windows_smoke.ps1
python tools/release.py --internal-testing --output NEW_EMPTY_INTERNAL_QA_DIRECTORY
```
Tests may write **synthetic** local reports in runner/temp; not user device source, and CI output ZIP was ephemeral. Owner Windows native/USB/WinRE/customer scope remain additional gates. Test authoritative GitHub exact code SHA `0ba167682c848056c5717c717b3b0d1ca98a9f3c`; docs-only follow-up SHA is separate and must be checked after commit.

## 6. Source preservation / version handoff
- Work isolated in `feature/pc-care-p15-p18-85-20261112`, Draft PR#1 unmerged into unchanged `feature/pc-care-offline-casepack-20261111@9c25ec379899b7e982cba429acf4ef9d01b8ce6e`. `main`, `feature/pc-care-usb`, AXMART³ CUBE branch, Cloudflare Production and user's original files unchanged. Rollback: close Draft PR/revert feature commit, **no force push**.
- Code: `products/pc-care/START_PC_CARE.cmd`, `ui/{case_review.js,recovery_readiness.html}`, `tools/{casepack.py,release.py}`, `tests/{test_case_review.cjs,test_casepack.py,test_owner_readiness_p15.py,test_package.py,test_release.py}`, `.github/workflows/pc-care-p19-qa.yml`.
- QA definition: exact P19 synthetic PASS verifies 85% **internal engineering**, not a security certification; true 95–100 gates are owner Win11 hardware + authorized file/QR/print + careful WinRE VM + genuine retail signing/privacy/pilot.
- Last code verification: GitHub Actions #43131173581 2026-11-12 KST on `0ba167682c848056c5717c717b3b0d1ca98a9f3c`. Updated 2026-11-12 KST; docs HEAD to record independently after commit.
