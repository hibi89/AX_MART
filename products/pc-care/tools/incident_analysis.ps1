# AXMART PC CARE - evidence-based interpretation, not automated diagnosis.
# PowerShell 5.1, pure function; no filesystem, registry or network side effects.
function Get-PcCareIncidentAssessment {
    [CmdletBinding()]
    param(
        [object[]]$EventEvidence = @(),
        [object[]]$DiskObservations = @(),
        [ValidateSet('collected','no matching events','truncated','unavailable')]
        [string]$EventCollectionStatus = 'unavailable'
    )
    $allEvents = @($EventEvidence | Where-Object { $null -ne $_ })
    $allDisks = @($DiskObservations | Where-Object { $null -ne $_ })
    $bugchecks = @($allEvents | Where-Object { $_.kind -eq 'bugcheck_record' })
    $shutdowns = @($allEvents | Where-Object { $_.kind -eq 'shutdown_signal' })
    $storageSignals = @($allEvents | Where-Object { $_.kind -eq 'storage_signal' })
    $diskWarnings = @($allDisks | Where-Object { $_.status -in @('Warning','Unhealthy') })
    $unknownDisks = @($allDisks | Where-Object { $_.status -notin @('Healthy','Warning','Unhealthy') })
    $findings = New-Object 'System.Collections.Generic.List[object]'
    $caveats = New-Object 'System.Collections.Generic.List[string]'
    $incomplete = $EventCollectionStatus -in @('truncated','unavailable')
    if ($EventCollectionStatus -eq 'unavailable') {
        [void]$caveats.Add('시스템 이벤트 조회 불가: 로그 부재나 장애 부재를 확인한 결과가 아닙니다.')
    } elseif ($EventCollectionStatus -eq 'truncated') {
        [void]$caveats.Add('시스템 이벤트 수집 상한 도달: 조회 기간 전체의 증거가 아닐 수 있습니다.')
    }
    if ($allDisks.Count -eq 0 -or $unknownDisks.Count -gt 0) {
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
    if ($findings.Count -eq 0) {
        [void]$caveats.Add('확인한 범위에 명확한 원인 후보가 없습니다. 하드웨어 정상 또는 고장 없음의 증거가 아닙니다.')
    }
    [ordered]@{
        schemaVersion = 1
        status = if ($incomplete) { 'incomplete' } else { 'limited_observations' }
        causeConfirmed = $false
        eventCollection = $EventCollectionStatus
        observedCounts = [ordered]@{
            bugcheckRecords = [int]$bugchecks.Count
            shutdownSignals = [int]$shutdowns.Count
            storageSignals = [int]$storageSignals.Count
            storageWarnings = [int]$diskWarnings.Count
        }
        findings = @($findings.ToArray())
        caveats = @($caveats.ToArray())
    }
}
