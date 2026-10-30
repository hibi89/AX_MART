"use strict";
const {test}=require("node:test");
const assert=require("node:assert/strict");
const {compareSignals}=require("../ui/history_signals.js");
function updateRecord(id,utc="2026-10-30T01:02:03.0000000Z"){return {
  kind:id===20?"update_installation_failure_record":"update_installation_success_record",
  eventId:id,timeBasis:"event_recorded_time",recordedUtc:utc
};}
function observation(){return {
  windows:{build:"26100"},eventWindowDays:30,
  collectionStatus:{windows:"collected",windowsUpdate:"collected",driverDevices:"collected"},
  windowsUpdate:{status:"collected",evidence:[updateRecord(20),updateRecord(19)],installationFailureRecords:1,installationSuccessRecords:1},
  driverDevices:{status:"collected",observedCount:1,samples:[{configurationCode:22,rootCauseConfirmed:false}]}
};}
function compare(a=observation(),b=observation()){return compareSignals({observations:a},{observations:b});}
test("three complete independent signals compared without device identifiers",()=>{
 const current=observation();current.windows.build="26200";
 current.windowsUpdate.installationFailureRecords=2;current.windowsUpdate.installationSuccessRecords=0;
 current.windowsUpdate.evidence=[updateRecord(20),updateRecord(20)];
 current.driverDevices.observedCount=0;current.driverDevices.samples=[];current.driverDevices.status="no matching devices";
 current.collectionStatus.driverDevices="no matching devices";
 const r=compare(observation(),current);
 assert.deepEqual(r.windows,{before:"26100",after:"26200",changed:true});
 assert.deepEqual(r.updates,{before:1,after:2,days:30});
 assert.deepEqual(r.devices,{before:1,after:0});
 assert.doesNotMatch(JSON.stringify(r),/serial|friendlyName|deviceId/i);
});
test("no matched updates and no matched devices are genuine zeros",()=>{
 const z=observation();z.windowsUpdate={status:"no matching events",evidence:[],installationFailureRecords:0,installationSuccessRecords:0};
 z.collectionStatus.windowsUpdate="no matching events";
 z.driverDevices={status:"no matching devices",observedCount:0,samples:[]};z.collectionStatus.driverDevices="no matching devices";
 const r=compare(z,z);assert.equal(r.updates.before,0);assert.equal(r.devices.before,0);
});
test("unavailable/truncated windows update never compare",()=>{
 for(const status of ["unavailable","truncated","no matching devices"]){const a=observation();a.windowsUpdate.status=status;a.collectionStatus.windowsUpdate=status;assert.equal(compare(a).updates,null);}
});
test("update window mismatch, cap and inconsistent evidence never compare",()=>{
 for(const mut of [a=>{a.eventWindowDays=7},a=>{a.windowsUpdate.evidence=Array(300).fill({})},
  a=>{a.windowsUpdate.installationFailureRecords=99},a=>{a.collectionStatus.windowsUpdate="unavailable"},
  a=>{a.windowsUpdate.installationFailureRecords=-1}]){const a=observation();mut(a);assert.equal(compare(a).updates,null);}
});
test("devices never show zero for missing, truncated, inconsistent or unsupported",()=>{
 const cases=[a=>{a.driverDevices.status="truncated";a.collectionStatus.driverDevices="truncated"},
  a=>{a.driverDevices.observedCount=31},a=>{a.driverDevices.samples=[]},
  a=>{a.driverDevices.status="unavailable";a.collectionStatus.driverDevices="unavailable"},
  a=>{a.driverDevices.observedCount=null},a=>{delete a.driverDevices},
  a=>{a.collectionStatus.driverDevices="unavailable"}];
 for(const mut of cases){const a=observation();mut(a);assert.equal(compare(a).devices,null);}
});
test("Windows build only if collected and strictly numeric",()=>{
 for(const mut of [a=>{a.windows.build="<secret>"},a=>{a.collectionStatus.windows="unavailable"},a=>{delete a.windows}]){
  const a=observation();mut(a);assert.equal(compare(a).windows,null);
 }
});
test("forged update records never become a valid count comparison",()=>{
 const mutations=[
  a=>{a.windowsUpdate.evidence=[{},{}]},
  a=>{a.windowsUpdate.evidence[0].eventId=19},
  a=>{a.windowsUpdate.evidence[0].kind="raw_private_event"},
  a=>{a.windowsUpdate.evidence[0].timeBasis="actual_crash_time"},
  a=>{a.windowsUpdate.evidence[0].recordedUtc="2026-02-30T01:00:00Z"},
  a=>{a.windowsUpdate.evidence[0].recordedUtc="2026-10-30T01:00:00"},
  a=>{a.windowsUpdate.evidence[0].recordedUtc="2026-10-30T01:00:00+09:00"},
  a=>{a.windowsUpdate.installationFailureRecords=0;a.windowsUpdate.installationSuccessRecords=2}
 ];
 for(const change of mutations){const input=observation();change(input);assert.equal(compare(input).updates,null);}
});
test("invalid PnP samples cannot produce a fabricated device count",()=>{
 for(const change of [
  a=>{a.driverDevices.samples=[{}]},
  a=>{a.driverDevices.samples=[{configurationCode:0,rootCauseConfirmed:false}]},
  a=>{a.driverDevices.samples=[{configurationCode:56,rootCauseConfirmed:false}]},
  a=>{a.driverDevices.samples=[{configurationCode:22,rootCauseConfirmed:true}]},
  a=>{a.driverDevices.samples=[{configurationCode:22}]}
 ]){const input=observation();change(input);assert.equal(compare(input).devices,null);}
});
test("valid normalized Windows UTC event and PnP records compare",()=>{
 const input=observation();
 input.windowsUpdate.evidence=[updateRecord(20,"2026-02-28T02:00:00Z"),updateRecord(19,"2024-02-29T02:00:00+00:00")];
 assert.deepEqual(compare(input).updates,{before:1,after:1,days:30});
 assert.deepEqual(compare(input).devices,{before:1,after:1});
});
test("unknown fields are not reflected in output or unexpected files touched",()=>{
 const a=observation();a.untrusted="SECRET USERNAME";a.windows.name="SECRET USERNAME";
 assert.doesNotMatch(JSON.stringify(compare(a)),/SECRET USERNAME/);
});
