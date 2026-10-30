"""Static packaging and safety gates; NOT a Windows runtime/PowerShell test."""
from pathlib import Path
import unittest
import re

ROOT = Path(__file__).resolve().parents[1]

class PackageTests(unittest.TestCase):
    def test_files_exist(self):
        for name in ["README.md","RUN_HEALTH_CHECK.cmd", "RUN_SAFE_REPAIR.cmd", "tools/diagnose.ps1", "tools/repair.ps1", "recovery/WINRE_READ_ONLY.cmd", "docs/SAFETY.md", "docs/PRODUCT_SCOPE.md"]:
            with self.subTest(name=name):
                self.assertTrue((ROOT/name).is_file(), name)

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
        self.assertIn("foreach ($owned in @($tempJson,$tempHtml))", report_io)
        self.assertIn("if ($movedJson) { Remove-Item -LiteralPath $finalJson", report_io)
        self.assertIn("if ($movedHtml) { Remove-Item -LiteralPath $finalHtml", report_io)
        self.assertIn("Report filename collision:", report_io)
        self.assertNotIn("foreach ($owned in @($tempJson,$tempHtml,$finalJson,$finalHtml))", report_io)

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

    def test_ps1_utf8_bom_for_windows_powershell_51(self):
        for name in ['tools/diagnose.ps1','tools/repair.ps1','tools/event_analysis.ps1','tools/incident_analysis.ps1','tools/telemetry_analysis.ps1','tools/pnp_analysis.ps1','tools/recorded_timeline.ps1','tools/report_io.ps1','tests/event_analysis.tests.ps1','tests/incident_analysis.tests.ps1','tests/telemetry_analysis.tests.ps1','tests/driver_timeline.tests.ps1','tests/report_io.tests.ps1']:
            self.assertTrue((ROOT/name).read_bytes().startswith(b'\xef\xbb\xbf'))

if __name__ == '__main__':
    unittest.main(verbosity=2)
