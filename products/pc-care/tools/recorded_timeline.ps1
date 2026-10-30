# AXMART PC CARE - bounded timeline of LOG-RECORDING timestamps only.
# Pure PowerShell 5.1: no system mutations, causality or crash times inferred.
function Get-PcCareRecordedTimeline {
    [CmdletBinding()]
    param(
        [object[]]$SystemEvidence = @(),
        [object[]]$UpdateEvidence = @(),
        [int]$WindowMinutes = 15,
        [int]$MaxEntries = 80,
        [ValidateSet('collected','no matching events','truncated','unavailable')]
        [string]$SystemCollectionStatus = 'unavailable',
        [ValidateSet('collected','no matching events','truncated','unavailable')]
        [string]$UpdateCollectionStatus = 'unavailable'
    )
    if ($WindowMinutes -lt 1 -or $WindowMinutes -gt 60) { throw 'WindowMinutes must be 1..60' }
    if ($MaxEntries -lt 1 -or $MaxEntries -gt 200) { throw 'MaxEntries must be 1..200' }
    # Never use stale arrays from a failed/no-match query or mix evidence providers.
    # The upstream normalizers bind kind to eventId; repeat the invariant at this boundary.
    $streams = New-Object 'System.Collections.Generic.List[object]'
    if ($SystemCollectionStatus -in @('collected','truncated')) {
        foreach ($item in @($SystemEvidence)) {
            [void]$streams.Add([pscustomobject]@{ scope='system'; item=$item })
        }
    }
    if ($UpdateCollectionStatus -in @('collected','truncated')) {
        foreach ($item in @($UpdateEvidence)) {
            [void]$streams.Add([pscustomobject]@{ scope='update'; item=$item })
        }
    }
    $rows = New-Object 'System.Collections.Generic.List[object]'
    foreach ($entry in $streams) {
        $item = $entry.item
        if ($null -eq $item) { continue }
        try {
            $kind = [string]$item.kind
            $id = [int]$item.eventId
            $systemMatch = ($entry.scope -eq 'system') -and (
                ($kind -eq 'bugcheck_record' -and $id -eq 1001) -or
                ($kind -eq 'shutdown_signal' -and $id -in @(41,6008)) -or
                ($kind -eq 'storage_signal' -and $id -in @(7,51,55,129,153,157))
            )
            $updateMatch = ($entry.scope -eq 'update') -and (
                ($kind -eq 'update_installation_failure_record' -and $id -eq 20) -or
                ($kind -eq 'update_installation_success_record' -and $id -eq 19)
            )
            if (-not ($systemMatch -or $updateMatch)) { continue }
            # DateTimeOffset.Parse otherwise accepts local/ambiguous timestamps.
            $rawTime = [string]$item.recordedUtc
            if ($rawTime -cnotmatch '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{1,7})?(?:Z|[+-]\d{2}:\d{2})        [void]$rows.Add([pscustomobject]@{
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
    $resultStatus = if ($totalAccepted -gt $MaxEntries -or
                        $SystemCollectionStatus -eq 'truncated' -or
                        $UpdateCollectionStatus -eq 'truncated') { 'truncated' } else { 'collected' }
    [pscustomobject]@{
        schemaVersion = 1
        timeBasis = 'event_recorded_time_not_verified_incident_time'
        windowMinutes = $WindowMinutes
        status = $resultStatus
        sourceCollection = [ordered]@{
            system = $SystemCollectionStatus
            update = $UpdateCollectionStatus
        }
        acceptedCount = $totalAccepted
        returnedCount = $mostRecent.Count
        windows = @($output.ToArray())
        note = '서로 가까운 이벤트 기록 시각을 묶었을 뿐이며, BugCheck 발생 시각·업데이트의 장애 원인·실제 종료 횟수를 입증하지 않습니다.'
    }
}
) { continue }
            $when = [datetimeoffset]::Parse($rawTime, [Globalization.CultureInfo]::InvariantCulture).ToUniversalTime()
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
    $resultStatus = if ($totalAccepted -gt $MaxEntries) { 'truncated' } else { 'collected' }
    [pscustomobject]@{
        schemaVersion = 1
        timeBasis = 'event_recorded_time_not_verified_incident_time'
        windowMinutes = $WindowMinutes
        status = $resultStatus
        acceptedCount = $totalAccepted
        returnedCount = $mostRecent.Count
        windows = @($output.ToArray())
        note = '서로 가까운 이벤트 기록 시각을 묶었을 뿐이며, BugCheck 발생 시각·업데이트의 장애 원인·실제 종료 횟수를 입증하지 않습니다.'
    }
}
