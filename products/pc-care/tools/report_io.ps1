# AXMART PC CARE: only locally-generated JSON/HTML report pair persistence.
# Never delete pre-existing files or write to Windows system configuration.
# Reject known cloud-sync folders, network paths and directory reparse ancestors.
# This cannot detect every third-party sync client; only private local directories are candidates.

# Mapping a network share to X: must not bypass the UNC and cloud-sync checks.
function Test-PcCareLocalDriveType {
    [CmdletBinding()]
    param([System.IO.DriveType]$DriveType)
    return ($DriveType -eq [System.IO.DriveType]::Fixed -or
            $DriveType -eq [System.IO.DriveType]::Removable)
}

function Test-PcCarePrivateReportFolder {
    [CmdletBinding()]
    param([string]$Folder)
    if ([string]::IsNullOrWhiteSpace($Folder) -or -not [System.IO.Path]::IsPathRooted($Folder)) { return $false }
    try {
        $full = [System.IO.Path]::GetFullPath($Folder).TrimEnd([char[]]@('\','/'))
        if ($full.StartsWith('\\', [System.StringComparison]::Ordinal)) { return $false }
        $driveRoot = [System.IO.Path]::GetPathRoot($full)
        if ([string]::IsNullOrWhiteSpace($driveRoot)) { return $false }
        $drive = [System.IO.DriveInfo]::new($driveRoot)
        if (-not (Test-PcCareLocalDriveType -DriveType $drive.DriveType)) { return $false }
        # Standard Windows cloud-sync folder names, including OneDrive - Organization.
        if ($full -match '(?i)(?:^|[\\/])(?:OneDrive(?: - [^\\/]+)?|Dropbox|Google Drive|GoogleDrive|iCloudDrive|Box Sync|BoxDrive)(?:[\\/]|$)') { return $false }
        foreach ($name in @('OneDrive','OneDriveCommercial','OneDriveConsumer','Dropbox','GoogleDrive','iCloudDrive')) {
            $syncFolder = [Environment]::GetEnvironmentVariable($name)
            if ([string]::IsNullOrWhiteSpace($syncFolder)) { continue }
            $syncRoot = [System.IO.Path]::GetFullPath($syncFolder).TrimEnd([char[]]@('\','/'))
            if ([string]::Equals($full, $syncRoot, [System.StringComparison]::OrdinalIgnoreCase) -or
                $full.StartsWith(($syncRoot + [System.IO.Path]::DirectorySeparatorChar), [System.StringComparison]::OrdinalIgnoreCase)) {
                return $false
            }
        }
        # Existing directory junctions/symlinks can redirect otherwise local paths.
        $part = $full
        while (-not [string]::IsNullOrWhiteSpace($part)) {
            if ([System.IO.File]::Exists($part)) { return $false }
            if ([System.IO.Directory]::Exists($part)) {
                $attr = [System.IO.File]::GetAttributes($part)
                if (($attr -band [System.IO.FileAttributes]::ReparsePoint) -ne 0) { return $false }
            }
            $parent = [System.IO.Path]::GetDirectoryName($part)
            if ([string]::IsNullOrWhiteSpace($parent) -or $parent -eq $part) { break }
            $part = $parent
        }
        return $true
    } catch { return $false }
}

function Save-PcCareReportPair {
    param([string]$JsonText, [string]$HtmlText, [string[]]$Candidates, [string]$FileBase)
    # Never let a caller-provided name resolve outside a nominated REPORTS folder.
    # Production uses pc-care-YYYYMMDD-HHmmss-GUID8; fixtures use fixture-one, etc.
    if ([string]::IsNullOrWhiteSpace($FileBase) -or
        $FileBase -cnotmatch '^[A-Za-z0-9][A-Za-z0-9_-]{0,79}$') {
        throw 'Invalid report file base: path separators, dots and reserved characters are not allowed.'
    }
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    foreach ($folder in $Candidates) {
        if (-not (Test-PcCarePrivateReportFolder -Folder $folder)) {
            Write-Warning '동기화 또는 외부/연결 경로에는 개인 PC 진단 보고서를 자동 저장하지 않습니다.'
            continue
        }
        $tempJson = Join-Path $folder ($FileBase + '.json.partial')
        $tempHtml = Join-Path $folder ($FileBase + '.html.partial')
        $finalJson = Join-Path $folder ($FileBase + '.json')
        $finalHtml = Join-Path $folder ($FileBase + '.html')
        # Existing report names are not owned by this invocation and MUST remain untouched.
        if ((Test-Path -LiteralPath $finalJson) -or (Test-Path -LiteralPath $finalHtml) -or
            (Test-Path -LiteralPath $tempJson) -or (Test-Path -LiteralPath $tempHtml)) {
            throw ('Report filename collision: ' + $FileBase)
        }
        $movedJson = $false
        $movedHtml = $false
        $ownedJson = $false
        $ownedHtml = $false
        try {
            New-Item -ItemType Directory -Path $folder -Force -ErrorAction Stop | Out-Null
            # CreateNew is atomic: concurrent writers and existing .partial files
            # cannot be overwritten between Test-Path and the actual file open.
            $jsonStream = [System.IO.File]::Open($tempJson, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
            $ownedJson = $true
            try {
                $jsonBytes = $utf8.GetBytes($JsonText)
                $jsonStream.Write($jsonBytes, 0, $jsonBytes.Length)
                $jsonStream.Flush()
            } finally { $jsonStream.Dispose() }
            $htmlStream = [System.IO.File]::Open($tempHtml, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
            $ownedHtml = $true
            try {
                $htmlBytes = $utf8.GetBytes($HtmlText)
                $htmlStream.Write($htmlBytes, 0, $htmlBytes.Length)
                $htmlStream.Flush()
            } finally { $htmlStream.Dispose() }
            # File.Move refuses an existing final path; never use overwrite/Force.
            [System.IO.File]::Move($tempJson, $finalJson)
            $movedJson = $true
            [System.IO.File]::Move($tempHtml, $finalHtml)
            $movedHtml = $true
            return @{ json=$finalJson; html=$finalHtml }
        } catch {
            Write-Warning ('보고서 저장 위치 사용 불가: {0} ({1})' -f $folder,$_.Exception.GetType().Name)
            # Delete only paths created or moved by THIS attempt. A conflicting
            # .partial path belongs to another run and must never be removed.
            if ($ownedJson) { Remove-Item -LiteralPath $tempJson -Force -ErrorAction SilentlyContinue }
            if ($ownedHtml) { Remove-Item -LiteralPath $tempHtml -Force -ErrorAction SilentlyContinue }
            if ($movedJson) { Remove-Item -LiteralPath $finalJson -Force -ErrorAction SilentlyContinue }
            if ($movedHtml) { Remove-Item -LiteralPath $finalHtml -Force -ErrorAction SilentlyContinue }
        }
    }
    throw '보고서 JSON/HTML 저장에 실패했습니다. 원본 시스템에는 변경을 가하지 않았습니다. 저장 공간 및 쓰기 권한을 확인하세요.'
}
