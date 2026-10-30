"""Optional OFFLINE browser/QR round-trip QA; not part of the consumer ZIP.

Requirements on developer machine: Python, playwright, cv2, Chromium.
Usage: python tests/qr_browser_smoke.py --chromium /path/to/chromium
No network, user reports, raw logs, QR cloud APIs, or external sites.
"""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path
from tempfile import TemporaryDirectory

ROOT = Path(__file__).resolve().parents[1]
SAMPLE = (
    "AXMART PC CARE\n"
    "상태:주의 필요\n"
    "신호:저장장치,업데이트실패 외 2종\n"
    "기록UTC:2026-10-30 03:10\n"
    "시각:로그기록/사고시간아님\n"
    "원인:미확정\n"
    "권고:백업후추가점검"
)


def main() -> int:
    parser = argparse.ArgumentParser(description="Private offline QR browser+decoder fixture.")
    parser.add_argument("--chromium", type=str, help="Optional explicit Chromium executable path")
    args = parser.parse_args()
    # These optional test dependencies are never needed by end users.
    import cv2
    from playwright.sync_api import sync_playwright

    qr_vendor = (ROOT / "ui/qrcode.min.js").read_text(encoding="utf-8")
    qr_ui = (ROOT / "ui/qr_ui.js").read_text(encoding="utf-8")
    if "</script" in qr_vendor.lower() or "</script" in qr_ui.lower():
        raise RuntimeError("Unexpected script closing tag in offline QR sources")
    html = (
        '<!doctype html><html lang="ko"><meta charset="utf-8">'
        '<style>body{background:#eee}.qr-holder{display:inline-block;'
        'background:#fff;padding:24px}.qr-holder:empty{display:none}</style>'
        '<textarea id="pc-care-share-text" readonly></textarea>'
        '<button id="pc-care-generate-qr">Generate QR</button>'
        '<div class="qr-holder" id="pc-care-qr-canvas"></div>'
        '<div id="pc-care-qr-status" role="status"></div>'
        '<script>' + qr_vendor + '</script>'
        '<script>' + qr_ui + '</script></html>'
    )
    checks = {}
    external_requests = []
    with sync_playwright() as pw, TemporaryDirectory(prefix="pc-care-offline-qr-") as temp:
        kw = dict(headless=True)
        if args.chromium:
            kw["executable_path"] = args.chromium
        browser = pw.chromium.launch(**kw)
        try:
            page = browser.new_page()
            page.on("request", lambda req: external_requests.append(req.url))
            page.set_content(html, wait_until="load")
            checks["no_qr_before_click"] = page.locator("#pc-care-qr-canvas").inner_text() == ""
            page.locator("#pc-care-share-text").evaluate("(el, value) => { el.value = value; }", SAMPLE)
            page.locator("#pc-care-generate-qr").click()
            page.locator("#pc-care-qr-canvas img, #pc-care-qr-canvas canvas").first.wait_for(state="attached", timeout=5000)
            checks["click_created_qr"] = "만들었습니다" in page.locator("#pc-care-qr-status").inner_text()
            checks["no_external_http_requests"] = not any(
                url.startswith(("http://", "https://")) for url in external_requests
            )
            qr_png = Path(temp) / "qr.png"
            page.locator("#pc-care-qr-canvas").screenshot(path=str(qr_png))
            pixels = cv2.imread(str(qr_png))
            if pixels is None:
                raise RuntimeError("Browser did not render a QR bitmap")
            # Enlarge pixels without anti-aliasing for deterministic scanner checks.
            scaled = cv2.resize(pixels, None, fx=2, fy=2, interpolation=cv2.INTER_NEAREST)
            decoded, _points, _straight = cv2.QRCodeDetector().detectAndDecode(scaled)
            checks["utf8_qr_roundtrip_exact"] = decoded == SAMPLE
            checks["qr_payload_sha256_matches"] = (
                hashlib.sha256(decoded.encode("utf-8")).hexdigest()
                == hashlib.sha256(SAMPLE.encode("utf-8")).hexdigest()
            )
            page.locator("#pc-care-share-text").evaluate(
                "(el) => { el.removeAttribute('readonly'); el.value += '\\nPRIVATE-EXTRA';"
                "el.dispatchEvent(new Event('input', {bubbles:true})); }"
            )
            checks["edit_clears_stale_qr"] = (
                page.locator("#pc-care-qr-canvas").inner_text() == ""
                and page.locator("#pc-care-qr-canvas img").count() == 0
            )
            page.locator("#pc-care-generate-qr").click()
            checks["malformed_regeneration_rejected"] = (
                page.locator("#pc-care-qr-canvas img").count() == 0
                and "차단" in page.locator("#pc-care-qr-status").inner_text()
            )
        finally:
            browser.close()
    print(json.dumps({
        "test_type": "offline local Chromium + OpenCV synthetic QR decode",
        "scope": "No user reports, no smartphone camera, no Windows/PowerShell runtime",
        "checks": checks,
    }, ensure_ascii=False, indent=2))
    return 0 if checks and all(checks.values()) else 1


if __name__ == "__main__":
    raise SystemExit(main())
