/**
 * AXMART³ local first product-catalog policy.
 * This module is an offline, data-only validator. It never performs purchases,
 * grants delivery, reads user data, or changes a remote storefront.
 */
import { createHash } from 'node:crypto';

export const CATALOG_VERSION = 'axmart.catalog.v1';
export const REQUIRED_CHECKS = Object.freeze([
  'windows10', 'windows11', 'winre', 'repair_safety',
  'security', 'license', 'customer_support', 'owner_approval'
]);
const IDENTIFIER = /^[a-z][a-z0-9-]{2,63}$/;
const GIT_SHA = /^[a-f0-9]{40}$/;
const PUBLIC_STATUS = Object.freeze({
  development: '개발 중 · 실제 기기 미검증',
  verification: '검증 진행 중 · 제공 준비 안 됨',
  review: '출시 검토 중 · 판매 및 다운로드 불가'
});

function exactObject(value, keys) {
  return value !== null && typeof value === 'object' && !Array.isArray(value) &&
    Object.keys(value).sort().join('\u0000') === [...keys].sort().join('\u0000');
}
function text(value, max = 120) {
  return typeof value === 'string' && value.length > 0 && value.length <= max &&
    value === value.trim() && !/[\u0000-\u001f\u007f-\u009f\p{Default_Ignorable_Code_Point}]/u.test(value) &&
    !/[<>]/.test(value);
}
function fail(message) { throw new TypeError('Invalid product catalog: ' + message); }

/**
 * Validates and canonically recreates an explicit list of real source projects.
 * The only current product is in development. Marking an item 'released',
 * or attaching an unverified link, is not a supported transition.
 */
export function validateCatalog(catalog) {
  if (!exactObject(catalog, ['schema_version', 'products']) ||
      catalog.schema_version !== 1 || !Array.isArray(catalog.products) ||
      catalog.products.length < 1 || catalog.products.length > 20) {
    fail('strict v1 schema and 1-20 products required');
  }
  const slugs = new Set();
  const products = catalog.products.map((p) => {
    if (!exactObject(p, ['slug', 'title', 'description', 'category',
       'source', 'stage', 'checks', 'delivery', 'sale'])) fail('product fields');
    if (typeof p.slug !== 'string' || !IDENTIFIER.test(p.slug) || slugs.has(p.slug)) {
      fail('duplicate or invalid product identifier');
    }
    slugs.add(p.slug);
    if (!text(p.title, 80) || !text(p.description, 300) ||
        typeof p.category !== 'string' || !IDENTIFIER.test(p.category)) {
      fail('product display information');
    }
    if (!exactObject(p.source, ['repository', 'branch', 'commit']) ||
        p.source.repository !== 'hibi89/AX_MART' ||
        typeof p.source.branch !== 'string' ||
        !/^feature\/[a-z0-9][a-z0-9-/]{1,80}$/.test(p.source.branch) ||
        typeof p.source.commit !== 'string' || !GIT_SHA.test(p.source.commit)) {
      fail('unverifiable or non-allowlisted private source reference');
    }
    if (!Object.hasOwn(PUBLIC_STATUS, p.stage)) fail('unapproved release stage');
    if (!exactObject(p.checks, REQUIRED_CHECKS) ||
        REQUIRED_CHECKS.some(check => typeof p.checks[check] !== 'boolean')) {
      fail('explicit evidence checklist');
    }
    if (!exactObject(p.delivery, ['mode', 'path', 'sha256']) ||
        p.delivery.mode !== 'disabled' || p.delivery.path !== null ||
        p.delivery.sha256 !== null) fail('unapproved download or delivery');
    if (!exactObject(p.sale, ['mode', 'price_minor', 'currency']) ||
        p.sale.mode !== 'disabled' || p.sale.price_minor !== null ||
        p.sale.currency !== null) fail('unapproved checkout or pricing');
    return {
      slug: p.slug, title: p.title, description: p.description,
      category: p.category, source: { ...p.source }, stage: p.stage,
      checks: Object.fromEntries(REQUIRED_CHECKS.map(k => [k, p.checks[k]])),
      delivery: {mode:'disabled', path:null, sha256:null},
      sale: {mode:'disabled', price_minor:null, currency:null}
    };
  });
  return {schema_version:1, products};
}

export function readinessReport(catalog) {
  const validated = validateCatalog(catalog);
  return {
    version: CATALOG_VERSION, product_count:validated.products.length,
    production_release_allowed:false,
    checkout_enabled:false, download_enabled:false,
    products: validated.products.map(p => ({
      slug:p.slug, stage:p.stage,
      missing_evidence:REQUIRED_CHECKS.filter(key => !p.checks[key]),
      evidence_marked_complete:REQUIRED_CHECKS.every(key => p.checks[key]),
      decision:'HOLD',
      reason:'EXPLICIT_RELEASE_AUTHORIZATION_AND_DELIVERY_BACKEND_NOT_IMPLEMENTED'
    }))
  };
}

/** Public output strips source paths, branch SHAs, internal checklist and secrets. */
export function publicCatalog(catalog) {
  const validated = validateCatalog(catalog);
  return {
    version:CATALOG_VERSION,
    availability:'DEVELOPMENT_ONLY',
    checkout_enabled:false,
    download_enabled:false,
    products:validated.products.map(p => ({
      id:p.slug, title:p.title, description:p.description,
      category:p.category, status: 'NOT_AVAILABLE',
      status_label:PUBLIC_STATUS[p.stage],
      price:null, purchase_url:null, download_url:null
    }))
  };
}

/** Stable receipt of source bytes, never a release authorization. */
export function catalogReceipt(raw) {
  if (typeof raw !== 'string' || Buffer.byteLength(raw, 'utf8') > 256*1024) {
    fail('catalog exceeds byte limit');
  }
  const parsed = JSON.parse(raw);
  validateCatalog(parsed);
  return {version:CATALOG_VERSION,
    sha256:createHash('sha256').update(raw,'utf8').digest('hex'),
    products:parsed.products.length, signed:false, owner_release_authorized:false};
}
