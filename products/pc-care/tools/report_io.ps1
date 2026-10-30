# AXMART PC CARE: only locally-generated JSON/HTML report pair persistence.
# Never delete pre-existing files or write to Windows system configuration.
function Save-PcCareReportPair {
    param([string]$JsonText, [string]$HtmlText, [string[]]$Candidates, [string]$FileBase)
    $utf8 = New-Object System.Text.UTF8Encoding($false)
    foreach ($folder in $Candidates) {
        if ([string]::IsNullOrWhiteSpace($folder)) { continue }
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
