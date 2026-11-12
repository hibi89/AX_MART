# AXMART³ CUBE owner preflight output safety — 2026-11-12 KST

## 1. Goal, requirements and stack
After REA_APP P95 work was blocked by a missing authorized native Windows/Babel environment, user instructed switching to another task. Selected independent AXMART³ CUBE owner preflight, not PC CARE or currently independently developed SOVIA. Original storefront, Cloudflare-linked `main`, PC CARE feature branch and customer assets must stay untouched. Technology: Node >=18, built-in `node:fs` and `node:test`, synthetic/local-only data.

## 2. Options and reason
A. Fix by keeping automatic recursive rollback after `mkdirSync` and trying to verify file ownership/inode before deletion; still vulnerable to replacement between inspection and `rmSync`, difficult to make cross-platform. B. **No automatic recursive cleanup on write error**: fail closed, preserve partial or swapped paths for owner review, require a new output path on retry; cost zero, safer and simpler. **Implemented B**. Trade-off: some failed builds leave partial files behind. No online activity, payment, credential change or external service.

## 3. Actual discovered defect and behavior
Previous exact `commerce/release-preflight.mjs` used `catch(err){rmSync(dest,{recursive:true,force:true});throw err;}`. If a shared output pathname is replaced between `mkdirSync(dest)` and writing the 3 receipt files, recursive cleanup can delete **unrelated replacement directory contents**. Reproduced the Node filesystem semantics with disposable data, and ran the exact previous source against the new race regression: **2 FAIL / 1 PASS**, including a test demonstrating the unrelated file was deleted.
New handler returns `OWNER_PREFLIGHT_HOLD` and never removes or traverses the output on failure. CLI has its existing generic hold/error exit and never publishes.

## 4. Implementation and measured evidence
- Modified `commerce/release-preflight.mjs`: removed unused `rmSync` import and destructive cleanup; output error preserves partial content for manual review.
- New `tests/release-preflight-write-race.test.mjs`: 3 filesystem tests: live replacement with another directory during the second receipt write, partial write failure leaves original for review/no overwrite, ordinary owner receipt build+source-independent verify still passes.
- Updated `package.json` test, test:commerce, test:release scripts to include the new regression without removing original suites.
- **Exact original and new GitHub source blob checks** against the locally executed files: core `b3dc05946b966bd52e347cf3296de2a39e77d264`, new QA `f72ff7f0e3cc490203e25682da115746b9791d98`, original 26-case QA `72f1d2c8ae27d31cc5f9e95378009fd52ae72941`, original CLI `e2eb06d9f943278507130ec45966ab843c73259a` — **4/4 match**.
- Linux Node22.16.0 ran `node --test tests/release-preflight.test.mjs tests/release-preflight-write-race.test.mjs`: **29/29 PASS / 0 FAIL / 0 SKIP**. New safety tests source-only run **3/3 PASS**. Reverting the exact code in a temporary local copy reintroduced failures (1 PASS/2 FAIL), then restoring exact fixed blob returned 3/3 PASS.
- Last GitHub feature code/test + npm-script SHA `34dac38ffac69df00eeb6610e380fbc5d0c37705`, author/committer `hibi89`. No full original `npm test` or `npm run build` at current feature SHA (requires additional files not in scoped local reproduction).

## 5. Status and limits
**AXMART³ CUBE stays 85% provisional engineering / RELEASE HOLD / sale NO-GO.** This is a verified actual safety correction, not proof of total storefront readiness. The existing 26 scoped tests and 3 new tests pass; full project build and test, real Chromium/Edge, actual Cloudflare production, product rights, PC CARE/WinRE, real user/merchant payment and fulfillment are **NOT VERIFIED**. No score increase based solely on test count.

## 6. Repo, branches, SHA and paths
Private `hibi89/AX_MART@feature/cube-owner-preflight-p85-20261112`, tested source `34dac38ffac69df00eeb6610e380fbc5d0c37705`. Previous branch before this change `04d2be272d3b2373a6fc7dd96df968b98b6366c0` is a rollback reference. Preserve `main` production-linked branch and `feature/pc-care-offline-casepack-20261111` independent owner branch without editing or merging. New QA path `tests/release-preflight-write-race.test.mjs`.

## 7. Commands, production and environment
From authorized full checkout: `npm run test:release`, `npm test`, `npm run build`, `npm run audit:release -- build --root . --output ../NEW_PRIVATE_REVIEW`, `npm run audit:release -- verify --root . --output ../NEW_PRIVATE_REVIEW`. The new local scoped 29-test run used Node22.16.0, standard library only. Production may be Cloudflare `https://ax-mart.pages.dev/` but this feature branch has **not** been deployed or used to claim production status; Vercel N/A. Do not alter existing main, domains, access or Cloudflare linkage.

## 8. Source/data security and rollback
Tests created temporary synthetic catalogs/source-dist pages, three owner receipts and a disposable unrelated sentinel. No customer PII, actual commerce transactions, secrets, API requests, original PC CARE binaries, third-party redistribution or external transfer. Failed builds leave possible partial files in a fresh output directory; owner must examine and manually choose cleanup, not automatic deletion. Git previous SHA allows code rollback.

## 9. Next priority and approvals
1. Run full source checkout Node `npm test` and `npm run build` on this exact feature SHA, including static catalog/products/support parity and full old homepage.
2. Run browser static UI/CSP/Network checks against a locally built output; verify no real checkout/login/payment/download/inquiry. Check Windows physical browser and Cloudflare only if authorized and without changing production.
3. Do not raise 85 provisional to 95 or enable real sales, payment, customer data or public deployment without provenance, customer/product rights, privacy/merchant/fulfillment design, live environment evidence and owner approval.

## 10. Handoff date and evidence boundary
2026-11-12 KST. **Verified** exact Git blob parity 4/4; existing 26 + new 3 = 29 PASS; original auto-delete failure reproduced in temporary filesystem and fixed. **Not verified** native production full npm/test/build/Cloudflare, customer Windows/rights/sales. No claims of final 95 completion.
