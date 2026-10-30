# AXMART PC CARE - evidence-based interpretation, not automated diagnosis.
# PowerShell 5.1, pure function; no filesystem, registry or network side effects.

# Only normalized event log evidence may create diagnostic review findings.
function Test-PcCareIncidentEvidence {
    [CmdletBinding()]
    param([object]$Evidence, [ValidateSet('system','update')][string]$Source)
    if ($null -eq $Evidence) { return $false }
    try {
        if ([string]$Evidence.timeBasis -cne 'event_recorded_time') { return $false }
        $kind = [string]$Evidence.kind
        $id = [int]$Evidence.eventId
        $provider = [string]$Evidence.provider
        $recorded = [string]$Evidence.recordedUtc
        if ($recorded -cnotmatch '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{1,7})?(?:Z|[+-]\d{2}:\d{2})$') { return $false }
        $when = [datetimeoffset]::Parse($recorded, [Globalization.CultureInfo]::InvariantCulture)
        if ($when -eq [datetimeoffset]::MinValue) { return $false }
        if ($Source -eq 'update') {
            return ((($kind -eq 'update_installation_failure_record' -and $id -eq 20) -or
                     ($kind -eq 'update_installation_success_record' -and $id -eq 19)) -and
                     ($provider -ceq 'Microsoft-Windows-WindowsUpdateClient'))
        }
        if ($kind -eq 'bugcheck_record' -and $id -eq 1001) {
            return $provider -match '^(?:BugCheck|WER-SystemErrorReporting|Microsoft-Windows-(?:BugCheck|WER-SystemErrorReporting))$'
        }
        if ($kind -eq 'shutdown_signal') {
            return (($id -eq 41 -and $provider -match '^(?:Microsoft-Windows-)?Kernel-Power$') -or
                    ($id -eq 6008 -and $provider -match '^EventLog$'))
        }
        if ($kind -eq 'storage_signal' -and $id -in @(7,51,55,129,153,157)) {
            return $provider -match '^(?:(?:Microsoft-Windows-)?(?:disk|ntfs|volmgr|storahci|stornvme|storport|storvsc|nvme)|Microsoft-Windows-Storage-Storport|iaStor(?:A|AC|V|VD))$'
        }
    } catch { return $false }
    return $false
}


# A missing warning is not an all-clear verdict when evidence coverage is incomplete.
function Get-PcCareAssessmentLabel {
    [CmdletBinding()]
    param([object[]]$Issues = @(), [object[]]$Limitations = @(), [object]$IncidentAssessment)
    if (@($Issues | Where-Object { $null -ne $_ -and $_.severity -eq 'high' }).Count -gt 0) { return '위험 신호' }
    if (@($Issues | Where-Object { $null -ne $_ -and $_.severity -eq 'medium' }).Count -gt 0) { return '주의 필요' }
    if (@($Limitations).Count -gt 0 -or $null -eq $IncidentAssessment -or
        [string]$IncidentAssessment.status -ne 'limited_observations') {
        return '확인 불완전'
    }
    return '관찰 범위 내 특이사항 없음'
}

function Get-PcCareIncidentAssessment {
    [CmdletBinding()]
    param(
        [object[]]$EventEvidence = @(),
        [object[]]$DiskObservations = @(),
        [ValidateSet('collected','empty','truncated','unavailable')]
        [string]$DiskCollectionStatus = 'unavailable',
        [object[]]$UpdateEvidence = @(),
        [object]$PnPSummary = $null,
        [ValidateSet('collected','no matching events','truncated','unavailable')]
        [string]$UpdateCollectionStatus = 'no matching events',
        [ValidateSet('collected','no matching events','truncated','unavailable')]
        [string]$EventCollectionStatus = 'unavailable'
    )
    # Stale arrays can survive a failed collector. They are not usable evidence.
    # Incomplete (truncated) collections retain observed signals with a caveat.
    $allEvents = @()
    $rejectedSystemEvidence = 0
    if ($EventCollectionStatus -in @('collected','truncated')) {
        $allEvents = @($EventEvidence | Where-Object { Test-PcCareIncidentEvidence -Evidence $_ -Source 'system' })
        $rejectedSystemEvidence = @($EventEvidence).Count - $allEvents.Count
    }
    # As with events and PnP, a failed or empty inventory cannot certify stale disk rows.
    # Truncated/collected queries may retain observed warnings, but never claim full coverage.
    $allDisks = @()
    if ($DiskCollectionStatus -in @('collected','truncated')) {
        $allDisks = @($DiskObservations | Where-Object { $null -ne $_ })
    }
    $bugchecks = @($allEvents | Where-Object { $_.kind -eq 'bugcheck_record' })
    $shutdowns = @($allEvents | Where-Object { $_.kind -eq 'shutdown_signal' })
    $storageSignals = @($allEvents | Where-Object { $_.kind -eq 'storage_signal' })
    $updateFailures = @()
    $rejectedUpdateEvidence = 0
    if ($UpdateCollectionStatus -in @('collected','truncated')) {
        $validUpdates = @($UpdateEvidence | Where-Object { Test-PcCareIncidentEvidence -Evidence $_ -Source 'update' })
        $rejectedUpdateEvidence = @($UpdateEvidence).Count - $validUpdates.Count
        $updateFailures = @($UpdateEvidence | Where-Object { $_.kind -eq 'update_installation_failure_record' -and (Test-PcCareIncidentEvidence -Evidence $_ -Source 'update') })
    }
    $diskWarnings = @($allDisks | Where-Object { $_.status -in @('Warning','Unhealthy') })
    $unknownDisks = @($allDisks | Where-Object { $_.status -notin @('Healthy','Warning','Unhealthy') })
    $pnpSamples = @()
    $pnpStatus = 'unavailable'
    if ($null -ne $PnPSummary) {
        $pnpStatus = [string]$PnPSummary.status
        if ($pnpStatus -in @('collected','truncated')) {
            $pnpSamples = @($PnPSummary.samples | Where-Object { $null -ne $_ })
        }
    }
    $pnpActiveIssues = @($pnpSamples | Where-Object { $_.configurationCode -gt 0 -and $_.configurationCode -ne 22 })
    $pnpDisabled = @($pnpSamples | Where-Object { $_.configurationCode -eq 22 })
    $findings = New-Object 'System.Collections.Generic.List[object]'
    $caveats = New-Object 'System.Collections.Generic.List[string]'
    $incomplete = ($EventCollectionStatus -in @('truncated','unavailable')) -or ($DiskCollectionStatus -ne 'collected')
    if ($rejectedSystemEvidence -gt 0 -or $rejectedUpdateEvidence -gt 0) {
        $incomplete = $true
        [void]$caveats.Add('원본 이벤트 정규화 검증을 통과하지 못한 기록을 제외했습니다. 수집 결과의 완전성을 확인할 수 없습니다.')
    }
    if ($EventCollectionStatus -eq 'unavailable') {
        [void]$caveats.Add('시스템 이벤트 조회 불가: 로그 부재나 장애 부재를 확인한 결과가 아닙니다.')
    } elseif ($EventCollectionStatus -eq 'truncated') {
        [void]$caveats.Add('시스템 이벤트 수집 상한 도달: 조회 기간 전체의 증거가 아닐 수 있습니다.')
    }
    if ($UpdateCollectionStatus -eq 'unavailable') {
        $incomplete = $true
        [void]$caveats.Add('Windows 업데이트 설치 기록 조회 불가: 최근 실패 이력이 없었다는 뜻이 아닙니다.')
    } elseif ($UpdateCollectionStatus -eq 'truncated') {
        $incomplete = $true
        [void]$caveats.Add('Windows 업데이트 설치 기록 조회 상한 도달: 일부 이력이 빠졌을 수 있습니다.')
    }
    if ($pnpStatus -in @('truncated','unavailable')) {
        $incomplete = $true
        [void]$caveats.Add('PnP 장치 구성 코드는 일부만 수집되었거나 조회할 수 없습니다. 장치가 정상이라는 결론은 내릴 수 없습니다.')
    }
    if ($DiskCollectionStatus -ne 'collected' -or $allDisks.Count -eq 0 -or $unknownDisks.Count -gt 0) {
        $incomplete = $true
        [void]$caveats.Add('물리 저장장치 상태의 일부 또는 전체를 확인하지 못했습니다.')
    }
    if ($diskWarnings.Count -gt 0 -or $storageSignals.Count -gt 0) {
        $proof = if ($diskWarnings.Count -gt 0) { 'storage_health_warning' } else { 'storage_event_observed' }
        [void]$findings.Add([ordered]@{
            code = 'STORAGE_FIRST'
            priority = 'high'
            evidenceLevel = 'observed_signal'
            evidenceType = $proof
            title = '저장장치 관련 신호 우선 확인'
            interpretation = '저장장치 상태 경고나 저장장치 오류 기록을 발견했습니다. 물리적 고장 원인은 확정할 수 없습니다.'
            alternative = '드라이버, 연결 상태, 파일시스템 또는 일시적 I/O 문제도 가능합니다.'
            nextAction = '중요 파일을 다른 물리 저장장치로 먼저 백업하고 상태를 독립적으로 점검하세요. 물리 손상 의심 시 쓰기 수리를 피하세요.'
            causeConfirmed = $false
        })
    }
    if ($bugchecks.Count -gt 0) {
        [void]$findings.Add([ordered]@{
            code = 'BUGCHECK_REVIEW'
            priority = 'medium'
            evidenceLevel = 'observed_signal'
            evidenceType = 'bugcheck_record'
            title = '블루스크린 기록 추가 분석'
            interpretation = 'BugCheck 관련 공급자의 1001번 기록이 있습니다. 기록 시각은 실제 충돌 시각과 다를 수 있습니다.'
            alternative = '드라이버, 메모리, 저장장치, 전원 등 여러 원인 가능성을 배제하지 못합니다.'
            nextAction = 'STOP 코드와 최근 변경 사항을 함께 검토하고 동일 증상이 재현되는지 확인하세요.'
            causeConfirmed = $false
        })
    }
    if ($pnpActiveIssues.Count -gt 0) {
        [void]$findings.Add([ordered]@{
            code = 'PNP_CONFIG_REVIEW'
            priority = 'medium'
            evidenceLevel = 'current_device_state'
            evidenceType = 'pnp_configuration_code'
            title = '장치 구성 상태 추가 검토'
            interpretation = 'Windows 장치 관리자에서 0이 아닌 장치 구성 코드가 관측되었습니다. 시각 정보가 없는 현재 상태입니다.'
            alternative = '의도적 사용 중지, 미설치·손상된 드라이버, 장치 구성 문제 등 서로 다른 가능성이 있습니다.'
            nextAction = '장치 관리자에서 실제 코드와 사용자 변경 이력을 직접 확인하세요. 무인 드라이버 업데이트·제거는 수행하지 않습니다.'
            causeConfirmed = $false
        })
    }
    if ($updateFailures.Count -gt 0) {
        [void]$findings.Add([ordered]@{
            code = 'UPDATE_FAILURE_REVIEW'
            priority = 'medium'
            evidenceLevel = 'observed_signal'
            evidenceType = 'update_installation_failure_record'
            title = 'Windows 업데이트 설치 실패 기록 검토'
            interpretation = 'WindowsUpdateClient 설치 실패 이벤트가 있습니다. 현재 업데이트 상태나 시스템 장애 원인을 단정할 수 없습니다.'
            alternative = '설치 재시도, 선행 업데이트·장치 드라이버·저장 공간 등 다양한 원인을 고려해야 합니다.'
            nextAction = 'Windows 업데이트 기록과 오류 코드를 공식 설정 화면에서 직접 확인하세요.'
            causeConfirmed = $false
        })
    }
    if ($shutdowns.Count -gt 0) {
        [void]$findings.Add([ordered]@{
            code = 'SHUTDOWN_REVIEW'
            priority = 'medium'
            evidenceLevel = 'observed_signal'
            evidenceType = 'shutdown_signal'
            title = '비정상 종료 신호 확인'
            interpretation = '41/6008 이벤트가 있습니다. 두 기록은 같은 종료를 지칭할 수 있으며 종료 횟수나 블루스크린 원인을 확정하지 않습니다.'
            alternative = '강제 종료, 전원 공급 중단 또는 시스템 오류 등 복수 가능성이 있습니다.'
            nextAction = '해당 시점의 사용자 상황과 다른 기록을 대조하세요.'
            causeConfirmed = $false
        })
    }
    if ($bugchecks.Count -gt 0 -and ($storageSignals.Count -gt 0 -or $diskWarnings.Count -gt 0)) {
        [void]$caveats.Add('블루스크린·저장장치 신호가 함께 관찰되었지만 시간적 인접성이나 인과관계는 확인되지 않았습니다.')
    }
    if ($updateFailures.Count -gt 0 -and $bugchecks.Count -gt 0) {
        [void]$caveats.Add('업데이트 설치 실패와 BugCheck 기록은 함께 발견되었지만 날짜/원인의 연관성은 입증되지 않았습니다.')
    }
    if ($findings.Count -eq 0) {
        [void]$caveats.Add('확인한 범위에 명확한 원인 후보가 없습니다. 하드웨어 정상 또는 고장 없음의 증거가 아닙니다.')
    }
    $statusLabel = if ($incomplete) { 'incomplete' } else { 'limited_observations' }
    [ordered]@{
        schemaVersion = 1
        status = $statusLabel
        causeConfirmed = $false
        eventCollection = $EventCollectionStatus
        observedCounts = [ordered]@{
            bugcheckRecords = [int]$bugchecks.Count
            shutdownSignals = [int]$shutdowns.Count
            storageSignals = [int]$storageSignals.Count
            storageWarnings = [int]$diskWarnings.Count
            updateFailureRecords = [int]$updateFailures.Count
            rejectedSystemEvidence = [int]$rejectedSystemEvidence
            rejectedUpdateEvidence = [int]$rejectedUpdateEvidence
            pnpIssueSamples = [int]$pnpActiveIssues.Count
            pnpDisabledSamples = [int]$pnpDisabled.Count
        }
        findings = @($findings.ToArray())
        caveats = @($caveats.ToArray())
    }
}
