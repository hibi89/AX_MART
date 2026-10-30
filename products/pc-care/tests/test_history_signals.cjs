"use strict";
const {test}=require("node:test");
const assert=require("node:assert/strict");
const {compareSignals}=require("../ui/history_signals.js");
function observation(){return {
  windows:{build:"26100"},eventWindowDays:30,
  collectionStatus:{windows:"collected",windowsUpdate:"collected",driverDevices:"collected"},
  windowsUpdate:{status:"collected",evidence:[{},{}],installationFailureRecords:1,installationSuccessRecords:1},
  driverDevices:{status:"collected",observedCount:1,samples:[{configurationCode:22}]}
};}
function compare(a=observation(),b=observation()){return compareSignals({observations:a},{observations:b});}
test("three complete independent signals compared without device identifiers",()=>{
 const current=observation();current.windows.build="26200";
 current.windowsUpdate.installationFailureRecords=2;current.windowsUpdate.installationSuccessRecords=0;
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
test("unknown fields are not reflected in output or unexpected files touched",()=>{
 const a=observation();a.untrusted="SECRET USERNAME";a.windows.name="SECRET USERNAME";
 assert.doesNotMatch(JSON.stringify(compare(a)),/SECRET USERNAME/);
});
