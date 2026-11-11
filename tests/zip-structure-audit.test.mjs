import test from 'node:test';import assert from 'node:assert/strict';import {mkdtempSync,writeFileSync,rmSync} from 'node:fs';import {join} from 'node:path';import {tmpdir} from 'node:os';import {deflateRawSync} from 'node:zlib';
import {inspectZipBytes,inspectLocalZip,crc32} from '../commerce/zip-structure-audit.mjs';
function zip(name='safe/file.txt',content='hello',method=0){
 const payload=Buffer.from(content);const compressed=method===8?deflateRawSync(payload):payload;
 const n=Buffer.from(name);let local=Buffer.alloc(30),central=Buffer.alloc(46),end=Buffer.alloc(22);
 local.writeUInt32LE(0x04034b50,0);local.writeUInt16LE(20,4);local.writeUInt16LE(0x0800,6);local.writeUInt16LE(method,8);local.writeUInt32LE(crc32(payload),14);local.writeUInt32LE(compressed.length,18);local.writeUInt32LE(payload.length,22);local.writeUInt16LE(n.length,26);
 central.writeUInt32LE(0x02014b50,0);central.writeUInt16LE(20,4);central.writeUInt16LE(20,6);central.writeUInt16LE(0x0800,8);central.writeUInt16LE(method,10);central.writeUInt32LE(crc32(payload),16);central.writeUInt32LE(compressed.length,20);central.writeUInt32LE(payload.length,24);central.writeUInt16LE(n.length,28);central.writeUInt32LE((0o100644<<16)>>>0,38);
 let dir=Buffer.concat([central,n]),l=Buffer.concat([local,n,compressed]);end.writeUInt32LE(0x06054b50,0);end.writeUInt16LE(1,8);end.writeUInt16LE(1,10);end.writeUInt32LE(dir.length,12);end.writeUInt32LE(l.length,16);return Buffer.concat([l,dir,end]);
}
test('actual stored ZIP validates bytes and blocks all release actions',()=>{const r=inspectZipBytes(zip());assert.equal(r.entries,1);assert.equal(r.files,1);assert.equal(r.release_allowed,false);assert.equal(r.download_enabled,false)});
test('real deflate ZIP validates decompression CRC',()=>{const r=inspectZipBytes(zip('data.csv','x'.repeat(1000),8));assert.equal(r.expanded_bytes,1000)});
test('forged zip magic without central records rejected',()=>assert.throws(()=>inspectZipBytes(Buffer.from('504b03040a', 'hex')),TypeError));
test('zip slip and ambiguous paths rejected',()=>{for(const path of ['../evil.txt','folder/../evil.txt','folder\\evil.txt','./evil.txt','C:/evil.txt'])assert.throws(()=>inspectZipBytes(zip(path)),TypeError)});
test('corrupted payload and forged crc rejected',()=>{const b=zip();b[35]^=0x10;assert.throws(()=>inspectZipBytes(b),TypeError)});
test('encrypted/descriptor flags rejected',()=>{const b=zip();b.writeUInt16LE(0x0801,6);assert.throws(()=>inspectZipBytes(b),TypeError)});
test('out of bounds claimed size rejected',()=>{const b=zip();const central=b.indexOf(Buffer.from('504b0102','hex'));b.writeUInt32LE(0x7fffffff,central+24);assert.throws(()=>inspectZipBytes(b),TypeError)});
test('local regular disk file audit is read-only and unchanged',()=>{const dir=mkdtempSync(join(tmpdir(),'cube-zip-'));try{const p=join(dir,'candidate.zip'),b=zip();writeFileSync(p,b);const r=inspectLocalZip(p);assert.equal(r.status,'STRUCTURAL_ONLY_PASS');assert.equal(inspectLocalZip(p).archive_sha256,r.archive_sha256);}finally{rmSync(dir,{recursive:true,force:true})}});
