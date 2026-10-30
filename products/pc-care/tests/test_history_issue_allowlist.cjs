"use strict";
const {test}=require("node:test");
const assert=require("node:assert/strict");
const {compareReports}=require("../ui/history_compare.js");
const {buildHistoryPrint}=require("../ui/history_print.js");
const CODES=["DISK_HEALTH","STORAGE_EVENTS","DISK_SPACE_CRITICAL","DISK_SPACE_LOW","BUGCHECK","UNEXPECTED_REBOOT","WINDOWS_UPDATE_FAILURE_RECORD","PNP_CONFIGURATION"];
const report=(t,issues=[])=>({schemaVersion:1,product:"AXMART PC CARE",mode:"read-only",generatedAt:t,assessment:"주의 필요",issues,
  observations:{eventWindowDays:30,eventCollection:"collected",collectionStatus:{physicalDisks:"collected"},bugchecks:[],unexpectedShutdowns:[],storageEvents:[],volumes:[],physicalDisks:[{status:"Healthy"}]}});
const earlier=(items=[])=>report("2026-10-28 08:00:00 +09:00",items);
const later=(items=[])=>report("2026-10-30 08:00:00 +09:00",items);
const input=items=>items.map(code=>({code}));
test("known warning codes without collector evidence are not treated as observed",()=>{
 const result=compareReports(earlier(),later(input(CODES)));
 assert.deepEqual(result.added,[]);
 assert.deepEqual(result.missing,[]);
 assert.match(result.caution.join(" "),/신규 경고 중 수집 증거가 불완전하거나/);
});
test("unknown uppercase code cannot appear as a newly observed warning",()=>{
 const r=compareReports(earlier(),later(input(["CUSTOMER_PRIVATE_NAME"])));
 assert.equal(r.added,null);assert.equal(r.missing,null);
 assert.match(r.caution.join(" "),/경고 코드 배열을 읽지 못해/);
 assert.doesNotMatch(JSON.stringify(r),/CUSTOMER_PRIVATE_NAME/);
});
test("unknown code mixed with trusted warning makes entire comparison uncertain",()=>{
 const r=compareReports(earlier(),later(input(["BUGCHECK","USER_SERIAL_1234"])));
 assert.equal(r.added,null);assert.equal(r.missing,null);
});
test("old report with unknown code cannot claim warning disappearance",()=>{
 const r=compareReports(earlier(input(["USER_SECRET_ABC"])),later());
 assert.equal(r.missing,null);assert.equal(r.added,null);
});
test("malformed and missing issue entries fail closed",()=>{
 for(const issue of [null,{}, {code:27},{code:"<script>"},{code:""}]){
  const r=compareReports(earlier(),later([issue]));
  assert.equal(r.added,null);
 }
 const r=compareReports(earlier(),later(null));
 assert.equal(r.added,null);
});
test("print builder never echoes syntactically valid arbitrary codes",()=>{
 const r={beforeTime:earlier().generatedAt,afterTime:later().generatedAt,beforeAssessment:"주의 필요",afterAssessment:"주의 필요",added:["PRIVATE_USERNAME"],missing:[],eventCounts:null,diskComparable:false,signals:null};
 const text=buildHistoryPrint(r);
 assert.match(text,/신규 경고  비교 불가/);
 assert.doesNotMatch(text,/PRIVATE_USERNAME/);
});
test("print builder rejects mixed known and untrusted warning codes",()=>{
 const r={beforeTime:earlier().generatedAt,afterTime:later().generatedAt,beforeAssessment:"주의 필요",afterAssessment:"주의 필요",added:["BUGCHECK","CREDIT_CARD_1234"],missing:[],eventCounts:null,diskComparable:false,signals:null};
 const text=buildHistoryPrint(r);
 assert.match(text,/신규 경고  비교 불가/);
 assert.doesNotMatch(text,/CREDIT_CARD_1234/);
});
test("print builder still shows bounded approved issue codes",()=>{
 const r={beforeTime:earlier().generatedAt,afterTime:later().generatedAt,beforeAssessment:"주의 필요",afterAssessment:"주의 필요",added:CODES,missing:[],eventCounts:null,diskComparable:false,signals:null};
 const text=buildHistoryPrint(r);
 assert.match(text,/DISK_HEALTH/);
 assert.match(text,/외 2종/);
 assert.doesNotMatch(text,/USER_SECRET/);
});
