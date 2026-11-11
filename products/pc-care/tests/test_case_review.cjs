'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const {model,bind,validUtcMinute,MAX_BYTES} = require('../ui/case_review.js');
const valid = () => ({
 schemaVersion:1,product:'AXMART PC CARE',mode:'read-only',assessment:'주의 필요',
 observations:{collectionStatus:{physicalDisks:'collected'}},
 consultation:{schemaVersion:1,containsIdentifiers:false,assessment:'주의 필요',
  storageSignal:'경고 신호 관측',windowsBuild:'26100',reviewItems:['저장장치 상태 경고'],
  recordedEvents:[{eventId:41,recordedUtc:'2026-11-11 04:15',provider:'PRIVATE_PROVIDER',message:'PRIVATE_MESSAGE'}]},
 owner:'PRIVATE_USERNAME',serial:'PRIVATE_SERIAL',filePath:'C:\\PRIVATE_PATH',message:'PRIVATE_MESSAGE'
});
const run = r => model(JSON.stringify(r)).lines.join('\n');
test('supported report displays bounded Korean review', () => {const out=run(valid());assert.match(out,/상담용 검토 초안/);assert.match(out,/이벤트 41/);assert.match(out,/검토 보류/);});
test('arbitrary strings and sensitive source fields never reach summary', () => {const out=run(valid());for(const privateText of ['PRIVATE_USERNAME','PRIVATE_PROVIDER','PRIVATE_MESSAGE','PRIVATE_SERIAL','PRIVATE_PATH'])assert.ok(!out.includes(privateText));});
test('schema, product, mode and consultation assessment must match', () => {for(const [key,val] of [['schemaVersion',2],['product','Other'],['mode','repair'],['assessment','위험 신호']]){const r=valid();r[key]=val;assert.throws(()=>run(r));}});
test('consultation claims cannot authorize output', () => {let r=valid();r.consultation.containsIdentifiers=true;assert.throws(()=>run(r));r=valid();r.consultation.assessment='확인 불완전';assert.throws(()=>run(r));});
test('unknown status and arbitrary issue labels are rejected', () => {let r=valid();r.consultation.storageSignal='ALL_OK';assert.throws(()=>run(r));r=valid();r.consultation.reviewItems.push('PRIVATE_FAKE');assert.throws(()=>run(r));});
test('forged events, decimal ids, invalid dates and excess entries rejected', () => {for(const fake of [{eventId:41.5,recordedUtc:'2026-11-11 04:15'},{eventId:999,recordedUtc:'2026-11-11 04:15'},{eventId:41,recordedUtc:'2026-02-30 04:15'},{eventId:41,recordedUtc:'2026-11-11 24:15'}]){const r=valid();r.consultation.recordedEvents=[fake];assert.throws(()=>run(r));}});
test('missing collection completeness never becomes clean', () => {const r=valid();r.assessment=r.consultation.assessment='관찰 범위 내 특이사항 없음';delete r.observations;assert.match(run(r),/확인 불완전/);});
test('strict UTC calendar accepts leap years, not impossible dates', () => {assert.equal(validUtcMinute('2028-02-29 23:59'),true);assert.equal(validUtcMinute('2027-02-29 23:59'),false);assert.equal(validUtcMinute('2026-01-01T00:00:00Z'),false);});
test('bounded source size and malformed JSON rejected', () => {assert.equal(MAX_BYTES,2000000);assert.throws(()=>model('garbage'));assert.throws(()=>model(' '.repeat(MAX_BYTES+1)));});
test('no network, persistence, remote links or HTML injection operations', () => {const js=fs.readFileSync(path.join(__dirname,'../ui/case_review.js'),'utf8');const html=fs.readFileSync(path.join(__dirname,'../ui/case_review.html'),'utf8');for(const unsafe of ['fetch(', 'XMLHttpRequest', 'localStorage', 'sessionStorage','innerHTML','sendBeacon','WebSocket'])assert.ok(!js.includes(unsafe),unsafe);assert.match(html,/connect-src 'none'/);assert.match(html,/<script src="\.\/case_review\.js" defer>/);});
test('file change while asynchronous read pending prevents stale content', async () => {
  const elements={};function element(id){return elements[id] ||= {id,disabled:false,textContent:'',files:[],handlers:{},addEventListener(type,fn){this.handlers[type]=fn;}};}
  const doc={getElementById:element};let printed=0;bind(doc,{print(){printed++;}});
  let finish;const oldFile={name:'old.json',size:140,text:()=>new Promise(resolve=>{finish=resolve;})};
  elements['case-file'].files=[oldFile];const pending=elements['case-analyze'].handlers.click();
  elements['case-file'].files=[{name:'new.json',size:100,text:async()=>JSON.stringify(valid())}];
  elements['case-file'].handlers.change();finish(JSON.stringify(valid()));await pending;
  assert.equal(elements['case-print'].disabled,true);assert.ok(!elements['case-output'].textContent.includes('이벤트 41'));
  await elements['case-analyze'].handlers.click();assert.equal(elements['case-print'].disabled,false);
  elements['case-print'].handlers.click();assert.equal(printed,1);
});
