import test from 'node:test';
import assert from 'node:assert/strict';
import {mkdtempSync, mkdirSync, writeFileSync, cpSync, existsSync, readFileSync, rmSync} from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import {spawnSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
import {dirname} from 'node:path';
const project=join(dirname(fileURLToPath(import.meta.url)),'..');
const index='<!doctype html><html><head><title>AXMART³</title></head><body>AXMART PC CARE — Windows 실기기 미검증. 판매·다운로드는 아직 지원하지 않습니다</body></html>';
function fixture(fn) {
  const root=mkdtempSync(join(tmpdir(),'axmart-build-'));
  for(const dir of ['commerce','scripts','cloudflare']) mkdirSync(join(root,dir));
  for(const file of ['commerce/catalog.mjs','commerce/catalog.json','commerce/catalog-page.mjs','scripts/build.mjs'])
    cpSync(join(project,file),join(root,file));
  writeFileSync(join(root,'index.html'),index);
  writeFileSync(join(root,'cloudflare','_headers'),'/*\n  X-Frame-Options: DENY\n');
  writeFileSync(join(root,'package.json'),'{"type":"module"}');
  const run=()=>spawnSync(process.execPath,[join(root,'scripts/build.mjs')],{cwd:root,encoding:'utf8',timeout:10000});
  try {return fn({root,run})} finally {rmSync(root,{recursive:true,force:true})}
}
test('catalog publisher builds a static safe public file and preserves index bytes',()=>fixture(({root,run})=>{
  const src=readFileSync(join(root,'index.html'));
  const proc=run();assert.equal(proc.status,0,proc.stderr);
  assert.deepEqual(readFileSync(join(root,'dist/index.html')),src);
  const listing=JSON.parse(readFileSync(join(root,'dist/catalog.json'),'utf8'));
  const catalogPage=readFileSync(join(root,'dist/products/index.html'),'utf8');
  assert.match(catalogPage,/AXMART PC CARE/);
  assert.match(catalogPage,/script-src 'none'/);
  assert.doesNotMatch(catalogPage,/<script\b|https?:\/\//i);
  assert.equal(listing.products.length,1);
  assert.equal(listing.products[0].title,'AXMART PC CARE');
  assert.equal(listing.products[0].status,'NOT_AVAILABLE');
  assert.equal(listing.products[0].price,null);
  assert.equal(listing.products[0].purchase_url,null);
  assert.equal(listing.products[0].download_url,null);
  const wire=JSON.stringify(listing);
  for(const text of ['b8706e0a77ec245acc7bc0672f121364c851f910','feature/pc-care-usb'])
    assert.equal(wire.includes(text),false);
}));
test('unapproved pricing or direct download is a hard build error',()=>fixture(({root,run})=>{
  const file=join(root,'commerce/catalog.json');
  const data=JSON.parse(readFileSync(file,'utf8'));
  data.products[0].sale.price_minor=500000;
  writeFileSync(file,JSON.stringify(data));
  const proc=run();assert.notEqual(proc.status,0);
  assert.equal(existsSync(join(root,'dist/catalog.json')),false);
}));
test('unapproved product label cannot appear in catalog without matching index',()=>fixture(({root,run})=>{
  const file=join(root,'commerce/catalog.json');
  const data=JSON.parse(readFileSync(file,'utf8'));
  data.products[0].title='Different Product';
  writeFileSync(file,JSON.stringify(data));
  const proc=run();assert.notEqual(proc.status,0);
  assert.equal(existsSync(join(root,'dist/catalog.json')),false);
}));
test('missing prototype disclosures block static release before output',()=>fixture(({root,run})=>{
  writeFileSync(join(root,'index.html'),'<!doctype html><html>AXMART³ AXMART PC CARE</html>');
  const proc=run();assert.notEqual(proc.status,0);
  assert.equal(existsSync(join(root,'dist/catalog.json')),false);
}));
