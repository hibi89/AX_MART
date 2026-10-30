"use strict";
const test=require("node:test");
const assert=require("node:assert/strict");
const {compareReports,validateReport}=require("../ui/history_compare.js");
function sample(at) {return {schemaVersion:1,product:"AXMART PC CARE",mode:"read-only",generatedAt:at,assessment:"주의 필요",
issues:[{code:"DISK_SPACE_LOW"}],observations:{eventWindowDays:30,eventCollection:"collected",collectionStatus:{physicalDisks:"collected",events:"collected",volumes:"collected"},
eventEvidence:[{kind:"bugcheck_record",provider:"BugCheck",eventId:1001,timeBasis:"event_recorded_time",recordedUtc:"2026-10-28T01:00:00.0000000Z"}],
bugchecks:[{time:"2026-10-28T10:00:00.000+09:00",stopCode:"0x0000000A"}],
unexpectedShutdowns:[],storageEvents:[],volumes:[{drive:"C:",sizeGB:100,remainingGB:20}],
physicalDisks:[{status:"Healthy"}]}};}
const a=sample("2026-10-29 11:00:00 +09:00"), b=sample("2026-10-30 11:00:00 +09:00");
test("new/missing issues and capacity delta",()=>{const r=compareReports(a,{...b,issues:[{code:"DISK_SPACE_CRITICAL"}],observations:{...b.observations,volumes:[{drive:"C:",sizeGB:100,remainingGB:4}]}});assert.deepEqual(r.added,["DISK_SPACE_CRITICAL"]);assert.deepEqual(r.missing,["DISK_SPACE_LOW"]);assert.equal(r.drives[0].change,-16);});
test("schema, mode, product, timestamp are mandatory",()=>{assert.ok(validateReport(a));for(const x of [{...b,schemaVersion:2},{...b,mode:"repair"},{...b,product:"wrong"},{...b,generatedAt:"bad"}])assert.throws(()=>compareReports(a,x));});
test("older/current order cannot be inverted or equal",()=>{assert.throws(()=>compareReports(b,a));assert.throws(()=>compareReports(a,a));});
test("no event comparisons when logs unavailable/truncated",()=>{for(const status of ["unavailable","truncated"])assert.equal(compareReports(a,{...b,observations:{...b.observations,eventCollection:status}}).eventCounts,null);});
test("no event comparisons if windows differ or result is capped",()=>{assert.equal(compareReports(a,{...b,observations:{...b.observations,eventWindowDays:7}}).eventCounts,null);assert.equal(compareReports(a,{...b,observations:{...b.observations,bugchecks:Array(30).fill({})}}).eventCounts,null);});
test("failed/denied volume collection cannot fake free space change",()=>{
 for(const status of ["unavailable","empty","truncated",null]){
   const current={...b,observations:{...b.observations,collectionStatus:{...b.observations.collectionStatus,volumes:status},
    volumes:[{drive:"C:",sizeGB:100,remainingGB:2}]}};
   assert.deepEqual(compareReports(a,current).drives,[]);
 }
 const previous={...a,observations:{...a.observations,collectionStatus:{...a.observations.collectionStatus,volumes:"unavailable"}}};
 assert.deepEqual(compareReports(previous,b).drives,[]);
});
test("duplicated logical drive letters reject ambiguous volume comparisons",()=>{
 const current={...b,observations:{...b.observations,volumes:[
  {drive:"C:",sizeGB:100,remainingGB:20},
  {drive:"c:",sizeGB:100,remainingGB:1}
 ]}};
 assert.deepEqual(compareReports(a,current).drives,[]);
});
test("incomplete volume data cannot erase a previous low-space warning",()=>{
 const previous={...a,issues:[{code:"DISK_SPACE_LOW"},{code:"BUGCHECK"}]};
 for(const status of ["incomplete","unavailable","truncated"]){
  const current={...b,issues:[],observations:{...b.observations,
   volumeRejectedCount:1,
   collectionStatus:{...b.observations.collectionStatus,volumes:status},
   volumes:[{drive:"C:",sizeGB:100,remainingGB:100}]}};
  const result=compareReports(previous,current);
  assert.deepEqual(result.missing,[]); // Still observed in current validated log.
  assert.deepEqual(result.drives,[]);
  assert.ok(result.caution.some(note=>note.includes("경고의 미관찰 여부")));
 }
});
test("forged collected volume status with rejected records cannot fake recovered free space",()=>{
 for(const bad of [1,2,"0",null]){
  const result=compareReports(a,{...b,issues:[],observations:{...b.observations,
   volumeRejectedCount:bad,
   collectionStatus:{...b.observations.collectionStatus,volumes:"collected"},
   volumes:[{drive:"C:",sizeGB:100,remainingGB:70}]}});
  assert.deepEqual(result.missing,[]);
  assert.deepEqual(result.drives,[]);
 }
});
test("malformed current volume rows cannot erase an old disk-space warning",()=>{
 for(const volumes of [[],null,
   [{drive:"C:",sizeGB:100,remainingGB:30},{drive:"c:",sizeGB:100,remainingGB:40}],
   [{drive:"PRIVATE",sizeGB:100,remainingGB:40}]]){
  const result=compareReports(a,{...b,issues:[],observations:{...b.observations,volumes}});
  assert.deepEqual(result.missing,[]);
 }
});
test("complete volume evidence preserves normal issue comparisons",()=>{
 const complete={...b,issues:[],observations:{...b.observations,volumeRejectedCount:0,
  volumes:[{drive:"C:",sizeGB:100,remainingGB:25}]}};
 const result=compareReports(a,complete);
 assert.deepEqual(result.missing,["DISK_SPACE_LOW"]);
 assert.equal(result.drives[0].change,5);
 const observed={...b,issues:[{code:"DISK_SPACE_CRITICAL"}],observations:{
   ...b.observations,volumeRejectedCount:1,collectionStatus:{...b.observations.collectionStatus,volumes:"incomplete"}}};
 const partial=compareReports(a,observed);
 assert.deepEqual(partial.added,["DISK_SPACE_CRITICAL"]);
 assert.deepEqual(partial.missing,[]);
});
test("valid collected volumes still report bounded capacity delta",()=>{
 const current={...b,observations:{...b.observations,volumes:[{drive:"C:",sizeGB:100,remainingGB:14}]}};
 assert.equal(compareReports(a,current).drives[0].change,-6);
});
test("invalid or unequal capacity drives are rejected",()=>{for(const v of [{drive:"C:",sizeGB:120,remainingGB:4},{drive:"<script>",sizeGB:100,remainingGB:4}])assert.deepEqual(compareReports(a,{...b,observations:{...b.observations,volumes:[v]}}).drives,[]);});
test("untrusted issue codes never enter output",()=>assert.equal(compareReports(a,{...b,issues:[{code:"<script>"}]}).added,null));
test("unknown disk is not healthy",()=>assert.equal(compareReports(a,{...b,observations:{...b.observations,physicalDisks:[{status:"Unknown"}]}}).disks.after.unknown,1));
test("missing issue list does not produce false success",()=>{
 const result=compareReports(a,{...b,issues:null});
 assert.equal(result.added,null);assert.equal(result.missing,null);
 assert.ok(result.caution.some(v=>v.includes("경고 코드")));
});
test("missing/empty/unsupported physical disk evidence is not a zero-warning claim",()=>{
 for(const observations of [
   {...b.observations,physicalDisks:[]},
   {...b.observations,physicalDisks:null},
   {...b.observations,physicalDisks:[{status:"Unknown"}]},
   {...b.observations,collectionStatus:{physicalDisks:"unavailable"}},
   {...b.observations,physicalDisks:[{status:"Healthy"},{status:"Warning"}]}
 ]) assert.equal(compareReports(a,{...b,observations}).diskComparable,false);
});
test("complete same-count storage observations remain comparable, with identity caveat",()=>{
 const result=compareReports(a,{...b,observations:{...b.observations,physicalDisks:[{status:"Warning"}]}});
 assert.equal(result.diskComparable,true);
 assert.equal(result.disks.before.warning,0);
 assert.equal(result.disks.after.warning,1);
 assert.ok(result.caution.some(s=>s.includes("동일성이 확인되지 않은")));
});

test("strict PowerShell date uses offset and rejects equal instants",()=>{
 const sameUtc={...b,generatedAt:"2026-10-29 02:00:00 +00:00"};
 assert.throws(()=>compareReports(a,sameUtc));
 const newerUtc={...b,generatedAt:"2026-10-29 02:00:01 +00:00"};
 assert.ok(compareReports(a,newerUtc));
});
test("strict date rejects impossible calendar and impossible offset",()=>{
 for(const at of ["2026-02-30 11:00:00 +09:00","2026-13-01 11:00:00 +09:00",
   "2026-10-30 24:00:00 +09:00","2026-10-30 11:99:00 +09:00",
   "2026-10-30 11:00:60 +09:00","2026-10-30 11:00:00 +15:00",
   "2026-10-30 11:00:00 +14:30","2026-10-30T11:00:00+09:00",
   "2026-10-30 11:00:00","2026-10-30 11:00:00 +09:0x"])
   assert.throws(()=>compareReports(a,{...b,generatedAt:at}),at);
});
test("valid leap day and UTC negative offsets compare correctly",()=>{
 const leap={...a,generatedAt:"2024-02-29 22:00:00 -05:00"};
 const following={...b,generatedAt:"2024-03-01 04:00:00 -04:00"};
 assert.ok(compareReports(leap,following));
});
test("System history counts must match validated normalizer evidence",()=>{
 const valid=compareReports(a,b);
 assert.deepEqual(valid.eventCounts,{days:30,before:[1,0,0],after:[1,0,0]});
 const invalid=[
   o=>{o.eventEvidence=[]}, // displayed rows cannot invent events
   o=>{o.eventEvidence=[{}]},
   o=>{o.eventEvidence[0].eventId=41},
   o=>{delete o.eventEvidence[0].provider},
   o=>{o.eventEvidence[0].provider="FakeBugCheck"},
   o=>{o.eventEvidence[0].kind="storage_signal"},
   o=>{o.eventEvidence[0].timeBasis="inferred_crash_time"},
   o=>{o.eventEvidence[0].recordedUtc="2026-02-30T01:00:00Z"},
   o=>{o.eventEvidence[0].recordedUtc="2026-10-28T01:00:00"},
   o=>{o.collectionStatus.events="unavailable"},
   o=>{delete o.eventEvidence},
   o=>{o.unexpectedShutdowns=[{}]},
   o=>{o.storageEvents=[{}]}
 ];
 for(const change of invalid){
   const report={...b,observations:structuredClone(b.observations)};
   change(report.observations);
   assert.equal(compareReports(a,report).eventCounts,null);
 }
});
test("System event provider must match event type and EventID",()=>{
 const failures=[
   {kind:"bugcheck_record",eventId:1001,provider:"PRIVATE-USERNAME"},
   {kind:"shutdown_signal",eventId:41,provider:"EventLog"},
   {kind:"shutdown_signal",eventId:6008,provider:"Kernel-Power"},
   {kind:"storage_signal",eventId:153,provider:"BugCheck"}
 ];
 for(const fail of failures){
   const current={...b,observations:{...b.observations,
     eventEvidence:[{...b.observations.eventEvidence[0],...fail}]}};
   assert.equal(compareReports(a,current).eventCounts,null);
 }
 const valid={...b,observations:{...b.observations,eventEvidence:[{...b.observations.eventEvidence[0],provider:"Microsoft-Windows-BugCheck"}]}};
 assert.deepEqual(compareReports(a,valid).eventCounts.after,[1,0,0]);
});
test("actual no-match is a genuine zero, missing logs are not",()=>{
 const empty={...b,observations:{...b.observations,
   eventCollection:"no matching events",
   collectionStatus:{...b.observations.collectionStatus,events:"no matching events"},
   eventEvidence:[],bugchecks:[],unexpectedShutdowns:[],storageEvents:[]}};
 assert.deepEqual(compareReports(a,empty).eventCounts.after,[0,0,0]);
 const missing={...empty,observations:{...empty.observations,eventCollection:"unavailable"}};
 assert.equal(compareReports(a,missing).eventCounts,null);
});
test("System source type and ID validation still allows real storage and shutdown observations",()=>{
 const newer={...b,observations:{...b.observations,
  eventEvidence:[
    {kind:"shutdown_signal",provider:"EventLog",eventId:6008,timeBasis:"event_recorded_time",recordedUtc:"2026-10-30T02:00:00.0000000Z"},
    {kind:"storage_signal",provider:"disk",eventId:153,timeBasis:"event_recorded_time",recordedUtc:"2026-10-30T02:00:01.0000000Z"}],
  bugchecks:[],unexpectedShutdowns:[{time:"2026-10-30T11:00:00.000+09:00",eventId:6008}],
  storageEvents:[{time:"2026-10-30T11:00:01.000+09:00",eventId:153,source:"disk"}]
 }};
 assert.deepEqual(compareReports(a,newer).eventCounts.after,[0,1,1]);
});
test("unrecognized assessment text never appears in comparison",()=>{
 const result=compareReports(a,{...b,assessment:"SECRET DEVICE SERIAL: 12345"});
 assert.equal(result.afterAssessment,"확인 불가");
 assert.doesNotMatch(JSON.stringify(result),/SECRET DEVICE SERIAL/);
 assert.ok(result.caution.some(v=>v.includes("상태값")));
});

test("System warning cannot disappear when the current log collector fails",()=>{
 const earlier={...a,issues:[{code:"BUGCHECK"},{code:"UNEXPECTED_REBOOT"},{code:"STORAGE_EVENTS"}]};
 const latest={...b,issues:[],observations:{...b.observations,eventCollection:"unavailable",
   collectionStatus:{...b.observations.collectionStatus,events:"unavailable"},
   eventEvidence:[],bugchecks:[],unexpectedShutdowns:[],storageEvents:[]}};
 const r=compareReports(earlier,latest);
 assert.deepEqual(r.missing,[]);
 assert.equal(r.eventCounts,null);
 assert.ok(r.caution.some(s=>s.includes("미관찰 여부를 판단하지 않습니다")));
});
test("System warning absence requires complete validated no-match log",()=>{
 const earlier={...a,issues:[{code:"BUGCHECK"}]};
 const latest={...b,issues:[],observations:{...b.observations,
   eventCollection:"no matching events",collectionStatus:{...b.observations.collectionStatus,events:"no matching events"},
   eventEvidence:[],bugchecks:[],unexpectedShutdowns:[],storageEvents:[]}};
 const r=compareReports(earlier,latest);
 assert.deepEqual(r.missing,["BUGCHECK"]);
 assert.deepEqual(r.eventCounts.after,[0,0,0]);
});
test("physical disk warning missing requires comparable complete disk inventory",()=>{
 const earlier={...a,issues:[{code:"DISK_HEALTH"}],observations:{...a.observations,physicalDisks:[{status:"Warning"}]}};
 const complete={...b,issues:[],observations:{...b.observations,physicalDisks:[{status:"Healthy"}]}};
 assert.deepEqual(compareReports(earlier,complete).missing,["DISK_HEALTH"]);
 const failed={...complete,observations:{...complete.observations,
   collectionStatus:{...complete.observations.collectionStatus,physicalDisks:"unavailable"}}};
 assert.deepEqual(compareReports(earlier,failed).missing,[]);
});
