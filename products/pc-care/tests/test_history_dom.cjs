"use strict";
const test = require("node:test");
const assert = require("node:assert/strict");
const vm = require("node:vm");
const fs = require("node:fs");
const path = require("node:path");
const script = fs.readFileSync(path.join(__dirname,"../ui/history_compare.js"),"utf8");
function sample(time,code) {
  return { schemaVersion:1,product:"AXMART PC CARE",mode:"read-only",generatedAt:time,
    assessment:"주의 필요",issues:[{code}],observations:{eventCollection:"collected",eventWindowDays:30,
    bugchecks:[],unexpectedShutdowns:[],storageEvents:[],volumes:[],physicalDisks:[]}};
}
const earlier = sample("2026-10-29 11:00:00 +09:00","DISK_SPACE_LOW");
const later = sample("2026-10-30 11:00:00 +09:00","DISK_SPACE_CRITICAL");
function setup() {
  const events = new Map();
  const element = id => ({
    files:[],
    disabled:false,
    textContent:"",
    addEventListener(name,fn) { events.set(id+":"+name,fn); }
  });
  const nodes={
    "previous-json":element("previous-json"),
    "current-json":element("current-json"),
    "compare":element("compare"),
    "output":element("output")
  };
  const document={ readyState:"complete",getElementById:id=>nodes[id] };
  vm.runInNewContext(script, {document}, {filename:"history_compare.js", timeout:1000});
  return {
    output:nodes.output,
    button:nodes.compare,
    choose(name,file) {
      nodes[name].files=file?[file]:[];
      events.get(name+":change")();
    },
    click:()=>events.get("compare:click")()
  };
}
function file(payload,name="report.json") {
  return {name,size:JSON.stringify(payload).length,text:async()=>JSON.stringify(payload)};
}
test("DOM flow: successful offline comparison displays only user-facing summary",async()=>{
  const a=setup();a.choose("previous-json",file(earlier));a.choose("current-json",file(later));
  await a.click();
  assert.match(a.output.textContent,/DISK_SPACE_CRITICAL/);
  assert.match(a.output.textContent,/DISK_SPACE_LOW/);
  assert.equal(a.button.disabled,false);
});
test("DOM flow: oversized file is rejected without invoking text()",async()=>{
  const a=setup();let reads=0;
  a.choose("previous-json",{name:"large.json",size:2000001,text:async()=>{reads++;return "{}";}});
  a.choose("current-json",file(later));
  await a.click();
  assert.equal(reads,0);assert.match(a.output.textContent,/비교 불가/);
});
test("DOM flow: invalid JSON fails without showing raw source",async()=>{
  const a=setup();a.choose("previous-json",{name:"secret.json",size:20,text:async()=>'{SECRET_SENSITIVE'});
  a.choose("current-json",file(later));await a.click();
  assert.match(a.output.textContent,/올바른 JSON 파일이 아닙니다/);
  assert.doesNotMatch(a.output.textContent,/SECRET_SENSITIVE/);
});
test("DOM flow: file changed during reading never displays stale result",async()=>{
  const a=setup();let finish;
  a.choose("previous-json",{name:"old.json",size:100,text:()=>new Promise(resolve=>{finish=resolve;})});
  a.choose("current-json",file(later));
  const pending=a.click();
  assert.equal(a.button.disabled,true);
  assert.equal(typeof finish,"function");
  a.choose("current-json",file(earlier));
  finish(JSON.stringify(earlier));
  await pending;
  assert.match(a.output.textContent,/파일 선택이 변경되어/);
  assert.doesNotMatch(a.output.textContent,/DISK_SPACE_CRITICAL/);
  assert.equal(a.button.disabled,false);
});
test("DOM flow: stale parse error does not erase revised selection status",async()=>{
  const a=setup();let fail;
  a.choose("previous-json",{name:"old.json",size:100,text:()=>new Promise((resolve,reject)=>{fail=reject;})});
  a.choose("current-json",file(later));
  const pending=a.click();
  a.choose("previous-json",file(earlier));
  fail(new Error("Sensitive file name"));
  await pending;
  assert.match(a.output.textContent,/파일 선택이 변경되어/);
  assert.doesNotMatch(a.output.textContent,/Sensitive/);
});
