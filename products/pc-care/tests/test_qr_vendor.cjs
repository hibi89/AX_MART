"use strict";
/*
 * AXMART PC CARE — actual vendored QR encoding regression (Node built-ins only).
 * Evaluates the bundled MIT qrcodejs inside a sandboxed mock DOM; no browser/network.
 * Verifies generated QR module data, not smartphone / image scanner behavior.
 */
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const test = require("node:test");

const ROOT = path.resolve(__dirname, "..");
const vendor = fs.readFileSync(path.join(ROOT, "ui/qrcode.min.js"), "utf8");
const license = fs.readFileSync(path.join(ROOT, "ui/QR_CODE_LICENSE.txt"), "utf8");
const KoreanPayload = [
  "AXMART PC CARE",
  "상태:주의 필요",
  "신호:저장장치,업데이트실패 외 2종",
  "기록UTC:2026-10-30 03:10",
  "시각:로그기록/사고시간아님",
  "원인:미확정",
  "권고:백업후추가점검"
].join("\n");

function loadVendor() {
  const sandbox = {
    navigator: {userAgent: "Offline fixture, not Android"},
    document: {
      documentElement: {tagName: "html"},
      createElement() { return {style: {}}; }
    }
  };
  vm.runInNewContext(vendor, sandbox, {timeout: 3000, filename: "qrcode.min.js"});
  assert.equal(typeof sandbox.QRCode, "function");
  return sandbox.QRCode;
}

function generate(QRCode, text) {
  // No browser or canvas: vendored QR constructor falls back to a DOM table.
  const host = {
    innerHTML: "",
    childNodes: [{offsetWidth: 256, offsetHeight: 256, style: {}}],
    style: {},
    title: ""
  };
  const code = new QRCode(host, {
    text,
    width: 256,
    height: 256,
    correctLevel: QRCode.CorrectLevel.M
  });
  assert.equal(host.title, text);
  const grid = code._oQRCode;
  assert.ok(grid, "actual vendor encoder must produce QR modules");
  return grid;
}

test("vendored library has MIT notice and targeted per-character byte reset", () => {
  assert.match(license, /MIT License/);
  assert.match(license, /davidshimjs/);
  assert.ok(vendor.includes("for(var b=[],d=0,e=this.data.length;e>d;d++){b=[];var f="));
  assert.equal(vendor.includes("</script"), false);
});

test("actual vendor QR encoder handles mixed Korean and ASCII without overflow", () => {
  const QRCode = loadVendor();
  const qr = generate(QRCode, KoreanPayload);
  assert.ok(qr.getModuleCount() >= 21 && qr.getModuleCount() <= 177);
  assert.ok(qr.isDark(0, 0), "top-left finder pattern must begin dark");
});

test("Unicode byte data has exactly one documented UTF-8 BOM", () => {
  const QRCode = loadVendor();
  const qr = generate(QRCode, KoreanPayload);
  const encoded = qr.dataList[0].parsedData;
  const bytes = Array.from(encoded);
  const expected = Array.from(Buffer.from(KoreanPayload, "utf8"));
  assert.equal(encoded.length, expected.length + 3);
  assert.deepEqual(bytes.slice(0, 3), [0xef, 0xbb, 0xbf]);
  assert.deepEqual(bytes.slice(3), expected);
});

test("mixed Korean-ASCII transitions do not repeat leftover byte suffixes", () => {
  const QRCode = loadVendor();
  for (const value of ["한A", "한A1한B", "테스트2026-10-30", "AXMART 제품 v1"]) {
    const qr = generate(QRCode, value);
    const bytes = Array.from(qr.dataList[0].parsedData);
    assert.deepEqual(bytes.slice(3), Array.from(Buffer.from(value, "utf8")), value);
  }
});

test("plain ASCII content has no UTF-8 BOM", () => {
  const QRCode = loadVendor();
  const text = "AXMART PC CARE ASCII-only 2026-10-30";
  const qr = generate(QRCode, text);
  assert.deepEqual(Array.from(qr.dataList[0].parsedData), Array.from(Buffer.from(text, "utf8")));
});

test("QR matrix contains properly shaped finder patterns", () => {
  const QRCode = loadVendor();
  const qr = generate(QRCode, KoreanPayload);
  const n = qr.getModuleCount();
  for (const [row, col] of [[0, 0], [0, n - 7], [n - 7, 0]]) {
    for (let r = 0; r < 7; r++) for (let c = 0; c < 7; c++) {
      const expected = (r === 0 || r === 6 || c === 0 || c === 6 ||
        (r >= 2 && r <= 4 && c >= 2 && c <= 4));
      assert.equal(qr.isDark(row + r, col + c), expected);
    }
  }
});

test("all 252 allowed status/signal/omission combinations encode exact UTF-8 bytes", () => {
  const QRCode = loadVendor();
  const states = ["위험 신호", "주의 필요", "확인 불완전", "관찰 범위 내 특이사항 없음"];
  const signals = ["저장장치", "공간부족", "블루스크린기록", "비정상종료", "업데이트실패", "장치상태"];
  let checked = 0;
  for (const status of states) {
    for (let left = 0; left < signals.length; left++) {
      for (let right = left; right < signals.length; right++) {
        for (const extraCount of [0, 2, 8]) {
          const signal = left === right ? signals[left] : signals[left] + "," + signals[right];
          const text = [
            "AXMART PC CARE",
            "상태:" + status,
            "신호:" + signal + (extraCount ? " 외 " + extraCount + "종" : ""),
            "기록UTC:2026-10-30 03:10",
            "시각:로그기록/사고시간아님",
            "원인:미확정",
            "권고:백업후추가점검"
          ].join("\n");
          const utf8 = Array.from(Buffer.from(text, "utf8"));
          assert.ok(utf8.length <= 250, "shared text must stay under byte limit");
          const grid = generate(QRCode, text);
          assert.ok(grid.getModuleCount() >= 21 && grid.getModuleCount() <= 177);
          const parsed = Array.from(grid.dataList[0].parsedData);
          assert.deepEqual(parsed.slice(0, 3), [0xef, 0xbb, 0xbf]);
          assert.deepEqual(parsed.slice(3), utf8);
          checked++;
        }
      }
    }
  }
  assert.equal(checked, 252);
});
