import test from 'node:test';
import assert from 'node:assert/strict';
import {mkdtempSync,mkdirSync,writeFileSync,copyFileSync,rmSync,symlinkSync} from 'node:fs';
import {join,resolve} from 'node:path';
import {tmpdir} from 'node:os';
import {spawnSync} from 'node:child_process';
import {fileURLToPath} from 'node:url';
import {dirname} from 'node:path';

const source=resolve(dirname(fileURLToPath(import.meta.url)),'../scripts/verify-cube-local.mjs');
function fixture(fn){
 const root=mkdtempSync(join(tmpdir(),'axmart-accept-test-'));
 const mk=(p,c)=>{const full=join(root,p);mkdirSync(dirname(full),{recursive:true});writeFileSync(full,c);};
 const tests=['tests/site.test.mjs','tests/release-preflight.test.mjs','tests/release-preflight-write-race.test.mjs'];
 const command='node --test '+tests.join(' ');
 mk('package.json',JSON.stringify({scripts:{test:command}}));
 for(const p of tests)mk(p,"import test from 'node:test'; test('synthetic '+"+JSON.stringify(p)+",()=>{});\n");
 mk('scripts/build.mjs',"import {mkdirSync,writeFileSync} from 'node:fs';mkdirSync('dist',{recursive:true});writeFileSync('dist/index.html','safe');\n");
 mk('scripts/release-preflight.mjs',`import {mkdirSync,writeFileSync,readFileSync} from 'node:fs';import{join}from'node:path';const[a,,b,,out]=process.argv.slice(2);if(a==='build'){mkdirSync(out);writeFileSync(join(out,'manifest.json'),JSON.stringify({signature:'NONE',decision:'HOLD'}));console.log(JSON.stringify({decision:'HOLD',payment_enabled:false,download_enabled:false,production_published:false}));}else if(a==='verify'){JSON.parse(readFileSync(join(out,'manifest.json')));console.log(JSON.stringify({decision:'HOLD',verified:true}));}else process.exit(2);\n`);
 copyFileSync(source,join(root,'scripts','verify-cube-local.mjs'));
 const run=(args=[])=>spawnSync(process.execPath,[join(root,'scripts/verify-cube-local.mjs'),...args],{encoding:'utf8',cwd:root});
 try{return fn({root,run,mk,tests});}finally{rmSync(root,{recursive:true,force:true});}
}
test('local command executes full listed test set, build and verified HOLD receipt',()=>fixture(({run,root})=>{
 const out=join(root,'audit');const r=run(['--output',out]);assert.equal(r.status,0,r.stderr);
 const line=r.stdout.trim().split('\n').at(-1);const result=JSON.parse(line);
 assert.equal(result.technical_local_tests,'PASS');assert.equal(result.release_decision,'HOLD');
 assert.equal(result.sales_go,false);assert.equal(result.browser_windows_customer_legal_verified,false);
 assert.equal(result.local_review_output,out);assert.match(result.manifest_sha256,/^[a-f0-9]{64}$/);
 assert.equal(run(['--output',out]).status,2,'never overwrite existing owner output');
}));
test('mandatory release test cannot be silently omitted',()=>fixture(({run,mk})=>{
 mk('package.json',JSON.stringify({scripts:{test:'node --test tests/site.test.mjs'}}));
 const r=run();assert.equal(r.status,2);assert.match(r.stderr,/mandatory original suites absent/);
}));
test('malformed shell-injection test command rejected, no command evaluation',()=>fixture(({run,mk})=>{
 mk('package.json',JSON.stringify({scripts:{test:'node --test tests/site.test.mjs; echo bad'}}));
 const r=run();assert.equal(r.status,2);assert.match(r.stderr,/cannot be verified/);
}));
test('symlinked dist blocked before any original test execution',()=>fixture(({run,root})=>{
 mkdirSync(join(root,'sentinel'));symlinkSync(join(root,'sentinel'),join(root,'dist'),'dir');
 const r=run();assert.equal(r.status,2);assert.match(r.stderr,/unsafe dist path/);
}));
test('non-absolute output rejected',()=>fixture(({run})=>{
 const r=run(['--output','../relative']);assert.equal(r.status,2);assert.match(r.stderr,/output must be absolute/);
}));
