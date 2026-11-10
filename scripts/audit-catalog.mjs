/** Offline owner-only catalog readiness check. Zero network, zero secrets. */
import { readFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { readinessReport, catalogReceipt } from '../commerce/catalog.mjs';
const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const raw = readFileSync(join(root, 'commerce', 'catalog.json'), 'utf8');
const report = {receipt:catalogReceipt(raw), readiness:readinessReport(JSON.parse(raw))};
process.stdout.write(JSON.stringify(report, null, 2) + '\n');
