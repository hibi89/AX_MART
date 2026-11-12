/**
 * AXMART³ owner-only preflight on a frozen local static build.
 * No checkout, permission changes, server, customer data, or network.
 * Never turns a release HOLD into an authorization.
 */
import { createHash } from 'node:crypto';
import { closeSync, fstatSync, lstatSync, openSync, readSync, mkdirSync, writeFileSync, readdirSync } from 'node:fs';
import { constants } from 'node:fs';
import { resolve, join, dirname, sep } from 'node:path';
import { renderCatalogPage } from './catalog-page.mjs';
import { renderSupportPage } from './support-page.mjs';

const MAX = Object.freeze({ 'commerce/catalog.json': 262144, 'index.html': 2_000_000,
  'cloudflare/_headers': 65536, 'dist/index.html': 2_000_000, 'dist/_headers': 65536,
  'dist/catalog.json': 262144, 'dist/products/index.html': 262144,
  'dist/support/index.html': 262144 });
const FILES = Object.keys(MAX);
const SHA = /^[a-f0-9]{40}$/;
const ID = /^[a-z][a-z0-9-]{2,63}$/;
const CHECKS = ['windows10','windows11','winre','repair_safety','security','license','customer_support','owner_approval'];
const SCHEMA = 'axmart.owner.preflight.v1';
const hash = bytes => createHash('sha256').update(bytes).digest('hex');
const exact = (v, keys) => v && typeof v === 'object' && !Array.isArray(v) &&
    Object.keys(v).sort().join('|') === [...keys].sort().join('|');
function fail(reason) { throw new TypeError('OWNER_PREFLIGHT_HOLD: ' + reason); }
function safePath(value) {
  if (typeof value !== 'string' || !value || value.length > 2048) fail('invalid path');
  const result = resolve(value);
  for (let p = result;;p=dirname(p)) {
    try { if (lstatSync(p).isSymbolicLink()) fail('linked path'); }
    catch (error) { if (error.code !== 'ENOENT') throw error; }
    if (p === dirname(p)) break;
  }
  return result;
}
function subpath(a,b) { return b === a || b.startsWith(a + sep); }
function readBounded(base, relative) {
  const path = safePath(join(base,relative));
  const before = lstatSync(path, {bigint:true});
  if (!before.isFile() || before.isSymbolicLink() || before.size > BigInt(MAX[relative])) fail('invalid/oversized ' + relative);
  const fd = openSync(path, constants.O_RDONLY | (constants.O_NOFOLLOW || 0));
  try {
    const stat = fstatSync(fd, {bigint:true});
    if (!stat.isFile() || stat.size > BigInt(MAX[relative]) || stat.dev !== before.dev ||
       stat.ino !== before.ino || stat.mtimeNs !== before.mtimeNs) fail('source changed ' + relative);
    const data = Buffer.alloc(Number(stat.size));
    let offset=0;
    while (offset < data.length) { const n=readSync(fd,data,offset,data.length-offset,offset); if(!n)fail('short file');offset+=n; }
    const after=fstatSync(fd,{bigint:true});
    if (after.size!==stat.size || after.mtimeNs!==stat.mtimeNs || after.ctimeNs!==stat.ctimeNs) fail('concurrent source write');
    return data;
  } finally {closeSync(fd);}
}
function strictJson(buffer, path) {
  try { return JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(buffer)); }
  catch { fail('invalid JSON ' + path); }
}
function safeText(value, max) {
  return typeof value==='string' && value.length>0 && value.length<=max &&
    value===value.trim() && !/[\u0000-\u001f\u007f-\u009f\p{Default_Ignorable_Code_Point}<>]/u.test(value);
}
function sourceCatalog(c) {
  if (!exact(c,['schema_version','products']) || c.schema_version!==1 ||
      !Array.isArray(c.products) || c.products.length<1 || c.products.length>20) fail('catalog schema');
  const seen=new Set();
  for(const p of c.products){
    if(!exact(p,['slug','title','description','category','source','stage','checks','delivery','sale']) ||
       typeof p.slug!=='string' || !ID.test(p.slug) || seen.has(p.slug) ||
       !safeText(p.title,80) || !safeText(p.description,300) ||
       typeof p.category!=='string' || !ID.test(p.category) ||
       !exact(p.source,['repository','branch','commit']) || p.source.repository!=='hibi89/AX_MART' ||
       typeof p.source.branch!=='string' || !/^feature\/[a-z0-9][a-z0-9-/]{1,80}$/.test(p.source.branch) ||
       typeof p.source.commit!=='string' || !SHA.test(p.source.commit) ||
       !['development','verification','review'].includes(p.stage) ||
       !exact(p.checks,CHECKS) || CHECKS.some(k=>typeof p.checks[k]!=='boolean') ||
       !exact(p.sale,['mode','price_minor','currency']) || p.sale.mode!=='disabled' ||
       p.sale.price_minor!==null || p.sale.currency!==null ||
       !exact(p.delivery,['mode','path','sha256']) || p.delivery.mode!=='disabled' ||
       p.delivery.path!==null || p.delivery.sha256!==null) fail('non-HOLD catalog product');
    seen.add(p.slug);
  }
  return c.products;
}
function publicProjection(product) {
  const labels={development:'개발 중 · 실제 기기 미검증',verification:'검증 진행 중 · 제공 준비 안 됨',review:'출시 검토 중 · 판매 및 다운로드 불가'};
  return {id:product.slug,title:product.title,description:product.description,
    category:product.category,status:'NOT_AVAILABLE',status_label:labels[product.stage],
    price:null,purchase_url:null,download_url:null};
}
function staticPage(buffer, what) {
  const s=buffer.toString('utf8');
  if (!/^\s*<!doctype html>/i.test(s) || !s.includes("script-src 'none'") ||
      !s.includes("form-action 'none'") || !s.includes("connect-src 'none'") ||
      /<script\b|<form\b|https?:\/\//i.test(s)) fail('unsafe ' + what);
  return s;
}
export function evaluatePreflight(root) {
  root=safePath(root);
  if(!lstatSync(root).isDirectory())fail('root is not directory');
  const bytes=Object.fromEntries(FILES.map(path=>[path,readBounded(root,path)]));
  // Cloudflare Pages publishes every file under dist, not only the assets
  // named in the review receipt. Refuse stale/unlisted assets and directories.
  const expectedDist=[
    ['dist',{_headers:'file','catalog.json':'file','index.html':'file',products:'directory',support:'directory'}],
    ['dist/products',{'index.html':'file'}],
    ['dist/support',{'index.html':'file'}],
  ];
  for (const [relative,allow] of expectedDist) {
    const entries=readdirSync(safePath(join(root,relative)),{withFileTypes:true});
    if (entries.length!==Object.keys(allow).length ||
        entries.some(e=>!Object.hasOwn(allow,e.name) ||
          (allow[e.name]==='file' ? !e.isFile() : !e.isDirectory())))
      fail('unexpected or linked publish asset in '+relative);
  }
  const catalog=strictJson(bytes['commerce/catalog.json'],'catalog');
  const products=sourceCatalog(catalog);
  const publicView=strictJson(bytes['dist/catalog.json'],'public catalog');
  const expected={version:'axmart.catalog.v1',availability:'DEVELOPMENT_ONLY',
    checkout_enabled:false,download_enabled:false,products:products.map(publicProjection)};
  if(JSON.stringify(publicView)!==JSON.stringify(expected))fail('catalog projection drift, checkout/download or source leak');
  if(!bytes['dist/index.html'].equals(bytes['index.html']))fail('homepage build mismatch');
  if(!bytes['dist/_headers'].equals(bytes['cloudflare/_headers']))fail('security header drift');
  const home=bytes['index.html'].toString('utf8');
  if(!home.includes('AXMART³') || !home.includes('판매·다운로드는 아직 지원하지 않습니다') ||
     !home.includes('Windows 실기기 미검증') || products.some(p=>!home.includes(p.title)))fail('missing homepage safety disclosure');
  const productPage=staticPage(bytes['dist/products/index.html'],'products page');
  const supportPage=staticPage(bytes['dist/support/index.html'],'support page');
  // Re-derive static pages from the pinned source catalogue/generators. Merely
  // matching CSP keywords cannot detect a modified (but plausible-looking) page.
  if (!bytes['dist/products/index.html'].equals(Buffer.from(renderCatalogPage(catalog),'utf8')) ||
      !bytes['dist/support/index.html'].equals(Buffer.from(renderSupportPage(),'utf8')))
    fail('generated product/support page byte parity drift');
  if(!productPage.includes('현재 판매 및 다운로드를 제공하지 않습니다') ||
     !supportPage.includes('문의 접수 서비스를 제공하지 않습니다'))fail('public no-sale disclosure missing');
  const missing=products.map(p=>({product_id:p.slug,missing_checks:CHECKS.filter(k=>!p.checks[k])}));
  const report={schema:SCHEMA,decision:'HOLD',owner_release_authorized:false,
    production_published_by_this_tool:false,payment_enabled:false,download_enabled:false,
    live_customer_inquiry_enabled:false,product_count:products.length,
    products:missing,source_sha256:Object.fromEntries(FILES.map(p=>[p,hash(bytes[p])])),
    verification_scope:'local static source-to-dist byte parity, no live browser or production claim',
    outstanding:['owner product and safety approval','actual customer/Windows validation',
      'payment/account/delivery backend and operational policy','legal/license review']};
  return report;
}
const encode = v=> Buffer.from(JSON.stringify(v,null,2)+'\n','utf8');
function htmlReport(report) {
  const rows=report.products.map(p=>`<tr><th>${p.product_id}</th><td>${p.missing_checks.length}</td><td>HOLD</td></tr>`).join('');
  return Buffer.from(`<!doctype html><html lang="ko"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta http-equiv="Content-Security-Policy" content="default-src 'none'; style-src 'unsafe-inline'; script-src 'none'; connect-src 'none'; img-src 'none'; form-action 'none'; base-uri 'none'"><title>AXMART³ 소유자 출시 검수</title><style>body{font:16px/1.6 system-ui,sans-serif;max-width:820px;margin:30px auto;padding:16px;background:#11101f;color:#eef4ff}h1{color:#9ef3d6}table{width:100%;border-collapse:collapse}th,td{text-align:left;padding:12px;border-bottom:1px solid #53446d}.hold{color:#ffbea2;font-weight:700}</style></head><body><h1>AXMART³ 로컬 출시 전 검수</h1><p class="hold">RELEASE HOLD — 결제·계정·다운로드·실고객 문의 접수 비활성</p><p>원본 빌드와 생성 정적 자산의 지역 파일 비교만 확인했습니다. 고객 안전·실행·법률·실제 운영 접속을 검증하거나 출시를 승인하지 않았습니다.</p><table><thead><tr><th>제품</th><th>남은 증거 항목</th><th>결정</th></tr></thead><tbody>${rows}</tbody></table><p>생성된 영수증은 무서명 SHA-256 무결성 확인용이며 공식 안전 인증서가 아닙니다.</p></body></html>\n`,'utf8');
}
function outputBytes(report) {
  const json=encode(report),html=htmlReport(report);
  const manifest=encode({schema:SCHEMA,signature:'NONE',decision:'HOLD',
    outputs_sha256:{'owner-review.json':hash(json),'owner-review.html':hash(html)}});
  return {'owner-review.json':json,'owner-review.html':html,'manifest.json':manifest};
}
export function buildPreflight(root,out) {
  const r=safePath(root),dest=safePath(out);
  if(subpath(r,dest)||subpath(dest,r))fail('output must be separate from source root');
  const report=evaluatePreflight(r),data=outputBytes(report);
  if(dirname(dest)===dest)fail('unsafe output');
  mkdirSync(dest,{recursive:false,mode:0o700});
  try {for(const [name,content] of Object.entries(data))writeFileSync(join(dest,name),content,{flag:'wx',mode:0o600});}
  catch(err){
    // The newly-created output path may have been replaced by another writer.
    // Recursive cleanup can delete that writer's unrelated files. Leave all
    // partial/replaced outputs untouched; owner must use a fresh output path.
    fail('output write failed; partial/replaced directory preserved for manual review');
  }
  return report;
}
export function verifyPreflight(root,out) {
  const r=safePath(root),dest=safePath(out);
  if(subpath(r,dest)||subpath(dest,r))fail('overlapping files');
  const expect=outputBytes(evaluatePreflight(r));
  const actual=readdirSync(dest).sort();
  if(actual.join('|')!==Object.keys(expect).sort().join('|'))fail('unexpected output files');
  for(const [name,content] of Object.entries(expect)){
    const p=safePath(join(dest,name)),st=lstatSync(p,{bigint:true});
    if(!st.isFile() || st.isSymbolicLink() || st.size>BigInt(500_000) ||
       !Buffer.from((()=>{const fd=openSync(p,constants.O_RDONLY|(constants.O_NOFOLLOW||0));try{const b=Buffer.alloc(Number(st.size));let offset=0;while(offset<b.length){let n=readSync(fd,b,offset,b.length-offset,offset);if(!n)fail('truncated receipt');offset+=n;}return b;}finally{closeSync(fd)}})()).equals(content))fail('receipt drift: '+name);
  }
  return true;
}
