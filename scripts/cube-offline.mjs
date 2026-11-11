/** Explicit local-only owner CLI; no network, accounts, writes, or purchase. */
import {readFileSync,lstatSync} from 'node:fs';
import {join,resolve,dirname} from 'node:path';
import {fileURLToPath} from 'node:url';
import {createHash} from 'node:crypto';
import {createDryRunIntent} from '../commerce/transaction-policy.mjs';
import {createSupportCase} from '../commerce/support-queue.mjs';
import {inspectLocalZip} from '../commerce/zip-structure-audit.mjs';
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
function bounded(path){
 if(typeof path!=='string'||path.length>1024)throw new TypeError('invalid file');
 const st=lstatSync(path);if(!st.isFile()||st.isSymbolicLink()||st.size>4096)throw new TypeError('invalid file');
 return readFileSync(path,'utf8');
}
function main(args){
 if(args.length!==3||args[1]!=='--input'||!['intent','support','zip'].includes(args[0]))throw new TypeError('invalid arguments');
 const [mode,,path]=args;
 if(mode==='zip')return inspectLocalZip(path);
 const raw=readFileSync(join(root,'commerce','catalog.json'),'utf8');
 const catalog=JSON.parse(raw),request=JSON.parse(bounded(path));
 const hash=createHash('sha256').update(raw,'utf8').digest('hex');
 if(request.source_sha256!==hash||!catalog.products.some(p=>p.slug===request.product_id))throw new TypeError('unverified catalog source');
 return mode==='intent'?createDryRunIntent(request,catalog):createSupportCase(request);
}
try{const out=main(process.argv.slice(2));process.stdout.write(JSON.stringify(out)+'\n');}
catch{process.stderr.write('LOCAL_REVIEW_HOLD: invalid or unauthorized input\n');process.exitCode=2;}
