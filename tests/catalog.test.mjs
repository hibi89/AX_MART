import test from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';
import { CATALOG_VERSION, REQUIRED_CHECKS, validateCatalog,
  readinessReport, publicCatalog, catalogReceipt } from '../commerce/catalog.mjs';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const raw = readFileSync(join(root, 'commerce', 'catalog.json'), 'utf8');
const base = JSON.parse(raw);
const clone = () => structuredClone(base);
const tamper = (change) => { const x=clone();change(x.products[0], x);return x; };
const blocked = (value) => assert.throws(() => validateCatalog(value), TypeError);

test('real PC CARE catalog is the single development-only project', () => {
  const x = validateCatalog(base);
  assert.equal(x.schema_version, 1);
  assert.equal(x.products.length, 1);
  assert.equal(x.products[0].slug, 'axmart-pc-care');
  assert.equal(x.products[0].stage, 'development');
  assert.equal(x.products[0].source.commit.length, 40);
});
test('public listing never contains payment or download action', () => {
  const out=publicCatalog(base);
  assert.equal(out.version, CATALOG_VERSION);
  assert.equal(out.checkout_enabled,false);
  assert.equal(out.download_enabled,false);
  assert.equal(out.products[0].status,'NOT_AVAILABLE');
  assert.equal(out.products[0].price,null);
  assert.equal(out.products[0].purchase_url,null);
  assert.equal(out.products[0].download_url,null);
});
test('public output strips private source identifiers and all check flags', () => {
  const out=JSON.stringify(publicCatalog(base));
  for(const hidden of ['hibi89/AX_MART','feature/pc-care-usb',
    'b8706e0a77ec245acc7bc0672f121364c851f910',
    'windows10','owner_approval','sha256','source']) assert.equal(out.includes(hidden),false,hidden);
});
test('release checklist returns all currently missing evidence and HOLD', () => {
  const report=readinessReport(base);
  assert.equal(report.production_release_allowed,false);
  assert.equal(report.products[0].decision,'HOLD');
  assert.deepEqual(report.products[0].missing_evidence, REQUIRED_CHECKS);
  assert.equal(report.products[0].evidence_marked_complete,false);
});
test('even all asserted checkboxes cannot authorize a storefront release', () => {
  const item = tamper(p => {for(const field of REQUIRED_CHECKS)p.checks[field]=true;});
  const report=readinessReport(item);
  assert.equal(report.products[0].evidence_marked_complete,true);
  assert.equal(report.production_release_allowed,false);
  assert.equal(report.checkout_enabled,false);
  assert.equal(report.download_enabled,false);
});
test('setting released or paid stage fails closed',()=>{
  for(const stage of ['released','free','paid','active','AVAILABLE'])
    blocked(tamper(p=>{p.stage=stage;}));
});
test('download URL, file, or forged checksum is forbidden',()=>{
  blocked(tamper(p=>{p.delivery.mode='url';p.delivery.path='https://example.com/a.zip';}));
  blocked(tamper(p=>{p.delivery.path='/downloads/unsafe.zip';}));
  blocked(tamper(p=>{p.delivery.sha256='a'.repeat(64);}));
});
test('price, currency or checkout activation is forbidden',()=>{
  blocked(tamper(p=>{p.sale.mode='checkout';}));
  blocked(tamper(p=>{p.sale.price_minor=500000;}));
  blocked(tamper(p=>{p.sale.currency='KRW';}));
});
test('display names reject tags, HTML insertion, and control chars',()=>{
  blocked(tamper(p=>{p.title='<script>alert(1)</script>';}));
  blocked(tamper(p=>{p.description='clean\u200bhidden';}));
  blocked(tamper(p=>{p.title='newline\nsecret';}));
});
test('source provenance requires allowlisted repository and pinned SHA',()=>{
  blocked(tamper(p=>{p.source.repository='attacker/repo';}));
  blocked(tamper(p=>{p.source.branch='main';}));
  blocked(tamper(p=>{p.source.commit='1234';}));
  blocked(tamper(p=>{p.source.commit='A'.repeat(40);}));
});
test('strict object shape rejects action, secret, and unsafe attributes',()=>{
  blocked(tamper(p=>{p.script='eval(1)';}));
  blocked(tamper(p=>{p.sale.credential='secret';}));
  blocked(tamper((p,c)=>{c.install='curl | sh';}));
  blocked(tamper(p=>{p.source.env='test';}));
});
test('checks must all be present and boolean, never string or 0',()=>{
  blocked(tamper(p=>{delete p.checks.windows10;}));
  blocked(tamper(p=>{p.checks.windows10='true';}));
  blocked(tamper(p=>{p.checks.winre=0;}));
  blocked(tamper(p=>{p.checks.unknown=true;}));
});
test('duplicate SKU or confusable slug fails closed',()=>{
  const a=clone();a.products.push(structuredClone(a.products[0]));blocked(a);
  blocked(tamper(p=>{p.slug='AXMART-PC-CARE';}));
  blocked(tamper(p=>{p.slug='axmart\u200d-pc-care';}));
});
test('version, product count and root shape are bounded',()=>{
  blocked({...clone(), schema_version:'1'});
  blocked({...clone(), products:[]});
  blocked({...clone(), products:Array(21).fill(base.products[0])});
  blocked({...clone(), products:{}});
  blocked(null);
});
test('catalog validator does not mutate owner source',()=>{
  const data=clone();const before=JSON.stringify(data);
  validateCatalog(data);readinessReport(data);publicCatalog(data);
  assert.equal(JSON.stringify(data),before);
});
test('receipt SHA256 matches source bytes exactly, never signs release',()=>{
  const r=catalogReceipt(raw);
  assert.equal(r.sha256,createHash('sha256').update(raw,'utf8').digest('hex'));
  assert.equal(r.signed,false);
  assert.equal(r.owner_release_authorized,false);
});
test('receipt rejects huge source and bogus content',()=>{
  assert.throws(()=>catalogReceipt('x'.repeat(256*1024+1)),TypeError);
  assert.throws(()=>catalogReceipt(JSON.stringify({version:1})),TypeError);
  assert.throws(()=>catalogReceipt(null),TypeError);
});
test('public JSON and audit report remain deterministic across calls',()=>{
  assert.equal(JSON.stringify(publicCatalog(base)),JSON.stringify(publicCatalog(base)));
  assert.equal(JSON.stringify(readinessReport(base)),JSON.stringify(readinessReport(base)));
});
test('owner-only audit CLI prints actual blocking checks without mutation',()=>{
  const before=readFileSync(join(root,'commerce','catalog.json'));
  const out=execFileSync(process.execPath,[join(root,'scripts','audit-catalog.mjs')],{cwd:root,encoding:'utf8'});
  const report=JSON.parse(out);
  assert.equal(report.readiness.products[0].decision,'HOLD');
  assert.equal(report.receipt.owner_release_authorized,false);
  assert.deepEqual(readFileSync(join(root,'commerce','catalog.json')),before);
});
