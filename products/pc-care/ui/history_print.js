"use strict";
// H08 local, privacy-bounded A4/PDF print summary. Never reads files or sends data.
(function(root){
 function buildHistoryPrint(result) {
   if (!result || typeof result !== "object") throw Error("No validated comparison");
   const validTime=s=>typeof s==="string" && /^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [+-]\d{2}:\d{2}$/.test(s) ? s:"확인 불가";
   const statuses=["위험 신호","주의 필요","확인 불완전","관찰 범위 내 특이사항 없음"];
   const state=s=>statuses.includes(s)?s:"확인 불가";
   const integer=n=>Number.isSafeInteger(n)&&n>=0?n:null;
   const warnings=(arr)=>{
     if (!Array.isArray(arr))return "비교 불가";
     const safe=arr.filter(x=>typeof x==="string" && /^[A-Z][A-Z0-9_]{1,63}$/.test(x));
     const excerpt=safe.slice(0,6).join(", ")||"없음";
     return excerpt+(safe.length>6?" 외 "+(safe.length-6)+"종":"");
   };
   const count=(v)=>{const n=integer(v);return n===null?"확인 불가":String(n);};
   const lines=[
     "AXMART PC CARE | 반복 검사 비교 요약",
     "비공식 참고자료 · 실제 고장 원인이나 수리 성공을 증명하지 않습니다.",
     "",
     "이전 검사  "+validTime(result.beforeTime),
     "최근 검사  "+validTime(result.afterTime),
     "진단 상태  "+state(result.beforeAssessment)+" → "+state(result.afterAssessment),
     "신규 경고  "+warnings(result.added),
     "최근 미관찰 경고  "+warnings(result.missing)
   ];
   if (result.eventCounts && Number.isInteger(result.eventCounts.days) &&
       result.eventCounts.days>=1 && result.eventCounts.days<=90 &&
       Array.isArray(result.eventCounts.before) && Array.isArray(result.eventCounts.after)) {
     const e=result.eventCounts;
     const names=["BugCheck 기록","비정상 종료 신호","저장장치 이벤트"];
     names.forEach((name,i)=>lines.push(name+"  "+count(e.before[i])+" → "+count(e.after[i])+" (각 "+e.days+"일 조회)"));
   } else lines.push("이벤트 기록  비교 불가 (검사 범위 또는 수집 한계)");
   if (result.diskComparable && result.disks && result.disks.before && result.disks.after) {
     lines.push("저장장치 경고 집계  "+count(result.disks.before.warning)+" → "+count(result.disks.after.warning));
   } else lines.push("저장장치 경고 집계  비교 불가");
   const s=result.signals;
   if (s && s.windows) lines.push("Windows 빌드  "+String(s.windows.before).replace(/[^0-9]/g,"").slice(0,6)+" → "+String(s.windows.after).replace(/[^0-9]/g,"").slice(0,6));
   else lines.push("Windows 빌드  비교 불가");
   if (s && s.updates) lines.push("업데이트 설치 실패 기록  "+count(s.updates.before)+" → "+count(s.updates.after));
   else lines.push("업데이트 설치 실패 기록  비교 불가");
   if (s && s.devices) lines.push("장치 구성 코드 관측  "+count(s.devices.before)+" → "+count(s.devices.after));
   else lines.push("장치 구성 코드 관측  비교 불가");
   lines.push("","해석에 필요한 주의",
     "· 비교한 보고서가 같은 PC·같은 물리 저장장치인지 자동 확인하지 않습니다.",
     "· 경고 미관찰·건수 감소는 문제 해결이나 고장 원인의 증거가 아닙니다.",
     "· 조회 기간·로그 수집 조건에 따라 건수가 달라질 수 있습니다.",
     "· 저장장치 이상이 의심되면 시스템 복구보다 중요한 파일 백업을 우선하세요.",
     "","오프라인 생성 · 파일명/경로/시리얼/원문 이벤트 메시지 미포함");
   return lines.join("\n");
 }
 const api={buildHistoryPrint};
 if(typeof module!=="undefined" && module.exports)module.exports=api;
 root.PcCareHistoryPrint=api;
})(typeof globalThis!=="undefined"?globalThis:this);
