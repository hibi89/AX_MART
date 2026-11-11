/** No-script, no-form customer FAQ; no actual ticket intake or checkout. */
export function renderSupportPage(){
 return `<!doctype html>
<html lang="ko"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="referrer" content="no-referrer">
<meta http-equiv="Content-Security-Policy" content="default-src 'none'; script-src 'none'; connect-src 'none'; img-src 'none'; style-src 'unsafe-inline'; form-action 'none'; base-uri 'none'">
<title>AXMART³ | 지원 및 출시 정책</title>
<style>:root{color-scheme:dark;font-family:system-ui}body{margin:0;background:#0e1020;color:#edf2ff;line-height:1.7}main{max-width:770px;margin:0 auto;padding:2rem}h1{color:#a9ffe8}h2{color:#c7b9ff}section{padding:1rem 0;border-top:1px solid #51497e}a{color:#85ffe0}a:focus-visible{outline:2px solid #85ffe0}</style>
</head><body><main><nav><a href="/">AXMART³ 홈</a> · <a href="/products/">개발 상품 보기</a></nav>
<h1>지원·출시 안내</h1><p>현재 AXMART PC CARE는 개발 중입니다. Windows 10/11 실기기 미검증 및 WinRE 안전성 검증 전이며 판매, 결제, 회원 가입, 다운로드 및 문의 접수 서비스를 제공하지 않습니다.</p>
<section><h2>언제 받을 수 있나요?</h2><p>출시 일정을 확정하지 않았습니다. 안전성·라이선스 검증과 별도 소유자 승인이 끝나기 전에는 배포하지 않습니다.</p></section>
<section><h2>데이터는 어디로 전송되나요?</h2><p>이 페이지는 스크립트, 문의 양식, 분석 도구, 외부 네트워크 요청을 포함하지 않습니다. 개인정보나 진단 로그를 업로드하지 마십시오.</p></section>
<section><h2>지금 결제하거나 예약할 수 있나요?</h2><p>아니요. 가격·주문·결제·이용권 발급·파일 전달 기능은 비활성화되어 있습니다.</p></section>
<section><h2>지원 요청은 어떻게 하나요?</h2><p>현재 온라인 문의 접수는 운영하지 않습니다. 공식 채널이 검증되어 공지되기 전에는 개인정보를 제출하지 마십시오.</p></section>
<footer>AXMART³ · 미출시 기술 프리뷰 · 검증 중인 제품 정보만 제공합니다.</footer></main></body></html>\n`;
}
