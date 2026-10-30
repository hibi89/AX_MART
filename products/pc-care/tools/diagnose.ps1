# AXMART PC CARE v0.1 | Windows PowerShell 5.1 | READ-ONLY DIAGNOSTICS
# It never schedules tasks, fixes disks, changes services, or sends telemetry.
[CmdletBinding()]
param([int]$Days = 30, [switch]$PassThru, [switch]$NoOpenReport)
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
# Do not let stale/partial query output masquerade as observed evidence when
# collection failed or returned no matching events.
$events = @()
if ($eventResult.status -in @('collected','truncated')) {
    $events = @($eventResult.events)
}
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
$updateInputEvents = @()
if ($updateResult.status -in @('collected','truncated')) {
    $updateInputEvents = @($updateResult.events)
}
$updateEvidence = @(ConvertTo-PcCareUpdateEvidence -Events $updateInputEvents)
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

# Driver status: query only non-zero Configuration Manager codes, never device IDs.
. (Join-Path $PSScriptRoot 'pnp_analysis.ps1')
$pnpRaw = @()
$pnpQueryStatus = 'unavailable'
try {
    $pnpRaw = @(Get-CimInstance -ClassName Win32_PnPEntity -Property ConfigManagerErrorCode,PNPClass -Filter 'ConfigManagerErrorCode > 0' -ErrorAction Stop | Select-Object -First 101)
    $pnpQueryStatus = if ($pnpRaw.Count -ge 101) { 'truncated' }
                      elseif ($pnpRaw.Count -eq 0) { 'no matching devices' }
                      else { 'collected' }
} catch {
    [void]$limits.Add('장치 구성 코드: PnP 관리 인터페이스 조회 불가. 드라이버 상태를 정상으로 판정하지 않습니다.')
}
$pnpSummary = ConvertTo-PcCarePnPSummary -Devices $pnpRaw -QueryStatus $pnpQueryStatus -MaxSamples 30
$observations['driverDevices'] = $pnpSummary
$collectionStatus['driverDevices'] = $pnpSummary.status
if ($pnpSummary.status -eq 'truncated') {
    [void]$limits.Add('장치 구성 코드 관측이 표시 상한(30개)에 도달했습니다. 기기 전체 오류 목록을 대표하지 않습니다.')
}
$activePnPErrors = @($pnpSummary.samples | Where-Object { $_.configurationCode -ne 22 })
if ($activePnPErrors.Count -gt 0) {
    Add-Issue 'medium' 'PNP_CONFIGURATION' '장치 구성 상태 확인 필요' ("Windows 장치 구성 오류 코드가 표본에서 {0}건 관측됐습니다 (코드 22 비활성화는 제외)." -f $activePnPErrors.Count) '장치 관리자에서 코드를 확인하세요. 무인 드라이버 설치·제거·DDU 실행은 하지 않습니다.'
}

# Event time proximity is not event causation or confirmed crash occurrence time.
. (Join-Path $PSScriptRoot 'recorded_timeline.ps1')
$recordedTimeline = Get-PcCareRecordedTimeline -SystemEvidence $evidence -UpdateEvidence $updateEvidence -MaxEntries 80 -WindowMinutes 15 -SystemCollectionStatus $eventResult.status -UpdateCollectionStatus $updateResult.status
$observations['recordedTimeline'] = $recordedTimeline
if ($recordedTimeline.status -eq 'truncated') {
    [void]$limits.Add('시간축 시각화는 최신 기록 80건만 표시합니다. 오래된 기록은 누락될 수 있습니다.')
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
$incidentAssessment = Get-PcCareIncidentAssessment -EventEvidence $evidence -DiskObservations @($diskData.ToArray()) -DiskCollectionStatus ([string]$collectionStatus['physicalDisks']) -EventCollectionStatus $eventResult.status -UpdateEvidence $updateEvidence -UpdateCollectionStatus $updateResult.status -PnPSummary $pnpSummary

$assessment = if (@($issues | Where-Object {$_.severity -eq 'high'}).Count -gt 0) { '위험 신호' }
              elseif (@($issues | Where-Object {$_.severity -eq 'medium'}).Count -gt 0) { '주의 필요' }
              elseif ($limits.Count -gt 0) { '확인 불완전' }
              else { '관찰 범위 내 특이사항 없음' }
$report = [ordered]@{
    schemaVersion=1; product='AXMART PC CARE'; version='0.1.0-alpha'; mode='read-only'
    generatedAt=(Get-Date).ToString('yyyy-MM-dd HH:mm:ss zzz')
    assessment=$assessment; observations=$observations
    analysis=$incidentAssessment
    issues=@($issues.ToArray()); limitations=@($limits.ToArray())
    privacy='보고서에는 사용자 이름, 디스크 일련번호, 이벤트 원문을 의도적으로 수집하지 않습니다. 로컬에만 저장됩니다.'
    caution='진단은 제한적인 신호 검사이며 하드웨어 정상 보증 또는 자동 수리 성공 보증이 아닙니다.'
}
# Privacy-filtered consultation view intentionally excludes raw details from the full diagnostic JSON.
. (Join-Path $PSScriptRoot 'consultation_report.ps1')
$consultationSummary = Get-PcCareConsultationSummary -Report $report
$report['consultation'] = $consultationSummary
# QR-compatible share TEXT only; do not copy the payload into diagnostic JSON.
. (Join-Path $PSScriptRoot 'share_payload.ps1')
$sharePayload = Get-PcCareSharePayload -Summary $consultationSummary
$report['sharePreview'] = [ordered]@{
    status = $sharePayload.status
    byteCount = $sharePayload.byteCount
    maxUtf8Bytes = $sharePayload.maxUtf8Bytes
    qrImageGenerated = $false
    payloadStoredInJson = $false
}
# Inline only licensed local assets so REPORTS still works after USB removal.
# QR code image is NEVER generated automatically; user must click inside the expanded preview.
$qrInlineScripts = ''
$qrEnabled = $false
try {
    $qrLibraryPath = Join-Path $root 'ui/qrcode.min.js'
    $qrUiPath = Join-Path $root 'ui/qr_ui.js'
    $qrLicensePath = Join-Path $root 'ui/QR_CODE_LICENSE.txt'
    if (-not (Test-Path -LiteralPath $qrLicensePath -PathType Leaf)) {
        throw 'QR license missing'
    }
    $qrVendorJs = [System.IO.File]::ReadAllText($qrLibraryPath, [System.Text.Encoding]::UTF8)
    $qrUserJs = [System.IO.File]::ReadAllText($qrUiPath, [System.Text.Encoding]::UTF8)
    $qrLicenseText = [System.IO.File]::ReadAllText($qrLicensePath, [System.Text.Encoding]::UTF8)
    if ($qrVendorJs.Length -gt 100000 -or $qrUserJs.Length -gt 20000 -or
        [string]::IsNullOrWhiteSpace($qrVendorJs) -or
        [string]::IsNullOrWhiteSpace($qrUserJs) -or
        $qrVendorJs -match '(?i)</script' -or $qrUserJs -match '(?i)</script' -or
        $qrLicenseText -notmatch 'MIT License' -or $qrLicenseText -match '\*/') {
        throw 'Invalid embedded QR script'
    }
    # Include the complete MIT attribution in each standalone saved HTML file.
    $qrInlineScripts = '<script>/*' + $qrLicenseText + '*/' + $qrVendorJs + '</script><script>' + $qrUserJs + '</script>'
    $qrEnabled = $true
} catch {
    # QR is optional: preserve the local read-only report and manual share text.
    $qrInlineScripts = ''
    $qrEnabled = $false
}
$report['sharePreview']['qrImageSupported'] = $qrEnabled
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
$pnpRows = New-Object 'System.Collections.Generic.List[string]'
foreach ($deviceState in @($pnpSummary.samples | Select-Object -First 30)) {
    $deviceLabel = if ($deviceState.interpretation -eq 'device_disabled') { '비활성화(의도적 가능)' }
                   elseif ($deviceState.interpretation -eq 'driver_not_installed_record') { '드라이버 미설치 기록' }
                   elseif ($deviceState.interpretation -eq 'device_cannot_start_record') { '장치 시작 불가 기록' }
                   else { '장치 구성 점검 필요' }
    [void]$pnpRows.Add(('<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>' -f (Esc $deviceState.category),(Esc $deviceState.configurationCode),(Esc $deviceLabel)))
}
if ($pnpRows.Count -eq 0) {
    $pnpEmptyLabel = if ($pnpSummary.status -eq 'unavailable') { '장치 코드 조회 불가(정상 판정 아님)' } else { '수집 범위에 일치 기록 없음(정상 보증 아님)' }
    [void]$pnpRows.Add(('<tr><td colspan="3">{0}</td></tr>' -f (Esc $pnpEmptyLabel)))
}
$timelineRows = New-Object 'System.Collections.Generic.List[string]'
foreach ($window in @($recordedTimeline.windows | Select-Object -Last 30)) {
    $codes = @($window.kinds) -join ', '
    [void]$timelineRows.Add(('<tr><td>{0}</td><td>{1}</td><td>{2}</td></tr>' -f (Esc $window.firstRecordedUtc),(Esc $window.evidenceCount),(Esc $codes)))
}
if ($timelineRows.Count -eq 0) {
    [void]$timelineRows.Add('<tr><td colspan="3">표시할 이벤트 기록 시각이 없습니다. 조회 실패와 구별해 확인하세요.</td></tr>')
}
$limRows = New-Object 'System.Collections.Generic.List[string]'
foreach ($l in $report.limitations) { [void]$limRows.Add('<li>'+(Esc $l)+'</li>') }
if ($limRows.Count -eq 0) { [void]$limRows.Add('<li>보고된 접근 제한이 없습니다. 다만 검사 범위 밖의 문제는 있을 수 있습니다.</li>') }
$color = if ($assessment -eq '위험 신호') {'#ff6a8a'} elseif ($assessment -eq '주의 필요') {'#f6cb73'} else {'#79e6b9'}
# Separate, bounded consultation renderer; browser print/PDF uses CSS only.
. (Join-Path $PSScriptRoot 'consultation_render.ps1')
$consultationHtml = ConvertTo-PcCareConsultationHtml -Summary $consultationSummary
. (Join-Path $PSScriptRoot 'share_preview.ps1')
$sharePreviewHtml = ConvertTo-PcCareSharePreviewHtml -Share $sharePayload -QrSupported $qrEnabled
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
.consult-sheet{border:1px solid #4c4055;background:#181825;padding:24px;border-radius:17px;margin:26px 0}
.consult-top{display:flex;justify-content:space-between;align-items:center;gap:12px}.consult-mark{font-weight:900;letter-spacing:-.3px}.consult-mark b{color:#b7f2d6}.consult-version{font-size:11px;color:#a99fb7}
.consult-sheet h2{font-size:26px;margin:18px 0 8px}.consult-disclaimer,.consult-hint{font-size:11px;line-height:1.5;color:#b2a8c0}
.consult-facts{display:grid;grid-template-columns:repeat(2,minmax(0,1fr));gap:10px;margin:17px 0}.consult-facts>div{padding:11px 13px;border:1px solid #464052;border-radius:9px}
.consult-facts span{display:block;font-size:11px;color:#b4acc2}.consult-facts strong{display:block;margin-top:4px;font-size:13px}
.consult-symptom,.consult-group{padding:11px 0;border-top:1px solid #3f374a;overflow-wrap:anywhere}.consult-symptom{font-size:12px}
.consult-group h3{font-size:15px;margin:3px 0 7px}.consult-group p,.consult-group li{font-size:12px;line-height:1.5}
.consult-group ul,.consult-group ol{margin:6px 0 2px;padding-left:20px}.consult-group li{margin:3px 0}
.consult-table{width:100%;table-layout:fixed;border-collapse:collapse}.consult-table th,.consult-table td{border-bottom:1px solid #484051;padding:6px;text-align:left;font-size:11px;overflow-wrap:anywhere}
.consult-bottom{border-top:1px solid #484051;margin-top:10px;padding-top:10px;font-size:10px;line-height:1.5;color:#b9b1c4}
.screen-help{font-size:12px;color:#b9b1c4}
.share-panel{padding:22px;margin:18px 0;background:#171520;border:1px solid #454052;border-radius:16px}
.share-panel h2{margin:0 0 8px}.share-panel summary{cursor:pointer;color:#b7f2d6;font-weight:700;padding:12px 0}
.share-disclosure textarea{display:block;width:100%;margin:8px 0 12px;padding:12px;border:1px solid #60506e;border-radius:8px;background:#101019;color:#f2f1f6;font-family:'Malgun Gothic',monospace;font-size:12px;line-height:1.5;resize:vertical}
.share-select{background:#6f53a0;border:0;border-radius:8px;color:white;padding:10px 14px;cursor:pointer;font-weight:700}
.share-select:focus-visible,.share-panel summary:focus-visible{outline:2px solid #a1edc8;outline-offset:3px}
.qr-holder{display:inline-block;background:#fff;padding:24px;border-radius:10px;margin-top:8px;max-width:100%}
.qr-holder:empty{display:none}.qr-holder img,.qr-holder canvas,.qr-holder svg{display:block;max-width:100%;height:auto}
.qr-generate{margin:10px 8px 8px 0}
/* Local-only report navigation: no JS, network, cookies or tracking. */
.skip-link{position:absolute;left:-9999px;top:auto}
.skip-link:focus{left:16px;top:16px;z-index:99;background:#231e30;color:#fff;padding:12px;border-radius:8px}
.quicknav{position:sticky;top:0;z-index:6;display:flex;flex-wrap:wrap;gap:7px;padding:12px;margin:12px 0 26px;border:1px solid #453553;border-radius:14px;background:#171320}
.quicknav a{padding:8px 10px;border-radius:9px;color:#e0c9fb;text-decoration:none;font-size:12px;font-weight:650}
.quicknav a:hover,.quicknav a:focus-visible{outline:2px solid #b8efcb;outline-offset:2px;color:#fff;background:#463256}
section[id]{scroll-margin-top:98px}
@media(max-width:650px){main{padding:20px 12px 48px}header{gap:10px}.quicknav{position:static;padding:9px;gap:5px}.quicknav a{font-size:11px;padding:8px}.consult-facts{grid-template-columns:1fr}}

@page{size:A4 portrait;margin:10mm}
@media print{
  html,body{background:#fff!important;color:#161616!important;font-family:'Malgun Gothic',Arial,sans-serif!important;color-scheme:light!important}
  main{width:100%!important;max-width:none!important;margin:0!important;padding:0!important}
  main>:not(#consultation-print){display:none!important}
  #consultation-print{display:block!important;margin:0!important;padding:0!important;background:#fff!important;border:0!important;border-radius:0!important;color:#161616!important;box-shadow:none!important}
  #consultation-print *{color:#161616!important;background:transparent!important;box-shadow:none!important}
  #consultation-print h2{font-size:18pt!important;margin:7pt 0 4pt!important}
  #consultation-print .consult-top{display:flex!important}
  #consultation-print .consult-mark{font-size:15pt!important}
  #consultation-print .consult-version,#consultation-print .consult-disclaimer,#consultation-print .consult-hint{font-size:8pt!important}
  #consultation-print .consult-facts{grid-template-columns:repeat(4,minmax(0,1fr))!important;gap:4pt!important;margin:8pt 0!important}
  #consultation-print .consult-facts>div{border:1px solid #bbb!important;padding:4pt!important}
  #consultation-print .consult-facts span{font-size:7pt!important}
  #consultation-print .consult-facts strong{font-size:8pt!important;overflow-wrap:anywhere}
  #consultation-print .consult-symptom,#consultation-print .consult-group{padding:4pt 0!important;border-color:#ccc!important;break-inside:avoid!important;page-break-inside:avoid!important}
  #consultation-print .consult-symptom,#consultation-print .consult-group p,#consultation-print .consult-group li{font-size:8.5pt!important;line-height:1.24!important}
  #consultation-print .consult-group h3{font-size:10pt!important;margin:2pt 0 3pt!important}
  #consultation-print .consult-group ul,#consultation-print .consult-group ol{margin:2pt 0!important}
  #consultation-print .consult-group li{margin:1pt 0!important}
  #consultation-print .consult-table th,#consultation-print .consult-table td{font-size:8pt!important;padding:3pt!important;border-color:#ddd!important}
  #consultation-print .consult-bottom{font-size:7.5pt!important;line-height:1.3!important;border-color:#ccc!important;padding-top:5pt!important}
}
</style></head><body><main><header><div class="brand"><b>AX</b>MART <em>PC CARE</em></div><div class="small">READ-ONLY / v0.1-alpha</div></header>
<a class="skip-link" href="#consultation-print">수리 상담표로 바로가기</a>
<h1>내 PC 건강검진 결과<span style="color:#a977e4">.</span></h1><p class="lead">시스템 로그와 저장장치 상태를 읽어 주요 위험 신호를 점검했습니다. 파일 삭제나 시스템 설정 변경 없이 검사했습니다.</p>
<div class="status">$(Esc $assessment)</div>
<nav class="quicknav" aria-label="진단 보고서 바로가기"><a href="#consultation-print">수리 상담표</a><a href="#incident-analysis">원인 해설</a><a href="#storage-health">저장장치</a><a href="#update-records">업데이트</a><a href="#driver-codes">장치 상태</a><a href="#incident-timeline">기록 시간축</a><a href="#limitations">검사 한계</a></nav>
<p class="screen-help">수리점 제출용 1페이지 요약은 아래에서 확인하세요. 브라우저에서 Ctrl+P → PDF로 저장하면 요약표만 인쇄됩니다. 별도 서버 전송은 없습니다.</p>
$consultationHtml
$sharePreviewHtml
<div class="grid"><div class="tile"><div class="small">블루스크린 관련 기록</div><strong>$(Esc $bugCountLabel)</strong></div><div class="tile"><div class="small">비정상 종료 이벤트</div><strong>$(Esc $shutdownCountLabel)</strong></div><div class="tile"><div class="small">저장장치 오류 이벤트</div><strong>$(Esc $storageCountLabel)</strong></div><div class="tile"><div class="small">발견한 주요 주의사항</div><strong>$($issues.Count)건</strong></div></div>
<section><h2>진단 결과와 권장 조치</h2>$($cards -join "`n")</section>
<section id="incident-analysis"><h2>원인 후보와 확인 한계</h2><p class="small">자동 규칙 해설이며 고장 원인 확정, 부품 교체 판정 또는 수리 보증이 아닙니다.</p>$($analysisCards -join "`n")</section>
<section><h2>드라이브 공간</h2><div class="scroll-table"><table><thead><tr><th>드라이브</th><th>여유 공간</th><th>여유 비율</th></tr></thead><tbody>$($rows -join "`n")</tbody></table></div></section>
<section id="storage-health"><h2>물리 저장장치 상태</h2><p class="small">Windows에서 제공한 상태 신호이며 실제 SSD/HDD 수명 또는 정상 작동을 보증하지 않습니다. 마모율/온도는 드라이버 지원 기기에서만 표시됩니다.</p><div class="scroll-table"><table><thead><tr><th>장치</th><th>상태 신호</th><th>마모율</th><th>온도</th></tr></thead><tbody>$($diskRows -join "`n")</tbody></table></div></section>
<section><h2>배터리 정보</h2><p class="small">$(Esc $batteryNote). 현재 충전량은 배터리 수명이나 건강도가 아닙니다. 용량 데이터는 기기/Windows 지원 여부에 따라 누락될 수 있습니다.</p><div class="scroll-table"><table><thead><tr><th>현재 충전량</th><th>설계 용량</th><th>완충 용량</th></tr></thead><tbody>$($batteryRows -join [Environment]::NewLine)</tbody></table></div></section>
<section id="update-records"><h2>Windows 업데이트 설치 기록</h2><p class="small">System WindowsUpdateClient 이벤트 19/20에 한정합니다. 기록 시각은 설치 작업의 기록 시각이며 블루스크린 발생 시각·원인이 아닙니다. $(Esc $updateLabel).</p><div class="scroll-table"><table><thead><tr><th>기록 시각</th><th>관측 상태</th></tr></thead><tbody>$($updateRows -join [Environment]::NewLine)</tbody></table></div></section>
<section id="driver-codes"><h2>장치 구성 코드</h2><p class="small">Windows PnP Configuration Manager 코드 중 0이 아닌 값만 조회합니다. 코드 22 비활성화는 의도적일 수 있습니다. 장치 고장·드라이버 문제 원인을 확정하지 않습니다.</p><div class="scroll-table"><table><thead><tr><th>범주</th><th>코드</th><th>관측 해석</th></tr></thead><tbody>$($pnpRows -join [Environment]::NewLine)</tbody></table></div></section>
<section id="incident-timeline"><h2>사건 기록 시간축</h2><p class="small">최신 이벤트 80건의 기록 시각 기준 15분 내 관측을 묶었습니다. 실제 충돌 시각·사건 횟수·업데이트 인과관계를 보증하지 않습니다.</p><div class="scroll-table"><table><thead><tr><th>시작 기록 UTC</th><th>기록 수</th><th>사건 분류</th></tr></thead><tbody>$($timelineRows -join [Environment]::NewLine)</tbody></table></div></section>
<section><h2>최근 블루스크린 상세</h2><p class="small">Windows System 로그 중 BugCheck 관련 기록 최대 15건입니다. 표의 시각은 이벤트가 기록된 시간이며 실제 충돌 시각이 아닐 수 있습니다. STOP 코드는 원인을 확정하지 않습니다.</p><div class="scroll-table"><table><thead><tr><th>기록 시각</th><th>STOP 코드(추출값)</th></tr></thead><tbody>$($crashRows -join "`n")</tbody></table></div></section>
<section id="limitations"><h2>검사 한계</h2><ul>$($limRows -join "`n")</ul><p class="small">Windows $(Esc $report.observations.windows.name) · 검사 기간: $Days 일 · 생성 $(Esc $report.generatedAt)</p></section>
<footer>AXMART PC CARE v0.1 테스트용 제품. 하드웨어 자체 검사, 메모리 덤프 분석, 악성코드 전수 검사, 수리 성공 보증은 제공하지 않습니다. BitLocker 복구키는 절대 입력하거나 이 도구에 저장하지 마세요.<br>결과는 이 기기에만 저장하며 인터넷으로 전송하지 않습니다. 판매 준비 전 실제 Windows 환경 검증이 필요합니다.</footer></main>$qrInlineScripts</body></html>
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
# Explicit test-only receipt lets Windows smoke validate THIS exact report pair.
# The normal double-click experience remains unchanged and opens local HTML.
if ($PassThru) {
    Write-Output ([pscustomobject]@{ json=$jsonPath; html=$htmlPath })
}
if (-not $NoOpenReport) {
    try { Start-Process -FilePath $htmlPath -ErrorAction Stop | Out-Null }
    catch { Write-Host 'Report saved. Open the HTML file manually.' }
}
