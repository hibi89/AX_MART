# AXMART PC CARE - explicit local preview of QR-compatible SHARE TEXT.
# Does not create a QR bitmap, upload data, or copy anything without user action.
function ConvertTo-PcCareSharePreviewHtml {
    [CmdletBinding()]
    param([Parameter(Mandatory=$true)][object]$Share, [bool]$QrSupported = $false)
    function Encode-PcCareShare([object]$Value) {
        return [System.Net.WebUtility]::HtmlEncode([string]$Value)
    }
    $safeCount = [int]$Share.byteCount
    $maxBytes = [int]$Share.maxUtf8Bytes
    if ($Share.status -ne 'ready' -or $safeCount -gt $maxBytes -or $null -eq $Share.payloadText) {
        return ('<section class="share-panel" id="share-preview"><h2>공유 텍스트 준비 불가</h2><p>허용된 UTF-8 바이트 제한을 넘었거나 검증하지 못했습니다. 정보를 임의로 잘라내지 않습니다.</p></section>')
    }
    $safeText = Encode-PcCareShare $Share.payloadText
    $byteLabel = Encode-PcCareShare ('{0}/{1} UTF-8 bytes' -f $safeCount,$maxBytes)
    $disclosure = Encode-PcCareShare $Share.disclosure
    $qrControls = ''
    if ($QrSupported) {
        $qrControls = @'
<button type="button" class="share-select qr-generate" id="pc-care-generate-qr">오프라인 QR 이미지 만들기 (선택)</button>
<p class="small" id="pc-care-qr-status" role="status" aria-live="polite">QR 이미지는 아직 생성되지 않았습니다.</p>
<div class="qr-holder" id="pc-care-qr-canvas" role="img" aria-label="명시 요청 후 생성되는 공유 텍스트 QR 이미지"></div>
'@
    } else {
        $qrControls = '<p class="small">QR 이미지 생성 구성 요소가 없어 텍스트만 표시합니다.</p>'
    }
    $html = @"
<section class="share-panel" id="share-panel" aria-label="오프라인 공유 텍스트">
<h2>오프라인 공유 텍스트 (QR용)</h2>
<p class="small">고장 종류와 기록 시각을 최소화한 텍스트입니다. QR 이미지 생성은 선택 사항이며 클릭하기 전에는 만들어지지 않습니다. 이미지와 공유 텍스트는 인터넷으로 전송되지 않습니다.</p>
<details class="share-disclosure">
<summary>공유 내용을 직접 확인하고 선택하기</summary>
<p class="small">$disclosure</p>
<label class="small" for="pc-care-share-text">공유 가능 텍스트 · $byteLabel · 원인 미확정</label>
<textarea id="pc-care-share-text" rows="8" readonly spellcheck="false" aria-label="직접 선택해 복사할 공유 문구">$safeText</textarea>
<button type="button" class="share-select" onclick="document.getElementById('pc-care-share-text').select()">전체 선택 (이후 Ctrl+C)</button>
$qrControls
<p class="small">사용자가 선택해 복사하기 전에는 전송하지 않습니다. 촬영·복사 후 제3자에게 공개될 수 있습니다.</p>
</details>
</section>
"@
    return $html
}
