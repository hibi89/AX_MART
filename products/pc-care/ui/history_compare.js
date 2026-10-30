"use strict";
(function (root) {
function validateReport(r){
 if(!r||typeof r!=="object"||Array.isArray(r)||r.schemaVersion!==1||r.product!=="AXMART PC CARE"||r.mode!=="read-only"||!r.observations||typeof r.observations!=="object"||Array.isArray(r.observations))throw Error("지원하지 않는 PC CARE 읽기 전용 JSON 형식입니다.");
 // PowerShell 5.1 emits yyyy-MM-dd HH:mm:ss zzz. Do not depend on
 // browser-specific Date.parse acceptance of this non-ISO text format.
 const m=typeof r.generatedAt==="string" && /^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2}) ([+-])(\d{2}):(\d{2})$/.exec(r.generatedAt);
 if(!m)throw Error("보고서 생성시각 형식이 올바르지 않습니다.");
 const y=Number(m[1]),mo=Number(m[2]),day=Number(m[3]),hour=Number(m[4]),minute=Number(m[5]),second=Number(m[6]);
 const offHours=Number(m[8]),offMinutes=Number(m[9]);
 const calendar=new Date(Date.UTC(y,mo-1,day,hour,minute,second));
 if(y<2000||y>2099||calendar.getUTCFullYear()!==y||calendar.getUTCMonth()!==mo-1||
   calendar.getUTCDate()!==day||calendar.getUTCHours()!==hour||calendar.getUTCMinutes()!==minute||
   calendar.getUTCSeconds()!==second||offHours>14||offMinutes>59||(offHours===14&&offMinutes!==0))
   throw Error("보고서 생성시각의 날짜 또는 UTC 시차가 유효하지 않습니다.");
 const offsetMinutes=(m[7]==="+"?1:-1)*(offHours*60+offMinutes);
 const stamp=calendar.getTime()-offsetMinutes*60000;
 if(!Number.isFinite(stamp))throw Error("보고서 생성시각을 확인할 수 없습니다.");
 return {r,stamp,o:r.observations};
}
function compareReports(oldReport,newReport){
 const a=validateReport(oldReport),b=validateReport(newReport);
 if(b.stamp<=a.stamp)throw Error("현재 보고서는 과거 보고서보다 나중에 생성되어야 합니다.");
 const caution=["동일한 PC의 보고서인지는 판별하지 못합니다. 다른 PC 기록을 비교하지 마세요.","이 결과는 관측치 비교이며 수리 성공이나 고장 해결을 증명하지 않습니다."];
 // Compare additional already-collected, bounded Windows signals without new OS reads.
 const signalApi = (typeof module !== "undefined" && module.exports) ? require("./history_signals.js") : root.PcCareHistorySignals;
 const signals = signalApi && typeof signalApi.compareSignals === "function" ? signalApi.compareSignals(a.r,b.r) : null;
 if (signals) caution.push(...signals.notes);
 else caution.push("추가 관측 비교 모듈을 불러오지 못해 확장 비교를 생략했습니다.");
 const issueCodes=new Set(["DISK_HEALTH","STORAGE_EVENTS","DISK_SPACE_CRITICAL","DISK_SPACE_LOW","BUGCHECK","UNEXPECTED_REBOOT","WINDOWS_UPDATE_FAILURE_RECORD","PNP_CONFIGURATION"]);
 // A syntactically uppercase value is NOT necessarily a PC CARE warning.
 // Unknown/malformed entries make the comparison incomplete, never "no warnings".
 const codeSet=x=>{
   if(!Array.isArray(x.r.issues))return null;
   const known=new Set();
   for(const issue of x.r.issues){
     if(!issue||typeof issue.code!=="string"||!issueCodes.has(issue.code))return null;
     known.add(issue.code);
   }
   return known;
 };
 const prev=codeSet(a),next=codeSet(b);
 // Unknown issue lists must not be presented as "no warnings".
 const added=prev&&next?[...next].filter(x=>!prev.has(x)).sort():null;
 const missing=prev&&next?[...prev].filter(x=>!next.has(x)).sort():null;
 const complete=x=>["collected","no matching events"].includes(x.o.eventCollection);
 const names=["bugchecks","unexpectedShutdowns","storageEvents"];
 const counts=x=>names.map(n=>Array.isArray(x.o[n])?x.o[n].length:null);
 const oldCounts=counts(a),newCounts=counts(b);
 const comparableEvents=complete(a)&&complete(b)&&Number.isInteger(a.o.eventWindowDays)&&a.o.eventWindowDays>0&&a.o.eventWindowDays===b.o.eventWindowDays&&oldCounts.concat(newCounts).every(n=>n!==null&&n<30);
 const eventCounts=comparableEvents?{days:a.o.eventWindowDays,before:oldCounts,after:newCounts}:null;
 caution.push(eventCounts?"이벤트 수는 이동하는 조회 기간의 로그 수로, 실제 사건 횟수나 호전을 의미하지 않습니다.":"이벤트 수는 기간·수집상태·표시 상한이 달라 비교하지 않습니다.");
 const volumeMap=x=>{const m=new Map();if(Array.isArray(x.o.volumes))for(const v of x.o.volumes){if(!v||!(/^[A-Z]:$/i.test(v.drive))||!Number.isFinite(v.sizeGB)||!Number.isFinite(v.remainingGB)||v.sizeGB<=0||v.remainingGB<0||v.remainingGB>v.sizeGB)continue;m.set(v.drive.toUpperCase(),v);}return m;};
 const pastDrives=volumeMap(a),currentDrives=volumeMap(b),drives=[];
 for(const [id,v] of currentDrives){const prevDisk=pastDrives.get(id);if(!prevDisk||Math.abs(v.sizeGB-prevDisk.sizeGB)/Math.max(v.sizeGB,prevDisk.sizeGB)>0.05)continue;drives.push({drive:id,before:prevDisk.remainingGB,after:v.remainingGB,change:Math.round((v.remainingGB-prevDisk.remainingGB)*10)/10});}
 drives.sort((x,y)=>x.drive.localeCompare(y.drive));
 if(drives.length)caution.push("같은 드라이브 문자·용량이어도 같은 물리 저장장치라는 보장은 없습니다.");
 const diskSummary=x=>!Array.isArray(x.o.physicalDisks)?null:{count:x.o.physicalDisks.length,warning:x.o.physicalDisks.filter(d=>d&&["Warning","Unhealthy"].includes(d.status)).length,unknown:x.o.physicalDisks.filter(d=>!d||!["Healthy","Warning","Unhealthy"].includes(d.status)).length};
 const disks={before:diskSummary(a),after:diskSummary(b)};
 // Missing data, unsupported device status, or a changing number of detected
 // disks cannot support a meaningful warning-count comparison.
 const diskComparable=!!(disks.before&&disks.after&&disks.before.count>0&&
   disks.before.count===disks.after.count&&disks.before.unknown===0&&disks.after.unknown===0&&
   a.o.collectionStatus&&a.o.collectionStatus.physicalDisks==="collected"&&
   b.o.collectionStatus&&b.o.collectionStatus.physicalDisks==="collected");
 caution.push(diskComparable?"물리 저장장치 경고 건수는 장치 동일성이 확인되지 않은 집계입니다.":"저장장치 조회 상태·장치 수·미확인 값 때문에 경고 건수의 직접 비교를 보류합니다.");
 if(missing&&missing.length)caution.push("최근 기록에 보이지 않는 경고는 문제가 해결됐다는 뜻이 아닙니다.");
 if(!prev||!next)caution.push("경고 코드 배열을 읽지 못해 신규/미관찰 경고 비교를 건너뛰었습니다.");
 // Never echo arbitrary untrusted assessment text from a local JSON file.
 const safeAssessment=r=>["위험 신호","주의 필요","확인 불완전","관찰 범위 내 특이사항 없음"].includes(r.assessment)?r.assessment:"확인 불가";
 if(safeAssessment(a.r)==="확인 불가"||safeAssessment(b.r)==="확인 불가")caution.push("진단 상태값을 인식하지 못해 확인 불가로 표시합니다.");
 return {beforeTime:a.r.generatedAt,afterTime:b.r.generatedAt,beforeAssessment:safeAssessment(a.r),afterAssessment:safeAssessment(b.r),added,missing,eventCounts,drives,disks,diskComparable,signals,caution};
}
  const api = { validateReport, compareReports };
  if (typeof module !== "undefined" && module.exports) module.exports = api;
  if (typeof document === "undefined") return;
  function init() {
    const prev = document.getElementById("previous-json");
    const curr = document.getElementById("current-json");
    const button = document.getElementById("compare");
    const output = document.getElementById("output");
    const printButton = document.getElementById("print-history");
    const printText = document.getElementById("history-print-text");
    if (!prev || !curr || !button || !output) return;
    function resetPrint() {
      if (printButton) printButton.disabled = true;
      if (printText) printText.textContent = "";
    }
    if (printButton) {
      printButton.addEventListener("click",()=>{
        if (printButton.disabled || !printText || !printText.textContent) return;
        if (typeof root.print === "function") root.print(); // Explicit user click only.
      });
    }
    let selectionRevision = 0; // Invalidate an in-flight comparison when a selected file changes.
    const batch = document.getElementById("history-batch");
    const historyPrevious = document.getElementById("history-previous");
    const historyCurrent = document.getElementById("history-current");
    const historyStatus = document.getElementById("history-status");
    let selectedHistory = null; // Ephemeral File handles, never persistent storage.
    const safeAssessment = report => ["위험 신호","주의 필요","확인 불완전","관찰 범위 내 특이사항 없음"].includes(report.assessment)?report.assessment:"확인 불가";
    function checkFile(f) {
      if (!f || f.size < 1 || f.size > 2000000) throw Error("JSON 파일은 2MB 이하만 선택하세요.");
      if (!/[.]json$/i.test(f.name)) throw Error("JSON 파일만 선택하세요.");
    }
    async function parseFile(f) {
      checkFile(f);
      return JSON.parse((await f.text()).replace(/^\uFEFF/, ""));
    }
    if (batch && historyPrevious && historyCurrent && historyStatus) {
      const clearHistory = () => {
        selectedHistory = null;
        historyPrevious.disabled = true;
        historyCurrent.disabled = true;
        historyPrevious.replaceChildren();
        historyCurrent.replaceChildren();
      };
      batch.addEventListener("change", async () => {
        const revision = ++selectionRevision;
        resetPrint();
        clearHistory();
        output.textContent = "이력 파일이 변경되어 이전 비교 내용을 지웠습니다.";
        const files = Array.from(batch.files || []);
        if (!files.length) { historyStatus.textContent = "선택한 파일이 없습니다."; return; }
        if (files.length > 25 || files.reduce((sum,f)=>sum+f.size,0) > 12000000) {
          historyStatus.textContent = "최대 25개, 합계 12MB 이하의 JSON만 선택하세요.";
          return;
        }
        historyStatus.textContent = "선택한 파일을 로컬에서 확인하고 있습니다.";
        try {
          const history = await Promise.all(files.map(async file => {
            const report = await parseFile(file);
            const validated = validateReport(report);
            return {file, stamp:validated.stamp, time:report.generatedAt, assessment:safeAssessment(report)};
          }));
          if (revision !== selectionRevision) return;
          if (history.length < 2) throw Error("적어도 두 건의 보고서를 선택해야 합니다.");
          history.sort((a,b)=>a.stamp-b.stamp);
          history.forEach((item,i) => {
            const label = (i+1)+". "+item.time+" | "+item.assessment;
            for (const select of [historyPrevious,historyCurrent]) {
              const option = document.createElement("option");
              option.value = String(i);
              option.textContent = label; // Never display file names or raw issues.
              select.appendChild(option);
            }
          });
          historyPrevious.value = "0";
          historyCurrent.value = String(history.length-1);
          historyPrevious.disabled = false;
          historyCurrent.disabled = false;
          selectedHistory = history;
          historyStatus.textContent = history.length+"개 보고서 확인. 과거/현재를 지정한 뒤 비교를 누르세요. 목록은 메모리에서만 유지됩니다.";
        } catch (_err) {
          if (revision === selectionRevision) {
            clearHistory();
            historyStatus.textContent = "보고서 일괄 선택을 사용할 수 없습니다. 개수·용량·JSON 형식 및 검사시각을 확인하세요.";
          }
        }
      });
      [historyPrevious,historyCurrent].forEach(select=>select.addEventListener("change",()=>{
        selectionRevision++;
        resetPrint();
        output.textContent = "비교 대상으로 선택한 검사 결과가 변경되었습니다.";
      }));
    }
    button.addEventListener("click", async () => {
      const requestRevision = selectionRevision;
      resetPrint();
      button.disabled = true;
      output.textContent = "기기 내부에서 보고서를 읽고 있습니다.";
      try {
        const selectedIndex = (select) => {
          const n = Number(select.value);
          return Number.isSafeInteger(n) && n >= 0 && n < selectedHistory.length ? n : -1;
        };
        const oldIndex = selectedHistory ? selectedIndex(historyPrevious) : -1;
        const newIndex = selectedHistory ? selectedIndex(historyCurrent) : -1;
        if (selectedHistory && (oldIndex < 0 || newIndex < 0 || oldIndex === newIndex)) throw Error("일괄 이력에서 서로 다른 두 검사를 선택하세요.");
        const oldFile = selectedHistory ? selectedHistory[oldIndex].file : prev.files[0];
        const newFile = selectedHistory ? selectedHistory[newIndex].file : curr.files[0];
        if (!oldFile || !newFile) throw Error("과거와 현재 JSON을 각각 선택하세요.");
        checkFile(oldFile);checkFile(newFile);
        const [before,after] = await Promise.all([parseFile(oldFile),parseFile(newFile)]);
        if (requestRevision !== selectionRevision) return; // Never display stale file data.
        if (JSON.stringify(before) === JSON.stringify(after)) throw Error("서로 다른 두 검사 결과를 선택하세요.");
        const result = compareReports(before,after);
        const lines = ["AXMART PC CARE — 오프라인 반복 검사 비교 (고장 확정 아님)",
          "과거: " + result.beforeTime, "현재: " + result.afterTime,
          "상태: " + result.beforeAssessment + " → " + result.afterAssessment,
          "새로 관찰된 경고 코드: " + (result.added===null ? "비교 불가 (경고 목록 누락)" : result.added.join(", ") || "없음"),
          "최근 관찰되지 않은 경고 코드: " + (result.missing===null ? "비교 불가 (경고 목록 누락)" : result.missing.join(", ") || "없음")];
        if (result.eventCounts) ["BugCheck 기록","종료 신호","저장장치 이벤트"].forEach((s,i) => lines.push(s+": "+result.eventCounts.before[i]+" → "+result.eventCounts.after[i]+" (각 "+result.eventCounts.days+"일 조회)"));
        else lines.push("이벤트 수: 비교 조건 불일치 / 미확인");
        if (result.drives.length) for (const d of result.drives) lines.push(d.drive+" 여유 공간: "+d.before+"GB → "+d.after+"GB (변화 "+d.change+"GB)");
        else lines.push("드라이브 용량 변화: 비교 가능한 관측값 없음");
        if (result.diskComparable) lines.push("저장장치 경고 집계: "+result.disks.before.warning+" → "+result.disks.after.warning);
        else lines.push("저장장치 경고 집계: 수집 상태 또는 장치 수가 달라 비교 불가");
        if (result.signals) {
          const s=result.signals;
          lines.push("Windows 빌드: "+(s.windows ? s.windows.before+" → "+s.windows.after+(s.windows.changed?" (변경 관찰)":" (변경 없음)") : "비교 불가"));
          lines.push("Windows 업데이트 설치 실패 기록: "+(s.updates ? s.updates.before+" → "+s.updates.after+" (각 "+s.updates.days+"일 이동 조회)" : "비교 불가"));
          lines.push("장치 구성 코드 관측: "+(s.devices ? s.devices.before+" → "+s.devices.after+" (장치 고장 확정 아님)" : "비교 불가"));
        } else lines.push("추가 관측값: 로컬 확장 모듈 미사용");
        lines.push("", "검사 한계:", ...result.caution.map(s => "- "+s));
        output.textContent = lines.join("\n");
        if (printButton && printText && root.PcCareHistoryPrint &&
            typeof root.PcCareHistoryPrint.buildHistoryPrint === "function") {
          printText.textContent = root.PcCareHistoryPrint.buildHistoryPrint(result);
          printButton.disabled = false;
        }
      } catch (err) {
        if (requestRevision === selectionRevision) output.textContent = "비교 불가: " + (err instanceof SyntaxError ? "올바른 JSON 파일이 아닙니다." : err.message);
      }
      finally {button.disabled=false;}
    });
    [prev,curr].forEach(input=>input.addEventListener("change",()=>{
      selectionRevision++;
      resetPrint();
      selectedHistory = null; // Explicit manual file selection overrides a prior batch.
      if (historyPrevious && historyCurrent) {historyPrevious.disabled=true; historyCurrent.disabled=true;}
      if (historyStatus) historyStatus.textContent="개별 JSON 선택으로 전환했습니다. 이력 일괄 선택을 다시 사용하려면 파일을 재선택하세요.";
      output.textContent="파일 선택이 변경되어 이전 비교 내용을 지웠습니다.";
    }));
  }
  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded",init);
  else init();
})(typeof globalThis !== "undefined" ? globalThis : this);
