import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {dirname,join} from 'node:path';
import {fileURLToPath} from 'node:url';
import {renderCatalogPage} from '../commerce/catalog-page.mjs';
const root=join(dirname(fileURLToPath(import.meta.url)),'..');
const source=JSON.parse(readFileSync(join(root,'commerce/catalog.json'),'utf8'));
const clone=()=>structuredClone(source);
test('customer-facing catalog page shows only actual source product and HOLD status',()=>{
 const html=renderCatalogPage(source);
 assert.match(html,/<html lang="ko">/);
 assert.match(html,/AXMART PC CARE/);
 assert.match(html,/Windows 실기기 미검증/);
 assert.match(html,/판매 및 다운로드를 제공하지 않습니다/);
 assert.doesNotMatch(html,/₩[0-9]/);
});
test('output includes accessible semantic HTML and home navigation',()=>{
 const html=renderCatalogPage(source);
 for(const text of ['<main>','<header>','<h1>','<article','aria-label="상품 목록"','<footer>','href="/"','name="viewport"'])
  assert.equal(html.includes(text),true,text);
});
test('no external scripts, images, CDN, forms, or network connections',()=>{
 const html=renderCatalogPage(source);
 assert.doesNotMatch(html,/<script\b|<img\b|<form\b|https?:\/\//i);
 assert.match(html,/script-src 'none'/);
 assert.match(html,/connect-src 'none'/);
 assert.match(html,/form-action 'none'/);
});
test('homepage source and private source ref never appear in generated page',()=>{
 const html=renderCatalogPage(source);
 for(const token of ['hibi89/AX_MART','feature/pc-care-usb','b8706e0a77ec245acc7bc0672f121364c851f910','owner_approval'])
  assert.equal(html.includes(token),false,token);
});
test('unsafe purchase and download URLs cannot reach the renderer',()=>{
 const bad=clone();bad.products[0].delivery.path='/downloads/app.zip';
 assert.throws(()=>renderCatalogPage(bad),TypeError);
 const bad2=clone();bad2.products[0].sale.price_minor=500000;
 assert.throws(()=>renderCatalogPage(bad2),TypeError);
});
test('untrusted HTML markup and script content are rejected',()=>{
 const bad=clone();bad.products[0].title='<svg onload=alert(1)>';
 assert.throws(()=>renderCatalogPage(bad),TypeError);
});
test('unapproved release stage cannot be published through a product page',()=>{
 const bad=clone();bad.products[0].stage='released';
 assert.throws(()=>renderCatalogPage(bad),TypeError);
});
test('all evidence toggles true cannot enable purchase or downloads',()=>{
 const changed=clone();for(const k of Object.keys(changed.products[0].checks))changed.products[0].checks[k]=true;
 const html=renderCatalogPage(changed);
 assert.match(html,/구매·다운로드·계정 등록을 제공하지 않습니다/);
 assert.doesNotMatch(html,/href=".*\.(exe|zip)"/);
});
test('no runtime or actual customer information are required to render',()=>{
 const html=renderCatalogPage(source);
 assert.equal(typeof html,'string');
 assert.doesNotMatch(html,/PRIVATE_CLIENT|customer_email|card_number|api[_-]?key/i);
});
test('stable deterministic page; original product object remains untouched',()=>{
 const previous=JSON.stringify(source);
 const first=renderCatalogPage(source), second=renderCatalogPage(source);
 assert.equal(first,second);
 assert.equal(JSON.stringify(source),previous);
});
