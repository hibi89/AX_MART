"""One-shot, offline developer QA for AXMART PC CARE.

Runs tests and builds an internal-only temporary ZIP; NEVER runs diagnostics,
repairs, customer data collectors, Git mutations, or a public release.
"""
from __future__ import annotations

import argparse
from datetime import datetime, timezone
from concurrent.futures import ThreadPoolExecutor
import hashlib
import json
import os
import re
from pathlib import Path
import shutil
import secrets
import subprocess
import sys
import tempfile
import time

ROOT = Path(__file__).resolve().parents[1]
JS_SCRIPTS = (
    'ui/history_compare.js', 'ui/history_signals.js', 'ui/qr_ui.js',
    'ui/qrcode.min.js', 'ui/history_print.js',
)
NODE_TESTS = (
    'tests/test_qr_ui.cjs', 'tests/test_qr_vendor.cjs',
    'tests/test_history_compare.cjs', 'tests/test_history_dom.cjs',
    'tests/test_history_signals.cjs', 'tests/test_history_batch.cjs',
    'tests/test_history_print.cjs', 'tests/test_history_issue_allowlist.cjs',
    'tests/test_history_evidence_integration.cjs',
)
NOT_VERIFIED = (
    'real Windows 11 system diagnosis and permissions',
    'real Edge/Chrome file:// execution, USB unicode paths',
    'QR camera scanning and A4 PDF print layout',
    'WinRE / physical-device backup / real repair',
    'public production site and distribution approval',
)


def command(name: str, argv: list[str], *, cwd: Path = ROOT) -> dict:
    """Execute exactly the named local test command, capturing bounded output."""
    started = time.monotonic()
    try:
        proc = subprocess.run(argv, cwd=cwd, capture_output=True, text=True,
                              errors='replace', check=False, timeout=180)
        return dict(name=name, status='pass' if proc.returncode == 0 else 'fail',
                    exit_code=proc.returncode, seconds=round(time.monotonic()-started, 2),
                    output=(proc.stdout + '\n' + proc.stderr)[-5000:])
    except (OSError, subprocess.TimeoutExpired) as exc:
        return dict(name=name, status='blocked', exit_code=None,
                    seconds=round(time.monotonic()-started, 2),
                    output=type(exc).__name__)


def classify_qa_status(stages: list[dict]) -> str:
    """Never label skipped native Windows coverage as complete QA."""
    if not stages:
        return 'fail'
    statuses = [item.get('status') for item in stages]
    if 'fail' in statuses or any(x not in ('pass', 'blocked', 'not-run', 'fail') for x in statuses):
        return 'fail'
    if 'blocked' in statuses:
        return 'blocked'
    if 'not-run' in statuses:
        return 'partial'
    return 'pass'


def classify_full_qa_stages(stages: list[dict]) -> str:
    """Require actual Node tests and verified ZIP before claiming a QA PASS.

    A failing/blocked syntax check or ZIP build may stand in for its stage to
    report the failure, but an intermediate success is never a completed gate.
    """
    if len(stages) != 4:
        return 'fail'
    slots = set()
    for stage in stages:
        name = stage.get('name')
        state = stage.get('status')
        if name == 'python-tests':
            slot = 'python'
        elif name == 'node-tests':
            slot = 'node'
        elif name == 'internal-zip':
            slot = 'zip'
        elif name == 'windows-powershell-51-synthetic':
            slot = 'windows'
        elif (isinstance(name, str) and
              name in {'node-syntax:' + script for script in JS_SCRIPTS} and
              state in ('fail', 'blocked')):
            slot = 'node'
        elif name in ('internal-zip-build', 'internal-zip-verify') and state in ('fail', 'blocked'):
            slot = 'zip'
        else:
            return 'fail'
        if slot in slots:
            return 'fail'
        slots.add(slot)
    return classify_qa_status(stages) if slots == {'python', 'node', 'zip', 'windows'} else 'fail'


def run_qa(root: Path, *, windows_synthetic: bool | None = None) -> dict:
    """Run independent QA stages concurrently; never regard a skip as a pass."""
    root = root.resolve()
    node = shutil.which('node')
    on_windows = os.name == 'nt' if windows_synthetic is None else windows_synthetic
    ps51 = (Path(os.environ.get('SystemRoot', r'C:\Windows')) /
            'System32/WindowsPowerShell/v1.0/powershell.exe') if on_windows else None
    stages: list[dict] = []
    def python_suite():
        result=command('python-tests', [sys.executable, '-m', 'unittest',
                         'discover', '-s', 'tests', '-p', 'test_*.py', '-v'], cwd=root)
        if result['status']=='pass':
            match=re.search(r'Ran ([0-9]+) tests?\b',result['output'])
            if not match or int(match.group(1)) < 1:
                return dict(name='python-tests',status='fail',output='No Python tests verified')
            result['tests']=int(match.group(1))
            skipped=re.search(r'\bskipped=([0-9]+)\b',result['output'])
            result['skipped']=int(skipped.group(1)) if skipped else 0
        return result
    def node_suite():
        if not node:
            return dict(name='node-tests', status='blocked', output='Node.js not installed')
        missing = [p for p in JS_SCRIPTS + NODE_TESTS if not (root / p).is_file()]
        if missing:
            return dict(name='node-tests', status='blocked', output='Missing: '+', '.join(missing))
        for js in JS_SCRIPTS:
            result=command('node-syntax', [node, '--check', js], cwd=root)
            if result['status'] != 'pass':
                result['name']='node-syntax:'+js
                return result
        # Keep Node 18.0+ compatibility; --test-reporter was added in 18.15.
        # Accept TAP (`# tests N`) and spec (`ℹ tests N`) summaries.
        result=command('node-tests', [node, '--test', *NODE_TESTS], cwd=root)
        if result['status']=='pass':
            match=re.search(r'(?m)^\S+\s+tests\s+([0-9]+)\s*$',result['output'])
            if not match or int(match.group(1)) < 1:
                return dict(name='node-tests',status='fail',output='No Node tests verified')
            result['tests']=int(match.group(1))
            skipped=re.search(r'(?m)^\S+\s+skipped\s+([0-9]+)\s*
        with tempfile.TemporaryDirectory(prefix='axmart-pc-care-internal-qa-') as tmp:
            dest = Path(tmp)
            packer = root / 'tools/release.py'
            if not packer.is_file():
                return dict(name='internal-zip',status='blocked',output='Missing release.py')
            build = command('internal-zip-build', [sys.executable, str(packer),
                            '--internal-testing', '--root', str(root), '--output', str(dest)], cwd=root)
            if build['status'] != 'pass':
                return build
            archives = list(dest.glob('*_INTERNAL_TEST_ONLY.zip'))
            if len(archives) != 1:
                return dict(name='internal-zip',status='fail',output='Expected exactly one internal ZIP')
            archive=archives[0]
            verify=command('internal-zip-verify', [sys.executable, str(packer),
                            '--verify', str(archive)], cwd=root)
            if verify['status'] != 'pass':
                return verify
            size=archive.stat().st_size
            actual=hashlib.sha256(archive.read_bytes()).hexdigest()
            sidecar=Path(str(archive)+'.sha256')
            if not sidecar.is_file() or sidecar.read_text(encoding='ascii') != f'{actual}  {archive.name}\n':
                return dict(name='internal-zip',status='fail',output='SHA256 sidecar mismatch')
            return dict(name='internal-zip',status='pass',zip_size_bytes=size,sha256=actual,
                        note='Temporary internal QA ZIP verified then deleted; not published')
    tasks=[python_suite,node_suite,zip_suite]
    with ThreadPoolExecutor(max_workers=3) as pool:
        stages.extend(list(pool.map(lambda fn: fn(), tasks)))
    if on_windows:
        if not ps51 or not ps51.is_file():
            stages.append(dict(name='windows-powershell-51-synthetic',status='blocked',output='Trusted Windows PS5.1 unavailable'))
        else:
            stages.append(command('windows-powershell-51-synthetic', [str(ps51),'-NoProfile',
                    '-NonInteractive','-ExecutionPolicy','Bypass','-File',
                    'tests/windows_smoke.ps1'],cwd=root))
    else:
        stages.append(dict(name='windows-powershell-51-synthetic',status='not-run',
                           output='Non-Windows host: Windows test not executed'))
    status = classify_full_qa_stages(stages)
    return dict(status=status,stages=stages,not_verified=NOT_VERIFIED,
                warning='PASS covers synthetic/source QA only, NOT actual Windows/WinRE operation')


def safe_qa_receipt(result: dict) -> dict:
    """Shareable synthetic-QA receipt: no logs, paths, commands, or user data."""
    allowed = {'pass', 'fail', 'blocked', 'partial', 'not-run'}
    status = result.get('status')
    if status not in allowed or status != classify_full_qa_stages(result.get('stages', [])):
        status = 'fail'
    stages = []
    expected_names = {'python-tests', 'node-tests', 'internal-zip', 'internal-zip-build',
                      'internal-zip-verify', 'windows-powershell-51-synthetic'}
    expected_names.update('node-syntax:' + name for name in JS_SCRIPTS)
    for stage in result.get('stages', []):
        name = stage.get('name', '')
        name = name if isinstance(name, str) and name in expected_names else 'unknown'
        state = stage.get('status')
        if state not in allowed:
            state = 'fail'
        record = {'name': name, 'status': state}
        count = stage.get('tests')
        if isinstance(count, int) and not isinstance(count, bool) and 0 <= count <= 100000:
            record['tests'] = count
        stages.append(record)
    return {
        'schemaVersion': 1,
        'product': 'AXMART PC CARE internal QA',
        'scope': 'synthetic_only_no_live_diagnosis',
        'status': status,
        'stages': stages,
        'unverified': list(NOT_VERIFIED),
        'generatedUtc': datetime.now(timezone.utc).isoformat(timespec='seconds'),
    }


def write_qa_receipt(result: dict, directory: Path) -> Path:
    """Create one private report without overwriting or serializing raw test output."""
    directory = Path(directory)
    if directory.is_symlink():
        raise ValueError('QA receipt directory cannot be a symlink')
    directory.mkdir(parents=True, exist_ok=True)
    document = safe_qa_receipt(result)
    data = (json.dumps(document, ensure_ascii=False, indent=2) + '\n').encode('utf-8')
    if len(data) > 16000:
        raise ValueError('QA receipt size exceeded')
    label = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')
    filename = directory / f'pc-care-qa-{label}-{secrets.token_hex(4)}.json'
    created = False
    try:
        with os.fdopen(os.open(filename, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600), 'wb') as target:
            created = True
            target.write(data)
            target.flush()
            os.fsync(target.fileno())
    except Exception:
        if created:
            filename.unlink(missing_ok=True)
        raise
    return filename


def main(argv: list[str] | None = None) -> int:
    parser=argparse.ArgumentParser(description='AXMART internal offline QA, NOT a public release')
    parser.add_argument('--root',type=Path,default=ROOT,help='working product tree')
    parser.add_argument('--receipt-dir', type=Path, help='Save a private, sanitized synthetic-QA receipt')
    args=parser.parse_args(argv)
    result=run_qa(args.root)
    for stage in result['stages']:
        print(f"{stage['status'].upper()}: {stage['name']}")
        if stage['status'] not in ('pass','not-run') and stage.get('output'):
            print(stage['output'][-1800:])
    print(json.dumps({k:v for k,v in result.items() if k!='stages'},ensure_ascii=False))
    if args.receipt_dir is not None:
        try:
            receipt_path = write_qa_receipt(result, args.receipt_dir)
            print(f'Local QA receipt: {receipt_path}')
        except (OSError, ValueError) as exc:
            print(f'QA RECEIPT FAILED: {type(exc).__name__}', file=sys.stderr)
            return 1
    # Partial native coverage is not a PASS and must propagate a nonzero exit.
    return 0 if result['status']=='pass' else (2 if result['status']=='partial' else 1)


if __name__ == '__main__':
    raise SystemExit(main())
,result['output'])
            result['skipped']=int(skipped.group(1)) if skipped else 0
        return result
    def zip_suite():
        with tempfile.TemporaryDirectory(prefix='axmart-pc-care-internal-qa-') as tmp:
            dest = Path(tmp)
            packer = root / 'tools/release.py'
            if not packer.is_file():
                return dict(name='internal-zip',status='blocked',output='Missing release.py')
            build = command('internal-zip-build', [sys.executable, str(packer),
                            '--internal-testing', '--root', str(root), '--output', str(dest)], cwd=root)
            if build['status'] != 'pass':
                return build
            archives = list(dest.glob('*_INTERNAL_TEST_ONLY.zip'))
            if len(archives) != 1:
                return dict(name='internal-zip',status='fail',output='Expected exactly one internal ZIP')
            archive=archives[0]
            verify=command('internal-zip-verify', [sys.executable, str(packer),
                            '--verify', str(archive)], cwd=root)
            if verify['status'] != 'pass':
                return verify
            size=archive.stat().st_size
            actual=hashlib.sha256(archive.read_bytes()).hexdigest()
            sidecar=Path(str(archive)+'.sha256')
            if not sidecar.is_file() or sidecar.read_text(encoding='ascii') != f'{actual}  {archive.name}\n':
                return dict(name='internal-zip',status='fail',output='SHA256 sidecar mismatch')
            return dict(name='internal-zip',status='pass',zip_size_bytes=size,sha256=actual,
                        note='Temporary internal QA ZIP verified then deleted; not published')
    tasks=[python_suite,node_suite,zip_suite]
    with ThreadPoolExecutor(max_workers=3) as pool:
        stages.extend(list(pool.map(lambda fn: fn(), tasks)))
    if on_windows:
        if not ps51 or not ps51.is_file():
            stages.append(dict(name='windows-powershell-51-synthetic',status='blocked',output='Trusted Windows PS5.1 unavailable'))
        else:
            stages.append(command('windows-powershell-51-synthetic', [str(ps51),'-NoProfile',
                    '-NonInteractive','-ExecutionPolicy','Bypass','-File',
                    'tests/windows_smoke.ps1'],cwd=root))
    else:
        stages.append(dict(name='windows-powershell-51-synthetic',status='not-run',
                           output='Non-Windows host: Windows test not executed'))
    status = classify_full_qa_stages(stages)
    return dict(status=status,stages=stages,not_verified=NOT_VERIFIED,
                warning='PASS covers synthetic/source QA only, NOT actual Windows/WinRE operation')


def safe_qa_receipt(result: dict) -> dict:
    """Shareable synthetic-QA receipt: no logs, paths, commands, or user data."""
    allowed = {'pass', 'fail', 'blocked', 'partial', 'not-run'}
    status = result.get('status')
    if status not in allowed or status != classify_full_qa_stages(result.get('stages', [])):
        status = 'fail'
    stages = []
    expected_names = {'python-tests', 'node-tests', 'internal-zip', 'internal-zip-build',
                      'internal-zip-verify', 'windows-powershell-51-synthetic'}
    expected_names.update('node-syntax:' + name for name in JS_SCRIPTS)
    for stage in result.get('stages', []):
        name = stage.get('name', '')
        name = name if isinstance(name, str) and name in expected_names else 'unknown'
        state = stage.get('status')
        if state not in allowed:
            state = 'fail'
        record = {'name': name, 'status': state}
        count = stage.get('tests')
        if isinstance(count, int) and not isinstance(count, bool) and 0 <= count <= 100000:
            record['tests'] = count
        stages.append(record)
    return {
        'schemaVersion': 1,
        'product': 'AXMART PC CARE internal QA',
        'scope': 'synthetic_only_no_live_diagnosis',
        'status': status,
        'stages': stages,
        'unverified': list(NOT_VERIFIED),
        'generatedUtc': datetime.now(timezone.utc).isoformat(timespec='seconds'),
    }


def write_qa_receipt(result: dict, directory: Path) -> Path:
    """Create one private report without overwriting or serializing raw test output."""
    directory = Path(directory)
    if directory.is_symlink():
        raise ValueError('QA receipt directory cannot be a symlink')
    directory.mkdir(parents=True, exist_ok=True)
    document = safe_qa_receipt(result)
    data = (json.dumps(document, ensure_ascii=False, indent=2) + '\n').encode('utf-8')
    if len(data) > 16000:
        raise ValueError('QA receipt size exceeded')
    label = datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')
    filename = directory / f'pc-care-qa-{label}-{secrets.token_hex(4)}.json'
    created = False
    try:
        with os.fdopen(os.open(filename, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600), 'wb') as target:
            created = True
            target.write(data)
            target.flush()
            os.fsync(target.fileno())
    except Exception:
        if created:
            filename.unlink(missing_ok=True)
        raise
    return filename


def main(argv: list[str] | None = None) -> int:
    parser=argparse.ArgumentParser(description='AXMART internal offline QA, NOT a public release')
    parser.add_argument('--root',type=Path,default=ROOT,help='working product tree')
    parser.add_argument('--receipt-dir', type=Path, help='Save a private, sanitized synthetic-QA receipt')
    args=parser.parse_args(argv)
    result=run_qa(args.root)
    for stage in result['stages']:
        print(f"{stage['status'].upper()}: {stage['name']}")
        if stage['status'] not in ('pass','not-run') and stage.get('output'):
            print(stage['output'][-1800:])
    print(json.dumps({k:v for k,v in result.items() if k!='stages'},ensure_ascii=False))
    if args.receipt_dir is not None:
        try:
            receipt_path = write_qa_receipt(result, args.receipt_dir)
            print(f'Local QA receipt: {receipt_path}')
        except (OSError, ValueError) as exc:
            print(f'QA RECEIPT FAILED: {type(exc).__name__}', file=sys.stderr)
            return 1
    # Partial native coverage is not a PASS and must propagate a nonzero exit.
    return 0 if result['status']=='pass' else (2 if result['status']=='partial' else 1)


if __name__ == '__main__':
    raise SystemExit(main())
