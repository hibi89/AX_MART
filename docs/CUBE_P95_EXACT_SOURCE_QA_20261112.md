# AXMART³ CUBE — P95 actual GitHub Actions acceptance (2026-11-12 KST)

## Scope and score
- Source: private `hibi89/AX_MART@feature/cube-owner-preflight-p85-20261112`.
- **Exact CI-tested commit: `037aa8bf5e9b251d39fa909f4354d10901fa4ed6`**, workflow `.github/workflows/cube-p95-source-qa.yml`; actual owner security/source features include earlier code `a0f5a8c20b937a29f64e5064266cabdeb7cd26e0`.
- Successful workflow: [CUBE P95 exact-source QA #43240934297](https://github.com/hibi89/AX_MART/actions/runs/43240934297). Both jobs `source-native-qa` and `windows-native-qa` **SUCCESS**, no skipped/cancelled original tests.
- Milestone evaluation (internal engineering, subjective scope-weighted): prior P85 +4pp Linux real full 13-file source test/build +3pp Windows hosted native exact-source test/build +2pp real offline headless Chrome DOM rendering +1pp independently verified SHA-bound HOLD owner receipt = **95% internal engineering milestone**. This is NOT a measurement of actual commercial readiness, launch qualification, PC CARE hardware reliability, legal rights or customer sale eligibility.

## Real source proof at exact commit
| Evidence | Linux Ubuntu Node22 | Hosted Windows Node22 |
| --- | --- | --- |
| Fresh GitHub authenticated checkout at workflow SHA | PASS | PASS |
| Native `npm test` all 13 registered suites | **117 pass / 0 fail / 0 skip** | **117 pass / 0 fail / 0 skip** |
| Native `npm run build` actual `index.html`/CSP/catalog/pages | PASS | PASS |
| Full `npm run verify:local` repeated 13 suites | **117 pass / 0 fail / 0 skip** | **117 pass / 0 fail / 0 skip** |
| Owner SHA review build + receipt verify | PASS, `HOLD` | PASS, `HOLD` |
| Actual headless Chrome `file://dist/index.html` JS-generated PC CARE card | PASS | NOT RUN (Chrome on Linux) |
| Production Cloudflare, real customer PC, WinRE/Defender/SmartScreen, license, merchant account | NOT VERIFIED | NOT VERIFIED |

- Test total per environment: 117 on initial `npm test` **plus** 117 on source-bound `verify:local`; do not confuse repeated runs with distinct test case count. Unique suite size **117 tests**.
- `npm run verify:local` prints `technical_local_tests:"PASS"`, `release_decision:"HOLD"`, `sales_go:false`, `browser_windows_customer_legal_verified:false`; Linux/Windows manifests may have different SHA if platform source path or bytes differ. GitHub workflow success means only bounded engineering scope.
- Chrome used headless offline local file and DNS blocking, verified actual `<article class="product-card" data-product="pc-care">` insertion; does NOT assert buyer interaction, accessibility audit, hosted site console/network behavior or actual production.
- Workflow permissions `contents:read`, credentials not persisted; Node22 installed, no dependency install scripts, 8-min per-job limit, no deployment/checkout/payment/telemetry/customer data upload.
- Earlier failed run `#43240539061` was **cancelled** by concurrency after a CI-only Bash line-continuation error; fixed in final SHA `037aa8...`. Never cite the cancelled run as green. Earlier `#43240127330` Linux-only PASS, superseded by both-OS final proof.

## Product and operations HOLD (separate from engineering P95)
- AXMART PC CARE Windows 10/11 real customer devices/WinRE recovery/safe repair, buyer security packages, customer feedback channel and consent, third-party component LICENSE/NOTICE and legal review, actual payment/order/entitlement/refund policy, account and live Cloudflare deployment remain UNVERIFIED or unimplemented.
- Never publish synthetic products, prices, testimonials, checkout, downloads or customer input before owner go decision; keep `RELEASE HOLD / SALE NO-GO`.
- `main` production-linked Cloudflare `https://ax-mart.pages.dev/` and separate PC CARE branches were **not edited** by CUBE P95 work; no actual production SHA reconciliation or end-user runtime claim. Vercel not applicable.
- Original source, design, user data, credentials, product branches and all Git history preserved. Can restore previous feature commit if needed.

## Acceptance and sync
- Product CUBE engineering marker target **P95 met** based on exact-source successful workflow; remove **only CUBE's** `[작업중]` in hub audit row after updating product STATUS/HANDOFF; preserve unrelated products' markers and percentages.
- Next P100: implement and verify actual customer release gates, third-party rights/NOTICE, buyer Windows/WinRE and operational support/payment/entitlement flow with explicit owner approval before any deployment or commercial availability. This is not a requirement to deploy feature today.
- Verification observed from GitHub run/job/decoded logs **2026-11-12 KST**. Functional CI commit `037aa8bf5e9b251d39fa909f4354d10901fa4ed6`; subsequent documentation-only commits must not be misreported as independently retested binaries.

