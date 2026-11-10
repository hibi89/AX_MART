# AXMART³ CUBE — P3 Customer-Facing Offline Product Status Page
2026-11-10 KST · private `feature/cube-commerce-core` only

## Goal & alternatives

AXMART³ currently has a user-approved, sophisticated dark-purple/mint landing page and only one actual source-backed product `AXMART PC CARE`; there are no verified customer accounts, payment providers or released download packages.

- **A: edit the 105KB original inline-JS homepage/enable a checkout panel.** Makes a prominent feature, but risks destroying the owner-approved visual identity, launches unverified software prematurely and needs customer data/security/payment approvals.
- **B: preserve the homepage byte-for-byte, generate a separate public static `/products` information page from the P1 canonical catalog**. No JavaScript, input form, external assets, data collection or transaction buttons. **Chosen** to add a genuinely user-visible artifact while keeping Production safety and zero recurring costs.

## Implementation and validation

- `commerce/catalog-page.mjs` exports `renderCatalogPage(catalog)`, which **revalidates the private source against the strict P1 catalog rules**, then renders ONLY public title, safe description, development status. It escapes text, rejects sale/download URL, product-list manipulation, invalid schema and fake release states. It never includes private repository name, branch/SHA or release checklist.
- `scripts/build.mjs` now emits `dist/catalog.json` and `dist/products/index.html` along with **byte-identical original** `dist/index.html` and `dist/_headers`. Generated page uses static responsive CSS + original platform color scheme (dark violet/mint) and accessible `lang=ko`, semantic header/main/product sections and explicit development notice. No external CDN/font, image, script, form or remote request.
- Strict document meta CSP: `default-src 'none'`, `script-src 'none'`, `img-src 'none'`, `connect-src 'none'`, `base-uri 'none'`, `form-action 'none'`; inline CSS only. A link to root `/` for user navigation is the only anchor.
- `tests/catalog-page.test.mjs` **10 new tests**, including XSS/HTML injection rejection, accidental real checkout/download suppression, zero content transfer, deterministic rendering, required disclaimers, source field privacy, and UI accessibility.
- `tests/build-catalog.test.mjs` already tests a minimal synthetic index fixture and now checks generated `dist/products/index.html` is present, contains the real name, and has no script/HTTP external resource.
- Node22.16.0 local isolated new-module suite: P1 19 + static build 4 + P2 package preflight 13 + P3 status page 10 = **46/46 PASS, 0 FAIL/0 SKIP**, after correcting P3 first failing wording and fixture missing new dependency; exact source files were compared to GitHub blob SHA. The 4 build tests use a small synthetic index, not the unchanged original 105KB homepage. **Full existing `npm test` including `tests/site.test.mjs` and actual Cloudflare Production are NOT_RUN/UNVERIFIED** until owner environment/GitHub CI run.
- Parent `main` branch is Cloudflare Production Git connection and **untouched**; URL `https://ax-mart.pages.dev/products` is a **future route after approved merge**, not a URL confirmed currently present.
- Does not enable payment, accounts, downloads, real customer support or checkout. Existing PC CARE Windows10/11/WinRE/repair/license remains unverified, RELEASE HOLD.

## Product completion assessment

AXMART³ CUBE provisional **45→48%** after P1/P2; P3 adds a new customer-facing safe product-information page and static build delivery for **+2%p**, provisional **50%**. This is a whole-product scope estimate, **not** evidence of production deployment, native full E2E, paid customers or release readiness. Next gate is correct full original homepage compatibility and a permitted, private inquiry/account/transaction/entitlement workflow with explicit data protection/payment approval.
