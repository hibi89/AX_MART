/** AXMART³ read-only customer-facing product listing from the policy-validated public catalog. */
import {publicCatalog} from './catalog.mjs';
const escapeText = value => String(value).replace(/[&<>"']/g,char=>({
  '&':'&amp;', '<':'&lt;', '>':'&gt;', '"':'&quot;', "'":'&#39;'
})[char]);

export function renderCatalogPage(source) {
  // The validator is the authority; never trust a caller's already-public JSON.
  const data=publicCatalog(source);
  if(data.checkout_enabled!==false || data.download_enabled!==false ||
     data.products.length<1 || data.products.length>20 ||
     data.products.some(item=>item.price!==null || item.purchase_url!==null ||
       item.download_url!==null || item.status!=='NOT_AVAILABLE')){
    throw new TypeError('Unsafe public storefront candidate');
  }
  const cards=data.products.map(item=>
    '<article class="product" aria-label="' + escapeText(item.title) + ' 상태">' +
    '<div class="pill">' + escapeText(item.status_label) + '</div>' +
    '<h2>' + escapeText(item.title) + '</h2>' +
    '<p>' + escapeText(item.description) + '</p>' +
    '<p class="restriction">현재 판매 및 다운로드를 제공하지 않습니다. 기능·안전성 검증 후 별도 안내합니다.</p>' +
    '</article>').join('');
  return '<!doctype html>\n<html lang="ko"><head><meta charset="utf-8">' +
    '<meta name="viewport" content="width=device-width, initial-scale=1">' +
    '<meta name="referrer" content="no-referrer">' +
    '<meta http-equiv="Content-Security-Policy" content="default-src \'none\'; script-src \'none\'; img-src \'none\'; connect-src \'none\'; style-src \'unsafe-inline\'; base-uri \'none\'; form-action \'none\'">' +
    '<title>AXMART³ | 개발 중인 실제 도구</title><style>' +
    ':root{color-scheme:dark;font-family:system-ui,-apple-system,sans-serif}' +
    'body{background:#0e1020;color:#edf2ff;line-height:1.6;margin:0;padding:0}' +
    'main{max-width:1050px;margin:auto;padding:clamp(1.25rem,4vw,3.5rem)}' +
    'a{color:#85ffe0;text-decoration:none}a:focus-visible{outline:3px solid #85ffe0}' +
    '.brand{color:#85ffe0;letter-spacing:.06em;font-weight:800}' +
    '.eyebrow{color:#bcb2ff;text-transform:uppercase;font-size:.85rem}' +
    'h1{font-size:clamp(2rem,5vw,3.5rem);line-height:1.15;margin:.5rem 0 1rem}' +
    '.lead{color:#bfc7d9;max-width:64ch}' +
    '.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(min(100%,300px),1fr));gap:1.25rem;margin:2rem 0}' +
    '.product{background:#1a1b33;border:1px solid #51497e;border-radius:18px;padding:1.5rem}' +
    '.product h2{margin:1rem 0 .5rem}.product p{color:#d2d6e4}' +
    '.pill{display:inline-block;background:#29244b;color:#c3f8e9;padding:.35rem .7rem;border-radius:100px;font-size:.82rem}' +
    '.restriction{font-size:.9rem;border-top:1px solid #51497e;padding-top:1rem}' +
    'footer{border-top:1px solid #51497e;padding:1.5rem 0;color:#aeb6ca;font-size:.9rem}' +
    '</style></head><body><main>' +
    '<nav aria-label="상위 페이지"><a class="brand" href="/">AXMART³</a></nav>' +
    '<header><p class="eyebrow">Source-backed product catalog</p>' +
    '<h1>검증 중인 실제 도구</h1>' +
    '<p class="lead">AXMART³는 실제 개발 소스가 확인된 프로젝트만 소개합니다. 현재 제품은 Windows 실기기 미검증 및 WinRE 안전성 검증 중이며 구매·다운로드·계정 등록을 제공하지 않습니다.</p></header>' +
    '<section aria-label="상품 목록" class="grid">' + cards + '</section>' +
    '<footer>실제 제품 검증과 명시적인 출시 승인 전까지 가격·후기·구매 버튼·다운로드 링크를 표시하지 않습니다. 이 페이지는 자동으로 정보를 수집하거나 전송하지 않습니다.</footer>' +
    '</main></body></html>\n';
}
