# AXMART PC CARE — Product & Integration Baseline (2026-10-31 KST)

Authority: `docs/FINAL_SPEC_V2.md` (full approved scope); `../AGENTS.md` and root `AGENTS.md` (safety/execution). This is a one-page execution index, not a redesign.

| Item | Confirmed baseline | Acceptance boundary |
| --- | --- | --- |
| Product | AXMART PC CARE portable Windows diagnostics and cautious recovery aid | Evidence-backed diagnosis, local 1-page consultation/QR, consent-only limited repair |
| Main source | `hibi89/AX_MART@feature/pc-care-usb`, `products/pc-care/` | `main` Cloudflare site untouched |
| Runtime | Windows 11 x64, Windows PowerShell 5.1, CMD, local HTML/CSS/vanilla JS | No installation or paid API, no cloud/telemetry |
| Dev/QA | Python 3.11+ packaging tests, Node.js offline UI tests, Windows PS5.1 smoke, optional Chromium | Python/Node NOT required by end users |
| Storage | Locally generated `REPORTS/pc-care-{timestamp}-{nonce}.json/.html` | `Save-PcCareReportPair` create-new, no overwrite; opt-in PDF/QR |
| Collector | `tools/diagnose.ps1` → `event_analysis.ps1`, `telemetry_analysis.ps1`, `pnp_analysis.ps1` | Read-only OS queries, provenance/status required |
| Analyzer | `incident_analysis.ps1`, `recorded_timeline.ps1` | `kind+eventId+origin+UTC offset` validation; no causal certainty |
| Reporter | `consultation_report.ps1`, `consultation_render.ps1`, `share_payload.ps1`, `report_io.ps1` | Whitelisted outputs; QR max 250 bytes; no raw identifiers |
| UI | Local `ui/` HTML/JS and `START_PC_CARE.cmd` | No customer data upload or background access |
| Recovery | `tools/repair.ps1` with backup attestation/consent; `recovery/` WinRE read-only readiness | Release B real file copy BLOCKED until physical disk/BitLocker/capacity/VM proof |
| Packaging | `tools/release.py`, `tools/preflight.py`, `RUN_RELEASE_QA.cmd` | Internal-only ZIP, strict allowlist/hash, never public until acceptance |

## End-to-end flow and boundary contracts

- Trigger: local CMD manual launch. No auto-elevation for read-only scan.
- Input: Windows OS/event/disk/Update/PnP read-only observation; bounds/permission and collection outcome captured. Failed/no-match observations never become evidence.
- Analysis: normalized evidence `{kind,eventId,recordedUtc,timeBasis}` + collection status → bounded findings and noncausal recorded-time groups. Query failure/truncation is disclosed, not interpreted as healthy.
- Output: `schemaVersion:1` local JSON/HTML pair; report paths returned only for the calling test session. Explicit user-controlled print/PDF/QR. Repeated run creates a new pair; no remote storage.
- Repair: different entry point, administrator check + backup declaration + explicit two-stage authorization + storage health gate, then limited DISM/SFC; error exits are not reported as success. This path requires Windows/VM validation before release.
- Recover: rollback by Git SHA; generated reports are local and excluded from customer package. No BitLocker keys, format, /MIR, bootloader change or unmanaged copy.

## Lightweight alternatives / decision

| Option | Speed | Cost | Runtime/maintenance | Selection |
| --- | --- | --- | --- | --- |
| A. Preserve existing PS5.1/CMD local modules and tighten contracts | Fastest, compatible with existing scripts | No API or dependency fee | Single Windows-compatible stack | **Selected under existing approved specification** |
| B. Rewrite in server/desktop framework | Slower; revalidate every module | Extra packaging/hosting risk | New runtime, data/privacy and migration work | Rejected absent new approval |

## Last verified boundary

2026-10-31: source-level contract checks 17/17 PASS for timeline status/origin/kind+ID/UTC enforcement and caller/test linkage; **PowerShell runtime, native Windows 11, USB, QR scan, actual A4 PDF, WinRE, real ZIP, CI are NOT_RUN/UNVERIFIED**. Branch comparison source SHA before this change: `dc53774703d1ea856599c599f3cf4b97418d885c`. The product is not publicly distributable or ready for paid sale. No user data or Production changed.

Next critical-path acceptance: Windows 11 `RUN_RELEASE_QA.cmd` and `tests/windows_smoke.ps1` synthetic → local read-only report pair → offline USB/Edge/QR/A4 → independent WinRE VM/physical-disk safety gate for Release B.
