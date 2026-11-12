import test from 'node:test';
import assert from 'node:assert/strict';
import {mkdtempSync,mkdirSync,rmSync,writeFileSync,readFileSync,existsSync,symlinkSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {join} from 'node:path';
import {spawnSync} from 'node:child_process';
import {createHash} from 'node:crypto';
import {evaluatePreflight,buildPreflight,verifyPreflight} from '../commerce/release-preflight.mjs';
const srcProduct={slug:'axmart-pc-care',title:'AXMART PC CARE',description:'Windows 진단 도구 미검증',category:'windows-tools',
  source:{repository:'hibi89/AX_MART',branch:'feature/pc-care-usb',commit:'a'.repeat(40)},stage:'development',
  checks:Object.fromEntries(['windows10','windows11','winre','repair_safety','security','license','customer_support','owner_approval'].map(k=>[k,false])),
  delivery:{mode:'disabled',path:null,sha256:null},sale:{mode:'disabled',price_minor:null,currency:null}};
const page = '<!doctype html><html><meta http-equiv="Content-Security-Policy" content="script-src \'none\'; connect-src \'none\'; form-action \'none\'"><body>현재 판매 및 다운로드를 제공하지 않습니다</body></html>';
const support = '<!doctype html><html><meta http-equiv="Content-Security-Policy" content="script-src \'none\'; connect-src \'none\'; form-action \'none\'"><body>문의 접수 서비스를 제공하지 않습니다</body></html>';
const start =()=>{const top=mkdtempSync(join(tmpdir(),'cube-p85-'));const root=join(top,'repo'),out=join(top,'owner');
  for(const dir of ['commerce','cloudflare','dist','dist/products','dist/support'])mkdirSync(join(root,dir),{recursive:true});
  const cat={schema_version:1,products:[structuredClone(srcProduct)]};
  const write=(path,s)=>writeFileSync(join(root,path),s);
  const publish=()=>write('dist/catalog.json',JSON.stringify({version:'axmart.catalog.v1',availability:'DEVELOPMENT_ONLY',checkout_enabled:false,download_enabled:false,
    products:cat.products.map(p=>({id:p.slug,title:p.title,description:p.description,category:p.category,status:'NOT_AVAILABLE',
    status_label:p.stage==='development'?'개발 중 · 실제 기기 미검증':'출시 검토 중 · 판매 및 다운로드 불가',price:null,purchase_url:null,download_url:null}))}));
  const home='<!doctype html><html>AXMART³ AXMART PC CARE 판매·다운로드는 아직 지원하지 않습니다 Windows 실기기 미검증</html>';
  write('index.html',home);write('dist/index.html',home);write('cloudflare/_headers','/*\n  X-Frame-Options: DENY\n');write('dist/_headers','/*\n  X-Frame-Options: DENY\n');
  write('dist/products/index.html',page);write('dist/support/index.html',support);
  const save=()=>write('commerce/catalog.json',JSON.stringify(cat));save();publish();
  return {top,root,out,cat,write,publish,save,cleanup:()=>rmSync(top,{force:true,recursive:true})};};
function withFixture(fn){const f=start();try{return fn(f);}finally{f.cleanup()}}
const failures = (title,change)=>test(title,()=>withFixture(f=>{change(f);assert.throws(()=>evaluatePreflight(f.root));assert.equal(existsSync(f.out),false)}));
test('original approved HOLD catalog and generated static files pass owner preflight',()=>withFixture(f=>{const r=evaluatePreflight(f.root);assert.equal(r.decision,'HOLD');assert.equal(r.production_published_by_this_tool,false);assert.equal(r.payment_enabled,false);assert.equal(r.download_enabled,false);assert.equal(r.products[0].missing_checks.length,8);assert.equal(Object.keys(r.source_sha256).length,8)}));
test('actual build and independently rederived verify PASS, no mutation of source',()=>withFixture(f=>{const h=createHash('sha256').update(readFileSync(join(f.root,'commerce/catalog.json'))).digest('hex');buildPreflight(f.root,f.out);assert.equal(verifyPreflight(f.root,f.out),true);assert.equal(h,createHash('sha256').update(readFileSync(join(f.root,'commerce/catalog.json'))).digest('hex'));assert.deepEqual((readFileSync(join(f.out,'owner-review.json'),'utf8').match(/"decision": "HOLD"/g)||[]).length,1)}));
test('all checklist true still cannot activate sale/checkout',()=>withFixture(f=>{for(const key of Object.keys(f.cat.products[0].checks))f.cat.products[0].checks[key]=true;f.save();const r=evaluatePreflight(f.root);assert.equal(r.products[0].missing_checks.length,0);assert.equal(r.decision,'HOLD');assert.equal(r.owner_release_authorized,false)}));
test('outputs byte deterministic across separate folders',()=>withFixture(f=>{buildPreflight(f.root,f.out);const o2=join(f.top,'second');buildPreflight(f.root,o2);for(const x of ['owner-review.json','owner-review.html','manifest.json'])assert.deepEqual(readFileSync(join(f.out,x)),readFileSync(join(o2,x)))}));
test('refuse overwrite of existing owner output',()=>withFixture(f=>{mkdirSync(f.out);writeFileSync(join(f.out,'keep'),'valuable');assert.throws(()=>buildPreflight(f.root,f.out));assert.equal(readFileSync(join(f.out,'keep'),'utf8'),'valuable')}));
test('detect tampered receipt even with recomputed output hash',()=>withFixture(f=>{buildPreflight(f.root,f.out);writeFileSync(join(f.out,'owner-review.json'),'{}');const man=JSON.parse(readFileSync(join(f.out,'manifest.json')));man.outputs_sha256['owner-review.json']=createHash('sha256').update('{}').digest('hex');writeFileSync(join(f.out,'manifest.json'),JSON.stringify(man));assert.throws(()=>verifyPreflight(f.root,f.out))}));
test('detect source catalog changes after owner review',()=>withFixture(f=>{buildPreflight(f.root,f.out);f.cat.products[0].description+=' altered';f.save();assert.throws(()=>verifyPreflight(f.root,f.out))}));
test('CLI build/verify returns HOLD but PASS status',()=>withFixture(f=>{const cmd=join(import.meta.dirname,'../scripts/release-preflight.mjs');const run=mode=>spawnSync(process.execPath,[cmd,mode,'--root',f.root,'--output',f.out],{encoding:'utf8'});const a=run('build');assert.equal(a.status,0,a.stderr);assert.equal(JSON.parse(a.stdout).payment_enabled,false);const b=run('verify');assert.equal(b.status,0,b.stderr);assert.equal(JSON.parse(b.stdout).verified,true);assert.equal(run('build').status,2)}));
failures('catalog unknown price/paid flag blocked',f=>{f.cat.products[0].sale.mode='enabled';f.save()});
failures('catalog unknown delivery URL blocked',f=>{f.cat.products[0].delivery.path='/downloads/unsafe';f.save()});
failures('catalog fake source SHA blocked',f=>{f.cat.products[0].source.commit='bad';f.save()});
failures('catalog extra customer email field blocked',f=>{f.cat.products[0].email='x@y.com';f.save()});
failures('catalog duplicate slug blocked',f=>{f.cat.products.push(structuredClone(f.cat.products[0]));f.save();f.publish()});
failures('public catalog enabling payment blocked',f=>{const path='dist/catalog.json',v=JSON.parse(readFileSync(join(f.root,path)));v.checkout_enabled=true;f.write(path,JSON.stringify(v))});
failures('public catalog leaking private source blocked',f=>{const path='dist/catalog.json',v=JSON.parse(readFileSync(join(f.root,path)));v.products[0].source=f.cat.products[0].source;f.write(path,JSON.stringify(v))});
failures('homepage build drift blocked',f=>f.write('dist/index.html','<html>modified</html>'));
failures('cloudflare header drift blocked',f=>f.write('dist/_headers','/*\n BAD'));
failures('product page external request blocked',f=>f.write('dist/products/index.html',page+'<a href="https://example.com">link</a>'));
failures('product page inline script blocked',f=>f.write('dist/products/index.html',page+'<script>alert(1)</script>'));
failures('support page form blocked',f=>f.write('dist/support/index.html',support+'<form></form>'));
failures('missing explicit support/no-sale disclosure blocked',f=>f.write('dist/support/index.html',page));
failures('original homepage missing protected disclosure blocked',f=>{const bad='<!doctype html>AXMART³ AXMART PC CARE';f.write('index.html',bad);f.write('dist/index.html',bad)});
failures('truncated/invalid JSON public catalog blocked',f=>f.write('dist/catalog.json','{broken'));
failures('oversized catalog blocked',f=>f.write('commerce/catalog.json','x'.repeat(262145)));
test('refuse symlinked output directory, source path, or nested output',()=>withFixture(f=>{buildPreflight(f.root,f.out);const other=join(f.top,'shortcut');try{symlinkSync(f.out,other,'dir');assert.throws(()=>verifyPreflight(f.root,other));}catch(error){if(error.code!=='EPERM')throw error;}assert.throws(()=>buildPreflight(f.root,join(f.root,'nested')))}));
test('no customer information/ private commit leaked into HTML',()=>withFixture(f=>{buildPreflight(f.root,f.out);const html=readFileSync(join(f.out,'owner-review.html'),'utf8');assert.ok(!html.includes(f.cat.products[0].source.commit));assert.ok(!html.includes('source_sha256'));assert.ok(!html.includes('<script'));assert.ok(html.includes('HOLD'))}));
