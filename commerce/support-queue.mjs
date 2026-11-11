/** Local metadata-only customer-support workflow. No contact fields, notes, network or automatic send. */
import {createHash} from 'node:crypto';
const ID=/^[a-z][a-z0-9-]{2,63}$/;
const SHA=/^[a-f0-9]{64}$/;
const TOPICS=['availability','installation','safety','license','billing'];
const STATES=['NEW','TRIAGED','WAITING_OWNER','CLOSED'];
const exact=(v,k)=>v!==null&&typeof v==='object'&&!Array.isArray(v)&&Object.keys(v).sort().join('|')===[...k].sort().join('|');
function fail(){throw new TypeError('Invalid private support workflow')}
const hash=x=>createHash('sha256').update(JSON.stringify(x),'utf8').digest('hex');
export function createSupportCase(req){
 if(!exact(req,['version','case_id','product_id','topic','owner_consent','source_sha256'])||req.version!==1||
   !ID.test(req.case_id)||!ID.test(req.product_id)||!TOPICS.includes(req.topic)||
   req.owner_consent!==true||typeof req.source_sha256!=='string'||!SHA.test(req.source_sha256))fail();
 const item={schema:'axmart.support.v1',case_id:req.case_id,product_id:req.product_id,
    topic:req.topic,status:'NEW',owner_consent:true,source_sha256:req.source_sha256,
    customer_personal_data_stored:false,public_submission_enabled:false,auto_reply_enabled:false};
 return {...item,receipt_sha256:hash(item)};
}
export function reviewSupportCase(record,change){
 if(!exact(change,['case_id','expected_receipt_sha256','next_state'])||!ID.test(change.case_id)||
     !SHA.test(change.expected_receipt_sha256)||!STATES.includes(change.next_state))fail();
 if(!record||record.case_id!==change.case_id||record.receipt_sha256!==change.expected_receipt_sha256||
    record.customer_personal_data_stored!==false||record.public_submission_enabled!==false||
    record.auto_reply_enabled!==false||record.owner_consent!==true||
    !exact(record,['schema','case_id','product_id','topic','status','owner_consent','source_sha256','customer_personal_data_stored','public_submission_enabled','auto_reply_enabled','receipt_sha256']))fail();
 const {receipt_sha256,...base}=record;
 if(hash(base)!==receipt_sha256)fail();
 const transitions={NEW:['TRIAGED','WAITING_OWNER'],TRIAGED:['WAITING_OWNER','CLOSED'],WAITING_OWNER:['TRIAGED','CLOSED'],CLOSED:[]};
 if(!transitions[record.status]?.includes(change.next_state))fail();
 const next={...base,status:change.next_state};
 return {...next,receipt_sha256:hash(next)};
}
export function summarizeSupportQueue(cases){
 if(!Array.isArray(cases)||cases.length>200)fail();
 const seen=new Set();const by_status=Object.fromEntries(STATES.map(x=>[x,0]));
 for(const c of cases){
   if(!c||!ID.test(c.case_id)||seen.has(c.case_id)||!STATES.includes(c.status)||
      c.customer_personal_data_stored!==false||c.public_submission_enabled!==false||
      c.auto_reply_enabled!==false)fail();
   const {receipt_sha256,...base}=c;
   if(typeof receipt_sha256!=='string'||!SHA.test(receipt_sha256)||hash(base)!==receipt_sha256)fail();
   seen.add(c.case_id);by_status[c.status]++;
 }
 return {schema:'axmart.support.summary.v1',total:cases.length,by_status,external_transmission:false};
}
