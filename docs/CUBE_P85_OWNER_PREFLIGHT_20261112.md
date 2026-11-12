# AXMART³ CUBE P85 — owner-only local release preflight (2026-11-12 KST)

## 1. Goal, requirements, technology
Private `hibi89/AX_MART` original `feature/cube-commerce-core` reached 70% provisional engineering. Scope for 85% is a **separate local owner release preflight**, not real checkout, membership, commercial download or Cloudflare deployment. Node >=18 and built-in Node APIs only; static site published via existing Cloudflare Pages main remains unchanged. PC CARE safety tests are owned by another chat/branch.

## 2. Designs compared and selected
- A: Immediately implement a Cloudflare Worker/D1 + identity + payment + customer entitlements in the existing public site. This could support real orders but adds recurring operating cost, new permissions, customer PII, payment fraud/idempotency and unverified PC CARE delivery risk; user approvals needed.
- B: Independent owner-only preflight verifies the existing source-backed catalog against the generated `dist`, publication security headers, disabled purchase/download policy, Korean customer safety disclaimers, and receipt integrity without touching production. Zero hosted/API cost, fewer regression risks and reusable before later real commerce. **Selected B**; no approval-locked external side effects.

## 3. Implemented
- `commerce/release-preflight.mjs`: strict schema checks on source catalog and exact public projection; checkout/download and source-data leakage fail closed. byte-match original `index.html` with `dist/index.html`, source `cloudflare/_headers` with `dist/_headers`; enforce no-script/no-form/no-external-resource static `dist/products/index.html` and `dist/support/index.html` plus required truthful release disclaimers. Symlink parents, oversized/malformed input, changed file during bounded read, duplicate products and incomplete evidence handled conservatively. No original-source edits, HTTP, real user data or secrets.
- Build **new output directory only**: `owner-review.json` (local SHA-256 of eight source/build inputs and eight required product gates), `owner-review.html` (dark Korean owner-facing HOLD summary, no source commit/paths/customer data), and `manifest.json` (unsigned SHA-256 of two outputs, explicit HOLD). Offline `verify` re-derives actual expected report and rejects altered/missing/extraneous output.
- `scripts/release-preflight.mjs`: explicit `build` and `verify` local CLI. Even all eight evidence flags true never gives sale authorization. Reports declare no production publishing, no live inquiry, no payment or entitlement.
- `tests/release-preflight.test.mjs` 26 native tests; `package.json` registers `test:release` and `audit:release` and adds suite to `test` and `test:commerce`. Existing `scripts/build.mjs`, `index.html`, catalog, PC CARE feature and main untouched.

## 4. Actual local verification and boundary
- Isolated Linux Node 22.16.0: `node --check commerce/release-preflight.mjs`, `node --check scripts/release-preflight.mjs`, `node --test tests/release-preflight.test.mjs` → **26 PASS / 0 FAIL / 0 SKIP**; source fixtures include controlled synthetic catalog/build output, CLI subprocess, byte reproducibility, readonly SHA preservation, tamper/forgery, duplicate/SHA/price/download/PII rejection, build-vs-source drift, CSP/remote-form/script injection, path safety, no-overwrite and offline HTML. No external network calls in module.
- Local byte-exact Git blobs equal remote committed files: `commerce/release-preflight.mjs` **6261803efa1eb8f97286130e37c67c81cbea9487**, `scripts/release-preflight.mjs` **e2eb06d9f943278507130ec45966ab843c73259a**, `tests/release-preflight.test.mjs` **72f1d2c8ae27d31cc5f9e95378009fd52ae72941**.
- **NOT RUN:** actual repo full `npm test`, actual original homepage 105KB `npm run build`, real `dist` and brand UX/Chrome/Edge network/console, Windows, actual Cloudflare Production URL/SHA and real customer authentication/payment/release. Synthetic test pass does **not** certify public runtime.

## 5. Usage
In actual authorized checkout of this feature branch, after existing `npm run build` on a clean tree:
~~~sh
npm run test:release
npm run audit:release -- build --root . --output ../AXMART_CUBE_PRIVATE_OWNER_REVIEW_NEW
npm run audit:release -- verify --root . --output ../AXMART_CUBE_PRIVATE_OWNER_REVIEW_NEW
~~~
Output must be a fresh separate folder and never added to the public `dist` or GitHub. Never submit third-party customer data.

## 6. Milestone rubric and release
Prior internal product engineering 70% remains baseline; new audit scope: +4 static homepage/header/catalog byte guard, +4 strict sale/download/data leak HOLD, +3 owner re-derived SHA receipt and deterministic HTML/JSON, +2 local CLI/no overwrite/symlink/size guard, +2 exact source tests = **85% provisional engineering**. Weighted subjective feature-scope estimate, not automated test coverage/customer acceptance. **RELEASE HOLD / SALE NO-GO**. Major missing 15%+ in practical terms: actual customer identity/consent, payment/refund reconciliation, entitlements, support intake/privacy, PC CARE Windows safety, customer download package, deployment/browser/rights.

## 7. Errors and pivot
No persistent test failures in verified run. Node18 compatibility reviewed; `import.meta.dirname` was replaced in the test with `dirname(fileURLToPath(import.meta.url))` and tests reran 26/26. Private full git checkout unavailable in this tool environment; do not assert full native build. Use authorized owner checkout for next gate, no blind paid CI/deployment.

## 8. Ten-point handoff and branch context
1. Goal/tech: standalone zero-network Node18+ owner preflight for CUBE, no commercial operations.
2. Feature decisions: A/B tradeoff and functions above.
3. Tests: local 26 PASS, exact three file blob hashes, missing original npm tests/Windows/real page/Cloudflare.
4. State: 85% provisional engineering with release HOLD; remaining real commerce gates unimplemented.
5. Errors/causes/stop-pivot: Node18 test syntax corrected; native full clone unavailable; no production incident claim.
6. Repository/branch: private `hibi89/AX_MART` original `feature/cube-commerce-core@061addb6e19c15b537181fcd278ce52878f07707`, new isolated `feature/cube-owner-preflight-p85-20261112`. Paths above. Final branch SHA verify after doc update.
7. Production/URL: `https://ax-mart.pages.dev/` main-linked Cloudflare project; **new feature not deployed**, Vercel N/A. Owner command above.
8. Original backups/security: Git base preserves index/catalog/PC CARE and source; no customer data/credentials, Git force, API payments, permissions, live uploads or Production modifications. Normal Git revert possible.
9. Next priorities/approval: authorized full checkout `npm test`+`npm run build`+`audit:release build/verify`, Chrome/Edge/mobile/live HTTP/console/network, actual user Windows, PC CARE safety and licensing, separate payment architecture/approval and explicit production authorization.
10. KST date/evidence: 2026-11-12; exact verified scope added three module/blob files and synthetic 26 tests. Docs-only HEAD and hub HEAD require final readback.
