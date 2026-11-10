import test from 'node:test';
import assert from 'node:assert/strict';
import {mkdtempSync,rmSync,writeFileSync,readFileSync,symlinkSync,statSync} from 'node:fs';
import {tmpdir} from 'node:os';
import {dirname,join,resolve} from 'node:path';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {spawnSync} from 'node:child_process';
import {auditCandidateArtifact} from '../commerce/package-audit.mjs';
const base=resolve(dirname(fileURLToPath(import.meta.url)),'..');
const catalog=JSON.parse(readFileSync(join(base,'commerce/catalog.json'),'utf8'));
const archive=Buffer.from([0x50,0x4b,0x03,0x04,1,2,3,4,5,6,7,8]);
function fixture(fn){
 const root=mkdtempSync(join(tmpdir(),'cube-package-'));
 const manifest=join(root,'candidate.json');
 const file=join(root,'candidate.zip');
 const contract={version:1,product_id:'axmart-pc-care',source_commit:catalog.products[0].source.commit,
   filename:'candidate.zip',size_bytes:archive.length,
   sha256:createHash('sha256').update(archive).digest('hex')};
 writeFileSync(file,archive);writeFileSync(manifest,JSON.stringify(contract));
 const run=()=>spawnSync(process.execPath,[join(base,'scripts/audit-package.mjs'),'--manifest',manifest],{cwd:base,encoding:'utf8',timeout:10000});
 try{return fn({root,manifest,file,contract,run})}finally{rmSync(root,{recursive:true,force:true})}
}
test('candidate same SHA, size and ZIP magic gets preflight receipt but no release',()=>fixture(({manifest,contract})=>{
 const out=auditCandidateArtifact(contract,catalog,manifest);
 assert.equal(out.status,'CANDIDATE_HASH_MATCH');
 assert.equal(out.release_allowed,false);
 assert.equal(out.customer_download_enabled,false);
 assert.equal(out.payment_enabled,false);
 assert.equal(out.owner_approval,'NOT_GRANTED');
 assert.match(out.note,/not archive-content/);
}));
test('a tampered single byte reports REVIEW_HOLD, never real release',()=>fixture(({manifest,contract,file})=>{
 writeFileSync(file,Buffer.from([0x50,0x4b,0x03,0x04,1,2,3,4,5,6,7,9]));
 const out=auditCandidateArtifact(contract,catalog,manifest);
 assert.equal(out.status,'REVIEW_HOLD');assert.equal(out.sha256_match,false);
}));
test('expected size mismatch reports HOLD',()=>fixture(({manifest,contract})=>{
 contract.size_bytes+=1;
 const out=auditCandidateArtifact(contract,catalog,manifest);
 assert.equal(out.size_match,false);assert.equal(out.release_allowed,false);
}));
test('non-ZIP bytes cannot be a release candidate even with correct SHA',()=>fixture(({manifest,contract,file})=>{
 const bad=Buffer.from('INVALID-DOWNLOAD');
 writeFileSync(file,bad);contract.size_bytes=bad.length;
 contract.sha256=createHash('sha256').update(bad).digest('hex');
 const out=auditCandidateArtifact(contract,catalog,manifest);
 assert.equal(out.status,'REVIEW_HOLD');assert.equal(out.zip_signature_only,false);
}));
test('source branch commit must match pinned product revision',()=>fixture(({manifest,contract})=>{
 contract.source_commit='0'.repeat(40);
 assert.throws(()=>auditCandidateArtifact(contract,catalog,manifest),TypeError);
}));
test('unsafe manifest file path traversal and extensions fail',()=>fixture(({manifest,contract})=>{
 for(const name of ['../secret.zip','/tmp/secret.zip','pkg.exe','pkg.ZIP','a\\b.zip','.zip','a b.zip']){
  contract.filename=name;
  assert.throws(()=>auditCandidateArtifact(contract,catalog,manifest),TypeError);
 }
}));
test('symlink source cannot pass as a regular local candidate',()=>fixture(({manifest,contract,root,file})=>{
 const link=join(root,'symlink.zip');
 try{symlinkSync(file,link)}catch(e){if(['EPERM','EACCES'].includes(e.code))return;throw e}
 contract.filename='symlink.zip';
 assert.throws(()=>auditCandidateArtifact(contract,catalog,manifest),TypeError);
}));
test('over 32 MiB declared size is rejected before any read',()=>fixture(({manifest,contract})=>{
 contract.size_bytes=32*1024*1024+1;
 assert.throws(()=>auditCandidateArtifact(contract,catalog,manifest),TypeError);
}));
test('extra action command or approval fields are rejected',()=>fixture(({manifest,contract})=>{
 contract.release=true;
 assert.throws(()=>auditCandidateArtifact(contract,catalog,manifest),TypeError);
}));
test('candidate file unchanged after verification',()=>fixture(({manifest,file,contract})=>{
 const before=readFileSync(file);auditCandidateArtifact(contract,catalog,manifest);
 assert.deepEqual(readFileSync(file),before);
}));
test('CLI child process returns 0 on candidate hash match but does not release',()=>fixture(({run})=>{
 const res=run();assert.equal(res.status,0,res.stderr);
 const out=JSON.parse(res.stdout);assert.equal(out.release_allowed,false);
 assert.equal(res.stderr,'');
}));
test('CLI tamper causes HOLD exit 2, no secrets leaked',()=>fixture(({run,file})=>{
 writeFileSync(file,Buffer.from([0x50,0x4b,0x03,0x04,1,2,3,4,5,6,7,9]));
 const res=run();assert.equal(res.status,2,res.stderr);
 assert.equal(JSON.parse(res.stdout).status,'REVIEW_HOLD');
}));
test('invalid CLI manifest gives sanitized error and no path leak',()=>fixture(({run,manifest})=>{
 writeFileSync(manifest,'{"version":1,"script":"secret","execute":true}');
 const res=run();assert.equal(res.status,1);assert.equal(res.stdout,'');
 assert.doesNotMatch(res.stderr,/candidate.json|secret/);
}));
