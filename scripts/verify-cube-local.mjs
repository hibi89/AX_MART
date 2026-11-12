/**
 * Explicit offline-only CUBE engineering acceptance command.
 * Runs original full native tests/build and owner preflight. Never deploys,
 * enables checkout, contacts remote services, or authorizes a sale.
 */
import {spawnSync} from 'node:child_process';
import {createHash} from 'node:crypto';
import {readFileSync,mkdtempSync,lstatSync,realpathSync} from 'node:fs';
import {join,resolve,dirname,isAbsolute} from 'node:path';
import {tmpdir} from 'node:os';
import {fileURLToPath} from 'node:url';

const root=resolve(dirname(fileURLToPath(import.meta.url)),'..');
const hash=data=>createHash('sha256').update(data).digest('hex');
const fail=(reason)=>{throw new Error('CUBE_LOCAL_ACCEPTANCE_HOLD: '+reason);};
function run(args){
  const child=spawnSync(process.execPath,args,{cwd:root,encoding:'utf8',maxBuffer:12*1024*1024,timeout:180_000});
  if(child.stdout)process.stdout.write(child.stdout);
  if(child.stderr)process.stderr.write(child.stderr);
  if(child.error || child.status!==0 || child.signal)fail('native stage failed: '+args[0]+' '+args.slice(1,3).join(' '));
  return child.stdout.trim();
}
function main(args){
  if(args.includes('--help')){
    if(args.length!==1)fail('bad help arguments');
    process.stdout.write('node scripts/verify-cube-local.mjs [--output NEW_ABSOLUTE_DIRECTORY]\n');
    return;
  }
  if(args.length!==0 && !(args.length===2&&args[0]==='--output'))fail('invalid arguments');
  const chosenOutput=args.length===2?args[1]:null;
  if(chosenOutput!==null && (!isAbsolute(chosenOutput)||resolve(chosenOutput)!==chosenOutput))
    fail('output must be absolute');
  const packageInfo=JSON.parse(readFileSync(join(root,'package.json'),'utf8'));
  const command=packageInfo?.scripts?.test;
  if(typeof command!=='string' || !/^node --test (?:tests\/[a-z0-9-]+\.test\.mjs(?: )?)+$/.test(command))
    fail('test command cannot be verified');
  const tests=command.split(' ').slice(2);
  if(!tests.includes('tests/site.test.mjs') || !tests.includes('tests/release-preflight.test.mjs') ||
     !tests.includes('tests/release-preflight-write-race.test.mjs'))fail('mandatory original suites absent');
  for(const path of tests){const full=join(root,path),st=lstatSync(full);if(!st.isFile()||st.isSymbolicLink())fail('linked test file');}
  const dist=join(root,'dist');
  // A legitimate production build creates dist. Never allow a linked output folder.
  try{const st=lstatSync(dist), actual=realpathSync(dist);
    const eq=process.platform==='win32'?actual.toLowerCase()===dist.toLowerCase():actual===dist;
    if(!st.isDirectory()||st.isSymbolicLink()||!eq)fail('unsafe dist path');}
  catch(err){if(err.code!=='ENOENT')throw err;}
  run(['--test',...tests]);
  run(['scripts/build.mjs']);
  const output=chosenOutput??join(mkdtempSync(join(tmpdir(),'axmart-cube-audit-')),'owner-review');
  const reviewBuild=JSON.parse(run(['scripts/release-preflight.mjs','build','--root',root,'--output',output]));
  const reviewVerify=JSON.parse(run(['scripts/release-preflight.mjs','verify','--root',root,'--output',output]));
  if(reviewBuild.decision!=='HOLD'||reviewBuild.payment_enabled!==false||reviewBuild.download_enabled!==false||
     reviewBuild.production_published!==false||reviewVerify.decision!=='HOLD'||reviewVerify.verified!==true)
    fail('unexpected release or payment flag');
  const manifest=readFileSync(join(output,'manifest.json'));
  const obj=JSON.parse(manifest.toString('utf8'));
  if(obj.signature!=='NONE'||obj.decision!=='HOLD')fail('non-HOLD receipt');
  process.stdout.write(JSON.stringify({schema:'axmart.local.acceptance.v1',
    technical_local_tests:'PASS',release_decision:'HOLD',sales_go:false,
    browser_windows_customer_legal_verified:false,manifest_sha256:hash(manifest),
    local_review_output:output})+'\n');
}
try{main(process.argv.slice(2));}catch(error){
  process.stderr.write('CUBE_LOCAL_ACCEPTANCE_HOLD: '+String(error?.message||error)+'\n');
  process.exitCode=2;
}
