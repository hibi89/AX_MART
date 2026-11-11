# AXMART PC CARE — P13 owner-triggered offline casepack (2026-11-11 KST)

## Purpose and source of truth

This is an **internal/consultant-only, opt-in, read-only** supplement to the existing Windows PowerShell 5.1 report pipeline; it is **not a Windows product release, repair, diagnosis certification, or customer distribution**. Product baseline is 50% provisional; this small additive utility does **not** elevate the whole-product readiness estimate without actual Windows/customer acceptance.

Code branch: `hibi89/AX_MART@feature/pc-care-offline-casepack-20261111`, cut from stable product `feature/pc-care-usb@b8706e0a77ec245acc7bc0672f121364c851f910`. Original `main` and Cloudflare storefront untouched.

## Implemented functionality

The owner or consultant selects one existing **local** PC CARE read-only diagnostic JSON and a previously nonexistent output directory. `tools/casepack.py` produces three files only: `case-summary.json`, `case-summary.html` (static A4 print CSS and restrictive CSP), and `case-manifest.json`. The report is revalidated as `schemaVersion:1`, `product:AXMART PC CARE`, `mode:read-only`, and matching canonical `consultation` assessment. The case is always `REVIEW_HOLD`; automatic repair, user approval, backup success, verified root cause and external transfer remain **false**.

Only a fixed allowlist of consultation assessment, storage signal, numeric Windows build, eight issue labels and at most four recognized event IDs/valid UTC timestamps enters the packet. Arbitrary report fields, raw event messages, provider, path, username, drive model/serial and details are **never copied**. A complete original report SHA-256 is recorded to detect changes; it is not a digital signature or proof that original diagnostic data was truthful. Manifest hashes bind the two static artifacts. The local `verify` subcommand recomputes deterministic output byte-for-byte against an explicitly supplied original report. Missing/extra files, symlinks, oversized JSON, unsupported reports, malformed dates, wrong assessment, collision and modified source/package are rejected or flagged.

Example in a **private nonsynced local directory**, Python 3.11+:

```powershell
python tools/casepack.py create --source "C:\\PrivateReports\\pc-care-example.json" --directory "C:\\PrivateReports\\new-consultation"
python tools/casepack.py verify --source "C:\\PrivateReports\\pc-care-example.json" --directory "C:\\PrivateReports\\new-consultation"
```

The caller must manually choose a private local path; current portable utility **does not reliably detect every cloud-synchronized folder, mapped network drive, or Windows junction**. Do not use OneDrive/Dropbox/network/shared paths. A generated HTML or case JSON may still contain nonzero time/status information; review before any voluntary sharing. This feature is NOT in the internal Release A ZIP allowlist, and Python is not a customer dependency or promised deliverable. It is not accessible from the current one-click GUI.

## Actual bounded verification

- Local Linux Python 3.13.5: `python -m unittest discover -s tests -p test_casepack.py -q` **9 PASS / 0 FAIL / 0 SKIP**. Actual subprocess CLI `create`→`verify`→modified-original `MISMATCH` passed; existing destination and source files untouched. Tests use synthetic JSON and injected PRIVATE_* markers.
- Chromium system browser with Playwright `page.set_content` of generated HTML: Korean title/REVIEW_HOLD warning visible, no raw private marker, horizontal overflow 0, JS errors 0, **external requests 0**. The environment blocks `file://` direct navigation with `ERR_BLOCKED_BY_ADMINISTRATOR`; **direct offline file opening, Windows Edge, actual A4 printed PDF, QR and camera NOT VERIFIED**.
- Exactly tested Git blob SHAs: `tools/casepack.py` **5343b920f3d85e68ef79dfd266fef1271bfd489a**, `tests/test_casepack.py` **27883f3eee1543a0ce7ecc41564654108b240455**, checked against current GitHub branch after recovery. Full existing 82 Python/117 Node/PS5.1/ZIP launcher and Windows CI were **not rerun** for this feature. No actual Windows diagnosis, repair command, WinRE, disk permission change, customer file, Production, cost or deployment.
- Correction history: A cloud-folder defense draft was malformed during connector update and produced an invalid double-pasted source. The branch was restored immediately to the SHA-exact previously tested 9-PASS module. Additional cloud sync folder blocking is therefore **PENDING**; do not claim it works. Browser `file://` administrative policy is a testing limitation, not proven app fault; `page.set_content` test does not override it. No force-push.

## Design choice, safety and next

Option A: auto-share the full original PC diagnostic HTML/JSON by default (fast, high privacy/cause-misattribution risk). Option B: explicit local-only privacy-minimized review packet with read-only checks and an unapproved status (implemented). Both cost zero APIs; B preserves evidence-boundary semantics at the cost of a developer Python tool and a separate owner review.

Next: demonstrate the tool on a complete synthetic Windows PowerShell-produced report (not a synthetic manually assembled schema), harden cloud/mapped-drive path and Windows NTFS/junction handling, verify A4/QR in a real Windows browser, then connect an opt-in private-consultant workflow only after consent and customer packaging decision. Real physical PC, BitLocker, WinRE, and safety-critical repairs remain separately approval-gated. Internal release/test ZIP and storefront **RELEASE HOLD** unchanged. No customer data uploaded or original source overwritten; rollback is previous `feature/pc-care-usb` parent SHA.
