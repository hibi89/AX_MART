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

    def test_rejects_zip_member_with_oversized_decompressed_size(self):
        archive, _ = release.build_internal(self.root, self.root / 'dist-internal')
        with zipfile.ZipFile(archive) as source:
            entries = [(info.filename, source.read(info)) for info in source.infolist()]
        malicious = self.root / 'malicious-bomb.zip'
        with zipfile.ZipFile(malicious, 'w', compression=zipfile.ZIP_DEFLATED) as output:
            for name, data in entries:
                if name == f'{release.FOLDER}/README.md':
                    data = b'x' * (release.MAX_FILE_BYTES + 1)
                output.writestr(name, data)
        with self.assertRaisesRegex(ValueError, 'oversized ZIP member'):
            release.verify_archive(malicious)

    def test_verify_cli_requires_sha256_sidecar(self):
        archive, checksum = release.build_internal(self.root, self.root / 'dist-internal')
        Path(str(archive) + '.sha256').unlink()
        self.assertEqual(release.verify_archive(archive), checksum)
        with self.assertRaisesRegex(ValueError, 'sidecar'):
            release.verify_archive(archive, require_sidecar=True)
        self.assertEqual(release.main(['--verify', str(archive)]), 1)

    def test_symlinked_source_parent_is_rejected(self):
        tools = self.root / 'tools'
        outside = self.root / 'outside-tools'
        tools.rename(outside)
        try:
            tools.symlink_to(outside, target_is_directory=True)
        except (OSError, NotImplementedError):
            self.skipTest('Directory symlinks not permitted on this Windows environment')
        with self.assertRaisesRegex(ValueError, 'Symlinked source directory'):
            release.build_internal(self.root, self.root / 'dist-internal')

    def test_oversized_manifest_rejected_before_reading(self):
        archive, _ = release.build_internal(self.root, self.root / 'dist-internal')
        with zipfile.ZipFile(archive) as source:
            entries = [(info.filename, source.read(info)) for info in source.infolist()]
        tampered = self.root / 'malicious-manifest.zip'
        with zipfile.ZipFile(tampered, 'w', compression=zipfile.ZIP_DEFLATED) as output:
            for name, data in entries:
                if name.endswith('/' + release.MANIFEST):
                    data = b'X' * (max(4096, len(release.ALLOWLIST)*160) + 1)
                output.writestr(name, data)
        with self.assertRaisesRegex(ValueError, 'oversized ZIP member'):
            release.verify_archive(tampered)

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
            'ui/history_signals.js',
            'ui/history_print.js',
            'recovery/RESCUE_READINESS.cmd',
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

    def test_developer_preflight_not_shipped_in_product(self):
        self.assertNotIn('tools/preflight.py', release.ALLOWLIST)
        self.assertNotIn('tests/test_preflight.py', release.ALLOWLIST)

    def test_checksum_symlink_rejected_without_touching_target_or_existing_zip(self):
        archive, _ = release.build_internal(self.root, self.root / 'dist-internal')
        original_zip = archive.read_bytes()
        checksum = Path(str(archive) + '.sha256')
        checksum.unlink()
        sentinel = self.root / 'do-not-modify.txt'
        sentinel.write_text('KEEP ORIGINAL', encoding='ascii')
        try:
            checksum.symlink_to(sentinel)
        except (OSError, NotImplementedError):
            self.skipTest('File symlinks unavailable on this host')
        with self.assertRaisesRegex(ValueError, 'symlink checksum'):
            release.build_internal(self.root, self.root / 'dist-internal')
        self.assertEqual(sentinel.read_text(encoding='ascii'), 'KEEP ORIGINAL')
        self.assertEqual(archive.read_bytes(), original_zip)
        self.assertTrue(checksum.is_symlink())

    def test_foreign_temporary_files_are_never_rewritten_or_deleted(self):
        output = self.root / 'dist-internal'
        output.mkdir(exist_ok=True)
        archive = output / f'{release.FOLDER}_INTERNAL_TEST_ONLY.zip'
        pending = Path(str(archive) + '.tmp')
        pending.write_bytes(b'OTHER-PROCESS-ZIP')
        with self.assertRaisesRegex(ValueError, 'incomplete internal build'):
            release.build_internal(self.root, output)
        self.assertEqual(pending.read_bytes(), b'OTHER-PROCESS-ZIP')
        pending.unlink()
        checksum_pending = Path(str(archive) + '.sha256.tmp')
        checksum_pending.write_bytes(b'OTHER-PROCESS-CHECKSUM')
        with self.assertRaisesRegex(ValueError, 'incomplete internal build'):
            release.build_internal(self.root, output)
        self.assertEqual(checksum_pending.read_bytes(), b'OTHER-PROCESS-CHECKSUM')
        self.assertFalse(archive.exists())

    def test_checksum_rebuild_uses_exclusive_temp_and_preserves_verified_output(self):
        archive, first_sha = release.build_internal(self.root, self.root / 'dist-internal')
        first_bytes = archive.read_bytes()
        checksum_file = Path(str(archive) + '.sha256')
        self.assertEqual(checksum_file.read_text(encoding='ascii'),
                         f'{first_sha}  {archive.name}\\n')
        archive2, second_sha = release.build_internal(self.root, self.root / 'dist-internal')
        self.assertEqual(archive, archive2)
        self.assertEqual(first_sha, second_sha)
        self.assertEqual(archive2.read_bytes(), first_bytes)
        self.assertFalse(Path(str(checksum_file) + '.tmp').exists())
        self.assertFalse(Path(str(archive) + '.tmp').exists())
        self.assertEqual(release.verify_archive(archive, require_sidecar=True), second_sha)

    def test_no_default_public_release(self):
        with self.assertRaises(SystemExit) as raised:
            release.main([])
        self.assertEqual(raised.exception.code, 2)


if __name__ == '__main__':
    unittest.main(verbosity=2)
