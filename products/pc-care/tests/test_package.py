"""Static packaging and safety gates; NOT a Windows runtime/PowerShell test."""
from pathlib import Path
import unittest
import re

ROOT = Path(__file__).resolve().parents[1]

class PackageTests(unittest.TestCase):
    def test_files_exist(self):
        for name in ["README.md","START_PC_CARE.cmd","RUN_HEALTH_CHECK.cmd", "RUN_SAFE_REPAIR.cmd", "tools/diagnose.ps1", "tools/repair.ps1", "recovery/WINRE_READ_ONLY.cmd", "docs/SAFETY.md", "docs/PRODUCT_SCOPE.md"]:
            with self.subTest(name=name):
                self.assertTrue((ROOT/name).is_file(), name)

    def test_home_menu_is_non_admin_offline_and_fail_closed(self):
        home = (ROOT / 'START_PC_CARE.cmd').read_text(encoding='utf-8')
        packager = (ROOT / 'tools/release.py').read_text(encoding='utf-8')
        self.assertIn('DisableDelayedExpansion', home)
        self.assertIn(r'%SystemRoot%\System32\choice.exe', home)
        self.assertIn('if not exist "%PC_CARE_CHOICE%" goto NO_CHOICE', home)
        self.assertIn('/C 123450 /N', home)
        self.assertIn('call "%PC_CARE_ROOT%RUN_HEALTH_CHECK.cmd"', home)
        self.assertIn('call "%PC_CARE_ROOT%RUN_SELF_TEST.cmd"', home)
        self.assertIn('if not exist "%PC_CARE_ROOT%RUN_HEALTH_CHECK.cmd" goto MISSING', home)
        self.assertIn('if not exist "%PC_CARE_ROOT%RUN_SELF_TEST.cmd" goto MISSING', home)
        self.assertIn("'START_PC_CARE.cmd'", packager)
        for forbidden in ['RUN_SAFE_REPAIR.cmd', 'tools\\repair.ps1', 'Start-Process', 'runas', 'powershell.exe', 'curl ', 'Invoke-WebRequest', 'diskpart ', 'bcdedit /set', 'del /', 'rmdir ']:
            with self.subTest(forbidden=forbidden):
                self.assertNotIn(forbidden.lower(), home.lower())

    def test_h08_local_history_compare_is_opt_in(self):
        home = (ROOT/'START_PC_CARE.cmd').read_text(encoding='utf-8')
        html = (ROOT/'ui/history_compare.html').read_text(encoding='utf-8')
        js = (ROOT/'ui/history_compare.js').read_text(encoding='utf-8')
        packager = (ROOT/'tools/release.py').read_text(encoding='utf-8')
        self.assertIn('if "%PC_CARE_PICK%"=="5" goto HISTORY', home)
        self.assertIn('if "%PC_CARE_PICK%"=="6" exit /b 0', home)
        self.assertIn(r'start "" "%PC_CARE_ROOT%ui\history_compare.html"', home)
        self.assertIn("connect-src 'none'", html)
        self.assertIn("selectionRevision", js)
        self.assertIn('calendar.getUTCDate()!==day', js)
        self.assertIn('offHours>14', js)
        self.assertIn('safeAssessment=r=>', js)
        self.assertNotIn('Date.parse(r.generatedAt)', js)
        history_fixture = (ROOT/'tests/test_history_compare.cjs').read_text(encoding='utf-8')
        self.assertIn('strict date rejects impossible calendar and impossible offset', history_fixture)
        self.assertIn('unrecognized assessment text never appears in comparison', history_fixture)
        self.assertIn("result.added===null", js)
        self.assertIn("result.diskComparable", js)
        self.assertIn('physicalDisks==="collected"', js)
        compare_fixture = (ROOT/'tests/test_history_compare.cjs').read_text(encoding='utf-8')
        self.assertIn("missing/empty/unsupported physical disk evidence", compare_fixture)
        self.assertIn("complete same-count storage observations", compare_fixture)
        self.assertIn("if (requestRevision !== selectionRevision) return", js)
        self.assertIn("if (requestRevision === selectionRevision) output.textContent", js)
        browser_fixture = (ROOT/'tests/test_history_dom.cjs').read_text(encoding='utf-8')
        self.assertIn("DOM flow: file changed during reading never displays stale result", browser_fixture)
        self.assertIn("DOM flow: stale parse error does not erase revised selection status", browser_fixture)
        workflow = (ROOT.parent.parent/'.github/workflows/pc-care-windows-synthetic.yml').read_text(encoding='utf-8')
        self.assertIn("tests/test_history_dom.cjs", workflow)
        self.assertIn('src="./history_compare.js"', html)
        self.assertIn('type="file"', html)
        self.assertIn('output.textContent = lines.join', js)
        self.assertIn('f.size > 2000000', js)
        self.assertIn('schemaVersion!==1', js)
        for forbidden in ('fetch(', 'XMLHttpRequest', 'sendBeacon', 'WebSocket', 'localStorage', 'sessionStorage', 'innerHTML'):
            self.assertNotIn(forbidden, js)
        self.assertIn("'ui/history_compare.html'", packager)
        self.assertIn("'ui/history_compare.js'", packager)

    def test_normal_check_is_read_only(self):
        text = (ROOT/'tools/diagnose.ps1').read_text(encoding='utf-8-sig')
        # No change-enabling cmdlets or dangerous commands in scanner.
        banned = [r'\bset-itemproperty\b',r'\bformat-volume\b',r'\bdisable-bitlocker\b',r'\bstart-process\s+[^\r\n]*\bdism\.exe',r'\brestart-computer\b',r'\binvoke-webrequest\b',r'\binvoke-restmethod\b',r'\bset-mppreference\b',r'\bchkdsk\s+[a-z]:\s+/[frx]']
        for pattern in banned:
            with self.subTest(pattern=pattern):
                self.assertNotRegex(text.lower(), pattern)
        self.assertIn("ConvertTo-Json", text)
        self.assertIn("[System.Net.WebUtility]::HtmlEncode", text)
        self.assertIn("Get-WinEvent", text)
        self.assertIn("Get-PhysicalDisk", text)
        self.assertIn("Get-CimInstance", text)
        normalizer = (ROOT/'tools/event_analysis.ps1').read_text(encoding='utf-8-sig')
        self.assertIn("NoMatchingEventsFound", normalizer)
        self.assertIn("mode='read-only'", text)
        # All report cleanup is isolated, never embedded in a scanning command.
        self.assertNotIn("Remove-Item", text)
        report_io = (ROOT/'tools/report_io.ps1').read_text(encoding='utf-8-sig')
        self.assertIn('[System.IO.FileMode]::CreateNew', report_io)
        self.assertIn('[System.IO.File]::Move($tempJson, $finalJson)', report_io)
        self.assertIn('[System.IO.File]::Move($tempHtml, $finalHtml)', report_io)
        self.assertIn('if ($ownedJson) { Remove-Item -LiteralPath $tempJson', report_io)
        self.assertIn('if ($ownedHtml) { Remove-Item -LiteralPath $tempHtml', report_io)
        self.assertIn("if ($movedJson) { Remove-Item -LiteralPath $finalJson", report_io)
        self.assertIn("if ($movedHtml) { Remove-Item -LiteralPath $finalHtml", report_io)
        self.assertIn("Report filename collision:", report_io)
        self.assertNotIn('[System.IO.File]::WriteAllText($tempJson', report_io)
        self.assertNotIn('Move-Item -LiteralPath $tempJson', report_io)

    def test_explicit_repair_approval_and_bounded_commands(self):
        text = (ROOT/'tools/repair.ps1').read_text(encoding='utf-8-sig')
        self.assertIn("Read-Host 'Type BACKUP", text)
        self.assertIn("Read-Host 'Type REPAIR", text)
        self.assertIn("IsInRole", text)
        self.assertIn("/RestoreHealth", text)
        self.assertIn("/scannow", text)
        for banned in ["format.exe", "bootrec", "bcdboot", "restart-computer", "Clear-Disk", "Remove-Partition", "manage-bde -off"]:
            self.assertNotIn(banned.lower(), text.lower())

    def test_recovery_is_not_boot_image(self):
        text=(ROOT/'recovery/WINRE_READ_ONLY.cmd').read_text()
        self.assertIn("bcdedit /enum",text)
        self.assertIn("manage-bde -status",text)
        self.assertNotIn("bcdedit /set",text)
        self.assertNotIn("diskpart /s",text)
        self.assertNotIn("bootrec /fix",text)
        self.assertNotIn("format ",text.lower())

    def test_event_provider_allowlist_and_schema_version(self):
        event = (ROOT/'tools/event_analysis.ps1').read_text(encoding='utf-8-sig')
        diag = (ROOT/'tools/diagnose.ps1').read_text(encoding='utf-8-sig')
        smoke = (ROOT/'tests/windows_smoke.ps1').read_text(encoding='utf-8-sig')
        fixture = (ROOT/'tests/event_analysis.tests.ps1').read_text(encoding='utf-8-sig')
        self.assertIn("^(?:BugCheck|WER-SystemErrorReporting|Microsoft-Windows-", event)
        self.assertIn("^(?:Microsoft-Windows-)?Kernel-Power$", event)
        self.assertIn("$provider -match '^EventLog$'", event)
        self.assertIn("Microsoft-Windows-Storage-Storport|iaStor", event)
        self.assertNotIn("'BugCheck|SystemErrorReporting'", event)
        self.assertNotIn("'disk|stor|nvme|ntfs|volmgr|iaStor'", event)
        for bad in ("FakeBugCheck","Kernel-Power-Helper","EventLogProxy","InventoryStore","diskmon"):
            self.assertIn(bad, fixture)
        self.assertIn("schemaVersion=1; product='AXMART PC CARE'", diag)
        self.assertIn("$json.schemaVersion -ne 1", smoke)

    def test_missing_event_data_is_not_reported_as_zero(self):
        text = (ROOT/'tools/diagnose.ps1').read_text(encoding='utf-8-sig')
        self.assertIn("$observations['eventCollection']", text)
        self.assertIn("'truncated'", text)
        self.assertIn("if ($eventQueryFailed) { '확인 불가' }", text)
        self.assertIn("Esc $bugCountLabel", text)
        self.assertIn("Esc $storageCountLabel", text)

    def test_unknown_storage_blocks_approved_repair(self):
        text = (ROOT/'tools/repair.ps1').read_text(encoding='utf-8-sig')
        self.assertIn("$disks.Count -eq 0", text)
        self.assertIn("HealthStatus -ne 'Healthy'", text)
        self.assertIn("Repair blocked (fail-closed)", text)
        self.assertLess(text.index("Get-PhysicalDisk"), text.index("Read-Host 'Type BACKUP"))
        self.assertLess(text.index("Read-Host 'Type REPAIR"), text.index("/RestoreHealth"))

    def test_winre_log_failure_and_privacy_notice(self):
        text = (ROOT/'recovery/WINRE_READ_ONLY.cmd').read_text()
        self.assertIn('if errorlevel 1 goto VIEWONLY', text)
        self.assertIn('manage-bde -status >>"%LOG%" 2>&1', text)
        self.assertIn('bcdedit /enum >>"%LOG%" 2>&1', text)
        self.assertIn("PRIVACY:", text)

    def test_windows_parser_smoke_is_opt_in(self):
        text = (ROOT/'tests/windows_smoke.ps1').read_text(encoding='utf-8-sig')
        self.assertIn('Parser]::ParseFile', text)
        self.assertIn('[switch]$RunReadOnly', text)
        self.assertNotIn('repair.ps1 -', text)

    def test_read_only_smoke_uses_own_receipt_not_other_run_report(self):
        diagnostic = (ROOT/'tools/diagnose.ps1').read_text(encoding='utf-8-sig')
        smoke = (ROOT/'tests/windows_smoke.ps1').read_text(encoding='utf-8-sig')
        self.assertIn('[switch]$PassThru', diagnostic)
        self.assertIn('[switch]$NoOpenReport', diagnostic)
        self.assertIn("Write-Output ([pscustomobject]@{ json=$jsonPath; html=$htmlPath })", diagnostic)
        self.assertIn('if (-not $NoOpenReport)', diagnostic)
        self.assertIn('-Days 1 -PassThru -NoOpenReport', smoke)
        self.assertIn('savedPair.Count -ne 1', smoke)
        self.assertIn('GetFullPath($jsonFile)', smoke)
        self.assertIn('Diagnostic receipt points outside allowed local report folders.', smoke)
        self.assertIn('ChangeExtension($jsonFile', smoke)
        self.assertIn("[0-9a-f]{8}[.]json$", smoke)
        self.assertIn("if (-not $allowed)", smoke)
        self.assertIn("Diagnostic receipt JSON or HTML is missing.", smoke)
        self.assertNotIn('Get-ChildItem -LiteralPath $dir', smoke)
        self.assertNotIn('LastWriteTime', smoke)
        self.assertNotIn('Sort-Object LastWriteTime', smoke)


    def test_report_has_escaped_disk_and_crash_details(self):
        text = (ROOT/'tools/diagnose.ps1').read_text(encoding='utf-8-sig')
        self.assertIn('최근 블루스크린 상세', text)
        self.assertIn('물리 저장장치 상태', text)
        self.assertIn('(Esc $d.model)', text)
        self.assertIn('(Esc $e.stopCode)', text)
        self.assertIn('if ($eventQueryFailed)', text)
        self.assertIn('마모율/온도는 드라이버 지원', text)

    def test_self_test_is_read_only_and_bundled(self):
        starter = (ROOT/'RUN_SELF_TEST.cmd').read_text(encoding='utf-8')
        smoke = (ROOT/'tests/windows_smoke.ps1').read_text(encoding='utf-8-sig')
        self.assertIn('windows_smoke.ps1', starter)
        self.assertIn('-RunReadOnly', starter)
        self.assertNotIn('repair.ps1', starter.lower())
        self.assertIn('Parser]::ParseFile', smoke)
        self.assertNotIn('repair.ps1 -', smoke)
        package = (ROOT/'tools/release.py').read_text(encoding='utf-8')
        self.assertIn("'RUN_SELF_TEST.cmd'", package)
        self.assertIn("'tests/windows_smoke.ps1'", package)
        self.assertIn("'tests/event_analysis.tests.ps1'", package)

    def test_offline_event_normalization_and_fixture_wiring(self):
        normalizer = (ROOT/'tools/event_analysis.ps1').read_text(encoding='utf-8-sig')
        diagnose = (ROOT/'tools/diagnose.ps1').read_text(encoding='utf-8-sig')
        smoke = (ROOT/'tests/windows_smoke.ps1').read_text(encoding='utf-8-sig')
        release = (ROOT/'tools/release.py').read_text(encoding='utf-8')
        fixture = (ROOT/'tests/event_analysis.tests.ps1').read_text(encoding='utf-8-sig')
        self.assertIn('ConvertTo-PcCareEvidence', normalizer)
        self.assertIn('Group-PcCareShutdownSignals', normalizer)
        self.assertIn('event_recorded_time', normalizer)
        self.assertIn('possibly_related_shutdown_signals', normalizer)
        self.assertIn('event_analysis.ps1', diagnose)
        self.assertIn("['shutdownGroups']", diagnose)
        self.assertIn("['eventCollection']", diagnose)
        self.assertIn('Save-PcCareReportPair', diagnose)
        self.assertIn('report_io.ps1', diagnose)
        self.assertIn("'tools/report_io.ps1'", release)
        self.assertIn("'tests/report_io.tests.ps1'", release)
        self.assertIn('report_io.tests.ps1', smoke)
        self.assertIn('event_analysis.tests.ps1', smoke)
        self.assertIn("'tools/event_analysis.ps1'", release)
        self.assertIn('EVENT FIXTURE PASS', fixture)
        self.assertNotIn('Invoke-RestMethod', normalizer)
        self.assertNotIn('Invoke-WebRequest', normalizer)

    def test_privilege_and_storage_support_are_explicit(self):
        diagnose = (ROOT/'tools/diagnose.ps1').read_text(encoding='utf-8-sig')
        self.assertIn("requestedElevation=$false", diagnose)
        self.assertIn("$observations['privilege']", diagnose)
        self.assertIn("reliabilityStatus='unavailable'", diagnose)
        self.assertIn("$item.reliabilityStatus = 'collected'", diagnose)
        self.assertIn("$item.reliabilityStatus = 'empty'", diagnose)
        self.assertNotIn('-Verb RunAs', diagnose)
        self.assertIn("['collectionStatus']", diagnose)

    def test_incident_explanations_are_local_and_noncausal(self):
        module = (ROOT/'tools/incident_analysis.ps1').read_text(encoding='utf-8-sig')
        diagnostic = (ROOT/'tools/diagnose.ps1').read_text(encoding='utf-8-sig')
        smoke = (ROOT/'tests/windows_smoke.ps1').read_text(encoding='utf-8-sig')
        allowlist = (ROOT/'tools/release.py').read_text(encoding='utf-8')
        fixture = (ROOT/'tests/incident_analysis.tests.ps1').read_text(encoding='utf-8-sig')
        self.assertIn('Get-PcCareIncidentAssessment', module)
        self.assertIn('causeConfirmed = $false', module)
        self.assertIn('STORAGE_FIRST', module)
        self.assertIn('SHUTDOWN_REVIEW', module)
        self.assertIn('BUGCHECK_REVIEW', module)
        self.assertIn('incident_analysis.ps1', diagnostic)
        self.assertIn('analysis=$incidentAssessment', diagnostic)
        self.assertIn('(Esc $finding.title)', diagnostic)
        self.assertIn('(Esc $finding.interpretation)', diagnostic)
        self.assertIn('incident_analysis.tests.ps1', smoke)
        self.assertIn("'tools/incident_analysis.ps1'", allowlist)
        self.assertIn("'tests/incident_analysis.tests.ps1'", allowlist)
        self.assertIn('INCIDENT FIXTURE PASS', fixture)
        self.assertIn('UPDATE_FAILURE_REVIEW', module)
        for blocked in ['Invoke-RestMethod','Invoke-WebRequest','Start-Process','RestoreHealth','scannow']:
            self.assertNotIn(blocked, module)

    def test_readonly_battery_and_update_source_wiring(self):
        telemetry = (ROOT/'tools/telemetry_analysis.ps1').read_text(encoding='utf-8-sig')
        diagnose = (ROOT/'tools/diagnose.ps1').read_text(encoding='utf-8-sig')
        smoke = (ROOT/'tests/windows_smoke.ps1').read_text(encoding='utf-8-sig')
        release = (ROOT/'tools/release.py').read_text(encoding='utf-8')
        fixture = (ROOT/'tests/telemetry_analysis.tests.ps1').read_text(encoding='utf-8-sig')
        self.assertIn('ConvertTo-PcCareBatterySnapshot', telemetry)
        self.assertIn('ConvertTo-PcCareUpdateEvidence', telemetry)
        self.assertIn("status='not_present'", telemetry)
        self.assertIn("status='unavailable'", telemetry)
        self.assertIn('event_recorded_time', telemetry)
        self.assertIn('Get-CimInstance -ClassName Win32_Battery', diagnose)
        self.assertIn("ProviderName='Microsoft-Windows-WindowsUpdateClient'", diagnose)
        self.assertIn('Get-WinEvent -FilterHashtable', diagnose)
        self.assertIn('telemetry_analysis.ps1', diagnose)
        self.assertIn("['battery']", diagnose)
        self.assertIn("['windowsUpdate']", diagnose)
        self.assertIn("(Esc $batteryNote)", diagnose)
        self.assertIn("(Esc $updateLabel)", diagnose)
        self.assertIn('telemetry_analysis.tests.ps1', smoke)
        self.assertIn("'tools/telemetry_analysis.ps1'", release)
        self.assertIn("'tests/telemetry_analysis.tests.ps1'", release)
        self.assertIn('TELEMETRY FIXTURE PASS', fixture)
        self.assertNotIn('Invoke-WebRequest', telemetry)
        self.assertNotIn('Invoke-RestMethod', telemetry)
        self.assertNotIn('Start-Process', telemetry)

    def test_pnp_and_timeline_are_scoped_noncausal_and_bundled(self):
        pnp = (ROOT/'tools/pnp_analysis.ps1').read_text(encoding='utf-8-sig')
        timeline = (ROOT/'tools/recorded_timeline.ps1').read_text(encoding='utf-8-sig')
        diag = (ROOT/'tools/diagnose.ps1').read_text(encoding='utf-8-sig')
        engine = (ROOT/'tools/incident_analysis.ps1').read_text(encoding='utf-8-sig')
        smoke = (ROOT/'tests/windows_smoke.ps1').read_text(encoding='utf-8-sig')
        package = (ROOT/'tools/release.py').read_text(encoding='utf-8')
        test = (ROOT/'tests/driver_timeline.tests.ps1').read_text(encoding='utf-8-sig')
        self.assertIn('ConvertTo-PcCarePnPSummary', pnp)
        self.assertIn('device_disabled', pnp)
        self.assertIn('Get-PcCareRecordedTimeline', timeline)
        self.assertIn('recorded_timestamp_proximity_only', timeline)
        self.assertIn('causeConfirmed = $false', timeline)
        self.assertIn("Get-CimInstance -ClassName Win32_PnPEntity", diag)
        self.assertIn("['driverDevices']", diag)
        self.assertIn("['recordedTimeline']", diag)
        self.assertIn('-PnPSummary $pnpSummary', diag)
        self.assertIn('PNP_CONFIG_REVIEW', engine)
        self.assertIn('driver_timeline.tests.ps1', smoke)
        self.assertIn("'tools/pnp_analysis.ps1'", package)
        self.assertIn("'tools/recorded_timeline.ps1'", package)
        self.assertIn("'tests/driver_timeline.tests.ps1'", package)
        self.assertIn('DRIVER/TIMELINE FIXTURE PASS', test)
        for source in [pnp,timeline]:
            for forbidden in ['Invoke-WebRequest','Invoke-RestMethod','Set-ItemProperty','Start-Process','Remove-Item']:
                self.assertNotIn(forbidden, source)

    def test_a4_consultation_is_private_print_only_and_bundled(self):
        source = (ROOT/'tools/consultation_report.ps1').read_text(encoding='utf-8-sig')
        html = (ROOT/'tools/consultation_render.ps1').read_text(encoding='utf-8-sig')
        diagnostic = (ROOT/'tools/diagnose.ps1').read_text(encoding='utf-8-sig')
        smoke = (ROOT/'tests/windows_smoke.ps1').read_text(encoding='utf-8-sig')
        fixture = (ROOT/'tests/consultation_report.tests.ps1').read_text(encoding='utf-8-sig')
        package = (ROOT/'tools/release.py').read_text(encoding='utf-8')
        self.assertIn('Get-PcCareConsultationSummary', source)
        self.assertIn('ConvertTo-PcCareConsultationHtml', html)
        self.assertIn('HtmlEncode', html)
        self.assertIn('consultation-print', html)
        self.assertIn('containsIdentifiers=$false', source)
        self.assertIn('Get-PcCareConsultationSummary -Report $report', diagnostic)
        self.assertIn("['consultation']", diagnostic)
        self.assertIn('$consultationHtml', diagnostic)
        self.assertIn('@page{size:A4 portrait', diagnostic)
        self.assertIn('@media print{', diagnostic)
        self.assertIn('main>:not(#consultation-print)', diagnostic)
        self.assertIn('Ctrl+P', diagnostic)
        self.assertIn("'tools/consultation_report.ps1'", package)
        self.assertIn("'tools/consultation_render.ps1'", package)
        self.assertIn("'tests/consultation_report.tests.ps1'", package)
        self.assertIn("consultation_report.tests.ps1", smoke)
        self.assertIn("CONSULTATION FIXTURE PASS", fixture)
        for module in [source, html]:
            for forbidden in ['Invoke-WebRequest','Invoke-RestMethod','Start-Process','Set-ItemProperty','Remove-Item']:
                self.assertNotIn(forbidden, module)
        for sensitive in ['DeviceID','.SerialNumber','.Message','.model','.FriendlyName']:
            self.assertNotIn(sensitive, source)

    def test_share_text_is_optional_local_bounded_and_private(self):
        payload = (ROOT/'tools/share_payload.ps1').read_text(encoding='utf-8-sig')
        preview = (ROOT/'tools/share_preview.ps1').read_text(encoding='utf-8-sig')
        diagnostic = (ROOT/'tools/diagnose.ps1').read_text(encoding='utf-8-sig')
        fixture = (ROOT/'tests/share_payload.tests.ps1').read_text(encoding='utf-8-sig')
        smoke = (ROOT/'tests/windows_smoke.ps1').read_text(encoding='utf-8-sig')
        package = (ROOT/'tools/release.py').read_text(encoding='utf-8')
        self.assertIn('Get-PcCareSharePayload', payload)
        self.assertIn('GetByteCount', payload)
        self.assertIn('MaxUtf8Bytes = 250', payload)
        self.assertIn("status = $payloadStatus", payload)
        self.assertIn('payloadText = $payloadSafe', payload)
        self.assertIn('qrImageGenerated = $false', payload)
        self.assertIn('ConvertTo-PcCareSharePreviewHtml', preview)
        self.assertIn('HtmlEncode', preview)
        self.assertIn('<details', preview)
        self.assertIn('<textarea', preview)
        self.assertIn('Ctrl+C', preview)
        self.assertIn("['sharePreview']", diagnostic)
        self.assertIn("payloadStoredInJson = $false", diagnostic)
        self.assertIn('$sharePreviewHtml', diagnostic)
        self.assertIn("'tools/share_payload.ps1'", package)
        self.assertIn("'tools/share_preview.ps1'", package)
        self.assertIn("'tests/share_payload.tests.ps1'", package)
        self.assertIn('share_payload.tests.ps1', smoke)
        self.assertIn('SHARE FIXTURE PASS', fixture)
        for source in [payload, preview]:
            for forbidden in ['Invoke-RestMethod','Invoke-WebRequest','Start-Process','Remove-Item','Set-ItemProperty']:
                self.assertNotIn(forbidden, source)
        for identifier in ['.SerialNumber','.DeviceID','.Message','.FriendlyName','.UserName']:
            self.assertNotIn(identifier, payload)

    def test_offline_qr_generation_is_opt_in_and_licensed(self):
        vendor = (ROOT/'ui/qrcode.min.js').read_text(encoding='utf-8')
        license_text = (ROOT/'ui/QR_CODE_LICENSE.txt').read_text(encoding='utf-8')
        qr_ui = (ROOT/'ui/qr_ui.js').read_text(encoding='utf-8')
        diagnostic = (ROOT/'tools/diagnose.ps1').read_text(encoding='utf-8-sig')
        preview = (ROOT/'tools/share_preview.ps1').read_text(encoding='utf-8-sig')
        package = (ROOT/'tools/release.py').read_text(encoding='utf-8')
        self.assertIn('Copyright (c) 2012 davidshimjs', license_text)
        self.assertIn('The MIT License', license_text)
        self.assertIn('QRCode', vendor)
        self.assertIn('new QRCode(target', qr_ui)
        self.assertIn('addEventListener("click"', qr_ui)
        self.assertIn('TextEncoder()', qr_ui)
        self.assertIn('bytes > 250', qr_ui)
        self.assertIn('id="pc-care-generate-qr"', preview)
        self.assertIn('QrSupported = $false', preview)
        self.assertIn('qrImageSupported', diagnostic)
        self.assertIn('$qrInlineScripts', diagnostic)
        self.assertIn('$qrLicenseText', diagnostic)
        self.assertIn('QR_CODE_LICENSE.txt', diagnostic)
        for name in ['ui/qrcode.min.js','ui/QR_CODE_LICENSE.txt','ui/qr_ui.js']:
            self.assertIn(repr(name), package)
        self.assertNotIn('</script', vendor.lower())
        for banned in ['fetch(', 'XMLHttpRequest', 'sendBeacon', 'navigator.clipboard', 'window.location=', 'Start-Process']:
            self.assertNotIn(banned, qr_ui)
        # No remote URLs for QR generation. SVG namespace in the vendor is not a network call.
        self.assertNotIn('http:', qr_ui)
        self.assertNotIn('https:', qr_ui)

    def test_report_local_navigation_has_safe_anchors(self):
        import re
        diagnostic = (ROOT/'tools/diagnose.ps1').read_text(encoding='utf-8-sig')
        self.assertIn('aria-label="진단 보고서 바로가기"', diagnostic)
        self.assertIn('class="skip-link"', diagnostic)
        self.assertIn('class="quicknav"', diagnostic)
        self.assertIn('quicknav a:focus-visible', diagnostic)
        self.assertIn('@media(max-width:650px)', diagnostic)
        renderer = (ROOT/'tools/consultation_render.ps1').read_text(encoding='utf-8-sig')
        ids = set(re.findall(r'id="([a-z-]+)"', diagnostic + renderer))
        links = re.findall(r'<a href="#([a-z-]+)">', diagnostic)
        self.assertTrue(links)
        self.assertTrue(set(links).issubset(ids), (links, ids))
        self.assertIn('main>:not(#consultation-print){display:none!important}', diagnostic)
        self.assertNotIn('<script src="http', diagnostic)
        self.assertNotIn('<script src="https', diagnostic)

    def test_launchers_use_trusted_powershell_and_fail_closed(self):
        for name in ('RUN_HEALTH_CHECK.cmd', 'RUN_SELF_TEST.cmd', 'RUN_SAFE_REPAIR.cmd'):
            source = (ROOT/name).read_text(encoding='utf-8')
            with self.subTest(name=name):
                self.assertIn('set "AXMART_PS51=%SystemRoot%\\System32\\WindowsPowerShell\\v1.0\\powershell.exe"', source)
                self.assertIn('if not exist "%AXMART_PS51%" (', source)
                self.assertIn('"%AXMART_PS51%" -NoLogo -NoProfile', source)
                self.assertIn('exit /b 2', source)
                self.assertIn('DisableDelayedExpansion', source)
                self.assertNotIn('where powershell.exe', source)
                self.assertNotRegex(source, r'(?im)^powershell[.]exe\s')
                self.assertNotIn('if not exist "%AXMART_PS51%"' + chr(10) + 'if errorlevel 1', source)
        self.assertTrue((ROOT/'tests/test_qr_ui.cjs').is_file())
        self.assertIn('node:test', (ROOT/'tests/test_qr_ui.cjs').read_text(encoding='utf-8'))

    def test_qr_share_schema_and_optional_browser_gate(self):
        qr_ui = (ROOT/'ui/qr_ui.js').read_text(encoding='utf-8')
        node_fixture = (ROOT/'tests/test_qr_ui.cjs').read_text(encoding='utf-8')
        browser_fixture = (ROOT/'tests/qr_browser_smoke.py').read_text(encoding='utf-8')
        package = (ROOT/'tools/release.py').read_text(encoding='utf-8')
        self.assertIn('hasExpectedShareFields', qr_ui)
        self.assertIn('lines.length !== 7', qr_ui)
        self.assertIn('allowed.indexOf(signals[i])', qr_ui)
        self.assertIn('function clearPreviousQr()', qr_ui)
        self.assertIn('source.addEventListener("input"', qr_ui)
        self.assertIn('button.addEventListener("click"', qr_ui)
        self.assertIn('bytes > 250', qr_ui)
        self.assertIn('test("invalid regeneration clears a QR created for older text"', node_fixture)
        self.assertIn('test("untrusted extra lines cannot be encoded as a QR"', node_fixture)
        self.assertIn('cv2.QRCodeDetector().detectAndDecode', browser_fixture)
        self.assertIn('utf8_qr_content_matches_after_explicit_bom_handling', browser_fixture)
        self.assertIn('no_external_http_requests', browser_fixture)
        self.assertIn('leading_utf8_bom_detected', browser_fixture)
        self.assertIn('qr_has_no_unexpected_prefix_or_suffix', browser_fixture)
        self.assertIn('edit_clears_stale_qr', browser_fixture)
        self.assertNotIn('tests/qr_browser_smoke.py', package)
        self.assertNotIn('fetch(', qr_ui)
        self.assertNotIn('XMLHttpRequest', qr_ui)

    def test_qr_rejects_impossible_calendar_dates(self):
        source = (ROOT/'ui/qr_ui.js').read_text(encoding='utf-8')
        node = (ROOT/'tests/test_qr_ui.cjs').read_text(encoding='utf-8')
        browser = (ROOT/'tests/qr_browser_smoke.py').read_text(encoding='utf-8')
        self.assertIn('Date.UTC(year, month - 1, day', source)
        self.assertIn('d.getUTCFullYear() === year', source)
        self.assertIn('d.getUTCMonth() + 1 === month', source)
        self.assertIn('d.getUTCDate() === day', source)
        self.assertIn('if (time === "미확인") return true;', source)
        for term in ('impossible February date', 'invalid leap day', 'valid leap-day timestamp',
                     'unknown recorded time remains'):
            self.assertIn(term, node)
        for term in ('invalid_february_30_rejected','invalid_leap_day_rejected',
                     'valid_leap_day_accepted','unknown_record_time_accepted','invalid_month_rejected'):
            self.assertIn(term, browser)

    def test_vendor_qr_reset_prevents_korean_ascii_byte_overflow(self):
        vendor = (ROOT/'ui/qrcode.min.js').read_text(encoding='utf-8')
        license_text = (ROOT/'ui/QR_CODE_LICENSE.txt').read_text(encoding='utf-8')
        vendor_tests = (ROOT/'tests/test_qr_vendor.cjs').read_text(encoding='utf-8')
        workflow = (ROOT.parent.parent/'.github/workflows/pc-care-windows-synthetic.yml').read_text(encoding='utf-8')
        package = (ROOT/'tools/release.py').read_text(encoding='utf-8')
        # Original minified byte parser incorrectly retained 3-byte suffixes
        # when ASCII followed a Korean character. Keep this minimal MIT patch.
        fixed = 'for(var b=[],d=0,e=this.data.length;e>d;d++){b=[];var f='
        self.assertEqual(vendor.count(fixed), 1)
        self.assertIn('The MIT License', license_text)
        self.assertIn('actual vendor QR encoder handles mixed Korean and ASCII', vendor_tests)
        self.assertIn('mixed Korean-ASCII transitions do not repeat leftover byte suffixes', vendor_tests)
        self.assertIn('node --test tests/test_qr_ui.cjs tests/test_qr_vendor.cjs', workflow)
        self.assertNotIn("'tests/test_qr_vendor.cjs'", package)
        self.assertNotIn('</script', vendor.lower())
        self.assertNotIn('XMLHttpRequest', vendor)
        self.assertNotIn('fetch(', vendor)

    def test_ps1_utf8_bom_for_windows_powershell_51(self):
        for name in ['tools/diagnose.ps1','tools/repair.ps1','tools/event_analysis.ps1','tools/incident_analysis.ps1','tools/telemetry_analysis.ps1','tools/pnp_analysis.ps1','tools/recorded_timeline.ps1','tools/consultation_report.ps1','tools/consultation_render.ps1','tools/share_payload.ps1','tools/share_preview.ps1','tools/report_io.ps1','tests/event_analysis.tests.ps1','tests/incident_analysis.tests.ps1','tests/telemetry_analysis.tests.ps1','tests/driver_timeline.tests.ps1','tests/consultation_report.tests.ps1','tests/share_payload.tests.ps1','tests/report_io.tests.ps1']:
            self.assertTrue((ROOT/name).read_bytes().startswith(b'\xef\xbb\xbf'))

if __name__ == '__main__':
    unittest.main(verbosity=2)
