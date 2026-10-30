# AXMART PC CARE: pure, read-only System event normalization (PowerShell 5.1).
# Recorded times are NOT guaranteed crash/outage times.
Set-StrictMode -Version 2.0

function ConvertTo-PcCareEvidence {
    [CmdletBinding()]
    param([object[]]$Events)
    $seen = @{}
    foreach ($item in @($Events)) {
        if ($null -eq $item) { continue }
        try {
            $id = [int]$item.Id
            $when = [datetime]$item.TimeCreated
            if ($when -eq [datetime]::MinValue) { continue }
            $provider = [string]$item.ProviderName
        } catch { continue }
        $kind = ''
        if ($id -eq 1001 -and $provider -match 'BugCheck|SystemErrorReporting') {
            $kind = 'bugcheck_record'
        } elseif (($id -eq 41 -and $provider -match 'Kernel-Power') -or ($id -eq 6008 -and $provider -match 'EventLog')) {
            $kind = 'shutdown_signal'
        } elseif ($id -in @(7,51,55,129,153,157) -and $provider -match 'disk|stor|nvme|ntfs|volmgr|iaStor') {
            $kind = 'storage_signal'
        } else { continue }
        # RecordId, when available, distinguishes separate entries with identical timestamps.
        $recordId = 0L
        try { if ($null -ne $item.RecordId) { $recordId = [long]$item.RecordId } } catch {}
        $recordedAt = $when.ToString('yyyy-MM-ddTHH:mm:ss.fffK', [Globalization.CultureInfo]::InvariantCulture)
        $dedup = if ($recordId -gt 0) { "$provider/$recordId" } else { "$provider/$id/$recordedAt" }
        if ($seen.ContainsKey($dedup)) { continue }
        $seen[$dedup] = $true
        $stopCode = $null
        if ($kind -eq 'bugcheck_record') {
            try {
                $message = [string]$item.Message
                if ($message -match '(?i)0x[0-9a-f]{8}') { $stopCode = $Matches[0].ToUpperInvariant() }
            } catch {}
        }
        [pscustomobject]@{
            kind = $kind
            eventId = $id
            provider = $provider
            recordedAt = $recordedAt
            timeBasis = 'event_recorded_time'
            stopCode = $stopCode
        }
    }
}

function Group-PcCareShutdownSignals {
    [CmdletBinding()]
    param([object[]]$Evidence)
    # A 41/6008 pair can describe one outage. Grouping is heuristic, never a proven count.
    $orderedSignals = @($Evidence | Where-Object { $null -ne $_ -and $_.kind -eq 'shutdown_signal' } | Sort-Object recordedAt)
    $groups = New-Object 'System.Collections.Generic.List[object]'
    $current = $null
    foreach ($signal in $orderedSignals) {
        try { $whenUtc = [datetimeoffset]::Parse([string]$signal.recordedAt).ToUniversalTime() }
        catch { continue }
        if ($null -eq $current -or ($whenUtc - $current.lastUtc).TotalMinutes -gt 10) {
            $current = [pscustomobject]@{
                firstRecordedAt = [string]$signal.recordedAt
                lastRecordedAt = [string]$signal.recordedAt
                lastUtc = $whenUtc
                eventIds = (New-Object 'System.Collections.Generic.List[int]')
                evidenceCount = 0
                interpretation = 'possibly_related_shutdown_signals'
            }
            [void]$groups.Add($current)
        }
        $current.lastRecordedAt = [string]$signal.recordedAt
        $current.lastUtc = $whenUtc
        $current.evidenceCount++
        if (-not $current.eventIds.Contains([int]$signal.eventId)) {
            [void]$current.eventIds.Add([int]$signal.eventId)
        }
    }
    foreach ($group in $groups) {
        [pscustomobject]@{
            firstRecordedAt = $group.firstRecordedAt
            lastRecordedAt = $group.lastRecordedAt
            eventIds = @($group.eventIds.ToArray())
            evidenceCount = [int]$group.evidenceCount
            interpretation = $group.interpretation
        }
    }
}
