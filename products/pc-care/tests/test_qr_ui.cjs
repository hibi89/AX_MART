"use strict";
// Node built-in synthetic tests. Executes ui/qr_ui.js with a fake DOM and fake QR constructor.
// Tests initiation, UTF-8 validation and fallback. Does not claim real browser/phone scanning.
const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");
const test = require("node:test");
const source = fs.readFileSync(path.join(__dirname, "../ui/qr_ui.js"), "utf8");
const valid = "AXMART PC CARE\n상태:주의 필요\n신호:저장장치\n기록UTC:2026-10-30 03:10\n시각:로그기록/사고시간아님\n원인:미확정\n권고:백업후추가점검";

function setup(text = valid, options = {}) {
  const calls = [];
  let click = null;
  let change = null;
  const button = {addEventListener(name, fn) {
    assert.equal(name, "click");
    click = fn;
  }};
  const input = {value: text, addEventListener(name, fn) {
    assert.equal(name, "input");
    change = fn;
  }};
  const target = {textContent: "old result"};
  const state = {textContent: ""};
  const nodes = {
    "pc-care-generate-qr": button,
    "pc-care-share-text": input,
    "pc-care-qr-canvas": target,
    "pc-care-qr-status": state
  };
  function QR(targetNode, data) {
    if (options.throwEncoder) throw new Error("fake render failure");
    calls.push({target: targetNode, data});
  }
  QR.CorrectLevel = {M: 7};
  const env = {
    document: {getElementById(key) {
      return options.missing === key ? null : nodes[key];
    }},
    QRCode: options.noQrLibrary ? undefined : QR,
    TextEncoder: options.noTextEncoder ? undefined : (options.TextEncoder || TextEncoder)
  };
  // No network, timers, clipboard, location, process, or real browser objects are exposed.
  vm.runInNewContext(source, env, {timeout: 1000, filename: "qr_ui.js"});
  return {calls, click: () => {
    if (click !== null) click();
  }, edit: nextText => {
    input.value = nextText;
    if (change !== null) change();
  }, attached: () => click !== null, input, target, state};
}

test("QR is never generated on HTML initialization", () => {
  const ui = setup();
  assert.ok(ui.attached());
  assert.equal(ui.calls.length, 0);
});

test("valid Korean text generates one QR only on deliberate click", () => {
  const ui = setup();
  ui.click();
  assert.equal(ui.calls.length, 1);
  assert.equal(ui.calls[0].target, ui.target);
  assert.equal(ui.calls[0].data.text, valid);
  assert.equal(ui.calls[0].data.correctLevel, 7);
  assert.equal(ui.calls[0].data.width, 256);
  assert.match(ui.state.textContent, /만들었습니다/);
});

test("malformed oversized Korean text is rejected without clipping", () => {
  const ui = setup("AXMART PC CARE\n" + "한".repeat(100));
  ui.click();
  assert.equal(ui.calls.length, 0);
  assert.match(ui.state.textContent, /차단/);
});

test("QR byte budget accepts exactly 250 bytes and rejects 251", () => {
  const encoderAtLimit = class { encode() { return new Uint8Array(250); } };
  const exact = setup(valid, {TextEncoder: encoderAtLimit});
  exact.click();
  assert.equal(exact.calls.length, 1);
  const encoderOverLimit = class { encode() { return new Uint8Array(251); } };
  const over = setup(valid, {TextEncoder: encoderOverLimit});
  over.click();
  assert.equal(over.calls.length, 0);
  assert.match(over.state.textContent, /차단/);
});

test("untrusted prefix cannot create QR", () => {
  const ui = setup("PRIVATE USER\nAXMART PC CARE\n");
  ui.click();
  assert.equal(ui.calls.length, 0);
});

test("empty input cannot create QR", () => {
  const ui = setup("");
  ui.click();
  assert.equal(ui.calls.length, 0);
});

test("missing vendor library falls back without claiming success", () => {
  const ui = setup(valid, {noQrLibrary: true});
  ui.click();
  assert.equal(ui.calls.length, 0);
  assert.match(ui.state.textContent, /지원되지/);
});

test("missing TextEncoder falls back without QR", () => {
  const ui = setup(valid, {noTextEncoder: true});
  ui.click();
  assert.equal(ui.calls.length, 0);
  assert.match(ui.state.textContent, /지원되지/);
});

test("QR constructor error clears old output and gives a safe fallback", () => {
  const ui = setup(valid, {throwEncoder: true});
  ui.click();
  assert.equal(ui.target.textContent, "");
  assert.equal(ui.calls.length, 0);
  assert.match(ui.state.textContent, /실패/);
});

test("editing a generated QR payload clears stale QR immediately", () => {
  const ui = setup();
  ui.click();
  assert.equal(ui.calls.length, 1);
  ui.target.textContent = "PREVIOUS-QR";
  ui.edit("AXMART PC CARE\n상태:주의 필요\n신호:업데이트실패");
  assert.equal(ui.target.textContent, "");
  assert.match(ui.state.textContent, /변경/);
  assert.equal(ui.calls.length, 1);
});

test("invalid regeneration clears a QR created for older text", () => {
  const ui = setup();
  ui.click();
  ui.target.textContent = "PREVIOUS-QR";
  ui.input.value = "PRIVATE-INPUT";
  ui.click();
  assert.equal(ui.target.textContent, "");
  assert.equal(ui.calls.length, 1);
  assert.match(ui.state.textContent, /차단/);
});

test("untrusted extra lines cannot be encoded as a QR", () => {
  const ui = setup(valid + "\nPRIVATE-USERNAME=someone");
  ui.click();
  assert.equal(ui.calls.length, 0);
  assert.match(ui.state.textContent, /차단/);
});

test("arbitrary text inside whitelisted fields is rejected", () => {
  const ui = setup(valid.replace("신호:저장장치", "신호:개인정보"));
  ui.click();
  assert.equal(ui.calls.length, 0);
});

test("missing time-basis warning is rejected", () => {
  const ui = setup(valid.replace("시각:로그기록/사고시간아님", "시각:확정"));
  ui.click();
  assert.equal(ui.calls.length, 0);
});

test("known multi-signal payload and omission marker are accepted", () => {
  const ui = setup(valid.replace("신호:저장장치", "신호:저장장치,업데이트실패 외 2종"));
  ui.click();
  assert.equal(ui.calls.length, 1);
});

test("omission marker matches the maximum allowed signal inventory", () => {
  const maximum = setup(valid.replace("신호:저장장치", "신호:저장장치,업데이트실패 외 4종"));
  maximum.click();
  assert.equal(maximum.calls.length, 1);
  for (const signalLine of [
    "신호:저장장치 외 1종",
    "신호:저장장치,업데이트실패 외 5종",
    "신호:저장장치,업데이트실패 외 999999999999종",
    "신호:저장장치,업데이트실패 외 0종",
  ]) {
    const invalid = setup(valid.replace("신호:저장장치", signalLine));
    invalid.click();
    assert.equal(invalid.calls.length, 0, signalLine);
    assert.match(invalid.state.textContent, /차단/);
  }
});

test("unknown or malformed event UTC time is rejected", () => {
  const ui = setup(valid.replace("기록UTC:2026-10-30 03:10", "기록UTC:<private>"));
  ui.click();
  assert.equal(ui.calls.length, 0);
});

test("impossible February date is blocked before QR generation", () => {
  const ui = setup(valid.replace("기록UTC:2026-10-30 03:10", "기록UTC:2026-02-30 03:10"));
  ui.click();
  assert.equal(ui.calls.length, 0);
  assert.match(ui.state.textContent, /차단/);
});

test("invalid leap day is blocked", () => {
  const ui = setup(valid.replace("기록UTC:2026-10-30 03:10", "기록UTC:2026-02-29 03:10"));
  ui.click();
  assert.equal(ui.calls.length, 0);
});

test("valid leap-day timestamp is accepted", () => {
  const ui = setup(valid.replace("기록UTC:2026-10-30 03:10", "기록UTC:2024-02-29 03:10"));
  ui.click();
  assert.equal(ui.calls.length, 1);
});

test("unknown recorded time remains an explicit accepted fallback", () => {
  const ui = setup(valid.replace("기록UTC:2026-10-30 03:10", "기록UTC:미확인"));
  ui.click();
  assert.equal(ui.calls.length, 1);
});

test("missing DOM nodes leave QR disabled without a page-load exception", () => {
  const ui = setup(valid, {missing: "pc-care-generate-qr"});
  assert.equal(ui.attached(), false);
  assert.equal(ui.calls.length, 0);
});

test("no network or clipboard calls are present in the isolated QR glue", () => {
  for (const blocked of ["fetch(", "XMLHttpRequest", "sendBeacon", "navigator.clipboard", "window.location", "eval(", "Function("]) {
    assert.equal(source.includes(blocked), false, blocked);
  }
});
