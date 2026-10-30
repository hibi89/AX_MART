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
      if (bytes < 1 || bytes > 250 || text.indexOf("AXMART PC CARE\n") !== 0) {
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
