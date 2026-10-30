# AXMART PC CARE - bounded timeline of LOG-RECORDING timestamps only.
# Pure PowerShell 5.1: no system mutations, causality or crash times inferred.
function Get-PcCareRecordedTimeline {
    [CmdletBinding()]
    param(
        [object[]]$SystemEvidence = @(),
        [object[]]$UpdateEvidence = @(),
        [int]$WindowMinutes = 15,
        [int]$MaxEntries = 80
    )
    if ($WindowMinutes -lt 1 -or $WindowMinutes -gt 60) { throw 'WindowMinutes must be 1..60' }
    if ($MaxEntries -lt 1 -or $MaxEntries -gt 200) { throw 'MaxEntries must be 1..200' }
    $accepted = @('bugcheck_record','shutdown_signal','storage_signal','update_installation_failure_record','update_installation_success_record')
    $rows = New-Object 'System.Collections.Generic.List[object]'
    foreach ($item in (@($SystemEvidence) + @($UpdateEvidence))) {
        if ($null -eq $item) { continue }
        try {
            $kind = [string]$item.kind
            if ($kind -notin $accepted) { continue }
            $when = [datetimeoffset]::Parse([string]$item.recordedUtc, [Globalization.CultureInfo]::InvariantCulture).ToUniversalTime()
            if ($when -eq [datetimeoffset]::MinValue) { continue }
        } catch { continue }
        [void]$rows.Add([pscustomobject]@{
            kind = $kind
            recordedUtc = $when.ToString('o', [Globalization.CultureInfo]::InvariantCulture)
            whenUtc = $when
        })
    }
    $totalAccepted = $rows.Count
    # Newest recorded evidence first; then chronological grouping.
    $mostRecent = @($rows.ToArray() | Sort-Object whenUtc -Descending | Select-Object -First $MaxEntries)
    $ordered = @($mostRecent | Sort-Object whenUtc)
    $windows = New-Object 'System.Collections.Generic.List[object]'
    $current = $null
    foreach ($item in $ordered) {
        if ($null -eq $current -or ($item.whenUtc - $current.start).TotalMinutes -gt $WindowMinutes) {
            $current = [pscustomobject]@{
                start = $item.whenUtc
                end = $item.whenUtc
                kinds = (New-Object 'System.Collections.Generic.List[string]')
                count = 0
            }
            [void]$windows.Add($current)
        }
        $current.end = $item.whenUtc
        $current.count++
        if (-not $current.kinds.Contains($item.kind)) { [void]$current.kinds.Add($item.kind) }
    }
    $output = New-Object 'System.Collections.Generic.List[object]'
    foreach ($w in $windows) {
        [void]$output.Add([pscustomobject]@{
            firstRecordedUtc = $w.start.ToString('o', [Globalization.CultureInfo]::InvariantCulture)
            lastRecordedUtc = $w.end.ToString('o', [Globalization.CultureInfo]::InvariantCulture)
            evidenceCount = [int]$w.count
            kinds = @($w.kinds.ToArray())
            interpretation = 'recorded_timestamp_proximity_only'
            causeConfirmed = $false
        })
    }
    [pscustomobject]@{
        schemaVersion = 1
        timeBasis = 'event_recorded_time_not_verified_incident_time'
        windowMinutes = $WindowMinutes
        status = if ($totalAccepted -gt $MaxEntries) { 'truncated' } else { 'collected' }
        acceptedCount = $totalAccepted
        returnedCount = $mostRecent.Count
        windows = @($output.ToArray())
        note = '서로 가까운 이벤트 기록 시각을 묶었을 뿐이며, BugCheck 발생 시각·업데이트의 장애 원인·실제 종료 횟수를 입증하지 않습니다.'
    }
}
