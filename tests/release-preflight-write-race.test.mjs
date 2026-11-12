/** Prevent accidental deletion of another writer's files during preflight failure. */
import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import {syncBuiltinESMExports} from 'node:module';
import {join} from 'node:path';
import {tmpdir} from 'node:os';
import {buildPreflight,verifyPreflight} from '../commerce/release-preflight.mjs';

function fixture() {
  const top=fs.mkdtempSync(join(tmpdir(),'axmart-cube-race-'));
  const root=join(top,'source');
  const out=join(top,'owner');
  for (const p of ['commerce','cloudflare','dist','dist/products','dist/support'])
    fs.mkdirSync(join(root,p),{recursive:true});
  const product={
    slug:'axmart-pc-care',title:'AXMART PC CARE',description:'Windows 진단 도구 미검증',
    category:'windows-tools',source:{repository:'hibi89/AX_MART',
      branch:'feature/pc-care-usb',commit:'a'.repeat(40)},
    stage:'development',checks:Object.fromEntries(
      ['windows10','windows11','winre','repair_safety','security','license','customer_support','owner_approval']
        .map(k=>[k,false])),
    delivery:{mode:'disabled',path:null,sha256:null},
    sale:{mode:'disabled',price_minor:null,currency:null},
  };
  const w=(p,bytes)=>fs.writeFileSync(join(root,p),bytes);
  w('commerce/catalog.json',JSON.stringify({schema_version:1,products:[product]}));
  w('dist/catalog.json',JSON.stringify({
    version:'axmart.catalog.v1',availability:'DEVELOPMENT_ONLY',
    checkout_enabled:false,download_enabled:false,
    products:[{id:product.slug,title:product.title,description:product.description,
      category:product.category,status:'NOT_AVAILABLE',
      status_label:'개발 중 · 실제 기기 미검증',price:null,purchase_url:null,download_url:null}]
  }));
  const home='<!doctype html><html>AXMART³ AXMART PC CARE 판매·다운로드는 아직 지원하지 않습니다 Windows 실기기 미검증</html>';
  w('index.html',home);w('dist/index.html',home);
  w('cloudflare/_headers','/*\n  X-Frame-Options: DENY\n');
  w('dist/_headers','/*\n  X-Frame-Options: DENY\n');
  w('dist/products/index.html',"<!doctype html><html><meta http-equiv=\"Content-Security-Policy\" content=\"script-src 'none'; connect-src 'none'; form-action 'none'\"><body>현재 판매 및 다운로드를 제공하지 않습니다</body></html>");
  w('dist/support/index.html',"<!doctype html><html><meta http-equiv=\"Content-Security-Policy\" content=\"script-src 'none'; connect-src 'none'; form-action 'none'\"><body>문의 접수 서비스를 제공하지 않습니다</body></html>");
  return {top,root,out,dispose:()=>fs.rmSync(top,{recursive:true,force:true})};
}

test('output replaced by unrelated directory during write must not be recursively deleted',()=>{
  const f=fixture(), moved=join(f.top,'original-generated');
  const realWrite=fs.writeFileSync;
  let replaced=false;
  try {
    fs.writeFileSync=function(path,...args) {
      if(!replaced && path===join(f.out,'owner-review.html')) {
        replaced=true;
        assert.ok(fs.existsSync(join(f.out,'owner-review.json')));
        fs.renameSync(f.out,moved);
        fs.mkdirSync(f.out);
        realWrite(join(f.out,'DO_NOT_DELETE.txt'),'UNRELATED VALUABLE DATA');
        throw new Error('injected disk failure after output path replacement');
      }
      return realWrite.call(fs,path,...args);
    };
    syncBuiltinESMExports();
    assert.throws(()=>buildPreflight(f.root,f.out),/partial\/replaced directory preserved/);
  } finally {
    fs.writeFileSync=realWrite;
    syncBuiltinESMExports();
    try {
      assert.equal(replaced,true);
      assert.equal(fs.readFileSync(join(f.out,'DO_NOT_DELETE.txt'),'utf8'),'UNRELATED VALUABLE DATA');
      assert.ok(fs.existsSync(join(moved,'owner-review.json')));
    } finally { f.dispose(); }
  }
});

test('plain I/O failure preserves partial owner data for manual review',()=>{
  const f=fixture();
  const realWrite=fs.writeFileSync;
  let failed=false;
  try {
    fs.writeFileSync=function(path,...args) {
      if(!failed && path===join(f.out,'owner-review.html')) {
        failed=true;throw new Error('injected I/O failure');
      }
      return realWrite.call(fs,path,...args);
    };
    syncBuiltinESMExports();
    assert.throws(()=>buildPreflight(f.root,f.out),/partial\/replaced directory preserved/);
  } finally {
    fs.writeFileSync=realWrite;
    syncBuiltinESMExports();
    try {
      assert.equal(failed,true);
      assert.ok(fs.existsSync(join(f.out,'owner-review.json')));
      assert.equal(fs.existsSync(join(f.out,'owner-review.html')),false);
      assert.throws(()=>buildPreflight(f.root,f.out),/EEXIST/);
    } finally {f.dispose();}
  }
});

test('normal owner receipts still build and independently verify',()=>{
  const f=fixture();
  try {
    const review=buildPreflight(f.root,f.out);
    assert.equal(review.decision,'HOLD');
    assert.equal(verifyPreflight(f.root,f.out),true);
  } finally {f.dispose();}
});
