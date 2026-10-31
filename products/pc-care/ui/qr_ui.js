/*
 * AXMART PC CARE QR UI (original glue code).
 * Fully offline. Never generates on page load, posts data or reads full diagnostic JSON.
 * QR encoding supplied by vendored qrcodejs MIT library; see ui/QR_CODE_LICENSE.txt.
 */
(function () {
  "use strict";
  var button = document.getElementById("pc-care-generate-qr");
  var source = document.getElementById("pc-care-share-text");
  var target = document.getElementById("pc-care-qr-canvas");
  var state = document.getElementById("pc-care-qr-status");
  if (!button || !source || !target || !state) return;
  var encoder = null;
  function hasExpectedShareFields(text) {
    var lines = text.split("\n");
    if (lines.length !== 7 ||
        lines[0] !== "AXMART PC CARE" ||
        lines[4] !== "시각:로그기록/사고시간아님" ||
        lines[5] !== "원인:미확정" ||
        lines[6] !== "권고:백업후추가점검") return false;
    var states = ["위험 신호", "주의 필요", "확인 불완전", "관찰 범위 내 특이사항 없음"];
    if (states.indexOf(lines[1].slice(3)) === -1 || lines[1].slice(0, 3) !== "상태:") return false;
    if (lines[2].slice(0, 3) !== "신호:") return false;
    var signalText = lines[2].slice(3);
    if (signalText !== "미확인") {
      var items = signalText.split(" 외 ");
      if (items.length > 2 || (items.length === 2 && !/^[1-4]종$/.test(items[1]))) return false;
      var signals = items[0].split(",");
      var allowed = ["저장장치", "공간부족", "블루스크린기록", "비정상종료", "업데이트실패", "장치상태"];
      if (signals.length < 1 || signals.length > 2) return false;
      // The payload builder adds an omission marker only after showing two
      // distinct values; six allowed categories therefore cap omissions at four.
      if (items.length === 2 && signals.length !== 2) return false;
      for (var i = 0; i < signals.length; i++) {
        if (allowed.indexOf(signals[i]) === -1 ||
            (i > 0 && signals[i] === signals[i - 1])) return false;
      }
    }
    if (lines[3].slice(0, 6) !== "기록UTC:") return false;
    var time = lines[3].slice(6);
    if (time === "미확인") return true;
    var match = /^(\d{4})-(0[1-9]|1[0-2])-([0-2][0-9]|3[01]) ([01][0-9]|2[0-3]):([0-5][0-9])$/.exec(time);
    if (!match) return false;
    // Reject impossible dates (e.g. Feb 30), not merely malformed timestamp strings.
    var year = Number(match[1]), month = Number(match[2]), day = Number(match[3]);
    if (year < 2000 || year > 9999) return false;
    var d = new Date(Date.UTC(year, month - 1, day, Number(match[4]), Number(match[5])));
    return d.getUTCFullYear() === year && d.getUTCMonth() + 1 === month &&
      d.getUTCDate() === day;
  }
  function clearPreviousQr() {
    target.textContent = "";
    encoder = null;
  }
  // Any edit invalidates the previously generated symbol, so a stale QR cannot be shared.
  source.addEventListener("input", function () {
    clearPreviousQr();
    state.textContent = "공유 문구가 변경되었습니다. 새 QR을 만들려면 내용을 다시 확인하고 버튼을 누르세요.";
  });
  button.addEventListener("click", function () {
    clearPreviousQr();
    try {
      if (typeof QRCode !== "function" || typeof TextEncoder !== "function") {
        state.textContent = "QR 생성이 지원되지 않습니다. 위의 공유 텍스트를 직접 복사하세요.";
        return;
      }
      var text = source.value;
      var bytes = new TextEncoder().encode(text).length;
      if (bytes < 1 || bytes > 250 || !hasExpectedShareFields(text)) {
        state.textContent = "공유 텍스트 길이 또는 형식을 확인할 수 없어 QR 생성을 차단했습니다.";
        return;
      }
      // No network: constructor renders directly inside the current local HTML.
      encoder = new QRCode(target, {
        text: text,
        width: 256,
        height: 256,
        colorDark: "#111111",
        colorLight: "#ffffff",
        correctLevel: QRCode.CorrectLevel.M
      });
      state.textContent = "QR 이미지를 이 기기에서 만들었습니다. 아직 실제 스마트폰 스캔 검증 전이며, 사진을 찍으면 내용이 공유될 수 있습니다.";
    } catch (_err) {
      target.textContent = "";
      encoder = null;
      state.textContent = "QR 생성에 실패했습니다. 공유 텍스트를 직접 복사하세요.";
    }
  });
}());
