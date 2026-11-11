"""Deterministic OFFLINE alpha test packaging. Never publishes or executes repair."""
from __future__ import annotations

import argparse
import hashlib
import os
import shutil
import stat
from pathlib import Path
import sys
import zipfile

VERSION = 'v0.1-alpha'
FOLDER = f'AXMART_PC_CARE_USB_{VERSION}'
ROOT = Path(__file__).resolve().parents[1]
ALLOWLIST = (
    'README.md',
    'START_PC_CARE.cmd',
    'RUN_HEALTH_CHECK.cmd',
    'RUN_SELF_TEST.cmd',
    'RUN_SAFE_REPAIR.cmd',
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
    'ui/case_review.html',
    'ui/case_review.js',
    'tools/report_io.ps1',
    'tools/repair.ps1',
    'tests/windows_smoke.ps1',
    'tests/event_analysis.tests.ps1',
    'tests/incident_analysis.tests.ps1',
    'tests/telemetry_analysis.tests.ps1',
    'tests/driver_timeline.tests.ps1',
    'tests/consultation_report.tests.ps1',
    'tests/share_payload.tests.ps1',
    'tests/report_io.tests.ps1',
    'recovery/WINRE_READ_ONLY.cmd',
    'recovery/RESCUE_READINESS.cmd',
    'docs/SAFETY.md',
    'docs/TROUBLESHOOTING.md',
    'docs/PRODUCT_SCOPE.md',
)
MANIFEST = 'MANIFEST-SHA256.txt'
MAX_FILE_BYTES = 5_000_000
ZIP_DATE = (2026, 10, 30, 0, 0, 0)


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def file_digest(path: Path) -> str:
    # Never read an external archive fully into memory just to hash it.
    sha = hashlib.sha256()
    with path.open('rb') as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b''):
            sha.update(chunk)
    return sha.hexdigest()


def source_files(root: Path) -> dict[str, bytes]:
    content = {}
    for name in ALLOWLIST:
        path = root / name
        # Parent symlinks can escape root even if the leaf is a regular file.
        current = root
        for part in Path(name).parts[:-1]:
            current = current / part
            if current.is_symlink():
                raise ValueError(f'Symlinked source directory: {name}')
        if path.is_symlink() or not path.is_file():
            raise ValueError(f'Missing, unsafe, or symlinked source: {name}')
        if path.stat().st_size > MAX_FILE_BYTES:
            raise ValueError(f'Unexpectedly large source: {name}')
        data = path.read_bytes()
        if not data:
            raise ValueError(f'Empty source: {name}')
        if name.endswith('.ps1') and not data.startswith(b'\xef\xbb\xbf'):
            raise ValueError(f'Windows PowerShell 5.1 requires UTF-8 BOM: {name}')
        content[name] = data
    return content


def manifest_bytes(content: dict[str, bytes]) -> bytes:
    return ''.join(f'{digest(data)}  {name}\n' for name, data in sorted(content.items())).encode('ascii')


def zip_member(archive: zipfile.ZipFile, name: str, data: bytes) -> None:
    info = zipfile.ZipInfo(f'{FOLDER}/{name}', date_time=ZIP_DATE)
    info.compress_type = zipfile.ZIP_DEFLATED
    info.create_system = 0  # Windows-friendly, stable metadata
    info.external_attr = 0o644 << 16
    archive.writestr(info, data, compress_type=zipfile.ZIP_DEFLATED, compresslevel=9)


def verify_archive(path: Path, *, require_sidecar: bool = False) -> str:
    """Bounded, fail-closed archive verification before any bulk decompression."""
    with zipfile.ZipFile(path, 'r') as archive:
        infos = archive.infolist()
        expected = {f'{FOLDER}/{x}' for x in ALLOWLIST} | {f'{FOLDER}/{MANIFEST}'}
        if len(infos) != len(expected) or {info.filename for info in infos} != expected:
            raise ValueError('Unexpected, duplicate, or missing ZIP member')
        manifest_limit = max(4096, len(ALLOWLIST) * 160)
        for info in infos:
            limit = manifest_limit if info.filename == f'{FOLDER}/{MANIFEST}' else MAX_FILE_BYTES
            if info.is_dir() or info.flag_bits & 1 or info.file_size < 1 or info.file_size > limit:
                raise ValueError('Unsafe or oversized ZIP member: ' + info.filename)
            if info.create_system == 3 and stat.S_ISLNK(info.external_attr >> 16):
                raise ValueError('Symlink ZIP member rejected: ' + info.filename)
        hashes = {}
        for name in ALLOWLIST:
            with archive.open(f'{FOLDER}/{name}', 'r') as stream:
                data = stream.read(MAX_FILE_BYTES + 1)
                if len(data) > MAX_FILE_BYTES or stream.read(1):
                    raise ValueError('Archive member too large: ' + name)
            if name.endswith('.ps1') and not data.startswith(b'\xef\xbb\xbf'):
                raise ValueError(f'Missing PowerShell BOM in package: {name}')
            hashes[name] = digest(data)
        with archive.open(f'{FOLDER}/{MANIFEST}', 'r') as stream:
            manifest = stream.read(manifest_limit + 1)
            if len(manifest) > manifest_limit or stream.read(1):
                raise ValueError('Manifest too large')
        wanted = ''.join(f'{hashes[name]}  {name}\n' for name in sorted(hashes)).encode('ascii')
        if manifest != wanted:
            raise ValueError('Internal manifest does not match archive')
    actual_digest = file_digest(path)
    checksum_file = Path(str(path) + '.sha256')
    if require_sidecar and not checksum_file.is_file():
        raise ValueError('Required SHA256 sidecar is missing')
    if checksum_file.is_file():
        expected_line = f'{actual_digest}  {path.name}\n'
        if checksum_file.read_text(encoding='ascii') != expected_line:
            raise ValueError('SHA256 sidecar does not match ZIP')
    return actual_digest

def build_internal(root: Path, output: Path) -> tuple[Path, str]:
    contents = source_files(root)
    output.mkdir(parents=True, exist_ok=True)
    zip_path = output / f'{FOLDER}_INTERNAL_TEST_ONLY.zip'
    if zip_path.is_symlink():
        raise ValueError('Refusing symlink output target')
    sidecar = Path(str(zip_path) + '.sha256')
    # A crafted sidecar symlink must never redirect an overwrite to user files.
    if sidecar.is_symlink():
        raise ValueError('Refusing symlink checksum target')
    # Build in unique exclusive files; a conflicting .tmp belongs to someone else.
    pending = output / (zip_path.name + '.tmp')
    checksum_pending = Path(str(sidecar) + '.tmp')
    if pending.is_symlink() or checksum_pending.is_symlink():
        raise ValueError('Refusing symlink temp target')
    if pending.exists() or checksum_pending.exists():
        raise ValueError('Existing incomplete internal build; manual review required')
    owned_zip_temp = False
    owned_checksum_temp = False
    try:
        with pending.open('xb') as stream:
            owned_zip_temp = True
            with zipfile.ZipFile(stream, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
                for name, data in sorted(contents.items()):
                    zip_member(archive, name, data)
                zip_member(archive, MANIFEST, manifest_bytes(contents))
        # Validate contents before exposing the completed file name.
        verify_archive(pending)
        checksum = file_digest(pending)
        with checksum_pending.open('x', encoding='ascii', newline='\n') as target:
            owned_checksum_temp = True
            target.write(f'{checksum}  {zip_path.name}\n')
        # Existing internal artifacts may belong to another run. Reuse only a
        # verified byte-identical pair; never replace a different ZIP or sidecar.
        if zip_path.is_symlink() or sidecar.is_symlink():
            raise ValueError('Refusing symlink output target')
        if zip_path.exists() or sidecar.exists():
            if zip_path.is_file() and sidecar.is_file():
                try:
                    if verify_archive(zip_path, require_sidecar=True) == checksum:
                        return zip_path, checksum
                except (OSError, ValueError, zipfile.BadZipFile):
                    pass
            raise ValueError('Existing internal output differs or is incomplete; manual review required')
        # os.replace would silently overwrite a file created after the check.
        # Exclusive creates protect existing files even during concurrent runs.
        owned_final_zip = False
        owned_final_sidecar = False
        try:
            with zip_path.open('xb') as target:
                owned_final_zip = True
                with pending.open('rb') as source:
                    shutil.copyfileobj(source, target)
                target.flush()
                os.fsync(target.fileno())
            with sidecar.open('x', encoding='ascii', newline='\n') as target:
                owned_final_sidecar = True
                target.write(f'{checksum}  {zip_path.name}\n')
                target.flush()
                os.fsync(target.fileno())
            if verify_archive(zip_path, require_sidecar=True) != checksum:
                raise ValueError('Post-write checksum verification failed')
        except Exception:
            # Roll back only the final paths created by this invocation.
            if owned_final_sidecar:
                sidecar.unlink(missing_ok=True)
            if owned_final_zip:
                zip_path.unlink(missing_ok=True)
            raise
    finally:
        # Never delete someone else's colliding temporary artifact.
        if owned_zip_temp and pending.exists() and not pending.is_symlink():
            pending.unlink()
        if owned_checksum_temp and checksum_pending.exists() and not checksum_pending.is_symlink():
            checksum_pending.unlink()
    return zip_path, checksum


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description='Internal Windows USB alpha ZIP packer. Does not publish or run repair.')
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument('--internal-testing', action='store_true', help='Create internal-only test ZIP; NOT a beta release.')
    group.add_argument('--verify', type=Path, help='Verify exact allowlist and hashes of an existing ZIP.')
    parser.add_argument('--root', type=Path, default=ROOT, help='Source directory (for tests).')
    parser.add_argument('--output', type=Path, help='Output directory; defaults to root/dist-internal.')
    args = parser.parse_args(argv)
    try:
        if args.verify:
            checksum = verify_archive(args.verify, require_sidecar=True)
            print(f'INTEGRITY PASS (NOT WINDOWS RUNTIME VERIFIED): {checksum}')
        else:
            zip_path, checksum = build_internal(args.root, args.output or args.root / 'dist-internal')
            print(f'INTERNAL TEST ZIP: {zip_path}')
            print(f'SHA256: {checksum}')
            print('NOT APPROVED FOR PUBLIC DISTRIBUTION. Windows/WinRE/repair tests pending.')
        return 0
    except (OSError, ValueError, zipfile.BadZipFile) as exc:
        print(f'PACKAGE FAILED: {exc}', file=sys.stderr)
        return 1


if __name__ == '__main__':
    raise SystemExit(main())
