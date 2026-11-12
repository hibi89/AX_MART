"""P15-P17 self-contained customer entry/Recovery HOLD static safety acceptance.

Source checks are NOT a real Windows CMD, Edge, QR camera or WinRE test.
"""
from pathlib import Path
import re
import unittest

ROOT = Path(__file__).resolve().parents[1]
MENU = ROOT / "START_PC_CARE.cmd"
HTML = ROOT / "ui/recovery_readiness.html"
PACKER = ROOT / "tools/release.py"


class OfflineOwnerReadinessTests(unittest.TestCase):
    def test_main_menu_explicit_positions_safety(self):
        text = MENU.read_text(encoding="utf-8")
        self.assertIn("/C 12345670 /N", text)
        self.assertIn('if "%PC_CARE_PICK%"=="6" goto CONSULTATION', text)
        self.assertIn('if "%PC_CARE_PICK%"=="7" goto RECOVERY_CARD', text)
        self.assertIn('if "%PC_CARE_PICK%"=="8" exit /b 0', text)
        self.assertIn('if not exist "%PC_CARE_ROOT%ui\\case_review.html" goto MISSING', text)
        self.assertIn('if not exist "%PC_CARE_ROOT%ui\\case_review.js" goto MISSING', text)
        self.assertIn('if not exist "%PC_CARE_ROOT%ui\\recovery_readiness.html" goto MISSING', text)
        self.assertEqual(text.count('start "" "%PC_CARE_ROOT%ui\\case_review.html"'), 1)
        self.assertEqual(text.count('start "" "%PC_CARE_ROOT%ui\\recovery_readiness.html"'), 1)

    def test_every_new_customer_entry_is_offline_readonly(self):
        text = MENU.read_text(encoding="utf-8")
        for phrase in ("runas", "start-process", "powershell.exe", "curl ",
                       "invoke-webrequest", "diskpart ", "bootrec ",
                       "bcdedit /set", "chkdsk /f", "format ", "/mir",
                       "run_safe_repair.cmd"):
            with self.subTest(phrase=phrase):
                self.assertNotIn(phrase, text.lower())
        self.assertNotIn("setlocal EnableDelayedExpansion", text)
        self.assertIn("DisableDelayedExpansion", text)
        self.assertIn("goto MISSING", text)

    def test_recovery_card_is_script_free_zero_network_hold(self):
        source = HTML.read_text(encoding="utf-8")
        lowered = source.lower()
        for forbidden in ("<script", "<iframe", "<form", "http://", "https://",
                          "fetch(", "xmlhttprequest", "localstorage",
                          "sessionstorage", "sendbeacon", "websocket",
                          "<img", "url("):
            with self.subTest(item=forbidden):
                self.assertNotIn(forbidden, lowered)
        for needed in ("default-src 'none'", "connect-src 'none'",
                       "object-src 'none'", "@page{size:A4",
                       "RELEASE HOLD", "WinRE", "BitLocker",
                       "다른 물리 디스크", "승인 아님", "백업",
                       "복구 준비 카드", "공식"):
            with self.subTest(item=needed):
                self.assertIn(needed, source)
        self.assertNotIn('value="true"', source)
        # Manual checklist must not imply the program completed any check.
        self.assertGreaterEqual(source.count('type="checkbox"'), 6)
        self.assertIn("현재 자동으로 확인되지 않았습니다", source)
        self.assertIn("체크 상태는 저장·전송되지 않습니다", source)

    def test_package_ship_both_customer_screens_and_existing_history(self):
        source = PACKER.read_text(encoding="utf-8")
        for member in ("ui/recovery_readiness.html", "ui/case_review.html",
                       "ui/case_review.js", "ui/history_compare.html",
                       "START_PC_CARE.cmd"):
            with self.subTest(member=member):
                self.assertIn("'" + member + "'", source)

    def test_no_recovery_machine_command_in_card(self):
        source = HTML.read_text(encoding="utf-8").lower()
        for command in ("bootrec /", "bcdboot ", "diskpart clean",
                        "robocopy ", "chkdsk /f", "chkdsk /r", "manage-bde -unlock",
                        "format c:", "powershell -enc", "sfc /scannow",
                        "dism /online /cleanup-image /restorehealth"):
            self.assertNotIn(command, source)


if __name__ == "__main__":
    unittest.main()
