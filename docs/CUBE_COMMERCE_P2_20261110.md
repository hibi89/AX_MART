# AXMART³ CUBE — P2 Artifact Integrity Preflight (2026-11-10 KST)

## Goal and decision

A software storefront should verify release candidate bytes before contemplating downloadable software. **Existing PC CARE is an unverified alpha, no approved ZIP release or owner authorization.** This feature is a read-only local preflight, not a release engine.

Options compared: (A) directly add auto-download after uploading a ZIP (low development cost but missing Windows/WinRE/security/license proof, high customer risk); (B) inspect an explicitly selected local candidate and print a deterministic hash/size/status receipt, always leaving release blocked. **B selected**, no hosting/auth/payment/CI setting changes, no user data transfer.

## Contract and invocation

The owner may provide a private *manifest* alongside a candidate ZIP in the same directory:

```json
{
  "version": 1,
  "product_id": "axmart-pc-care",
  "source_commit": "b8706e0a77ec245acc7bc0672f121364c851f910",
  "filename": "candidate.zip",
  "size_bytes": 12345,
  "sha256": "<64 lowercase hex digits copied from locally verified candidate>"
}
```

`npm run audit:package -- --manifest /your/private/path/candidate.json`, or
`node scripts/audit-package.mjs --manifest /your/private/path/candidate.json`.

This command never creates or modifies the ZIP, manifest or product catalog. It emits only the product ID, digests, sizes, match flags and *not approved* policy; user file paths, archive contents and private customer data are not printed.

- File must be locally named `^[A-Za-z0-9][A-Za-z0-9_-]{0,99}\\.zip$`, a regular non-symlink file alongside manifest; no absolute/path traversal in filename, no remote URLs or downloads.
- Up to 32 MiB per candidate. Exact file descriptor identity/mtime/ctime/size before/after bounded read, strong SHA-256 check, expected length check, four initial ZIP magic bytes `PK 03 04`. No extraction or code execution.
- Exit 0 when SHA256/size/4-byte signature match, status `CANDIDATE_HASH_MATCH`; **this is NOT validation of archive members, Windows/WinRE functionality, malware absence, code signing, license or customer safety**. A four-byte magic prefix is not a ZIP structural audit.
- Exit 2 `REVIEW_HOLD` if file bytes do not match or non-ZIP header; exit 1 static sanitized `INVALID_LOCAL_PACKAGE_INPUT` for invalid manifest, wrong branch SHA, unsafe path, missing file etc.
- Always `release_allowed:false`, `customer_download_enabled:false`, `payment_enabled:false`, `owner_approval:'NOT_GRANTED'`. Even a valid candidate is not for delivery.

## Evidence and follow-up

- Added `commerce/package-audit.mjs`, `scripts/audit-package.mjs`, `tests/package-audit.test.mjs` (13 cases). Existing P1 `tests/catalog.test.mjs` 19 + `tests/build-catalog.test.mjs` 4 = **36 new Node22.16.0 local tests PASS, 0 FAIL**, using byte-identical source blobs confirmed with local `git hash-object`. P2 initially 13 tests yielded 2 failures because a ZIP header loop changed its own boundary; fixed header byte count and whole new suite 36/36 PASS. Native test suite on isolated new modules + synthetic limited HTML fixture; **original existing `tests/site.test.mjs` with full 105KB index and live Cloudflare site not rerun**.
- Production `main` unchanged, Cloudflare Pages `ax-mart` auto deployment unaffected. Private `feature/cube-commerce-core` only. Product implementation `feature/pc-care-usb` untouched.
- Next real checkout/deployment steps require payment-provider, customer data retention/consent, security, refund & licensing, operational plan and explicit approval; no mock purchase or fake order confirmations.
- Product completion estimate is still constrained by absent auth, checkout, customer inquiry, entitlement, verified distribution, Windows PC CARE evidence, Windows/WinRE VM/real device tests, and live Production verification. P1+P2 alone do not constitute a complete marketplace.
