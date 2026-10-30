# AXMART PC CARE - pure, privacy-bounded battery and Windows Update normalization.
# Windows PowerShell 5.1; no OS reads or writes in these functions.

function ConvertTo-PcCareBatterySnapshot {
    [CmdletBinding()]
    param(
        [object[]]$Batteries = @(),
        [ValidateSet('collected','empty','unavailable')]
        [string]$QueryStatus = 'unavailable'
    )
    if ($QueryStatus -eq 'unavailable') {
        return [pscustomobject]@{ status='unavailable'; batteryCount=$null; samples=@(); note='배터리 조회 실패 또는 미지원: 배터리 없음으로 판단하지 않습니다.' }
    }
    $valid = @($Batteries | Where-Object { $null -ne $_ })
    if ($valid.Count -eq 0) {
        return [pscustomobject]@{ status='not_present'; batteryCount=0; samples=@(); note='Windows 배터리 장치가 보고되지 않았습니다. 데스크톱에서는 일반적인 결과입니다.' }
    }
    $samples = New-Object 'System.Collections.Generic.List[object]'
    foreach ($b in @($valid | Select-Object -First 8)) {
        $charge = $null
        $batteryState = $null
        $design = $null
        $full = $null
        # Null, zero and out-of-range values never become a fabricated health percentage.
        try {
            if ($null -ne $b.EstimatedChargeRemaining) {
                $c = [int]$b.EstimatedChargeRemaining
                if ($c -ge 0 -and $c -le 100) { $charge = $c }
            }
        } catch {}
        try {
            if ($null -ne $b.BatteryStatus) {
                $st = [int]$b.BatteryStatus
                if ($st -ge 1 -and $st -le 11) { $batteryState = $st }
            }
        } catch {}
        try {
            if ($null -ne $b.DesignCapacity) {
                $n = [long]$b.DesignCapacity
                if ($n -gt 0 -and $n -lt 10000000) { $design = $n }
            }
        } catch {}
        try {
            if ($null -ne $b.FullChargeCapacity) {
                $n = [long]$b.FullChargeCapacity
                if ($n -gt 0 -and $n -lt 10000000) { $full = $n }
            }
        } catch {}
        [void]$samples.Add([pscustomobject]@{
            chargeRemainingPercent = $charge
            batteryStatusCode = $batteryState
            designCapacityMWh = $design
            fullChargeCapacityMWh = $full
        })
    }
    [pscustomobject]@{
        status = 'collected'
        batteryCount = [int]$valid.Count
        samples = @($samples.ToArray())
        note = '현재 충전량은 배터리 건강도/잔여 수명이 아닙니다. 용량 값은 Windows 공급자가 지원할 때만 표시합니다.'
    }
}

function ConvertTo-PcCareUpdateEvidence {
    [CmdletBinding()]
    param([object[]]$Events = @())
    $seen = @{}
    foreach ($item in $Events) {
        if ($null -eq $item) { continue }
        try {
            $id = [int]$item.Id
            $provider = [string]$item.ProviderName
            if ($id -notin @(19,20) -or $provider -notmatch '(^|-)WindowsUpdateClient$') { continue }
            $when = [datetime]$item.TimeCreated
            if ($when -eq [datetime]::MinValue) { continue }
        } catch { continue }
        $recordId = 0L
        try { if ($null -ne $item.RecordId) { $recordId = [long]$item.RecordId } } catch {}
        if ($recordId -gt 0) {
            $key = "$provider/$recordId"
            if ($seen.ContainsKey($key)) { continue }
            $seen[$key] = $true
        }
        $kind = if ($id -eq 20) { 'update_installation_failure_record' } else { 'update_installation_success_record' }
        [pscustomobject]@{
            kind = $kind
            eventId = $id
            recordedAt = $when.ToString('yyyy-MM-ddTHH:mm:ss.fffK', [Globalization.CultureInfo]::InvariantCulture)
            recordedUtc = $when.ToUniversalTime().ToString('o', [Globalization.CultureInfo]::InvariantCulture)
            timeBasis = 'event_recorded_time'
        }
    }
}

# Device-dependent counters do not establish SSD remaining life or hardware health.
# Keep raw device data out of reports; invalid/sentinel values become unknown.
function ConvertTo-PcCareStorageMetrics {
    [CmdletBinding()]
    param([object]$Counter)
    $wear = $null
    $temperature = $null
    if ($null -ne $Counter) {
        try {
            if ($null -ne $Counter.Wear) {
                $candidate = [double]$Counter.Wear
                if (-not [double]::IsNaN($candidate) -and -not [double]::IsInfinity($candidate) -and
                    $candidate -gt 0 -and $candidate -le 100 -and $candidate -eq [math]::Truncate($candidate)) {
                    $wear = [int]$candidate
                }
            }
        } catch {}
        try {
            if ($null -ne $Counter.Temperature) {
                $candidate = [double]$Counter.Temperature
                if (-not [double]::IsNaN($candidate) -and -not [double]::IsInfinity($candidate) -and
                    $candidate -gt 0 -and $candidate -le 125 -and $candidate -eq [math]::Truncate($candidate)) {
                    $temperature = [int]$candidate
                }
            }
        } catch {}
    }
    return [pscustomobject]@{ wearPercent=$wear; temperatureC=$temperature }
}
