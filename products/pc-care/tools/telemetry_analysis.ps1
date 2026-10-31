# AXMART PC CARE - pure, privacy-bounded battery and Windows Update normalization.
# Windows PowerShell 5.1; no OS reads or writes in these functions.

function ConvertTo-PcCareIntegralValue {
    [CmdletBinding()]
    param([object]$Value, [long]$Minimum = [long]::MinValue, [long]$Maximum = [long]::MaxValue)
    if ($null -eq $Value) { return $null }
    try {
        $text = [Convert]::ToString($Value, [Globalization.CultureInfo]::InvariantCulture)
        if ($text -cnotmatch '^-?\d{1,18}$') { return $null }
        $number = 0L
        if (-not [long]::TryParse($text, [Globalization.NumberStyles]::AllowLeadingSign,
                [Globalization.CultureInfo]::InvariantCulture, [ref]$number)) { return $null }
        if ($number -lt $Minimum -or $number -gt $Maximum) { return $null }
        return $number
    } catch { return $null }
}

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
        $c = ConvertTo-PcCareIntegralValue -Value $b.EstimatedChargeRemaining -Minimum 0 -Maximum 100
        if ($null -ne $c) { $charge = [int]$c }
        $st = ConvertTo-PcCareIntegralValue -Value $b.BatteryStatus -Minimum 1 -Maximum 11
        if ($null -ne $st) { $batteryState = [int]$st }
        $n = ConvertTo-PcCareIntegralValue -Value $b.DesignCapacity -Minimum 1 -Maximum 9999999
        if ($null -ne $n) { $design = $n }
        $n = ConvertTo-PcCareIntegralValue -Value $b.FullChargeCapacity -Minimum 1 -Maximum 9999999
        if ($null -ne $n) { $full = $n }
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
            $idText = [Convert]::ToString($item.Id, [Globalization.CultureInfo]::InvariantCulture)
            if ($idText -cnotmatch '^\d{1,5}$') { continue }
            $id = [int]::Parse($idText, [Globalization.NumberStyles]::None, [Globalization.CultureInfo]::InvariantCulture)
            if ($id -gt 65535) { continue }
            $provider = [string]$item.ProviderName
            if ($id -notin @(19,20) -or $provider -ne 'Microsoft-Windows-WindowsUpdateClient') { continue }
            $when = [datetime]$item.TimeCreated
            if ($when -eq [datetime]::MinValue) { continue }
        } catch { continue }
        $recordId = 0L
        try {
            if ($null -ne $item.RecordId) {
                $recordText = [Convert]::ToString($item.RecordId, [Globalization.CultureInfo]::InvariantCulture)
                $parsedRecordId = 0L
                if ($recordText -cmatch '^\d{1,18}$' -and
                    [long]::TryParse($recordText, [Globalization.NumberStyles]::None,
                        [Globalization.CultureInfo]::InvariantCulture, [ref]$parsedRecordId)) {
                    $recordId = $parsedRecordId
                }
            }
        } catch { $recordId = 0L }
        if ($recordId -gt 0) {
            $key = "$provider/$recordId"
            if ($seen.ContainsKey($key)) { continue }
            $seen[$key] = $true
        }
        $kind = if ($id -eq 20) { 'update_installation_failure_record' } else { 'update_installation_success_record' }
        [pscustomobject]@{
            kind = $kind
            eventId = $id
            provider = 'Microsoft-Windows-WindowsUpdateClient'
            recordedAt = $when.ToString('yyyy-MM-ddTHH:mm:ss.fffK', [Globalization.CultureInfo]::InvariantCulture)
            recordedUtc = $when.ToUniversalTime().ToString('o', [Globalization.CultureInfo]::InvariantCulture)
            timeBasis = 'event_recorded_time'
        }
    }
}

# Device-dependent counters do not establish SSD remaining life or hardware health.
# Keep raw device data out of reports; invalid/sentinel values become unknown.

# Never serialize device-provided friendly names, serials or arbitrary status text.
# The ordinal is valid only during this scan, not a physical identifier across runs.
function ConvertTo-PcCarePrivateDiskObservation {
    [CmdletBinding()]
    param([Parameter(Mandatory=$true)][object]$Disk,
          [ValidateRange(1,65535)][int]$Ordinal)
    $health = [string]$Disk.HealthStatus
    if ($health -notin @('Healthy','Warning','Unhealthy','Unknown')) { $health = 'Unknown' }
    $allowOps = @('OK','Degraded','Error','Unknown','Lost Communication',
                  'Predictive Failure','No Contact','Stressed','Starting','Stopping',
                  'Stopped','In Service')
    $safeOps = New-Object 'System.Collections.Generic.List[string]'
    foreach ($value in @($Disk.OperationalStatus)) {
        $op = [string]$value
        if ($op -in $allowOps -and -not $safeOps.Contains($op)) {
            [void]$safeOps.Add($op)
        }
    }
    $operational = if ($safeOps.Count -gt 0) { $safeOps -join ',' } else { 'unavailable' }
    return [ordered]@{
        model = ('물리 저장장치 {0}' -f $Ordinal)
        status = $health
        operationalStatus = $operational
        reliabilityStatus = 'unavailable'
        wearPercent = $null
        temperatureC = $null
    }
}

function ConvertTo-PcCareStorageMetrics {
    [CmdletBinding()]
    param([object]$Counter)
    $wear = $null
    $temperature = $null
    if ($null -ne $Counter) {
        $candidate = ConvertTo-PcCareIntegralValue -Value $Counter.Wear -Minimum 1 -Maximum 100
        if ($null -ne $candidate) { $wear = [int]$candidate }
        $candidate = ConvertTo-PcCareIntegralValue -Value $Counter.Temperature -Minimum 1 -Maximum 125
        if ($null -ne $candidate) { $temperature = [int]$candidate }
    }
    return [pscustomobject]@{ wearPercent=$wear; temperatureC=$temperature }
}

# Pure Win32_LogicalDisk volume normalization. Invalid provider data must not
# terminate an otherwise useful diagnosis or produce NaN/Infinity in JSON.
function ConvertTo-PcCareVolumeSample {
    [CmdletBinding()]
    param([object]$Volume)
    if ($null -eq $Volume) { return $null }
    try {
        $drive = ([string]$Volume.DeviceID).ToUpperInvariant()
        if ($drive -cnotmatch '^[A-Z]:$') { return $null }
        if ($null -eq $Volume.Size -or $null -eq $Volume.FreeSpace) { return $null }
        if ($Volume.Size -is [bool] -or $Volume.FreeSpace -is [bool]) { return $null }
        $capacity = [double]$Volume.Size
        $remaining = [double]$Volume.FreeSpace
        if ([double]::IsNaN($capacity) -or [double]::IsInfinity($capacity) -or
            [double]::IsNaN($remaining) -or [double]::IsInfinity($remaining) -or
            $capacity -ne [math]::Truncate($capacity) -or $remaining -ne [math]::Truncate($remaining) -or
            $capacity -le 0 -or $remaining -lt 0 -or $remaining -gt $capacity) {
            return $null
        }
        $pct = [math]::Round(($remaining / $capacity) * 100, 1)
        $gb = [math]::Round($remaining / 1GB, 1)
        $sizeGB = [math]::Round($capacity / 1GB, 1)
        return [pscustomobject]@{
            drive = $drive
            remainingGB = $gb
            freePercent = $pct
            sizeGB = $sizeGB
            capacityBytes = $capacity
            remainingBytes = $remaining
        }
    } catch {
        return $null
    }
}

# Compute warning thresholds from unrounded byte counts, never display-rounded
# remainingGB/freePercent. Rounding can hide a 4.96 GB/4.96% critical disk.
function Get-PcCareVolumeRisk {
    [CmdletBinding()]
    param([object]$Sample)
    if ($null -eq $Sample) { return 'unavailable' }
    try {
        $size = [double]$Sample.capacityBytes
        $free = [double]$Sample.remainingBytes
        if ([double]::IsNaN($size) -or [double]::IsInfinity($size) -or
            [double]::IsNaN($free) -or [double]::IsInfinity($free) -or
            $size -le 0 -or $free -lt 0 -or $free -gt $size) {
            return 'unavailable'
        }
        if ($size -lt 20GB) { return 'none' }
        if ($free -lt 5GB -or ($free / $size) -lt 0.05) { return 'high' }
        if (($free / $size) -lt 0.15) { return 'medium' }
        return 'none'
    } catch { return 'unavailable' }
}
