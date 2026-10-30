# AXMART PC CARE v0.1 | Windows PowerShell 5.1 | READ-ONLY DIAGNOSTICS
# It never schedules tasks, fixes disks, changes services, or sends telemetry.
[CmdletBinding()]
param([int]$Days = 30)
$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'
if ($Days -lt 1 -or $Days -gt 90) { throw 'Days must be between 1 and 90.' }
$root = Split-Path -Parent $PSScriptRoot
$reportDir = Join-Path $root 'REPORTS'
try { New-Item -ItemType Directory -Path $reportDir -Force -ErrorAction Stop | Out-Null }
catch {
    $reportDir = Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'AXMART-PC-CARE-Reports'
    New-Item -ItemType Directory -Path $reportDir -Force -ErrorAction Stop | Out-Null
}
$stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
$base = 'pc-care-{0}-{1}' -f $stamp, ([guid]::NewGuid().ToString('N').Substring(0,8))
$jsonPath = Join-Path $reportDir ($base + '.json')
$htmlPath = Join-Path $reportDir ($base + '.html')
$issues = New-Object 'System.Collections.Generic.List[object]'
$limits = New-Object 'System.Collections.Generic.List[string]'
$observations = [ordered]@{}

function Add-Issue([string]$Severity, [string]$Code, [string]$Title, [string]$Explain, [string]$Advice) {
    [void]$issues.Add([ordered]@{ severity=$Severity; code=$Code; title=$Title; explanation=$Explain; recommendation=$Advice })
}
function Safe-Collect([scriptblock]$Action, [string]$Label) {
    try { return (& $Action) } catch {
        [void]$limits.Add(('{0}: 데이터를 읽지 못했습니다 ({1})' -f $Label, $_.Exception.GetType().Name))
        return $null
    }
}
function Esc([object]$Value) {
    return [System.Net.WebUtility]::HtmlEncode([string]$Value)
}

Write-Host '[AXMART PC CARE] Read-only health check...' -ForegroundColor Cyan
$os = Safe-Collect { Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop } 'Windows 버전'
if ($null -ne $os) {
    $observations['windows'] = @{ name=[string]$os.Caption; version=[string]$os.Version; build=[string]$os.BuildNumber; bootTime=([string]$os.LastBootUpTime) }
}
else { $observations['windows'] = @{ name='확인 불가'; version=''; build=''; bootTime='' } }

# Logical volume free space; do not collect absolute file paths or filenames.
$volumes = @(Safe-Collect { @(Get-CimInstance -ClassName Win32_LogicalDisk -Filter 'DriveType=3' -ErrorAction Stop) } '디스크 여유 공간')
$volData = New-Object 'System.Collections.Generic.List[object]'
foreach ($v in $volumes) {
    if ($null -eq $v -or $null -eq $v.DeviceID -or [double]$v.Size -le 0) { continue }
    $remaining = [double]$v.FreeSpace
    $capacity = [double]$v.Size
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
$disks = @(Safe-Collect { @(Get-PhysicalDisk -ErrorAction Stop) } '저장장치 건강 상태')
$diskData = New-Object 'System.Collections.Generic.List[object]'
foreach ($disk in $disks) {
    if ($null -eq $disk) { continue }
    $state = [string]$disk.HealthStatus
    $item = [ordered]@{ model=[string]$disk.FriendlyName; status=$state; operationalStatus=([string]($disk.OperationalStatus -join ',')); wearPercent=$null; temperatureC=$null }
    try {
        $counter = $disk | Get-StorageReliabilityCounter -ErrorAction Stop
        if ($null -ne $counter) {
            if ($null -ne $counter.Wear -and $counter.Wear -ne 0) { $item.wearPercent=[int]$counter.Wear }
            if ($null -ne $counter.Temperature -and $counter.Temperature -ne 0) { $item.temperatureC=[int]$counter.Temperature }
        }
    } catch { } # Optional device-dependent data, do not claim pass.
    [void]$diskData.Add($item)
    if ($state -in @('Warning','Unhealthy')) {
        Add-Issue 'high' 'DISK_HEALTH' '저장장치 상태 경고' ("{0}: {1}" -f $disk.FriendlyName,$state) '디스크 수리를 시도하기 전에 데이터를 다른 저장장치에 백업하고 저장장치 점검을 받으세요.'
    } elseif ($state -ne 'Healthy') {
        [void]$limits.Add(('저장장치 {0}: 상태 확인 불가/미지원 ({1})' -f $disk.FriendlyName,$state))
    }
}
if ($diskData.Count -eq 0) { [void]$limits.Add('장치별 SMART/저장장치 상태를 확인하지 못했습니다.') }
$observations['physicalDisks'] = @($diskData.ToArray())

# Event 1001 is a BSOD only when its provider reports a bugcheck.
$start = (Get-Date).AddDays(-$Days)
$eventQueryFailed = $false
try {
    $events = @(Get-WinEvent -FilterHashtable @{ LogName='System'; StartTime=$start; Id=41,6008,1001,7,51,55,129,153,157 } -MaxEvents 1500 -ErrorAction Stop)
} catch {
    if ($_.FullyQualifiedErrorId -match 'NoMatchingEventsFound' -or $_.Exception.Message -match 'No events were found|조건에 맞는 이벤트') {
        $events = @()
    } else {
        $events = @()
        $eventQueryFailed = $true
        [void]$limits.Add('시스템 이벤트: 데이터 접근이 제한되었습니다. 블루스크린 유무를 판단할 수 없습니다.')
    }
}
$crashes = New-Object 'System.Collections.Generic.List[object]'
$unexpected = New-Object 'System.Collections.Generic.List[object]'
$storageErrors = New-Object 'System.Collections.Generic.List[object]'
foreach ($e in $events) {
    if ($null -eq $e) { continue }
    $provider = [string]$e.ProviderName
    $when = ([datetime]$e.TimeCreated).ToString('yyyy-MM-dd HH:mm')
    if ($e.Id -eq 1001 -and ($provider -match 'BugCheck|SystemErrorReporting')) {
        $code = '확인 불가'
        try {
            if ([string]$e.Message -match '(?i)0x[0-9a-f]{8}') { $code = $matches[0].ToUpperInvariant() }
        } catch { }
        [void]$crashes.Add(@{ time=$when; stopCode=$code })
    }
    elseif (($e.Id -eq 41 -and $provider -match 'Kernel-Power') -or ($e.Id -eq 6008 -and $provider -match 'EventLog')) {
        [void]$unexpected.Add(@{ time=$when; eventId=[int]$e.Id })
    }
    elseif (($e.Id -in @(7,51,55,129,153,157)) -and ($provider -match 'disk|stor|nvme|ntfs|volmgr|iaStor')) {
        [void]$storageErrors.Add(@{ time=$when; eventId=[int]$e.Id; source=$provider })
    }
}
# Logs are capped to keep the tool responsive; warn if the query may be truncated.
$eventsTruncated = ($events.Count -ge 1500)
if ($eventsTruncated) {
    [void]$limits.Add('시스템 이벤트는 최근 1,500건까지만 수집했습니다. 전체 검사 기간의 이벤트를 모두 확인한 결과가 아닐 수 있습니다.')
}
# 41 and 6008 can refer to the same outage, hence no false 'X crashes' diagnosis.
if ($crashes.Count -gt 0) {
    $severity = if ($crashes.Count -ge 3) { 'high' } else { 'medium' }
    Add-Issue $severity 'BUGCHECK' '최근 블루스크린 기록 발견' ("최근 {0}일간 BugCheck 기록 {1}건" -f $Days,$crashes.Count) 'STOP 코드를 확인하고 최근 설치한 드라이버·업데이트 변경 이력과 연관성을 조사하세요. 단일 원인으로 단정하지 않습니다.'
}
if ($unexpected.Count -gt 0) {
    Add-Issue 'medium' 'UNEXPECTED_REBOOT' '비정상 종료 기록 발견' ("최근 {0}일간 이벤트 {1}건(중복 종료 가능)" -f $Days,$unexpected.Count) '정전, 강제 종료, 과열, 드라이버 오류 등 여러 원인을 점검하세요. 41번 이벤트만으로 블루스크린 확정 불가.'
}
if ($storageErrors.Count -gt 0) {
    Add-Issue 'high' 'STORAGE_EVENTS' '저장장치 관련 오류 이벤트 발견' ("최근 {0}일간 저장장치/파일시스템 이벤트 {1}건" -f $Days,$storageErrors.Count) '중요 데이터 우선 백업. 물리 장애 가능성이 있으면 CHKDSK 복구 옵션을 무작정 실행하지 마세요.'
}
$observations['eventWindowDays'] = $Days
$observations['bugchecks'] = @($crashes.ToArray())
$observations['unexpectedShutdowns'] = @($unexpected.ToArray() | Select-Object -First 30)
$observations['storageEvents'] = @($storageErrors.ToArray() | Select-Object -First 30)
$observations['eventCollection'] = if ($eventQueryFailed) { 'unavailable' } elseif ($eventsTruncated) { 'truncated' } elseif ($events.Count -eq 0) { 'no matching events' } else { 'collected' }
# Never show zero as a verified count when the System log could not be read.
$bugCountLabel = if ($eventQueryFailed) { '확인 불가' } elseif ($eventsTruncated) { '{0}건 (수집분)' -f $crashes.Count } else { '{0}건' -f $crashes.Count }
$shutdownCountLabel = if ($eventQueryFailed) { '확인 불가' } elseif ($eventsTruncated) { '{0}건 (수집분)' -f $unexpected.Count } else { '{0}건' -f $unexpected.Count }
$storageCountLabel = if ($eventQueryFailed) { '확인 불가' } elseif ($eventsTruncated) { '{0}건 (수집분)' -f $storageErrors.Count } else { '{0}건' -f $storageErrors.Count }

# Optional indication; third-party AV users must not be labeled unprotected.
$defender = Safe-Collect { Get-MpComputerStatus -ErrorAction Stop } 'Microsoft Defender'
if ($null -ne $defender) {
    $observations['defender'] = @{ available=$true; antivirusEnabled=([bool]$defender.AntivirusEnabled); realtime=([bool]$defender.RealTimeProtectionEnabled) }
    if (-not [bool]$defender.RealTimeProtectionEnabled) {
        [void]$limits.Add('Microsoft Defender 실시간 보호가 비활성일 수 있습니다. 타사 백신 사용 여부는 별도 확인이 필요합니다.')
    }
} else { $observations['defender'] = @{ available=$false; antivirusEnabled=$null; realtime=$null } }

$assessment = if (@($issues | Where-Object {$_.severity -eq 'high'}).Count -gt 0) { '위험 신호' }
              elseif (@($issues | Where-Object {$_.severity -eq 'medium'}).Count -gt 0) { '주의 필요' }
              elseif ($limits.Count -gt 0) { '확인 불완전' }
              else { '관찰 범위 내 특이사항 없음' }
$report = [ordered]@{
    product='AXMART PC CARE'; version='0.1.0-alpha'; mode='read-only'
    generatedAt=(Get-Date).ToString('yyyy-MM-dd HH:mm:ss zzz')
    assessment=$assessment; observations=$observations
    issues=@($issues.ToArray()); limitations=@($limits.ToArray())
    privacy='보고서에는 사용자 이름, 디스크 일련번호, 이벤트 원문을 의도적으로 수집하지 않습니다. 로컬에만 저장됩니다.'
    caution='진단은 제한적인 신호 검사이며 하드웨어 정상 보증 또는 자동 수리 성공 보증이 아닙니다.'
}
$report | ConvertTo-Json -Depth 8 | Out-File -LiteralPath $jsonPath -Encoding utf8 -Force

$cards = New-Object 'System.Collections.Generic.List[string]'
foreach ($i in $report.issues) {
    $tone = if ($i.severity -eq 'high') { 'danger' } else { 'warn' }
    [void]$cards.Add(('<article class="issue {0}"><div class="tag">{1}</div><h3>{2}</h3><p>{3}</p><p class="advice">권장: {4}</p></article>' -f $tone, (Esc $i.severity), (Esc $i.title), (Esc $i.explanation), (Esc $i.recommendation)))
}
if ($cards.Count -eq 0) { [void]$cards.Add('<article class="issue"><h3>이번 검사 범위에서 명확한 위험 이벤트를 찾지 못했습니다.</h3><p>모든 하드웨어가 정상임을 보장하는 결과는 아닙니다.</p></article>') }
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
<section><h2>드라이브 공간</h2><div class="scroll-table"><table><thead><tr><th>드라이브</th><th>여유 공간</th><th>여유 비율</th></tr></thead><tbody>$($rows -join "`n")</tbody></table></div></section>
<section><h2>물리 저장장치 상태</h2><p class="small">Windows에서 제공한 상태 신호이며 실제 SSD/HDD 수명 또는 정상 작동을 보증하지 않습니다. 마모율/온도는 드라이버 지원 기기에서만 표시됩니다.</p><div class="scroll-table"><table><thead><tr><th>장치</th><th>상태 신호</th><th>마모율</th><th>온도</th></tr></thead><tbody>$($diskRows -join "`n")</tbody></table></div></section>
<section><h2>최근 블루스크린 상세</h2><p class="small">Windows System 로그의 BugCheck 관련 공급자 기록 중 최대 15건을 표시합니다. STOP 코드는 원인을 확정하지 않습니다.</p><div class="scroll-table"><table><thead><tr><th>기록 시각</th><th>STOP 코드(추출값)</th></tr></thead><tbody>$($crashRows -join "`n")</tbody></table></div></section>
<section><h2>검사 한계</h2><ul>$($limRows -join "`n")</ul><p class="small">Windows $(Esc $report.observations.windows.name) · 검사 기간: $Days 일 · 생성 $(Esc $report.generatedAt)</p></section>
<footer>AXMART PC CARE v0.1 테스트용 제품. 하드웨어 자체 검사, 메모리 덤프 분석, 악성코드 전수 검사, 수리 성공 보증은 제공하지 않습니다. BitLocker 복구키는 절대 입력하거나 이 도구에 저장하지 마세요.<br>결과는 이 기기에만 저장하며 인터넷으로 전송하지 않습니다. 판매 준비 전 실제 Windows 환경 검증이 필요합니다.</footer></main></body></html>
"@
[System.IO.File]::WriteAllText($htmlPath, $html, (New-Object System.Text.UTF8Encoding($false)))
Write-Host ('Assessment: ' + $assessment) -ForegroundColor Green
Write-Host ('Saved JSON : ' + $jsonPath)
Write-Host ('Saved report: ' + $htmlPath)
try { Start-Process -FilePath $htmlPath -ErrorAction Stop | Out-Null }
catch { Write-Host 'Report saved. Open the HTML file manually.' }
