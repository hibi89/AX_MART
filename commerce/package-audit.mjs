/** AXMART³ candidate ZIP integrity preflight. Read-only; never approves release. */
import {createHash} from 'node:crypto';
import {constants, openSync, fstatSync, lstatSync, readSync, closeSync} from 'node:fs';
import {dirname, join, basename} from 'node:path';
import {validateCatalog} from './catalog.mjs';

export const PACKAGE_AUDIT_VERSION='axmart.package.preflight.v1';
const MAX_BYTES=32*1024*1024;
const SHA=/^[a-f0-9]{64}$/;
const FILE=/^[a-zA-Z0-9][a-zA-Z0-9_-]{0,99}\.zip$/;
function strict(value, fields) {
  return value!==null && typeof value==='object' && !Array.isArray(value) &&
    Object.keys(value).sort().join('|')===[...fields].sort().join('|');
}
function same(a,b) {
  return a.dev===b.dev&&a.ino===b.ino&&a.size===b.size&&
    a.mtimeNs===b.mtimeNs&&a.ctimeNs===b.ctimeNs;
}
export function auditCandidateArtifact(contract, catalog, manifestPath) {
  const validated=validateCatalog(catalog);
  if(!strict(contract,['version','product_id','source_commit','filename','size_bytes','sha256'])||
     contract.version!==1||typeof contract.product_id!=='string'||
     !FILE.test(contract.filename)||basename(contract.filename)!==contract.filename||
     !Number.isSafeInteger(contract.size_bytes)||contract.size_bytes<4||
     contract.size_bytes>MAX_BYTES||typeof contract.sha256!=='string'||!SHA.test(contract.sha256)||
     typeof manifestPath!=='string'||manifestPath.length>1024) {
    throw new TypeError('Invalid local release-candidate manifest');
  }
  const product=validated.products.find(p=>p.slug===contract.product_id);
  if(!product||product.source.commit!==contract.source_commit||
     product.delivery.mode!=='disabled'||product.sale.mode!=='disabled'){
    throw new TypeError('Candidate does not match approved development source');
  }
  const path=join(dirname(manifestPath),contract.filename);
  const before=lstatSync(path,{bigint:true});
  if(!before.isFile()||before.isSymbolicLink()||before.size>BigInt(MAX_BYTES)){
    throw new TypeError('Candidate must be a bounded regular file');
  }
  const fd=openSync(path,constants.O_RDONLY|(constants.O_NOFOLLOW??0));
  try{
    const start=fstatSync(fd,{bigint:true});
    if(!start.isFile()||!same(before,start))throw new TypeError('Candidate changed during open');
    const hash=createHash('sha256');const buffer=Buffer.alloc(65536);
    const header=[];let read=0;
    while(read<=MAX_BYTES){
      const count=readSync(fd,buffer,0,Math.min(buffer.length,MAX_BYTES+1-read),null);
      if(!count)break;
      hash.update(buffer.subarray(0,count));
      const headerBytes=Math.min(4-header.length,count);
      for(let i=0;i<headerBytes;i++)header.push(buffer[i]);
      read+=count;
    }
    if(read>MAX_BYTES||read!==Number(start.size)||!same(start,fstatSync(fd,{bigint:true}))||
       !same(start,lstatSync(path,{bigint:true}))){
      throw new TypeError('Candidate changed or exceeded limits during read');
    }
    const digest=hash.digest('hex');
    const zipMagic=header.length===4&&header[0]===0x50&&header[1]===0x4b&&
                   header[2]===0x03&&header[3]===0x04;
    const sizeMatch=read===contract.size_bytes;
    const hashMatch=digest===contract.sha256;
    return {
      version:PACKAGE_AUDIT_VERSION,product_id:product.slug,
      status:zipMagic&&sizeMatch&&hashMatch?'CANDIDATE_HASH_MATCH':'REVIEW_HOLD',
      candidate_sha256:digest,expected_sha256:contract.sha256,
      bytes_checked:read,expected_bytes:contract.size_bytes,
      size_match:sizeMatch,sha256_match:hashMatch,zip_signature_only:zipMagic,
      release_allowed:false,owner_approval:'NOT_GRANTED',
      customer_download_enabled:false,payment_enabled:false,
      note:'SHA256/size/ZIP signature are not archive-content, malware, Windows/WinRE, license or customer-safety certification.'
    };
  }finally{closeSync(fd)}
}
