/** Owner-only local release safety preflight. Never publishes, enables sales or contacts a server. */
import {buildPreflight, verifyPreflight} from '../commerce/release-preflight.mjs';
function main(args) {
  if(args.length!==5 || !['build','verify'].includes(args[0]) || args[1]!=='--root' || args[3]!=='--output')
    throw new TypeError('expected: build|verify --root PATH --output NEW_OR_EXISTING_DIR');
  if(args[0]==='build')return buildPreflight(args[2],args[4]);
  verifyPreflight(args[2],args[4]);
  return {decision:'HOLD',verified:true};
}
try {
  const result=main(process.argv.slice(2));
  process.stdout.write(JSON.stringify({version:'axmart.owner.preflight.v1',decision:'HOLD',
    verified:process.argv[2]==='verify',product_count:result.product_count??null,
    production_published:false,payment_enabled:false,download_enabled:false})+'\n');
} catch {
  process.stderr.write('OWNER_PREFLIGHT_HOLD: invalid source, build or receipt\n');
  process.exitCode=2;
}
