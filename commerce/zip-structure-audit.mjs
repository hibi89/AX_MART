/** Offline bounded ZIP structure + content audit; not a malware or release approval. */
import {readFileSync, lstatSync} from 'node:fs';
import {createHash} from 'node:crypto';
import {inflateRawSync} from 'node:zlib';
export const ZIP_INSPECT_VERSION='axmart.zip.deep.v1';
const MAX_ZIP=16*1024*1024,MAX_OUT=24*1024*1024,MAX_FILE=8*1024*1024,MAX_ENTRIES=300;
const isFile=v=>typeof v==='string'&&v.length<=1024&&v.length>0;
function reject(reason){throw new TypeError('ZIP candidate rejected: '+reason)}
const table=Array.from({length:256},(_,i)=>{let c=i;for(let b=0;b<8;b++)c=(c&1)?0xedb88320^(c>>>1):c>>>1;return c>>>0});
export function crc32(buf){let c=0xffffffff;for(const b of buf)c=table[(c^b)&255]^(c>>>8);return (c^0xffffffff)>>>0;}
export function inspectZipBytes(bytes){
 if(!Buffer.isBuffer(bytes)||bytes.length<22||bytes.length>MAX_ZIP)reject('file size');
 const b=bytes,len=b.length,rd16=i=>b.readUInt16LE(i),rd32=i=>b.readUInt32LE(i);
 let eocd=-1;
 for(let i=len-22;i>=Math.max(0,len-22-65535);i--){if(rd32(i)===0x06054b50&&i+22+rd16(i+20)===len){eocd=i;break;}}
 if(eocd<0)reject('missing or trailing EOCD');
 const entries=rd16(eocd+10),dirSize=rd32(eocd+12),dirStart=rd32(eocd+16);
 if(rd16(eocd+4)!==0||rd16(eocd+6)!==0||rd16(eocd+8)!==entries||
    entries<1||entries>MAX_ENTRIES||dirStart===0xffffffff||dirSize===0xffffffff||
    dirStart+dirSize!==eocd)reject('multi-disk/ZIP64/central layout');
 let i=dirStart,expanded=0,files=0;const seen=new Set(),regions=[];
 for(let n=0;n<entries;n++){
  if(i+46>eocd||rd32(i)!==0x02014b50)reject('central directory');
  const flags=rd16(i+8),method=rd16(i+10),checksum=rd32(i+16),compressed=rd32(i+20),size=rd32(i+24);
  const nameLen=rd16(i+28),extraLen=rd16(i+30),commentLen=rd16(i+32),disk=rd16(i+34);
  const attrs=rd32(i+38),local=rd32(i+42),end=i+46+nameLen+extraLen+commentLen;
  if(end>eocd||!nameLen||nameLen>160||disk!==0||(flags&0x0009)!==0||
     (flags&0x0040)!==0||(flags&0x0800)===0||![0,8].includes(method)||
     compressed>MAX_ZIP||size>MAX_FILE||size===0xffffffff||local===0xffffffff)reject('unsafe ZIP flags/size/encoding');
  const name=b.subarray(i+46,i+46+nameLen).toString('utf8');
  if(!/^[A-Za-z0-9][A-Za-z0-9._/-]{0,159}$/.test(name)||name.includes('..')||name.includes('//')||
     name.split('/').some(part=>part==='.'||part==='..')||seen.has(name)||name.startsWith('/')||name.endsWith('.'))reject('unsafe filename');
  seen.add(name);
  const kind=(attrs>>>16)&0o170000;
  if(kind!==0&&kind!==0o100000&&kind!==0o040000)reject('symlink or special entry');
  const folder=name.endsWith('/');if(folder&&size!==0)reject('directory with content');
  if(local+30>dirStart||rd32(local)!==0x04034b50)reject('missing local header');
  const localFlags=rd16(local+6),localMethod=rd16(local+8),localNameLen=rd16(local+26),localExtra=rd16(local+28);
  const dataStart=local+30+localNameLen+localExtra,dataEnd=dataStart+compressed;
  if(localFlags!==flags||localMethod!==method||rd32(local+14)!==checksum||
     rd32(local+18)!==compressed||rd32(local+22)!==size||localNameLen!==nameLen||
     dataEnd>dirStart||!b.subarray(local+30,local+30+nameLen).equals(b.subarray(i+46,i+46+nameLen)))reject('local header mismatch');
  if(method===0&&compressed!==size)reject('stored size mismatch');
  regions.push([local,dataEnd]);
  let body;
  try{body=method===0?b.subarray(dataStart,dataEnd):inflateRawSync(b.subarray(dataStart,dataEnd),{maxOutputLength:Math.min(MAX_FILE+1,MAX_OUT-expanded+1)});}
  catch{reject('inflate failed or output cap')}
  if(body.length!==size||crc32(body)!==checksum)reject('payload CRC/size mismatch');
  expanded+=size;if(expanded>MAX_OUT)reject('expanded archive too large');
  if(!folder)files++;i=end;
 }
 if(i!==eocd)reject('central size mismatch');
 regions.sort((a,b)=>a[0]-b[0]);for(let j=1;j<regions.length;j++)if(regions[j][0]<regions[j-1][1])reject('overlap');
 return {version:ZIP_INSPECT_VERSION,status:'STRUCTURAL_ONLY_PASS',entries,files,
   expanded_bytes:expanded,archive_sha256:createHash('sha256').update(b).digest('hex'),
   malware_verified:false,windows_verified:false,license_verified:false,
   release_allowed:false,payment_enabled:false,download_enabled:false};
}
export function inspectLocalZip(path){
 if(!isFile(path))reject('path');const s=lstatSync(path,{bigint:true});
 if(!s.isFile()||s.isSymbolicLink()||s.size>BigInt(MAX_ZIP))reject('not a bounded regular file');
 const bytes=readFileSync(path);const end=lstatSync(path,{bigint:true});
 if(s.dev!==end.dev||s.ino!==end.ino||s.size!==end.size||s.mtimeNs!==end.mtimeNs||s.ctimeNs!==end.ctimeNs)reject('file changed');
 return inspectZipBytes(bytes);
}
