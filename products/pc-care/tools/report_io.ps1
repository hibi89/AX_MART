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
        try {
            New-Item -ItemType Directory -Path $folder -Force -ErrorAction Stop | Out-Null
            [System.IO.File]::WriteAllText($tempJson, $JsonText, $utf8)
            [System.IO.File]::WriteAllText($tempHtml, $HtmlText, $utf8)
            Move-Item -LiteralPath $tempJson -Destination $finalJson -ErrorAction Stop
            $movedJson = $true
            Move-Item -LiteralPath $tempHtml -Destination $finalHtml -ErrorAction Stop
            $movedHtml = $true
            return @{ json=$finalJson; html=$finalHtml }
        } catch {
            Write-Warning ('보고서 저장 위치 사용 불가: {0} ({1})' -f $folder,$_.Exception.GetType().Name)
            # Remove generated temporary files; delete final names only when WE moved them.
            foreach ($owned in @($tempJson,$tempHtml)) {
                Remove-Item -LiteralPath $owned -Force -ErrorAction SilentlyContinue
            }
            if ($movedJson) { Remove-Item -LiteralPath $finalJson -Force -ErrorAction SilentlyContinue }
            if ($movedHtml) { Remove-Item -LiteralPath $finalHtml -Force -ErrorAction SilentlyContinue }
        }
    }
    throw '보고서 JSON/HTML 저장에 실패했습니다. 원본 시스템에는 변경을 가하지 않았습니다. 저장 공간 및 쓰기 권한을 확인하세요.'
}
