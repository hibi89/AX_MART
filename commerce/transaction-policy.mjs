/** Offline purchase-request dry-run. No payment, account, entitlement or file issuance. */
import {createHash} from 'node:crypto';
export const INTENT_VERSION='axmart.intent.v1';
const ID=/^[a-z][a-z0-9-]{2,63}$/;
const HASH=/^[a-f0-9]{64}$/;
const SHA=/^[a-f0-9]{40}$/;
const exact=(v,keys)=>v!==null&&typeof v==='object'&&!Array.isArray(v)&&Object.keys(v).sort().join('|')===[...keys].sort().join('|');
const digest=v=>createHash('sha256').update(JSON.stringify(v),'utf8').digest('hex');
function fail(){throw new TypeError('Invalid offline transaction-intent contract')}
function validateItem(item){
 if(!exact(item,['slug','title','description','category','source','stage','checks','delivery','sale']))fail();
 if(!ID.test(item.slug)||!exact(item.source,['repository','branch','commit'])||item.source.repository!=='hibi89/AX_MART'||!/^feature\/[a-z0-9][a-z0-9-/]{1,80}$/.test(item.source.branch)||!SHA.test(item.source.commit)||
    !['development','verification','review'].includes(item.stage)||
    !exact(item.delivery,['mode','path','sha256'])||item.delivery.mode!=='disabled'||item.delivery.path!==null||item.delivery.sha256!==null||
    !exact(item.sale,['mode','price_minor','currency'])||item.sale.mode!=='disabled'||item.sale.price_minor!==null||item.sale.currency!==null||
    !exact(item.checks,['windows10','windows11','winre','repair_safety','security','license','customer_support','owner_approval'])) fail();
 for(const v of Object.values(item.checks))if(typeof v!=='boolean')fail();
}
/** Strict intentionally offline normalized view of trusted private catalog. */
export function createDryRunIntent(request, catalog) {
 if(!exact(request,['version','request_id','product_id','purpose','source_sha256'])||
    request.version!==1||!ID.test(request.request_id)||!ID.test(request.product_id)||
    !['availability','beta_interest','commercial_interest'].includes(request.purpose)||
    typeof request.source_sha256!=='string'||!HASH.test(request.source_sha256)||
    !catalog||!Array.isArray(catalog.products)||catalog.products.length!==1) fail();
 const selected=catalog.products.find(x=>x.slug===request.product_id);
 if(!selected)fail();validateItem(selected);
 const intent={version:INTENT_VERSION,request_id:request.request_id,product_id:selected.slug,
    purpose:request.purpose,source_commit:selected.source.commit,
    source_sha256:request.source_sha256,decision:'HOLD',
    payment_state:'NOT_CREATED',account_state:'NOT_CREATED',entitlement_state:'NOT_ISSUED',
    download_state:'DISABLED',price_minor:null,currency:null,
    owner_action:'REVIEW_ONLY',blockers:['CUSTOMER_VALIDATION','PAYMENT_BACKEND','ENTITLEMENT_BACKEND','OWNER_RELEASE_APPROVAL']};
 return {...intent,receipt_sha256:digest(intent)};
}
export function verifyDryRunIntent(request,catalog,receipt){
 if(!receipt||typeof receipt!=='object'||Array.isArray(receipt))return false;
 try {const expected=createDryRunIntent(request,catalog);return exact(receipt,Object.keys(expected))&&JSON.stringify(receipt)===JSON.stringify(expected)}
 catch{return false}
}
/** Idempotent append-only simulation, duplicate IDs held rather than reissued. */
export function summarizeDryRuns(receipts){
 if(!Array.isArray(receipts)||receipts.length>200)fail();
 const seen=new Set();let duplicates=0;
 for(const r of receipts){
  if(!exact(r,['version','request_id','product_id','purpose','source_commit','source_sha256','decision','payment_state','account_state','entitlement_state','download_state','price_minor','currency','owner_action','blockers','receipt_sha256'])||
      r.version!==INTENT_VERSION||!ID.test(r.request_id)||!ID.test(r.product_id)||
      r.decision!=='HOLD'||r.payment_state!=='NOT_CREATED'||r.account_state!=='NOT_CREATED'||r.entitlement_state!=='NOT_ISSUED'||
      r.download_state!=='DISABLED'||r.price_minor!==null||r.currency!==null||r.owner_action!=='REVIEW_ONLY'||
      !Array.isArray(r.blockers)||r.blockers.join(',')!=='CUSTOMER_VALIDATION,PAYMENT_BACKEND,ENTITLEMENT_BACKEND,OWNER_RELEASE_APPROVAL'||!HASH.test(r.receipt_sha256))fail();
  const {receipt_sha256,...base}=r;if(digest(base)!==receipt_sha256)fail();
  if(seen.has(r.request_id))duplicates++;seen.add(r.request_id);
 }
 return {version:INTENT_VERSION,distinct_requests:seen.size,duplicate_requests:duplicates,
   payment_enabled:false,download_enabled:false,decision:'HOLD'};
}
