# AXMART PC CARE - read-only PnP configuration error normalization.
# Pure Windows PowerShell 5.1 helper: no device names, IDs, serials or raw CIM records.
# ConfigManagerErrorCode is a device status signal, not a proof of faulty driver.
function ConvertTo-PcCarePnPSummary {
    [CmdletBinding()]
    param(
        [object[]]$Devices = @(),
        [ValidateSet('collected','no matching devices','truncated','unavailable')]
        [string]$QueryStatus = 'unavailable',
        [int]$MaxSamples = 30
    )
    if ($MaxSamples -lt 1 -or $MaxSamples -gt 100) { throw 'MaxSamples must be 1..100' }
    if ($QueryStatus -in @('unavailable','no matching devices')) {
        # A no-match result is not a license to reinterpret leftover raw samples.
        # Only a successful collected/truncated query may yield observations.
        $note = if ($QueryStatus -eq 'unavailable') {
            '장치 관리 인터페이스를 조회하지 못했습니다. 장치 문제가 없다는 뜻이 아닙니다.'
        } else {
            '현재 조회 범위에서 비정상 구성 코드를 발견하지 못했습니다. 전체 장치 정상 보증이 아닙니다.'
        }
        return [pscustomobject]@{
            status=$QueryStatus
            observedCount=$(if ($QueryStatus -eq 'unavailable') { $null } else { 0 })
            samples=@()
            note=$note
        }
    }
    $valid = New-Object 'System.Collections.Generic.List[object]'
    foreach ($d in @($Devices)) {
        if ($null -eq $d) { continue }
        try {
            $rawCode = $d.ConfigManagerErrorCode
            if ($null -eq $rawCode) { continue }
            $codeText = [Convert]::ToString($rawCode, [Globalization.CultureInfo]::InvariantCulture)
            if ($codeText -notmatch '^\d{1,10}$') { continue }
            $code = [int]::Parse($codeText, [Globalization.NumberStyles]::None,
                [Globalization.CultureInfo]::InvariantCulture)
        } catch { continue }
        if ($code -lt 1 -or $code -gt 55) { continue }
        # PnPClass is an optional CATEGORY; whitelist it to avoid serial/device strings.
        $category = 'other'
        try {
            $raw = [string]$d.PNPClass
            if ($raw -in @('Display','Net','MEDIA','USB','System','DiskDrive','HDC','Bluetooth','Keyboard','Mouse','Monitor','Battery')) {
                $category = $raw
            }
        } catch {}
        $interpretation = if ($code -eq 22) { 'device_disabled' }
                          elseif ($code -eq 28) { 'driver_not_installed_record' }
                          elseif ($code -eq 10) { 'device_cannot_start_record' }
                          else { 'device_configuration_issue_record' }
        [void]$valid.Add([pscustomobject]@{
            configurationCode = $code
            category = $category
            interpretation = $interpretation
            rootCauseConfirmed = $false
        })
    }
    $samples = @($valid.ToArray() | Select-Object -First $MaxSamples)
    $state = if ($QueryStatus -eq 'truncated' -or $valid.Count -ge $MaxSamples) { 'truncated' }
             elseif ($valid.Count -eq 0) { 'no matching devices' }
             else { 'collected' }
    [pscustomobject]@{
        status = $state
        observedCount = [int]$valid.Count
        samples = @($samples)
        note = 'Windows 장치 구성 코드 관측치입니다. 비활성화(22)는 의도적일 수 있고 코드만으로 드라이버나 하드웨어 원인을 확정하지 않습니다.'
    }
}
