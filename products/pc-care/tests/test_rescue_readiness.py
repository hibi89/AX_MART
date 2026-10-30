"""Structural, non-Windows test for Release B preview-only CMD safety boundaries.

This suite does NOT claim actual cmd.exe, WinRE, BitLocker, disk or USB verification.
"""
import re
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / 'recovery' / 'RESCUE_READINESS.cmd'

class RescueReadinessTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.body = SCRIPT.read_text(encoding='ascii')
        cls.active = '\n'.join(line.strip().lower().split(' echo ', 1)[0] for line in cls.body.splitlines()
            if line.strip() and not line.lstrip().lower().startswith(('rem ', 'echo ', '@echo ')))

    def test_never_copies_writes_or_executes_mutating_commands(self):
        for pattern in [r'\brobocopy(?:\.exe)?\s+[^\r\n]', r'\bcopy\s+[^\r\n]',
            r'\bxcopy\b', r'\bmove\b', r'\bdel\b', r'\brmdir\b',
            r'\bformat\b', r'\bchkdsk\b', r'\bdiskpart\b', r'\bmanage-bde\s+-',
            r'\bbootrec\b', r'\bbcdboot\b', r'\bstart\b', r'\bcall\b',
            r'\bpowershell\b', r'\bwmic\b', r'\bfsutil\b', r'\bcertutil\b',
            r'\breg\s+', r'\bset\s+/p\b', r'(?<!\^)>(?!nul)', r'<']:
            with self.subTest(pattern=pattern):
                self.assertNotRegex(self.active, pattern)

    def test_previews_candidates_but_not_names_or_personal_file_contents(self):
        self.assertIn('disableDelayedExpansion'.lower(), self.active)
        self.assertIn('for %%d in (c d e f g h i j k l m n o p q r s t u v w y z)', self.active)
        self.assertIn('%%d:\\windows\\system32\\config\\system', self.active)
        self.assertIn('%%d:\\users', self.active)
        self.assertNotIn('for /f', self.active)
        self.assertNotRegex(self.active, r'\bdir\b|\btype\b|\bfindstr\b')

    def test_no_success_path_and_explicit_unverified_gates(self):
        self.assertEqual(self.active.count('exit /b 3'), 2)
        self.assertNotRegex(self.active, r'exit\s+/b\s+0')
        for phrase in ('physical disk identity not proven', 'bitlocker lock state',
                       'destination free space', '4gib limit', 'efs', 'independent copy/hash'):
            self.assertIn(phrase, self.body.lower())
        self.assertIn('RESULT: BLOCKED - THIS IS NOT A BACKUP', self.body)

    def test_no_temp_logs_or_credential_prompt(self):
        self.assertNotRegex(self.active, r'\bmkdir\b|\bmd\b|\btee\b|\bchoice\b|\bset\s+/p')
        self.assertNotIn('%%D:\\Users\\*', self.body)
        self.assertIn('Do NOT enter recovery keys or passwords', self.body)

if __name__ == '__main__':
    unittest.main(verbosity=2)
