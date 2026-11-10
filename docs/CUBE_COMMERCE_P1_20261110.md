# AXMART³ CUBE — P1 Catalog Authority / Release-Safety Gate
2026-11-10 KST · private feature branch `feature/cube-commerce-core` (not Cloudflare Production)

## Goal and decisions

The official AXMART³ storefront at `https://ax-mart.pages.dev/` is a static Cloudflare Pages site, while the product implementation exists separately at `feature/pc-care-usb`. Site `main` currently promotes only **AXMART PC CARE** as *in development; no download/payment*. A store must not accidentally expose fake catalog entries, unverified software, checkout, or sensitive GitHub source data.

- **Alternative A:** connect a real payment processor, accounts, DB and downloadable files now. It could provide transactions, but would alter permissions, require compliance/data protection, incur costs, and violate the owner's current release HOLD (Windows/WinRE not tested).
- **Alternative B (chosen):** offline source-of-truth catalog, build-time public JSON with strict default-deny payment/download rules, and owner-only evidence audit. Uses only Node >=18 built-ins, no paid APIs or auth/hosting changes. Storefront HTML unchanged; branch is isolated from Cloudflare Production until explicit merge approval.

## Paths and contracts

- `commerce/catalog.json`: explicit catalog for one existing source-backed product `axmart-pc-care`. Private repository `hibi89/AX_MART`, source `feature/pc-care-usb` pinned to `b8706e0a77ec245acc7bc0672f121364c851f910`; no synthetic items or price. Checks `windows10/windows11/winre/repair_safety/security/license/customer_support/owner_approval` currently **all false**, because verified proof is unavailable.
- `commerce/catalog.mjs`: strict bounded schema, duplicate/invalid identifier, XSS-like text, fake URL, checkout/price/delivery fields and unapproved release state rejected. `readinessReport` returns explicit missing evidence and always `production_release_allowed:false`, including if booleans are flipped; a boolean is not a cryptographic release authorization.
- `publicCatalog` strips all private GitHub branch/commit/checklist details and outputs `NOT_AVAILABLE`, null price/purchase/download URLs, and `checkout_enabled:false`.
- `scripts/build.mjs`: retains original Cloudflare build and byte-identical existing `index.html`, preserves required unverified/disallowed-distribution warnings, and additionally checks catalog against the storefront before emitting `dist/catalog.json`. It fails before output if product info or authorization deviates. It never publishes a package ZIP or enables payment.
- `scripts/audit-catalog.mjs`: `npm run audit:catalog` prints locally computed SHA256 source receipt, evidence blockers and explicit HOLD; it changes no files.
- `tests/catalog.test.mjs` 19 cases and `tests/build-catalog.test.mjs` 4 cases: Node22.16.0 native local full **23 PASS/0 FAIL** on byte-identical new source modules/build/test fixture. Expected Git object SHA verified before GitHub commit for all six source/fixture files. `npm run test:commerce` registered, `npm test` retains original `tests/site.test.mjs`; original index.html was not present in the isolated test checkout, so combined real-repo npm suite and real Cloudflare Production **UNVERIFIED**. The four build tests use a deliberately limited synthetic HTML fixture, not the 105KB visual page. No claim of Production verification.

## Current release policy

AXMART PC CARE is an **alpha, not publicly installable**. Windows 10/11 real hardware, WinRE, repair safety, code-signing/SmartScreen, software licenses, customer support, owner explicit consent, legal/payment terms are not proven. `stage:'released'`, paid price or download links are rejected rather than self-authorized. Future commerce identity/order/payment/fulfillment code must be designed and authorized separately.

## Next completion gates

1. Exact current branch Node full `npm test`, `npm run build`, production candidate desktop/mobile browser test with existing user-approved design and no customer data leak.
2. Source-backed product lifecycle and verified package/owner permission mechanism; paid transaction/payment-provider integration **requires separate approval** and must never fake purchase receipts.
3. Static `catalog.json` can be consumed by future frontend only after explicit main integration review; deploy production SHA and inspect actual site HTTP/JS/Console/Network. Never merge this branch into Cloudflare-linked `main` without approval.
4. After native test and a functioning buyer inquiry/entitlement workflow exists, review provisional product completion; this P1 does **not** by itself make a functioning sales marketplace.

## Evidence and backups

- Baseline `main` SHA `fbb32362455378b85bcdd0b5037d1f338055fb71`; feature branch created from this SHA; rollback by returning feature branch to this SHA or abandoning branch.
- `index.html`, logos/hero, `main`, `feature/pc-care-usb`, live Cloudflare deployment, accounts, domains, permissions and customer files unchanged.
- Live URL `https://ax-mart.pages.dev/` existed previously; current independent web fetch failed (tool access unavailable), thus runtime and production commit mapping **unverified**, not declared broken.
- Testing uses only synthetic fixtures and the existing source metadata already in the private GitHub repository.
