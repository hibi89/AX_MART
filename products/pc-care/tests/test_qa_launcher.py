"""Static safeguards for the developer-only Windows one-click preflight launcher.

This is not proof of actual cmd.exe or PowerShell 5.1 execution.
"""
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / 'RUN_RELEASE_QA.cmd'

class ReleaseQaLauncherTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.body = SCRIPT.read_text(encoding='ascii')
        cls.active = [line.strip().lower() for line in cls.body.splitlines()
                      if line.strip() and not line.lstrip().lower().startswith(('rem ', 'echo ', '@echo '))]

    def test_internal_only_not_a_customer_release(self):
        script = self.body
        self.assertIn('Development-only PC CARE release QA', script)
        self.assertIn('NOT shipped in customer ZIP', script)
        self.assertIn('NOT DISTRIBUTION', script)

    def test_runs_only_developer_preflight(self):
        calls = [line for line in self.active if 'tools\\preflight.py' in line and line.startswith('%qa_py%')]
        self.assertEqual(len(calls), 1)
        self.assertIn('--root', calls[0])
        self.assertIn('--root "."', calls[0])

    def test_developer_launcher_excluded_from_package_allowlist(self):
        import ast
        release = ast.parse((ROOT/'tools/release.py').read_text(encoding='utf-8'))
        allowlists = [node.value for node in release.body if isinstance(node, ast.Assign)
                      and any(isinstance(t, ast.Name) and t.id == 'ALLOWLIST' for t in node.targets)]
        self.assertEqual(len(allowlists), 1)
        allowlist = ast.literal_eval(allowlists[0])
        self.assertNotIn('RUN_RELEASE_QA.cmd', allowlist)
        self.assertNotIn('tests/test_qa_launcher.py', allowlist)

    def test_no_real_diagnostics_or_system_changes(self):
        commands = '\n'.join(self.active)
        for item in ('-runreadonly', 'run_health_check.cmd', 'run_self_test.cmd',
                     'run_safe_repair.cmd', 'diagnose.ps1', 'repair.ps1',
                     'format-volume', 'diskpart ', 'chkdsk ', 'manage-bde ',
                     'bcdedit ', 'reg add', 'del /', 'rmdir ', 'git push',
                     'curl ', 'invoke-webrequest', 'powershell.exe -file'):
            with self.subTest(item=item):
                self.assertNotIn(item, commands)

    def test_missing_required_sources_fail_closed(self):
        self.assertIn('if not exist "%PC_CARE_DEV_ROOT%tools\\preflight.py" goto MISSING', self.body)
        self.assertIn('if not exist "%PC_CARE_DEV_ROOT%tools\\release.py" goto MISSING', self.body)
        self.assertIn('if not exist "%PC_CARE_DEV_ROOT%tests\\windows_smoke.ps1" goto MISSING', self.body)
        self.assertIn('exit /b 3', self.body)

    def test_python_version_and_runtime_validation(self):
        self.assertIn('sys.version_info >= (3,11)', self.body)
        self.assertIn('if errorlevel 1 goto NO_PYTHON', self.body)
        self.assertIn('exit /b 2', self.body)

    def test_subprocess_result_propagated(self):
        self.assertIn('set "QA_EXIT=%ERRORLEVEL%"', self.body)
        self.assertIn('exit /b %QA_EXIT%', self.body)
        self.assertIn('QA FAILED or BLOCKED.', self.body)

    def test_no_customer_files_or_qa_logs_written(self):
        self.assertIn('set "PYTHONDONTWRITEBYTECODE=1"', self.body)
        self.assertIn('set "PYTHONNOUSERSITE=1"', self.body)
        active = '\n'.join(self.active)
        for item in ('copy ', 'xcopy ', 'robocopy ', 'move ', 'set /p',
                     '>>', '>"', '> %', 'mkdir ', 'rmdir ', 'start '):
            self.assertNotIn(item, active)

if __name__ == '__main__':
    unittest.main(verbosity=2)
