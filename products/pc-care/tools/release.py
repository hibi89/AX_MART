"""Deterministic OFFLINE alpha test packaging. Never publishes or executes repair."""
from __future__ import annotations

import argparse
import hashlib
import os
from pathlib import Path
import sys
import zipfile

VERSION = 'v0.1-alpha'
FOLDER = f'AXMART_PC_CARE_USB_{VERSION}'
ROOT = Path(__file__).resolve().parents[1]
ALLOWLIST = (
    'README.md',
    'RUN_HEALTH_CHECK.cmd',
    'RUN_SELF_TEST.cmd',
    'RUN_SAFE_REPAIR.cmd',
    'tools/diagnose.ps1',
    'tools/repair.ps1',
    'tests/windows_smoke.ps1',
    'recovery/WINRE_READ_ONLY.cmd',
    'docs/SAFETY.md',
    'docs/TROUBLESHOOTING.md',
    'docs/PRODUCT_SCOPE.md',
)
MANIFEST = 'MANIFEST-SHA256.txt'
MAX_FILE_BYTES = 5_000_000
ZIP_DATE = (2026, 10, 30, 0, 0, 0)


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def source_files(root: Path) -> dict[str, bytes]:
    content = {}
    for name in ALLOWLIST:
        path = root / name
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


def verify_archive(path: Path) -> str:
    with zipfile.ZipFile(path, 'r') as archive:
        if archive.testzip() is not None:
            raise ValueError('Bad archive CRC')
        names = archive.namelist()
        expected = {f'{FOLDER}/{x}' for x in ALLOWLIST} | {f'{FOLDER}/{MANIFEST}'}
        if len(names) != len(expected) or set(names) != expected:
            raise ValueError('Unexpected, duplicate, or missing ZIP member')
        actual = {name: archive.read(f'{FOLDER}/{name}') for name in ALLOWLIST}
        for name, data in actual.items():
            if len(data) > MAX_FILE_BYTES:
                raise ValueError(f'Archive member too large: {name}')
            if name.endswith('.ps1') and not data.startswith(b'\xef\xbb\xbf'):
                raise ValueError(f'Missing PowerShell BOM in package: {name}')
        if archive.read(f'{FOLDER}/{MANIFEST}') != manifest_bytes(actual):
            raise ValueError('Internal manifest does not match archive')
    actual_digest = digest(path.read_bytes())
    checksum_file = Path(str(path) + '.sha256')
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
    # Build to a temporary file, then atomically replace to avoid a partial ZIP.
    pending = output / (zip_path.name + '.tmp')
    if pending.is_symlink():
        raise ValueError('Refusing symlink temp target')
    try:
        with zipfile.ZipFile(pending, 'w', compression=zipfile.ZIP_DEFLATED, compresslevel=9) as archive:
            for name, data in sorted(contents.items()):
                zip_member(archive, name, data)
            zip_member(archive, MANIFEST, manifest_bytes(contents))
        # Validate contents before exposing the completed file name.
        verify_archive(pending)
        os.replace(pending, zip_path)
        checksum = digest(zip_path.read_bytes())
        Path(str(zip_path) + '.sha256').write_text(f'{checksum}  {zip_path.name}\n', encoding='ascii')
        if verify_archive(zip_path) != checksum:
            raise ValueError('Post-write checksum verification failed')
    finally:
        if pending.exists():
            pending.unlink()
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
            checksum = verify_archive(args.verify)
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
