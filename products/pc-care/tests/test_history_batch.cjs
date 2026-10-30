"use strict";
const test=require("node:test");
const assert=require("node:assert/strict");
const vm=require("node:vm");
const fs=require("node:fs");
const path=require("node:path");
const read=name=>fs.readFileSync(path.join(__dirname,"../ui",name),"utf8");
function fakeFile(obj,name="sensitive-user-path.json") {
  const raw=JSON.stringify(obj);
  return {name,size:raw.length,text:async()=>raw};
}
function report(time,code="DISK_SPACE_LOW") {return {schemaVersion:1,product:"AXMART PC CARE",mode:"read-only",generatedAt:time,
  assessment:"주의 필요",issues:[{code}],observations:{eventWindowDays:30,eventCollection:"collected",collectionStatus:{physicalDisks:"collected"},bugchecks:[],unexpectedShutdowns:[],storageEvents:[],volumes:[],physicalDisks:[{status:"Healthy"}]}};}
const dates=["2026-10-27 09:00:00 +09:00","2026-10-29 09:00:00 +09:00","2026-10-30 09:00:00 +09:00"];
function setup() {
 const callbacks=new Map();
 function control(id) {
  return {id,files:[],value:"",disabled:false,textContent:"",options:[],
   addEventListener(name,fn) { callbacks.set(id+":"+name,fn); },
   replaceChildren() {this.options=[];this.value="";},
   appendChild(option) {this.options.push(option);} };
 }
 const ids=["previous-json","current-json","compare","output","history-batch","history-previous","history-current","history-status"];
 const nodes=Object.fromEntries(ids.map(id=>[id,control(id)]));
 const document={readyState:"complete",getElementById:id=>nodes[id],createElement:tag=>({tag,value:"",textContent:""})};
 const context=vm.createContext({document, module:undefined});
 for(const script of ["history_signals.js","history_compare.js"])vm.runInContext(read(script),context,{filename:script,timeout:1000});
 return {nodes,
  select:async(id,files)=>{nodes[id].files=files;return callbacks.get(id+":change")();},
  choose:(id,value)=>{nodes[id].value=value;return callbacks.get(id+":change")();},
  compare:()=>callbacks.get("compare:click")()};
}
test("batch can select unordered 3 reports and compare oldest and latest",async()=>{
 const a=setup();
 await a.select("history-batch",[fakeFile(report(dates[2],"BUGCHECK")),fakeFile(report(dates[0])),fakeFile(report(dates[1]))]);
 assert.equal(a.nodes["history-previous"].options.length,3);
 assert.ok(a.nodes["history-previous"].options[0].textContent.includes(dates[0]));
 assert.equal(a.nodes["history-current"].value,"2");
 assert.equal(a.nodes["history-previous"].value,"0");
 await a.compare();
 assert.match(a.nodes.output.textContent,/BUGCHECK/);
 assert.match(a.nodes.output.textContent,/DISK_SPACE_LOW/);
 assert.match(a.nodes["history-status"].textContent,/3개 보고서/);
 assert.doesNotMatch(a.nodes["history-previous"].options[0].textContent,/sensitive-user-path/);
});
test("bad JSON within batch rejects entire batch without displaying raw contents",async()=>{
 const a=setup();const malformed={name:"secret-path.json",size:24,text:async()=>"not JSON SECRET 999"};
 await a.select("history-batch",[fakeFile(report(dates[0])),malformed]);
 assert.equal(a.nodes["history-previous"].disabled,true);
 assert.equal(a.nodes["history-previous"].options.length,0);
 assert.doesNotMatch(a.nodes["history-status"].textContent,/SECRET|secret-path/);
});
test("file count and aggregate size are limited before reading contents",async()=>{
 const a=setup();let reads=0;const big={name:"report.json",size:600000,text:async()=>{reads++;return "{}";}};
 await a.select("history-batch",Array(26).fill(big));
 assert.equal(reads,0);
 assert.match(a.nodes["history-status"].textContent,/최대 25개/);
 await a.select("history-batch",Array(21).fill(big));
 assert.equal(reads,0);
 assert.match(a.nodes["history-status"].textContent,/합계 12MB/);
});
test("same report selected as both previous and current is rejected",async()=>{
 const a=setup();await a.select("history-batch",[fakeFile(report(dates[0])),fakeFile(report(dates[1]))]);
 a.choose("history-current","0");await a.compare();
 assert.match(a.nodes.output.textContent,/서로 다른 두 검사/);
});
test("manual previous/current selection overrides batch without reading stale batch file",async()=>{
 const a=setup();await a.select("history-batch",[fakeFile(report(dates[0])),fakeFile(report(dates[1]))]);
 await a.select("previous-json",[fakeFile(report(dates[1],"DISK_SPACE_LOW"))]);
 await a.select("current-json",[fakeFile(report(dates[2],"WINDOWS_UPDATE_FAILURE_RECORD"))]);
 assert.equal(a.nodes["history-previous"].disabled,true);
 await a.compare();
 assert.match(a.nodes.output.textContent,/WINDOWS_UPDATE_FAILURE_RECORD/);
 assert.doesNotMatch(a.nodes.output.textContent,/BUGCHECK/);
});
test("late first batch cannot overwrite newer batch",async()=>{
 const a=setup();let resolve;
 const slow={name:"old.json",size:100,text:()=>new Promise(done=>{resolve=done;})};
 const pending=a.select("history-batch",[slow,fakeFile(report(dates[1]))]);
 const next=a.select("history-batch",[fakeFile(report(dates[1])),fakeFile(report(dates[2]))]);
 await next;const before=a.nodes["history-previous"].options[0].textContent;
 resolve(JSON.stringify(report(dates[0])));await pending;
 assert.equal(a.nodes["history-previous"].options[0].textContent,before);
 assert.equal(a.nodes["history-current"].options.length,2);
});
test("invalid index is rejected instead of loading unrelated files",async()=>{
 const a=setup();await a.select("history-batch",[fakeFile(report(dates[0])),fakeFile(report(dates[1]))]);
 a.choose("history-previous","../secret");await a.compare();
 assert.match(a.nodes.output.textContent,/비교 불가/);
});
test("unsupported report timestamp and unknown assessment never leak sensitive values",async()=>{
 const a=setup();const invalid=report("2026-02-30 10:00:00 +09:00");invalid.assessment="TOKEN SECRET";
 await a.select("history-batch",[fakeFile(report(dates[0])),fakeFile(invalid)]);
 assert.equal(a.nodes["history-previous"].disabled,true);
 assert.doesNotMatch(a.nodes["history-status"].textContent,/TOKEN SECRET/);
 const another=report(dates[1]);another.assessment="TOKEN SECRET";
 await a.select("history-batch",[fakeFile(report(dates[0])),fakeFile(another)]);
 assert.match(a.nodes["history-current"].options[1].textContent,/확인 불가/);
 assert.doesNotMatch(a.nodes["history-current"].options[1].textContent,/TOKEN SECRET/);
});
