"""No Windows required: test deterministic alpha ZIP safety and integrity."""
from pathlib import Path
from tempfile import TemporaryDirectory
import importlib.util
import sys
import unittest
import zipfile

RELEASE_PATH = Path(__file__).resolve().parents[1] / 'tools' / 'release.py'
spec = importlib.util.spec_from_file_location('release', RELEASE_PATH)
release = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = release
spec.loader.exec_module(release)


class ReleaseTests(unittest.TestCase):
    def setUp(self):
        self.temp = TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name) / 'source'
        for name in release.ALLOWLIST:
            path = self.root / name
            path.parent.mkdir(parents=True, exist_ok=True)
            data = ('safe content: ' + name).encode('utf-8')
            if name.endswith('.ps1'):
                data = b'\xef\xbb\xbf' + data
            path.write_bytes(data)

    def test_manifest_and_sha256_match(self):
        path, checksum = release.build_internal(self.root, self.root / 'dist-internal')
        self.assertEqual(release.verify_archive(path), checksum)
        with zipfile.ZipFile(path) as archive:
            self.assertIn(f'{release.FOLDER}/{release.MANIFEST}', archive.namelist())

    def test_deterministic_binary_for_unchanged_sources(self):
        first, before = release.build_internal(self.root, self.root / 'dist-internal')
        snapshot = first.read_bytes()
        second, after = release.build_internal(self.root, self.root / 'dist-internal')
        self.assertEqual(before, after)
        self.assertEqual(snapshot, second.read_bytes())

    def test_secret_report_is_not_shipped(self):
        sensitive = self.root / 'REPORTS' / 'private_event_log.json'
        sensitive.parent.mkdir(parents=True, exist_ok=True)
        sensitive.write_text('PRIVATE EVENT')
        path, _ = release.build_internal(self.root, self.root / 'dist-internal')
        with zipfile.ZipFile(path) as archive:
            self.assertFalse(any('REPORTS' in n or 'private' in n for n in archive.namelist()))

    def test_missing_bom_or_file_blocks_build(self):
        (self.root / 'tools' / 'repair.ps1').write_text('unencoded')
        with self.assertRaisesRegex(ValueError, 'UTF-8 BOM'):
            release.build_internal(self.root, self.root / 'dist-internal')
        (self.root / 'tools' / 'repair.ps1').unlink()
        with self.assertRaisesRegex(ValueError, 'Missing'):
            release.build_internal(self.root, self.root / 'dist-internal')

    def test_tampered_archive_or_sidecar_is_rejected(self):
        path, _ = release.build_internal(self.root, self.root / 'dist-internal')
        Path(str(path) + '.sha256').write_text('0' * 64 + f'  {path.name}\n')
        with self.assertRaisesRegex(ValueError, 'sidecar'):
            release.verify_archive(path)

    def test_internal_zip_includes_transitive_self_test_dependencies(self):
        """An internal ZIP must include every script the read-only launcher loads."""
        required = {
            'RUN_SELF_TEST.cmd',
            'START_PC_CARE.cmd',
            'tests/windows_smoke.ps1',
            'tests/event_analysis.tests.ps1',
            'tools/diagnose.ps1',
            'tools/event_analysis.ps1',
            'tools/incident_analysis.ps1',
            'tools/telemetry_analysis.ps1',
            'tools/pnp_analysis.ps1',
            'tools/recorded_timeline.ps1',
            'tools/consultation_report.ps1',
            'tools/consultation_render.ps1',
            'tools/share_payload.ps1',
            'tools/share_preview.ps1',
            'ui/qrcode.min.js',
            'ui/QR_CODE_LICENSE.txt',
            'ui/qr_ui.js',
            'ui/history_compare.html',
            'ui/history_compare.js',
            'tests/incident_analysis.tests.ps1',
            'tests/telemetry_analysis.tests.ps1',
            'tests/driver_timeline.tests.ps1',
            'tests/consultation_report.tests.ps1',
            'tests/share_payload.tests.ps1',
            'tools/report_io.ps1',
            'tests/report_io.tests.ps1',
        }
        self.assertTrue(required.issubset(release.ALLOWLIST))
        archive, _ = release.build_internal(self.root, self.root / 'dist-internal')
        with zipfile.ZipFile(archive) as handle:
            paths = set(handle.namelist())
        for item in required:
            self.assertIn(f'{release.FOLDER}/{item}', paths)

    def test_no_default_public_release(self):
        with self.assertRaises(SystemExit) as raised:
            release.main([])
        self.assertEqual(raised.exception.code, 2)


if __name__ == '__main__':
    unittest.main(verbosity=2)
