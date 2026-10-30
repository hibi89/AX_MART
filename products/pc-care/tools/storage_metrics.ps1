# Pure Windows PowerShell 5.1 storage telemetry bounds. No OS reads or writes.
# Wear is a device-reported percentage of wear, NOT remaining SSD life.
function ConvertTo-PcCareStorageMetrics {
    [CmdletBinding()]
    param([object]$Counter)
    $result = [ordered]@{
        reliabilityStatus = 'unavailable'
        wearPercent = $null
        temperatureC = $null
    }
    if ($null -eq $Counter) { return [pscustomobject]$result }
    $result.reliabilityStatus = 'collected'
    # Untrusted storage drivers may return 255/65535 sentinel values or strings.
    # Zero readings can mean an unsupported device; preserve unknown rather than a fake 0%.
    try {
        if ($null -ne $Counter.Wear) {
            $v = [double]$Counter.Wear
            if (-not [double]::IsNaN($v) -and -not [double]::IsInfinity($v) -and
                $v -gt 0 -and $v -le 100 -and $v -eq [math]::Truncate($v)) {
                $result.wearPercent = [int]$v
            }
        }
    } catch {}
    try {
        if ($null -ne $Counter.Temperature) {
            $v = [double]$Counter.Temperature
            if (-not [double]::IsNaN($v) -and -not [double]::IsInfinity($v) -and
                $v -ge -20 -and $v -le 125 -and $v -eq [math]::Truncate($v) -and $v -ne 0) {
                $result.temperatureC = [int]$v
            }
        }
    } catch {}
    return [pscustomobject]$result
}
