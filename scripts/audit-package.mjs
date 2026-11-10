/** Read-only local ZIP candidate integrity check; no release action. */
import {readFileSync} from 'node:fs';
import {dirname,resolve,join} from 'node:path';
import {fileURLToPath} from 'node:url';
import {auditCandidateArtifact} from '../commerce/package-audit.mjs';
const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
function main(args=process.argv.slice(2)){
 try{
  if(args.length!==2||args[0]!=='--manifest'||typeof args[1]!=='string'||
    !args[1]||args[1].startsWith('-')||args[1].length>1024||/[\u0000-\u001f\u007f]/.test(args[1])){
    throw new TypeError('Invalid input');
  }
  const catalog=JSON.parse(readFileSync(join(root,'commerce/catalog.json'),'utf8'));
  const body=readFileSync(args[1]);
  if(body.length>8192)throw new TypeError('Manifest too long');
  const contract=JSON.parse(new TextDecoder('utf-8',{fatal:true}).decode(body));
  const receipt=auditCandidateArtifact(contract,catalog,args[1]);
  process.stdout.write(JSON.stringify(receipt)+'\n');
  return receipt.status==='CANDIDATE_HASH_MATCH'?0:2;
 }catch(_error){
  process.stderr.write('{"status":"ERROR","code":"INVALID_LOCAL_PACKAGE_INPUT"}\n');
  return 1;
 }
}
process.exitCode=main();
