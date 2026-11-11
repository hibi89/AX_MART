# AXMART³ CUBE P4–P8 — 2026-11-11 KST

## Design decision
Option A: online Worker/D1, payments, account and entitlement immediately. Customer flows could eventually work but require consent, security review, paid/authority changes and PC CARE safety release. Option B: owner-local, fail-closed business state and release safety with future integration. Chosen B (no cost, no account/PII upload, no Production changes).

## Implemented source and contracts
- commerce/support-queue.mjs: metadata-only support request with exact schema, owner_consent, SHA-chained NEW/TRIAGED/WAITING_OWNER/CLOSED; no customer contact, message content, auto-send or web endpoint.
- commerce/transaction-policy.mjs: source-pinned local interest request, deterministic HOLD receipt, never creates price, payment, account, entitlement or download. Duplicate request IDs observable in offline summary.
- commerce/zip-structure-audit.mjs: byte-bounded ZIP central directory and local header, paths, duplicate/symlink/flag/ZIP64 controls, CRC32 verification for stored and deflate, output size and count caps. ZIP structural pass is NOT malware, WinRE, license, or distribution approval.
- commerce/support-page.mjs: no JavaScript, no form, connect-src none, no external resources, truthful nonreleased PC CARE FAQ.
- scripts/cube-offline.mjs: owner passes explicit local --input file. For interest/support, input source_sha256 must equal exact commerce/catalog.json bytes and product ID must exist; invalid/PII field yields exit2 generic HOLD, not path/content exfiltration. For zip, explicit local candidate file only.
- scripts/build.mjs: adds static dist/support/index.html and safety check. Existing index copy, catalog and products release HOLD remain; tests/build-catalog.test.mjs fixture updated to copy new module; package scripts include new suites.

## Test and score boundary
- Node22.16 Linux targeted five new test files: transaction 6, support 5, ZIP 8, support page 2, CLI 5 = 26/26 PASS, 0 FAIL, 0 SKIP. All ten new code/test blobs matched git hash-object; original private catalog 3414c25fe818367a526a2a4132a03c832e672ec6.
- Earlier P1-P3 46/46 PASS is prior source scope. Current full npm test/build (incl original 105KB index, changed build fixture), real browser/Cloudflare/Windows/real customer ZIP not run. Expected 74 tests are NOT reported as executed.
- Milestone rubric: pre-existing 50%; P4 support +4pp; P5 HOLD policy +4pp; P6 ZIP safety +5pp; P7 static support +3pp; P8 SHA-bound CLI/build integration +4pp = provisional 70%. P8 publication build needs full checkout QA. This number measures completed engineering tasks, NOT commercial product readiness.

## Preserve and next
- main fbb32362455378b85bcdd0b5037d1f338055fb71, PC CARE b8706e0a77ec245acc7bc0672f121364c851f910, index blob d8fca85669e73008f55a6eaf93c1c493f8ed707d unchanged. No deploy, live payment, rights, secrets, input uploads or approvals.
- Next authorized owner of branch: full npm test+build; browser direct experience, Windows/WinRE customer safety; product availability/rights/owner approval; approved privacy/secure customer inquiry storage and payment/refund/entitlement design; only then main release.
