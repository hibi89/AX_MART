"use strict";
const {test}=require("node:test");
const assert=require("node:assert/strict");
const fs=require("node:fs");
const path=require("node:path");
const vm=require("node:vm");
const read=name=>fs.readFileSync(path.join(__dirname,"../ui",name),"utf8");
const {buildHistoryPrint}=require("../ui/history_print.js");
const before="2026-10-28 01:00:00 +09:00",after="2026-10-30 01:00:00 +09:00";
function sample(when,code){return {
 schemaVersion:1,product:"AXMART PC CARE",mode:"read-only",generatedAt:when,
 assessment:"주의 필요",issues:[{code}],
 observations:{eventWindowDays:30,eventCollection:"collected",
 collectionStatus:{physicalDisks:"collected"},bugchecks:[],unexpectedShutdowns:[],
 storageEvents:[],volumes:[],physicalDisks:[{status:"Healthy"}]}
};}
function fixture(){
 const callbacks=new Map(),elements={},counts={print:0};
 for(const id of ["previous-json","current-json","compare","output","print-history","history-print-text",
  "history-batch","history-previous","history-current","history-status"]){
  elements[id]={files:[],value:"",disabled:id==="print-history",textContent:"",options:[],
   addEventListener(n,fn){callbacks.set(id+":"+n,fn);},
   replaceChildren(){this.options=[];this.value="";},
   appendChild(item){this.options.push(item);}
  };
 }
 const document={readyState:"complete",getElementById:id=>elements[id],
  createElement:()=>({value:"",textContent:""})};
 const context=vm.createContext({document,print:()=>counts.print++});
 for(const file of ["history_signals.js","history_print.js","history_compare.js"])
  vm.runInContext(read(file),context,{filename:file,timeout:1000});
 const fileFor=report=>{const raw=JSON.stringify(report);return {name:"PRIVATE_John_Doe.json",size:raw.length,text:async()=>raw};};
 const select=(id,files)=>{elements[id].files=files;return callbacks.get(id+":change")();};
 return {elements,counts,callbacks,select,fileFor,click:()=>callbacks.get("compare:click")(),
  print:()=>callbacks.get("print-history:click")()};
}
test("print summary contains only allowed signals and required uncertainty",()=>{
 const s=buildHistoryPrint({
 beforeTime:before,afterTime:after,beforeAssessment:"위험 신호",afterAssessment:"주의 필요",
 added:["BUGCHECK"],missing:["DISK_SPACE_LOW"],eventCounts:null,diskComparable:false,
 signals:{windows:{before:"26100",after:"26200"},updates:{before:3,after:1},devices:{before:2,after:0}}});
 assert.match(s,/BUGCHECK/);
 assert.match(s,/Windows 빌드  26100 → 26200/);
 assert.match(s,/비교 불가/);
 assert.match(s,/원인이나 수리 성공을 증명하지/);
 assert.match(s,/파일명\/경로\/시리얼/);
});
test("print builder drops arbitrary raw values and limits warning output",()=>{
 const s=buildHistoryPrint({
 beforeTime:before,afterTime:after,beforeAssessment:"PRIVATE-SECRET",afterAssessment:"주의 필요",
 added:["SECRET=user_name",...Array(90).fill("BUGCHECK")],missing:null,eventCounts:null,
 disks:null,diskComparable:false,signals:null});
 assert.doesNotMatch(s,/PRIVATE-SECRET|SECRET=user_name/);
 assert.match(s,/확인 불가/);
 assert.match(s,/외 84종/);
 assert.ok(s.length<1600);
});
test("print builder fails closed on missing and invalid numeric counts",()=>{
 const s=buildHistoryPrint({
 beforeTime:before,afterTime:after,beforeAssessment:"위험 신호",afterAssessment:"주의 필요",
 added:[],missing:[],eventCounts:{days:30,before:[-1,4,6],after:[2,3,4]},
 diskComparable:true,disks:{before:{warning:-8},after:{warning:4}},signals:null});
 assert.match(s,/BugCheck 기록  확인 불가 → 2/);
 assert.match(s,/저장장치 경고 집계  확인 불가 → 4/);
});
test("print click is disabled before successful comparison",async()=>{
 const f=fixture();
 await f.print();
 assert.equal(f.counts.print,0);
 assert.equal(f.elements["print-history"].disabled,true);
 assert.equal(f.elements["history-print-text"].textContent,"");
});
test("successful comparison builds private summary and prints only on click",async()=>{
 const f=fixture();
 f.select("previous-json",[f.fileFor(sample(before,"BUGCHECK"))]);
 f.select("current-json",[f.fileFor(sample(after,"STORAGE_EVENTS"))]);
 await f.click();
 const s=f.elements["history-print-text"].textContent;
 assert.equal(f.elements["print-history"].disabled,false);
 assert.match(s,/STORAGE_EVENTS/);
 assert.doesNotMatch(s,/PRIVATE_John_Doe|user.name|serial.number/i);
 assert.equal(f.counts.print,0);
 await f.print();
 assert.equal(f.counts.print,1);
});
test("file selection invalidates print immediately after valid comparison",async()=>{
 const f=fixture();
 f.select("previous-json",[f.fileFor(sample(before,"BUGCHECK"))]);
 f.select("current-json",[f.fileFor(sample(after,"STORAGE_EVENTS"))]);
 await f.click();
 f.select("current-json",[f.fileFor(sample(after,"BUGCHECK"))]);
 assert.equal(f.elements["print-history"].disabled,true);
 assert.equal(f.elements["history-print-text"].textContent,"");
 await f.print();
 assert.equal(f.counts.print,0);
});
test("failed comparison cannot print previous result or private JSON parse error",async()=>{
 const f=fixture();
 f.select("previous-json",[f.fileFor(sample(before,"BUGCHECK"))]);
 f.select("current-json",[f.fileFor(sample(after,"STORAGE_EVENTS"))]);
 await f.click();
 const bad={name:"private-secret.json",size:99,text:async()=>"{ bad USERSECRET"};
 f.select("current-json",[bad]);
 await f.click();
 assert.match(f.elements.output.textContent,/비교 불가/);
 assert.equal(f.elements["print-history"].disabled,true);
 assert.doesNotMatch(f.elements.output.textContent,/USERSECRET/);
});
test("batch selection invalidates a prior printable summary",async()=>{
 const f=fixture();
 f.select("previous-json",[f.fileFor(sample(before,"BUGCHECK"))]);
 f.select("current-json",[f.fileFor(sample(after,"STORAGE_EVENTS"))]);
 await f.click();
 await f.select("history-batch",[f.fileFor(sample(before,"BUGCHECK")),f.fileFor(sample(after,"STORAGE_EVENTS"))]);
 assert.equal(f.elements["print-history"].disabled,true);
 assert.equal(f.elements["history-print-text"].textContent,"");
 await f.click();
 assert.equal(f.elements["print-history"].disabled,false);
});
test("A4 print CSS hides all input panels; no remote resources",()=>{
 const html=read("history_compare.html");
 assert.match(html,/@page\s*\{\s*size:A4 portrait/i);
 assert.match(html,/main>:not\(#print-sheet\)\s*\{display:none!important/);
 assert.match(html,/id="print-history"/);
 assert.match(html,/id="history-print-text"/);
 assert.ok(html.indexOf('src="./history_print.js"')<html.indexOf('src="./history_compare.js"'));
 assert.match(html,/connect-src 'none'/);
 assert.doesNotMatch(html,/<script[^>]+src="https?:\/\//);
});
