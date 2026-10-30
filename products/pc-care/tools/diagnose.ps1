# AXMART PC CARE v0.1 | Windows PowerShell 5.1 | READ-ONLY DIAGNOSTICS
# It never schedules tasks, fixes disks, changes services, or sends telemetry.
[CmdletBinding()]
param([int]$Days = 30)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
if ($Days -lt 1 -or $Days -gt 90) { throw 'Days must be between 1 and 90.' }
$root = Split-Path -Parent $PSScriptRoot
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$base = 'pc-care-{0}-{1}' -f $stamp, ([guid]::NewGuid().ToString('N').Substring(0,8))
$issues = New-Object 'System.Collections.Generic.List[object]'
$limits = New-Object 'System.Collections.Generic.List[string]'
$observations = [ordered]@{}
$collectionStatus = [ordered]@{}

function Add-Issue([string]$Severity, [string]$Code, [string]$Title, [string]$Explain, [string]$Advice) {
    [void]$issues.Add([ordered]@{ severity=$Severity; code=$Code; title=$Title; explanation=$Explain; recommendation=$Advice })
}
function Safe-Collect([scriptblock]$Action, [string]$Label, [string]$Key) {
    try {
        $result = @(& $Action)
        $nonNull = @($result | Where-Object { $null -ne $_ })
        $collectionStatus[$Key] = if ($nonNull.Count -eq 0) { 'empty' } else { 'collected' }
        if ($nonNull.Count -eq 0) {
            [void]$limits.Add(('{0}: 정보가 반환되지 않았습니다 (조회 성공, 결과 없음).' -f $Label))
        }
        return $result
    } catch {
        $collectionStatus[$Key] = 'unavailable'
        # Never serialize exception messages, machine paths, or account information.
        [void]$limits.Add(('{0}: 데이터를 읽지 못했습니다 ({1})' -f $Label, $_.Exception.GetType().Name))
        return $null
    }
}
function Esc([object]$Value) {
    return [System.Net.WebUtility]::HtmlEncode([string]$Value)
}

# Observe current privileges; never elevate automatically.
try {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    $privilege = if ($principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) { 'administrator' } else { 'standard' }
} catch {
    $privilege = 'unavailable'
    [void]$limits.Add('현재 사용자 권한을 판별하지 못했습니다.')
}
$observations['privilege'] = @{ state=$privilege; requestedElevation=$false }
$collectionStatus['privilege'] = if ($privilege -eq 'unavailable') { 'unavailable' } else { 'collected' }

Write-Host '[AXMART PC CARE] Read-only health check...' -ForegroundColor Cyan
$os = Safe-Collect { Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop } 'Windows 버전' 'windows'
if ($null -ne $os) {
    $observations['windows'] = @{ name=[string]$os.Caption; version=[string]$os.Version; build=[string]$os.BuildNumber; bootTime=([string]$os.LastBootUpTime) }
}
else { $observations['windows'] = @{ name='확인 불가'; version=''; build=''; bootTime='' } }

# Logical volume free space; do not collect absolute file paths or filenames.
$volumes = @(Safe-Collect { @(Get-CimInstance -ClassName Win32_LogicalDisk -Filter 'DriveType=3' -ErrorAction Stop) } '디스크 여유 공간' 'volumes')
$volData = New-Object 'System.Collections.Generic.List[object]'
foreach ($v in $volumes) {
    if ($null -eq $v) { continue }
    if ($null -eq $v.DeviceID -or $null -eq $v.Size -or $null -eq $v.FreeSpace) {
        [void]$limits.Add('드라이브: 일부 용량 데이터가 제공되지 않아 해당 볼륨을 평가하지 않았습니다.')
        continue
    }
    $remaining = [double]$v.FreeSpace
    $capacity = [double]$v.Size
    if ($capacity -le 0 -or $remaining -lt 0 -or $remaining -gt $capacity) {
        [void]$limits.Add('드라이브: 유효하지 않은 용량 값이 있어 해당 볼륨을 평가하지 않았습니다.')
        continue
    }
    $pct = [math]::Round(($remaining / $capacity) * 100, 1)
    $gb = [math]::Round($remaining / 1GB, 1)
    [void]$volData.Add(@{ drive=[string]$v.DeviceID; remainingGB=$gb; freePercent=$pct; sizeGB=[math]::Round($capacity / 1GB,1) })
    if ($capacity -ge 20GB -and ($pct -lt 5 -or $gb -lt 5)) {
        Add-Issue 'high' 'DISK_SPACE_CRITICAL' ("{0} 드라이브 공간 부족" -f $v.DeviceID) ("남은 공간 {0}GB ({1}%)" -f $gb,$pct) '중요 파일 백업 후 불필요한 파일을 직접 정리하세요. 자동 삭제는 하지 않습니다.'
    } elseif ($capacity -ge 20GB -and $pct -lt 15) {
        Add-Issue 'medium' 'DISK_SPACE_LOW' ("{0} 드라이브 여유 공간 부족" -f $v.DeviceID) ("남은 공간 {0}GB ({1}%)" -f $gb,$pct) '용량 변화를 확인하고 개인 파일을 백업하세요.'
    }
}
$observations['volumes'] = @($volData.ToArray())

# Storage provider may not expose NVMe SMART. Unknown is not Healthy.
$disks = @(Safe-Collect { @(Get-PhysicalDisk -ErrorAction Stop) } '저장장치 건강 상태' 'physicalDisks')
$diskData = New-Object 'System.Collections.Generic.List[object]'
foreach ($disk in $disks) {
    if ($null -eq $disk) { continue }
    $state = [string]$disk.HealthStatus
    $item = [ordered]@{ model=[string]$disk.FriendlyName; status=$state; operationalStatus=([string]($disk.OperationalStatus -join ',')); reliabilityStatus='unavailable'; wearPercent=$null; temperatureC=$null }
    try {
        $counter = $disk | Get-StorageReliabilityCounter -ErrorAction Stop
        if ($null -ne $counter) {
            $item.reliabilityStatus = 'collected'
            if ($null -ne $counter.Wear -and $counter.Wear -ne 0) { $item.wearPercent=[int]$counter.Wear }
            if ($null -ne $counter.Temperature -and $counter.Temperature -ne 0) { $item.temperatureC=[int]$counter.Temperature }
        } else { $item.reliabilityStatus = 'empty' }
    } catch {
        # Optional device-dependent telemetry; an unsupported API is not proof of health.
        $item.reliabilityStatus = 'unavailable'
    }
    [void]$diskData.Add($item)
    if ($state -in @('Warning','Unhealthy')) {
        Add-Issue 'high' 'DISK_HEALTH' '저장장치 상태 경고' ("{0}: {1}" -f $disk.FriendlyName,$state) '디스크 수리를 시도하기 전에 데이터를 다른 저장장치에 백업하고 저장장치 점검을 받으세요.'
    } elseif ($state -ne 'Healthy') {
        [void]$limits.Add(('저장장치 {0}: 상태 확인 불가/미지원 ({1})' -f $disk.FriendlyName,$state))
    }
}
if ($diskData.Count -eq 0) { [void]$limits.Add('장치별 SMART/저장장치 상태를 확인하지 못했습니다.') }
$observations['physicalDisks'] = @($diskData.ToArray())

# Keep evidence normalization independent of OS collection so synthetic fixtures can test it.
. (Join-Path $PSScriptRoot 'event_analysis.ps1')
$start = (Get-Date).AddDays(-$Days)
$eventResult = Invoke-PcCareEventQuery -MaxEvents 1500 -Query {
    Get-WinEvent -FilterHashtable @{ LogName='System'; StartTime=$start; Id=41,6008,1001,7,51,55,129,153,157 } -MaxEvents 1500 -ErrorAction Stop
}
$events = @($eventResult.events)
$eventQueryFailed = ($eventResult.status -eq 'unavailable')
if ($eventQueryFailed) {
    [void]$limits.Add('시스템 이벤트: 로그 조회 실패 또는 접근 권한 부족. 조회 결과가 0건이라고 판단하지 않습니다.')
}
$evidence = @(ConvertTo-PcCareEvidence -Events $events)
$crashes = @($evidence | Where-Object { $_.kind -eq 'bugcheck_record' } | ForEach-Object {
    @{ time=$_.recordedAt; stopCode=$(if ($null -eq $_.stopCode) { '확인 불가' } else { $_.stopCode }); timeBasis='recorded_not_crash_time' }
})
$unexpected = @($evidence | Where-Object { $_.kind -eq 'shutdown_signal' } | ForEach-Object {
    @{ time=$_.recordedAt; eventId=$_.eventId }
})
$shutdownGroups = @(Group-PcCareShutdownSignals -Evidence $evidence)
$storageErrors = @($evidence | Where-Object { $_.kind -eq 'storage_signal' } | ForEach-Object {
    @{ time=$_.recordedAt; eventId=$_.eventId; source=$_.provider }
})
$eventsTruncated = ($eventResult.status -eq 'truncated')
if ($eventsTruncated) {
    [void]$limits.Add('시스템 이벤트 1,500건 조회 상한 도달: 검사 기간 전체를 확인하지 못했을 가능성이 있습니다.')
}
if ($crashes.Count -gt 0) {
    $severity = if ($crashes.Count -ge 3) { 'high' } else { 'medium' }
    Add-Issue $severity 'BUGCHECK' '블루스크린 관련 로그 발견' ("최근 {0}일간 BugCheck 기록 {1}건 (기록 시각은 실제 충돌 시각과 다를 수 있음)" -f $Days,$crashes.Count) 'STOP 코드를 확인하고 복수 원인을 비교하세요. 이벤트 1001의 기록 시간만으로 장애 발생 시각을 확정하지 마세요.'
}
if ($unexpected.Count -gt 0) {
    Add-Issue 'medium' 'UNEXPECTED_REBOOT' '비정상 종료 신호 발견' ("이벤트 41/6008 총 {0}건, 시간 근접 그룹 {1}개(중복 가능, 실제 종료 횟수 아님)" -f $unexpected.Count,$shutdownGroups.Count) '41/6008은 한 번의 종료를 함께 가리킬 수 있습니다. 해당 기록만으로 블루스크린이나 원인을 확정할 수 없습니다.'
}
if ($storageErrors.Count -gt 0) {
    Add-Issue 'high' 'STORAGE_EVENTS' '저장장치 관련 오류 기록 발견' ("최근 {0}일간 저장장치/파일시스템 이벤트 {1}건" -f $Days,$storageErrors.Count) '데이터를 먼저 백업하세요. 장치 이상 시 쓰기 복구 명령을 무작정 실행하지 마세요.'
}
$observations['eventWindowDays'] = $Days
$observations['bugchecks'] = @($crashes | Select-Object -First 30)
$observations['unexpectedShutdowns'] = @($unexpected | Select-Object -First 30)
$observations['shutdownGroups'] = @($shutdownGroups | Select-Object -First 30)
$observations['storageEvents'] = @($storageErrors | Select-Object -First 30)
$observations['eventEvidence'] = @($evidence | Select-Object -First 1500)
$observations['eventCollection'] = $eventResult.status
$collectionStatus['events'] = $observations['eventCollection']
$observations['eventCollectionLimit'] = 1500
$observations['eventTimeMeaning'] = 'System event recorded time, not verified incident time'
# Zero is not verified when logs are unavailable, nor complete when capped.
$bugCountLabel = if ($eventQueryFailed) { '확인 불가' } elseif ($eventsTruncated) { '{0}건 (수집분)' -f $crashes.Count } else { '{0}건' -f $crashes.Count }
$shutdownCountLabel = if ($eventQueryFailed) { '확인 불가' } elseif ($eventsTruncated) { '{0}건 신호 (수집분)' -f $unexpected.Count } else { '{0}건 신호 (중복 가능)' -f $unexpected.Count }
$storageCountLabel = if ($eventQueryFailed) { '확인 불가' } elseif ($eventsTruncated) { '{0}건 (수집분)' -f $storageErrors.Count } else { '{0}건' -f $storageErrors.Count }

# Optional, strictly read-only battery and Windows Update observations.
# A missing battery on a desktop is normal; a denied CIM query is NOT absence.
. (Join-Path $PSScriptRoot 'telemetry_analysis.ps1')
$batteryRaw = @()
$batteryQueryStatus = 'unavailable'
try {
    $batteryRaw = @(Get-CimInstance -ClassName Win32_Battery -ErrorAction Stop | Where-Object { $null -ne $_ })
    $batteryQueryStatus = if ($batteryRaw.Count -gt 0) { 'collected' } else { 'empty' }
} catch {
    [void]$limits.Add('배터리: Windows 관리 인터페이스 조회 불가. 배터리가 없다는 판정은 아닙니다.')
}
$batterySnapshot = ConvertTo-PcCareBatterySnapshot -Batteries $batteryRaw -QueryStatus $batteryQueryStatus
$observations['battery'] = $batterySnapshot
$collectionStatus['battery'] = $batterySnapshot.status

# Official WindowsUpdateClient installation records 19/20 from the System log.
# Recorded event timestamps are not proof that a specific update caused any crash.
$updateResult = Invoke-PcCareEventQuery -MaxEvents 300 -Query {
    Get-WinEvent -FilterHashtable @{ LogName='System'; ProviderName='Microsoft-Windows-WindowsUpdateClient'; Id=19,20; StartTime=$start } -MaxEvents 300 -ErrorAction Stop
}
$updateEvidence = @(ConvertTo-PcCareUpdateEvidence -Events @($updateResult.events))
$updateFailures = @($updateEvidence | Where-Object { $_.kind -eq 'update_installation_failure_record' })
$updateSuccesses = @($updateEvidence | Where-Object { $_.kind -eq 'update_installation_success_record' })
$observations['windowsUpdate'] = [ordered]@{
    status = $updateResult.status
    scope = 'System/WindowsUpdateClient installation event IDs 19/20 only'
    evidence = @($updateEvidence | Select-Object -First 300)
    installationFailureRecords = [int]$updateFailures.Count
    installationSuccessRecords = [int]$updateSuccesses.Count
    timeBasis = 'event_recorded_time'
}
$collectionStatus['windowsUpdate'] = $updateResult.status
if ($updateResult.status -eq 'unavailable') {
    [void]$limits.Add('Windows 업데이트 설치 이벤트 조회 불가. 설치 기록이 없다고 판단하지 않습니다.')
} elseif ($updateResult.status -eq 'truncated') {
    [void]$limits.Add('Windows 업데이트 이벤트 300건 조회 한도에 도달했습니다. 전체 기간을 대표하지 않습니다.')
}
if ($updateFailures.Count -gt 0) {
    Add-Issue 'medium' 'WINDOWS_UPDATE_FAILURE_RECORD' 'Windows 업데이트 설치 실패 기록' ("최근 {0}일간 설치 실패 관련 이벤트 {1}건(확인된 수집분)" -f $Days,$updateFailures.Count) 'Windows 업데이트 기록을 확인하세요. 이 이벤트만으로 블루스크린이나 고장 원인을 확정할 수 없습니다.'
}

# Optional indication; third-party AV users must not be labeled unprotected.
$defender = Safe-Collect { Get-MpComputerStatus -ErrorAction Stop } 'Microsoft Defender' 'defender'
if ($null -ne $defender) {
    $observations['defender'] = @{ available=$true; antivirusEnabled=([bool]$defender.AntivirusEnabled); realtime=([bool]$defender.RealTimeProtectionEnabled) }
    if (-not [bool]$defender.RealTimeProtectionEnabled) {
        [void]$limits.Add('Microsoft Defender 실시간 보호가 비활성일 수 있습니다. 타사 백신 사용 여부는 별도 확인이 필요합니다.')
    }
} else { $observations['defender'] = @{ available=$false; antivirusEnabled=$null; realtime=$null } }

$observations['collectionStatus'] = $collectionStatus
# Local evidence rules do not make a hardware diagnosis or confirm causality.
. (Join-Path $PSScriptRoot 'incident_analysis.ps1')
$incidentAssessment = Get-PcCareIncidentAssessment -EventEvidence $evidence -DiskObservations @($diskData.ToArray()) -EventCollectionStatus $eventResult.status -UpdateEvidence $updateEvidence -UpdateCollectionStatus $updateResult.status

$assessment = if (@($issues | Where-Object {$_.severity -eq 'high'}).Count -gt 0) { '위험 신호' }
              elseif (@($issues | Where-Object {$_.severity -eq 'medium'}).Count -gt 0) { '주의 필요' }
              elseif ($limits.Count -gt 0) { '확인 불완전' }
              else { '관찰 범위 내 특이사항 없음' }
$report = [ordered]@{
    product='AXMART PC CARE'; version='0.1.0-alpha'; mode='read-only'
    generatedAt=(Get-Date).ToString('yyyy-MM-dd HH:mm:ss zzz')
    assessment=$assessment; observations=$observations
    analysis=$incidentAssessment
    issues=@($issues.ToArray()); limitations=@($limits.ToArray())
    privacy='보고서에는 사용자 이름, 디스크 일련번호, 이벤트 원문을 의도적으로 수집하지 않습니다. 로컬에만 저장됩니다.'
    caution='진단은 제한적인 신호 검사이며 하드웨어 정상 보증 또는 자동 수리 성공 보증이 아닙니다.'
}
$jsonText = $report | ConvertTo-Json -Depth 10

$cards = New-Object 'System.Collections.Generic.List[string]'
foreach ($i in $report.issues) {
    $tone = if ($i.severity -eq 'high') { 'danger' } else { 'warn' }
    [void]$cards.Add(('<article class="issue {0}"><div class="tag">{1}</div><h3>{2}</h3><p>{3}</p><p class="advice">권장: {4}</p></article>' -f $tone, (Esc $i.severity), (Esc $i.title), (Esc $i.explanation), (Esc $i.recommendation)))
}
if ($cards.Count -eq 0) { [void]$cards.Add('<article class="issue"><h3>이번 검사 범위에서 명확한 위험 이벤트를 찾지 못했습니다.</h3><p>모든 하드웨어가 정상임을 보장하는 결과는 아닙니다.</p></article>') }
$analysisCards = New-Object 'System.Collections.Generic.List[string]'
foreach ($finding in $report.analysis.findings) {
    [void]$analysisCards.Add(('<article class="issue"><div class="tag">{0}</div><h3>{1}</h3><p>{2}</p><p>다른 가능성: {3}</p><p class="advice">다음 단계: {4}</p></article>' -f (Esc $finding.evidenceLevel),(Esc $finding.title),(Esc $finding.interpretation),(Esc $finding.alternative),(Esc $finding.nextAction)))
}
if ($analysisCards.Count -eq 0) {
    [void]$analysisCards.Add('<p>현재 증거에서 특정 원인을 결론 내릴 수 없습니다. 정보 부재를 정상으로 해석하지 마세요.</p>')
}
foreach ($caveat in $report.analysis.caveats) {
    [void]$analysisCards.Add(('<p class="small">제한사항: {0}</p>' -f (Esc $caveat)))
}
$rows = New-Object 'System.Collections.Generic.List[string]'
foreach ($v in $report.observations.volumes) {
    [void]$rows.Add(('<tr><td>{0}</td><td>{1}GB</td><td>{2}%</td></tr>' -f (Esc $v.drive), (Esc $v.remainingGB), (Esc $v.freePercent)))
}
if ($rows.Count -eq 0) { [void]$rows.Add('<tr><td colspan="3">저장장치 공간 정보를 확인하지 못했습니다.</td></tr>') }
$diskRows = New-Object 'System.Collections.Generic.List[string]'
foreach ($d in $report.observations.physicalDisks) {
    $health = if ($d.status -eq 'Healthy') { '정상 신호(보증 아님)' }
              elseif ($d.status -in @('Warning','Unhealthy')) { '경고: ' + [string]$d.status }
              else { '확인 불가: ' + [string]$d.status }
    $wear = if ($null -eq $d.wearPercent) { '미지원' } else { ('{0}%' -f $d.wearPercent) }
    $temp = if ($null -eq $d.temperatureC) { '미지원' } else { ('{0}°C' -f $d.temperatureC) }
    [void]$diskRows.Add(('<tr><td>{0}</td><td>{1}</td><td>{2}</td><td>{3}</td></tr>' -f (Esc $d.model),(Esc $health),(Esc $wear),(Esc $temp)))
}
if ($diskRows.Count -eq 0) { [void]$diskRows.Add('<tr><td colspan="4">물리 저장장치 정보를 읽지 못했습니다. 정상 판정이 아닙니다.</td></tr>') }
$crashRows = New-Object 'System.Collections.Generic.List[string]'
foreach ($e in @($report.observations.bugchecks | Select-Object -First 15)) {
    [void]$crashRows.Add(('<tr><td>{0}</td><td>{1}</td></tr>' -f (Esc $e.time),(Esc $e.stopCode)))
}
if ($crashRows.Count -eq 0) {
    $crashMessage = if ($eventQueryFailed) { '시스템 로그를 조회하지 못해 블루스크린 기록을 판단할 수 없습니다.' }
                    else { '확인한 System 이벤트 범위에서 BugCheck 기록이 없었습니다. 블루스크린이 없었다는 보증은 아닙니다.' }
    [void]$crashRows.Add(('<tr><td colspan="2">{0}</td></tr>' -f (Esc $crashMessage)))
}
$batteryNote = if ($batterySnapshot.status -eq 'not_present') { '배터리 장치 미감지(데스크톱일 수 있음)' }
               elseif ($batterySnapshot.status -eq 'unavailable') { '배터리 데이터 조회 불가(배터리 없음이 아님)' }
               else { ('배터리 {0}개 보고됨' -f $batterySnapshot.batteryCount) }
$batteryRows = New-Object 'System.Collections.Generic.List[string]'
foreach ($batterySample in $batterySnapshot.samples) {
    $chargeLabel = if ($null -eq $batterySample.chargeRemainingPercent) { '확인 불가' } else { ('{0}% (현재 충전량)' -f $batterySample.chargeRemainingPercent) }
    $designLabel = if ($null -eq $batterySample.designCapacityMWh) { '미지원' } else { ('{0} mWh' -f $batterySample.designCapacityMWh) }
    $fullLabel = if ($null -eq $batterySample.fullChargeCapacityMWh) { '미지원' } else { ('{0} mWh' -f $batterySample.fullChargeCapacityMWh) }
    [void]$batteryRows.Add(('<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>' -f (Esc $chargeLabel),(Esc $designLabel),(Esc $fullLabel)))
}
if ($batteryRows.Count -eq 0) {
    [void]$batteryRows.Add(('<tr><td colspan="3">{0}</td></tr>' -f (Esc $batteryNote)))
}
$updateLabel = if ($updateResult.status -eq 'unavailable') { '조회 불가' }
               elseif ($updateResult.status -eq 'truncated') { '수집 일부 (300건 제한)' }
               elseif ($updateResult.status -eq 'no matching events') { '해당 기간 내 일치 기록 없음 (정상 보증 아님)' }
               else { '조회됨' }
$updateRows = New-Object 'System.Collections.Generic.List[string]'
foreach ($updateItem in @($updateEvidence | Select-Object -First 30)) {
    $eventLabel = if ($updateItem.kind -eq 'update_installation_failure_record') { '설치 실패 기록' } else { '설치 성공 기록' }
    [void]$updateRows.Add(('<tr><td>{0}</td><td>{1}</td></tr>' -f (Esc $updateItem.recordedAt),(Esc $eventLabel)))
}
if ($updateRows.Count -eq 0) {
    [void]$updateRows.Add(('<tr><td colspan="2">{0}</td></tr>' -f (Esc $updateLabel)))
}
$limRows = New-Object 'System.Collections.Generic.List[string]'
foreach ($l in $report.limitations) { [void]$limRows.Add('<li>'+(Esc $l)+'</li>') }
if ($limRows.Count -eq 0) { [void]$limRows.Add('<li>보고된 접근 제한이 없습니다. 다만 검사 범위 밖의 문제는 있을 수 있습니다.</li>') }
$color = if ($assessment -eq '위험 신호') {'#ff6a8a'} elseif ($assessment -eq '주의 필요') {'#f6cb73'} else {'#79e6b9'}
# Static local HTML: all dynamic fields encoded, no remote scripts, fonts, or data requests.
$html = @"
<!doctype html><html lang="ko"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>AXMART PC CARE | 진단 보고서</title><style>
:root{font-family:system-ui,'Malgun Gothic',sans-serif;background:#0b0b13;color:#f5f2ff;color-scheme:dark}
*{box-sizing:border-box}body{margin:0;background:radial-gradient(ellipse at 80% 0%,#2a123d,#0b0b13 45%);min-height:100vh}
main{max-width:990px;margin:auto;padding:42px 24px 80px}header{display:flex;justify-content:space-between;align-items:center;border-bottom:1px solid #363040;padding-bottom:22px}
.brand{font-weight:900;letter-spacing:-.5px;font-size:22px}.brand b{color:#ca8dff}.brand em{font-style:normal;color:#78f0b6;font-size:12px}
h1{font-size:clamp(30px,5vw,54px);letter-spacing:-2px;margin:32px 0 12px}.lead{color:#bcb7c8;line-height:1.7}
.status{display:inline-block;border:1px solid $color;padding:11px 18px;border-radius:999px;color:$color;font-weight:800;margin:20px 0}
.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:12px;margin:20px 0 40px}
.tile,section{background:#171520;border:1px solid #31293a;border-radius:18px;padding:22px}.tile strong{display:block;font-size:28px;margin-top:8px}
.small{color:#a7a0b4;font-size:12px;line-height:1.7}h2{font-size:22px;margin:0 0 16px}section{margin:18px 0}.issue{padding:16px 18px;background:#211b2b;border:1px solid #3b304a;border-radius:13px;margin:12px 0}
.issue.danger{border-left:4px solid #ff6a8a}.issue.warn{border-left:4px solid #f6cb73}.issue h3{margin:6px 0}.issue p{color:#c4c0cc;line-height:1.6;font-size:14px}.issue .advice{color:#a5f0d0}
.tag{font-size:11px;color:#cba4ff;letter-spacing:.1em;text-transform:uppercase}.scroll-table{overflow-x:auto}table{width:100%;border-collapse:collapse}td,th{padding:12px;border-bottom:1px solid #33303a;text-align:left}th{color:#aaa3b8}
footer{color:#a7a0b4;font-size:12px;line-height:1.7;margin-top:30px}li{line-height:1.7;color:#c1b9cf}
</style></head><body><main><header><div class="brand"><b>AX</b>MART <em>PC CARE</em></div><div class="small">READ-ONLY / v0.1-alpha</div></header>
<h1>내 PC 건강검진 결과<span style="color:#a977e4">.</span></h1><p class="lead">시스템 로그와 저장장치 상태를 읽어 주요 위험 신호를 점검했습니다. 파일 삭제나 시스템 설정 변경 없이 검사했습니다.</p>
<div class="status">$(Esc $assessment)</div>
<div class="grid"><div class="tile"><div class="small">블루스크린 관련 기록</div><strong>$(Esc $bugCountLabel)</strong></div><div class="tile"><div class="small">비정상 종료 이벤트</div><strong>$(Esc $shutdownCountLabel)</strong></div><div class="tile"><div class="small">저장장치 오류 이벤트</div><strong>$(Esc $storageCountLabel)</strong></div><div class="tile"><div class="small">발견한 주요 주의사항</div><strong>$($issues.Count)건</strong></div></div>
<section><h2>진단 결과와 권장 조치</h2>$($cards -join "`n")</section>
<section><h2>원인 후보와 확인 한계</h2><p class="small">자동 규칙 해설이며 고장 원인 확정, 부품 교체 판정 또는 수리 보증이 아닙니다.</p>$($analysisCards -join "`n")</section>
<section><h2>드라이브 공간</h2><div class="scroll-table"><table><thead><tr><th>드라이브</th><th>여유 공간</th><th>여유 비율</th></tr></thead><tbody>$($rows -join "`n")</tbody></table></div></section>
<section><h2>물리 저장장치 상태</h2><p class="small">Windows에서 제공한 상태 신호이며 실제 SSD/HDD 수명 또는 정상 작동을 보증하지 않습니다. 마모율/온도는 드라이버 지원 기기에서만 표시됩니다.</p><div class="scroll-table"><table><thead><tr><th>장치</th><th>상태 신호</th><th>마모율</th><th>온도</th></tr></thead><tbody>$($diskRows -join "`n")</tbody></table></div></section>
<section><h2>배터리 정보</h2><p class="small">$(Esc $batteryNote). 현재 충전량은 배터리 수명이나 건강도가 아닙니다. 용량 데이터는 기기/Windows 지원 여부에 따라 누락될 수 있습니다.</p><div class="scroll-table"><table><thead><tr><th>현재 충전량</th><th>설계 용량</th><th>완충 용량</th></tr></thead><tbody>$($batteryRows -join [Environment]::NewLine)</tbody></table></div></section>
<section><h2>Windows 업데이트 설치 기록</h2><p class="small">System WindowsUpdateClient 이벤트 19/20에 한정합니다. 기록 시각은 설치 작업의 기록 시각이며 블루스크린 발생 시각·원인이 아닙니다. $(Esc $updateLabel).</p><div class="scroll-table"><table><thead><tr><th>기록 시각</th><th>관측 상태</th></tr></thead><tbody>$($updateRows -join [Environment]::NewLine)</tbody></table></div></section>
<section><h2>최근 블루스크린 상세</h2><p class="small">Windows System 로그 중 BugCheck 관련 기록 최대 15건입니다. 표의 시각은 이벤트가 기록된 시간이며 실제 충돌 시각이 아닐 수 있습니다. STOP 코드는 원인을 확정하지 않습니다.</p><div class="scroll-table"><table><thead><tr><th>기록 시각</th><th>STOP 코드(추출값)</th></tr></thead><tbody>$($crashRows -join "`n")</tbody></table></div></section>
<section><h2>검사 한계</h2><ul>$($limRows -join "`n")</ul><p class="small">Windows $(Esc $report.observations.windows.name) · 검사 기간: $Days 일 · 생성 $(Esc $report.generatedAt)</p></section>
<footer>AXMART PC CARE v0.1 테스트용 제품. 하드웨어 자체 검사, 메모리 덤프 분석, 악성코드 전수 검사, 수리 성공 보증은 제공하지 않습니다. BitLocker 복구키는 절대 입력하거나 이 도구에 저장하지 마세요.<br>결과는 이 기기에만 저장하며 인터넷으로 전송하지 않습니다. 판매 준비 전 실제 Windows 환경 검증이 필요합니다.</footer></main></body></html>
"@
# Do not report success until both outputs are safely persisted.
# A writable directory is not guaranteed by New-Item; a USB may be read-only.
. (Join-Path $PSScriptRoot 'report_io.ps1')
$reportCandidates = @(Join-Path $root 'REPORTS')
$documents = [Environment]::GetFolderPath('MyDocuments')
if (-not [string]::IsNullOrWhiteSpace($documents)) {
    $reportCandidates += (Join-Path $documents 'AXMART-PC-CARE-Reports')
}
$savedFiles = Save-PcCareReportPair -JsonText $jsonText -HtmlText $html -Candidates $reportCandidates -FileBase $base
$jsonPath = $savedFiles.json
$htmlPath = $savedFiles.html
Write-Host ('Assessment: ' + $assessment) -ForegroundColor Green
Write-Host ('Saved JSON : ' + $jsonPath)
Write-Host ('Saved report: ' + $htmlPath)
try { Start-Process -FilePath $htmlPath -ErrorAction Stop | Out-Null }
catch { Write-Host 'Report saved. Open the HTML file manually.' }
