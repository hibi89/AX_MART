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
        banned = [r'\bremove-item\b',r'\bset-itemproperty\b',r'\bformat-volume\b',r'\bdisable-bitlocker\b',r'\bstart-process\s+[^\r\n]*\bdism\.exe',r'\brestart-computer\b',r'\binvoke-webrequest\b',r'\binvoke-restmethod\b',r'\bset-mppreference\b',r'\bchkdsk\s+[a-z]:\s+/[frx]']
        for pattern in banned:
            with self.subTest(pattern=pattern):
                self.assertNotRegex(text.lower(), pattern)
        self.assertIn("ConvertTo-Json", text)
        self.assertIn("[System.Net.WebUtility]::HtmlEncode", text)
        self.assertIn("Get-WinEvent", text)
        self.assertIn("Get-PhysicalDisk", text)
        self.assertIn("Get-CimInstance", text)
        self.assertIn("NoMatchingEventsFound", text)
        self.assertIn("mode='read-only'", text)

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

    def test_ps1_utf8_bom_for_windows_powershell_51(self):
        for name in ['tools/diagnose.ps1','tools/repair.ps1']:
            self.assertTrue((ROOT/name).read_bytes().startswith(b'\xef\xbb\xbf'))

if __name__ == '__main__':
    unittest.main(verbosity=2)
