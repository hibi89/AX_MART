"""Explicit opt-in, no-network PC CARE consultation packet from a local report.

Not an automatic diagnosis, authenticated attestation, source evidence export,
backup, WinRE recovery, or permission to perform repair.
"""
from __future__ import annotations

import argparse
from datetime import datetime
import hashlib
from html import escape
import json
import os
from pathlib import Path
import re
import stat
import sys

FORMAT = 'axmart-pc-care-consultation-packet-v1'
STATUSES = frozenset(('위험 신호', '주의 필요', '확인 불완전', '관찰 범위 내 특이사항 없음'))
STORAGE = frozenset(('미확인', '경고 신호 관측', 'Windows 정상 신호 (보증 아님)'))
CODES = frozenset(('저장장치 상태 경고','저장장치 관련 이벤트','저장 공간 매우 부족',
                   '저장 공간 부족','BugCheck 관련 기록','비정상 종료 신호',
                   'Windows 업데이트 설치 실패 기록','장치 구성 코드 점검'))
EVENT_IDS = frozenset((19, 20, 41, 6008, 1001, 7, 51, 55, 129, 153, 157))
MAX_SOURCE = 2 * 1024 * 1024
MAX_OUTPUT = 16 * 1024
FILE_NAMES = ('case-summary.json', 'case-summary.html', 'case-manifest.json')


def block():
    raise ValueError('PC_CARE_CASEPACK_BLOCKED')


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def object_only(value):
    return isinstance(value, dict)


def read_local(path: Path, extension: str, maximum: int) -> bytes:
    if not isinstance(path, Path) or not path.is_absolute() or path.suffix.lower() != extension:
        block()
    # Every existing ancestor must be a real directory, not a link or junction.
    for parent in (path, *path.parents):
        try:
            info = parent.lstat()
        except (FileNotFoundError, PermissionError, OSError):
            block()
        if stat.S_ISLNK(info.st_mode):
            block()
    try:
        before = path.lstat()
        if not stat.S_ISREG(before.st_mode) or not (0 < before.st_size <= maximum):
            block()
        flags = os.O_RDONLY | getattr(os, 'O_NOFOLLOW', 0)
        descriptor = os.open(path, flags)
        try:
            opened = os.fstat(descriptor)
            if (opened.st_dev, opened.st_ino, opened.st_size) != (before.st_dev, before.st_ino, before.st_size):
                block()
            with os.fdopen(os.dup(descriptor), 'rb') as source:
                content = source.read(maximum + 1)
            after = os.fstat(descriptor)
            if (after.st_dev, after.st_ino, after.st_size, after.st_mtime_ns) != (before.st_dev, before.st_ino, before.st_size, before.st_mtime_ns):
                block()
        finally:
            os.close(descriptor)
        if len(content) != before.st_size or len(content) > maximum:
            block()
        return content
    except (OSError, UnicodeError):
        block()


def json_decode(data: bytes):
    try:
        return json.loads(data.decode('utf-8', errors='strict'))
    except (UnicodeError, ValueError):
        block()


def safe_consultation(data: bytes) -> dict:
    report = json_decode(data)
    if not object_only(report) or report.get('schemaVersion') != 1 or report.get('product') != 'AXMART PC CARE' or report.get('mode') != 'read-only':
        block()
    original = report.get('consultation')
    if not object_only(original) or original.get('schemaVersion') != 1 or original.get('containsIdentifiers') is not False:
        block()
    label = original.get('assessment')
    if label not in STATUSES or report.get('assessment') != label:
        block()
    # This is an evidence-minimized customer handoff, NOT a second diagnosis.
    # A "no issue observed" label cannot survive a missing disk collector or
    # contradictory known warning. Preserve uncertainty, never fabricate OK.
    observations = report.get('observations')
    collection = observations.get('collectionStatus') if object_only(observations) else None
    disk_collected = (object_only(collection) and collection.get('physicalDisks') == 'collected')
    storage = original.get('storageSignal')
    if storage not in STORAGE:
        block()
    build = str(original.get('windowsBuild', ''))
    if not re.fullmatch(r'[0-9]{1,6}', build):
        build = '미확인'
    raw_codes = original.get('reviewItems')
    if not isinstance(raw_codes, list) or len(raw_codes) > 12 or any(not isinstance(s, str) or s not in CODES for s in raw_codes):
        block()
    if label == '관찰 범위 내 특이사항 없음':
        if not disk_collected:
            label = '확인 불완전'
        elif storage == '경고 신호 관측' or raw_codes:
            label = '주의 필요'
    raw_events = original.get('recordedEvents')
    if not isinstance(raw_events, list) or len(raw_events) > 4:
        block()
    events = []
    for item in raw_events:
        if not object_only(item) or type(item.get('eventId')) is not int or item['eventId'] not in EVENT_IDS:
            block()
        timestamp = item.get('recordedUtc')
        if not isinstance(timestamp, str) or not re.fullmatch(r'\d{4}-\d{2}-\d{2} \d{2}:\d{2}', timestamp):
            block()
        try:
            datetime.strptime(timestamp, '%Y-%m-%d %H:%M')
        except ValueError:
            block()
        # Never copy raw provider, message, host identity, account, paths or source text.
        events.append({'event_id': item['eventId'], 'recorded_utc': timestamp})
    return {'format': FORMAT, 'version': 1, 'status': 'REVIEW_HOLD',
            'source_sha256': digest(data), 'assessment': label, 'storage_signal': storage,
            'windows_build': build, 'review_codes': list(dict.fromkeys(raw_codes)),
            'recorded_events': events, 'source_verified_authentic': False,
            'cause_determined': False, 'repair_authorized': False,
            'external_transfer': False, 'original_modified': False}


def make_html(summary: dict) -> bytes:
    def h(value):
        return escape(str(value), quote=True)
    codes = ''.join(f'<li>{h(x)}</li>' for x in summary['review_codes']) or '<li>기록된 범주 없음</li>'
    events = ''.join(f'<li>이벤트 {e["event_id"]} · UTC {h(e["recorded_utc"])}</li>' for e in summary['recorded_events']) or '<li>표시 가능한 기록 없음</li>'
    html = ('<!doctype html><html lang="ko"><head><meta charset="utf-8">'
            '<meta http-equiv="Content-Security-Policy" content="default-src &#39;none&#39;; style-src &#39;unsafe-inline&#39;; base-uri &#39;none&#39;; form-action &#39;none&#39;">'
            '<title>PC CARE 상담 초안</title><style>@page{size:A4;margin:15mm}'
            'body{font:14px system-ui,sans-serif;max-width:700px;margin:auto;line-height:1.6;color:#222}'
            'h1{font-size:22px}h2{font-size:16px}strong{font-weight:700}li{break-inside:avoid}'
            'aside{border:2px solid #777;padding:12px}code{overflow-wrap:anywhere}</style></head><body>'
            '<h1>AXMART PC CARE · 수리 상담 초안</h1>'
            '<aside><strong>검토 필요 / 승인되지 않음</strong> — 로컬 보고서에 기록된 제한적 관측만 정리합니다. '
            '원인 확정·수리 보증·백업 완료·사용자 승인으로 해석하면 안 됩니다.</aside>'
            f'<p>판정: <strong>{h(summary["assessment"])}</strong> · 저장장치: {h(summary["storage_signal"])} · '
            f'Windows 빌드: {h(summary["windows_build"])}</p>'
            f'<h2>상담할 신호 범주</h2><ul>{codes}</ul><h2>이벤트 기록 시각</h2><ul>{events}</ul>'
            '<p>UTC는 기록 시각이며 실제 장애 발생 시각이나 인과관계를 확정하지 않습니다.</p>'
            '<h2>사용자 확인 항목</h2><ol><li>중요 파일 별도 백업 및 복원 가능 여부 확인</li>'
            '<li>수리점에서 근거와 진단 방법 확인</li><li>부품 교체 전 예상 비용과 대안 확인</li></ol>'
            '<p>문서 작성만으로 DISM/SFC, WinRE, 파일 복사·복구, 디스크 쓰기 명령이 실행되지 않습니다.</p>'
            f'<p>원본 SHA-256(로컬 대조용): <code>{h(summary["source_sha256"])}</code></p>'
            '</body></html>\n')
    return html.encode('utf-8')


def encode_json(obj: dict) -> bytes:
    return (json.dumps(obj, ensure_ascii=False, indent=2, sort_keys=True) + '\n').encode('utf-8')


def files_for_source(data: bytes) -> dict[str, bytes]:
    summary = safe_consultation(data)
    content = {'case-summary.json': encode_json(summary), 'case-summary.html': make_html(summary)}
    manifest = {'format': FORMAT, 'version': 1, 'status': 'REVIEW_HOLD',
                'source_sha256': summary['source_sha256'],
                'files': {name: {'sha256': digest(item), 'bytes': len(item)} for name, item in sorted(content.items())},
                'approved': False, 'external_transfer': False}
    content['case-manifest.json'] = encode_json(manifest)
    if any(not (0 < len(v) <= MAX_OUTPUT) for v in content.values()):
        block()
    return content


def verify(source: bytes, directory: Path) -> dict:
    if not directory.is_absolute() or not directory.is_dir() or directory.is_symlink():
        block()
    if {p.name for p in directory.iterdir()} != set(FILE_NAMES):
        block()
    content = {name: read_local(directory / name, '.json' if name.endswith('.json') else '.html', MAX_OUTPUT)
               for name in FILE_NAMES}
    intended = files_for_source(source)
    # Stable canonical rendering makes both source/JSON semantics and HTML output independently verifiable.
    good = all(content[name] == intended[name] for name in FILE_NAMES)
    return {'status': 'MATCHED_UNAPPROVED' if good else 'MISMATCH',
            'files_match': good, 'source_sha256': digest(source),
            'cause_determined': False, 'repair_authorized': False,
            'external_transfer': False, 'original_modified': False}


def create(source: bytes, directory: Path) -> dict:
    if not directory.is_absolute() or directory.exists() or directory.is_symlink():
        block()
    # Refuse output through symlink parents, cloud/network paths are never copied by this program.
    for parent in directory.parents:
        if parent.is_symlink() or not parent.is_dir():
            block()
    content = files_for_source(source)
    created = False
    try:
        directory.mkdir(mode=0o700, exist_ok=False)
        created = True
        for name, data in content.items():
            flags = os.O_WRONLY | os.O_CREAT | os.O_EXCL | getattr(os, 'O_NOFOLLOW', 0)
            fd = os.open(directory / name, flags, 0o600)
            with os.fdopen(fd, 'wb') as output:
                output.write(data)
        return verify(source, directory)
    except Exception:
        if created:
            for name in FILE_NAMES:
                p = directory / name
                if p.is_file() and not p.is_symlink():
                    p.unlink()
            directory.rmdir()
        raise


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description='Offline owner-triggered PC CARE consultation draft; never repairs')
    sub = parser.add_subparsers(dest='action', required=True)
    for name in ('create', 'verify'):
        p = sub.add_parser(name)
        p.add_argument('--source', required=True, type=Path)
        p.add_argument('--directory', required=True, type=Path)
    args = parser.parse_args(argv)
    try:
        source = read_local(args.source, '.json', MAX_SOURCE)
        result = create(source, args.directory) if args.action == 'create' else verify(source, args.directory)
        print(json.dumps(result, ensure_ascii=False, sort_keys=True))
        return 0 if result['status'] == 'MATCHED_UNAPPROVED' else 2
    except (OSError, ValueError, TypeError):
        print('{"status":"PC_CARE_CASEPACK_BLOCKED","repair_authorized":false}')
        return 1


if __name__ == '__main__':
    sys.exit(main())
