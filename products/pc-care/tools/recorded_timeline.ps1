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
    # Ignore stale arrays from failed or empty queries and do not mix providers.
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
            # Local timestamps are ambiguous; require the normalizer's UTC/offset.
            $rawTime = [string]$item.recordedUtc
            if ($rawTime -cnotmatch '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{1,7})?(?:Z|[+-]\d{2}:\d{2})$') { continue }
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
        # Only note bounded co-observation inside a time window; never infer causation.
        $coObserved = New-Object 'System.Collections.Generic.List[string]'
        $observedKinds = @($w.kinds.ToArray())
        if ($observedKinds -contains 'bugcheck_record' -and $observedKinds -contains 'storage_signal') {
            [void]$coObserved.Add('bugcheck_storage_proximity')
        }
        if ($observedKinds -contains 'shutdown_signal' -and $observedKinds -contains 'storage_signal') {
            [void]$coObserved.Add('shutdown_storage_proximity')
        }
        if ($observedKinds -contains 'bugcheck_record' -and $observedKinds -contains 'update_installation_failure_record') {
            [void]$coObserved.Add('bugcheck_update_proximity')
        }
        [void]$output.Add([pscustomobject]@{
            firstRecordedUtc = $w.start.ToString('o', [Globalization.CultureInfo]::InvariantCulture)
            lastRecordedUtc = $w.end.ToString('o', [Globalization.CultureInfo]::InvariantCulture)
            evidenceCount = [int]$w.count
            kinds = @($observedKinds)
            coObserved = @($coObserved.ToArray())
            interpretation = 'recorded_timestamp_proximity_only'
            causeConfirmed = $false
        })
    }
    $sourceUnavailable = ($SystemCollectionStatus -eq 'unavailable' -or $UpdateCollectionStatus -eq 'unavailable')
    $sourceTruncated = ($SystemCollectionStatus -eq 'truncated' -or $UpdateCollectionStatus -eq 'truncated')
    $resultStatus = if ($totalAccepted -gt $MaxEntries -or $sourceTruncated) { 'truncated' }
                    elseif ($sourceUnavailable -and $totalAccepted -eq 0) { 'unavailable' }
                    elseif ($sourceUnavailable) { 'incomplete' }
                    elseif ($totalAccepted -eq 0) { 'no matching events' }
                    else { 'collected' }
    [pscustomobject]@{
        schemaVersion = 1
        timeBasis = 'event_recorded_time_not_verified_incident_time'
        windowMinutes = $WindowMinutes
        status = $resultStatus
        sourceCollection = [ordered]@{
            system = $SystemCollectionStatus
            update = $UpdateCollectionStatus
        }
        coverageComplete = (-not $sourceUnavailable -and -not $sourceTruncated -and $totalAccepted -le $MaxEntries)
        acceptedCount = $totalAccepted
        returnedCount = $mostRecent.Count
        windows = @($output.ToArray())
        note = '근접 신호는 같은 기록 시각 묶음에 포함된 종류만 표시합니다. 실제 장애 시각·원인·사건 횟수의 증거가 아니며 수집 실패·상한은 불완전으로 표시합니다.'
    }
}
