"use strict";
// Full normalized JSON -> local H08 comparison -> private print summary.
// Synthetic only; no device inspection, filesystem writes or remote transport.
const {test}=require("node:test");
const assert=require("node:assert/strict");
const {compareReports}=require("../ui/history_compare.js");
const {buildHistoryPrint}=require("../ui/history_print.js");
const event=(kind,eventId,utc)=>({
  kind,eventId,timeBasis:"event_recorded_time",recordedUtc:utc
});
const update=(id)=>event(id===20?"update_installation_failure_record":"update_installation_success_record",id,"2026-10-29T01:00:00.0000000Z");
const d=(code)=>({configurationCode:code,category:"other",interpretation:"device_configuration_issue_record",rootCauseConfirmed:false});
function snapshot(at,{after=false}={}){
 const e=after
   ? [event("shutdown_signal",41,"2026-10-30T01:01:00.0000000Z")]
   : [event("bugcheck_record",1001,"2026-10-29T01:01:00.0000000Z"),event("shutdown_signal",6008,"2026-10-29T01:02:00.0000000Z"),event("storage_signal",153,"2026-10-29T01:03:00.0000000Z")];
 const updates=after?[]:[update(20),update(19)];
 const devices=after?[]:[d(10)];
 return {schemaVersion:1,product:"AXMART PC CARE",mode:"read-only",generatedAt:at,assessment:"주의 필요",
   issues:after?[]:[{code:"BUGCHECK"},{code:"STORAGE_EVENTS"}],
   observations:{
    eventWindowDays:30,eventCollection:"collected",eventEvidence:e,
    collectionStatus:{events:"collected",windows:"collected",physicalDisks:"collected",
      windowsUpdate:after?"no matching events":"collected",driverDevices:after?"no matching devices":"collected"},
    windows:{build:"26100"},volumes:[{drive:"C:",sizeGB:100,remainingGB:after?24:21}],
    physicalDisks:[{status:"Healthy"}],
    bugchecks:after?[]:[{time:"2026-10-29T10:01:00.000+09:00",stopCode:"0x0000000A"}],
    unexpectedShutdowns:[{time:after?"2026-10-30T10:01:00.000+09:00":"2026-10-29T10:02:00.000+09:00",eventId:after?41:6008}],
    storageEvents:after?[]:[{time:"2026-10-29T10:03:00.000+09:00",eventId:153,source:"disk"}],
    windowsUpdate:{status:after?"no matching events":"collected",evidence:updates,
      installationFailureRecords:after?0:1,installationSuccessRecords:after?0:1},
    driverDevices:{status:after?"no matching devices":"collected",observedCount:devices.length,samples:devices}
   }
 };
}
const before=snapshot("2026-10-29 11:00:00 +09:00");
const after=snapshot("2026-10-30 11:00:00 +09:00",{after:true});
const copy=x=>JSON.parse(JSON.stringify(x));
test("real-shaped normalized event JSON connects history comparison to offline print",()=>{
 const c=compareReports(before,after);
 assert.deepEqual(c.eventCounts,{days:30,before:[1,1,1],after:[0,1,0]});
 assert.deepEqual(c.signals.updates,{before:1,after:0,days:30});
 assert.deepEqual(c.signals.devices,{before:1,after:0});
 const summary=buildHistoryPrint(c);
 assert.match(summary,/BugCheck 기록  1 → 0/);
 assert.match(summary,/업데이트 설치 실패 기록  1 → 0/);
 assert.match(summary,/장치 구성 코드 관측  1 → 0/);
 assert.match(summary,/고장 원인이나 수리 성공을 증명하지 않습니다/);
});
test("forged System display rows cannot invent event counts or printable success",()=>{
 const forged=copy(after);
 forged.observations.eventEvidence=[];
 forged.observations.bugchecks=[{time:"PRIVATE-NAME"}];
 const c=compareReports(before,forged);
 assert.equal(c.eventCounts,null);
 const text=buildHistoryPrint(c);
 assert.match(text,/이벤트 기록  비교 불가/);
 assert.doesNotMatch(text,/PRIVATE-NAME/);
});
test("stale System array after unavailable query stays non-comparable",()=>{
 const stale=copy(after);
 stale.observations.eventCollection="unavailable";
 stale.observations.collectionStatus.events="unavailable";
 assert.equal(compareReports(before,stale).eventCounts,null);
});
test("invalid Windows Update record and PnP device item cannot fake statistics",()=>{
 const bad=copy(before);
 bad.observations.windowsUpdate.evidence[0].kind="secret_device";
 bad.observations.driverDevices.samples[0].configurationCode="10 PRIVATE_SERIAL";
 const c=compareReports(bad,after);
 assert.equal(c.signals.updates,null);
 assert.equal(c.signals.devices,null);
 assert.doesNotMatch(buildHistoryPrint(c),/PRIVATE_SERIAL|secret_device/);
});
test("missing all System samples is an observed zero only after complete no-match",()=>{
 const none=copy(after);
 none.observations.eventCollection="no matching events";
 none.observations.collectionStatus.events="no matching events";
 none.observations.eventEvidence=[];
 none.observations.unexpectedShutdowns=[];
 assert.deepEqual(compareReports(before,none).eventCounts.after,[0,0,0]);
 none.observations.collectionStatus.events="unavailable";
 assert.equal(compareReports(before,none).eventCounts,null);
});
