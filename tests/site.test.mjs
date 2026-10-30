import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { execFileSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { dirname, resolve, join } from 'node:path';
const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
test('Cloudflare production build preserves AXMART storefront', async () => {
  execFileSync(process.execPath, [join(root,'scripts/build.mjs')], {cwd:root});
  const [src, built, headers] = await Promise.all(['index.html','dist/index.html','dist/_headers'].map(p=>readFile(join(root,p),'utf8')));
  assert.equal(built,src);
  for (const text of ['수상할 정도로', '실제 거래는 아직 지원하지 않습니다', 'id="market-list"', 'id="search-dialog"', 'id="cart-dialog"']) assert.ok(built.includes(text),text);
  assert.match(built,/data:image\/webp;base64/);
  assert.match(headers,/X-Content-Type-Options: nosniff/);
  assert.doesNotMatch(built,/(?:sk_live_|sk_test_|ghp_|CF_API_TOKEN\s*=)/);
});
