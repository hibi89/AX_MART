// Dependency-free Cloudflare Pages static build. Never embeds credentials.
import { copyFile, mkdir, readFile, stat, writeFile } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { dirname, resolve, join } from 'node:path';
import { publicCatalog, catalogReceipt } from '../commerce/catalog.mjs';
import {renderCatalogPage} from '../commerce/catalog-page.mjs';
const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const html = await readFile(join(root, 'index.html'), 'utf8');
if (!html.toLowerCase().includes('<!doctype html>') || !html.includes('AXMART³')) throw new Error('AXMART index.html missing');
if (!html.includes('판매·다운로드는 아직 지원하지 않습니다') || !html.includes('Windows 실기기 미검증')) throw new Error('Prototype disclosure missing');
const rawCatalog = await readFile(join(root, 'commerce', 'catalog.json'), 'utf8');
const catalog = publicCatalog(JSON.parse(rawCatalog));
const receipt = catalogReceipt(rawCatalog);
if (catalog.products.some(product => !html.includes(product.title))) throw new Error('Homepage differs from approved source catalog');
if (catalog.checkout_enabled !== false || catalog.download_enabled !== false ||
    catalog.products.some(product => product.status !== 'NOT_AVAILABLE' ||
      product.purchase_url !== null || product.download_url !== null || product.price !== null)) {
  throw new Error('Unverified paid or downloadable product blocked');
}
const out = join(root, 'dist');
await mkdir(out, { recursive: true });
await copyFile(join(root, 'index.html'), join(out, 'index.html'));
await copyFile(join(root, 'cloudflare', '_headers'), join(out, '_headers'));
await writeFile(join(out, 'catalog.json'), JSON.stringify(catalog, null, 2) + '\n', 'utf8');
await mkdir(join(out, 'products'), {recursive:true});
await writeFile(join(out, 'products', 'index.html'), renderCatalogPage(JSON.parse(rawCatalog)), 'utf8');
console.log('Pages static output: dist/index.html (' + (await stat(join(out, 'index.html'))).size + ' bytes), catalog ' + catalog.products.length + ', audited ' + receipt.sha256.slice(0, 12));
