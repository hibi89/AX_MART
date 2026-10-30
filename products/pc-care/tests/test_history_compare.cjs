"use strict";
const test=require("node:test");
const assert=require("node:assert/strict");
const {compareReports,validateReport}=require("../ui/history_compare.js");
function sample(at) {return {schemaVersion:1,product:"AXMART PC CARE",mode:"read-only",generatedAt:at,assessment:"주의 필요",
issues:[{code:"DISK_SPACE_LOW"}],observations:{eventWindowDays:30,eventCollection:"collected",bugchecks:[{}],
unexpectedShutdowns:[],storageEvents:[],volumes:[{drive:"C:",sizeGB:100,remainingGB:20}],
physicalDisks:[{status:"Healthy"}]}};}
const a=sample("2026-10-29 11:00:00 +09:00"), b=sample("2026-10-30 11:00:00 +09:00");
test("new/missing issues and capacity delta",()=>{const r=compareReports(a,{...b,issues:[{code:"DISK_SPACE_CRITICAL"}],observations:{...b.observations,volumes:[{drive:"C:",sizeGB:100,remainingGB:4}]}});assert.deepEqual(r.added,["DISK_SPACE_CRITICAL"]);assert.deepEqual(r.missing,["DISK_SPACE_LOW"]);assert.equal(r.drives[0].change,-16);});
test("schema, mode, product, timestamp are mandatory",()=>{assert.ok(validateReport(a));for(const x of [{...b,schemaVersion:2},{...b,mode:"repair"},{...b,product:"wrong"},{...b,generatedAt:"bad"}])assert.throws(()=>compareReports(a,x));});
test("older/current order cannot be inverted or equal",()=>{assert.throws(()=>compareReports(b,a));assert.throws(()=>compareReports(a,a));});
test("no event comparisons when logs unavailable/truncated",()=>{for(const status of ["unavailable","truncated"])assert.equal(compareReports(a,{...b,observations:{...b.observations,eventCollection:status}}).eventCounts,null);});
test("no event comparisons if windows differ or result is capped",()=>{assert.equal(compareReports(a,{...b,observations:{...b.observations,eventWindowDays:7}}).eventCounts,null);assert.equal(compareReports(a,{...b,observations:{...b.observations,bugchecks:Array(30).fill({})}}).eventCounts,null);});
test("invalid or unequal capacity drives are rejected",()=>{for(const v of [{drive:"C:",sizeGB:120,remainingGB:4},{drive:"<script>",sizeGB:100,remainingGB:4}])assert.deepEqual(compareReports(a,{...b,observations:{...b.observations,volumes:[v]}}).drives,[]);});
test("untrusted issue codes never enter output",()=>assert.deepEqual(compareReports(a,{...b,issues:[{code:"<script>"}]}).added,[]));
test("unknown disk is not healthy",()=>assert.equal(compareReports(a,{...b,observations:{...b.observations,physicalDisks:[{status:"Unknown"}]}}).disks.after.unknown,1));
test("missing issue list does not produce false success",()=>assert.ok(compareReports(a,{...b,issues:null}).caution.some(v=>v.includes("경고 코드"))));
