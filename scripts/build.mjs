// Dependency-free Cloudflare Pages static build. Never embeds credentials.
import { copyFile, mkdir, readFile, stat } from 'node:fs/promises';
import { fileURLToPath } from 'node:url';
import { dirname, resolve, join } from 'node:path';
const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const html = await readFile(join(root, 'index.html'), 'utf8');
if (!html.toLowerCase().includes('<!doctype html>') || !html.includes('AXMART')) throw new Error('AXMART index.html missing');
if (!html.includes('판매·다운로드는 아직 지원하지 않습니다') || !html.includes('Windows 실기기 미검증')) throw new Error('Prototype disclosure missing');
const out = join(root, 'dist');
await mkdir(out, { recursive: true });
await copyFile(join(root, 'index.html'), join(out, 'index.html'));
await copyFile(join(root, 'cloudflare', '_headers'), join(out, '_headers'));
console.log(`Pages static output: dist/index.html (${(await stat(join(out, 'index.html'))).size} bytes)`);
