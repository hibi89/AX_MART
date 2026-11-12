import importlib.util
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

HERE = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('casepack', HERE / 'tools' / 'casepack.py')
cp = importlib.util.module_from_spec(spec)
spec.loader.exec_module(cp)


def report():
    return {
        'schemaVersion': 1, 'product': 'AXMART PC CARE', 'mode': 'read-only',
        'assessment': '주의 필요',
        'consultation': {
            'schemaVersion': 1, 'containsIdentifiers': False, 'assessment': '주의 필요',
            'storageSignal': '경고 신호 관측', 'windowsBuild': '26100',
            'reviewItems': ['저장장치 상태 경고', '저장 공간 부족'],
            'recordedEvents': [{'eventId': 1001, 'recordedUtc': '2026-11-11 11:32',
                                'provider': 'PRIVATE_PROVIDER', 'message': 'PRIVATE_MESSAGE'}],
            'windowsUser': 'PRIVATE_USERNAME', 'deviceModel': 'PRIVATE_DRIVE_SERIAL',
            'consultationQuestions': ['PRIVATE_QUESTION']
        },
        'observations': {'systemPath': 'PRIVATE_C_USERS_SECRET', 'physicalDisks': ['PRIVATE_DISK']},
        'privacy': 'PRIVATE_REPORT_RAW'
    }


def encode(r=None):
    return json.dumps(report() if r is None else r, ensure_ascii=False).encode('utf-8')


class CasePack(unittest.TestCase):
    def test_ambiguous_duplicate_json_keys_and_boolean_schemas_fail_closed(self):
        raw = encode()
        # Repeated top-level keys must not be interpreted differently by
        # Python validators, browser review, or downstream support tools.
        repeated = raw[:-1] + b',"mode":"repair"}'
        with self.assertRaisesRegex(ValueError, 'BLOCKED'):
            cp.safe_consultation(repeated)
        for key in ('schemaVersion',):
            bad = report()
            bad[key] = True
            with self.assertRaisesRegex(ValueError, 'BLOCKED'):
                cp.safe_consultation(encode(bad))
            bad = report()
            bad['consultation'][key] = True
            with self.assertRaisesRegex(ValueError, 'BLOCKED'):
                cp.safe_consultation(encode(bad))
        for invalid in ([], {'wrong': 'schema'}):
            bad = report()
            bad['consultation']['assessment'] = invalid
            with self.assertRaisesRegex(ValueError, 'BLOCKED'):
                cp.safe_consultation(encode(bad))
            bad = report()
            bad['consultation']['storageSignal'] = invalid
            with self.assertRaisesRegex(ValueError, 'BLOCKED'):
                cp.safe_consultation(encode(bad))

    def test_missing_disk_evidence_downgrades_clean_to_incomplete(self):
        r = report()
        r['assessment'] = r['consultation']['assessment'] = '관찰 범위 내 특이사항 없음'
        r['consultation']['storageSignal'] = 'Windows 정상 신호 (보증 아님)'
        r['consultation']['reviewItems'] = []
        r['observations'].pop('collectionStatus', None)
        output = cp.safe_consultation(encode(r))
        self.assertEqual('확인 불완전', output['assessment'])
        self.assertFalse(output['repair_authorized'])
        r['observations']['collectionStatus'] = {'physicalDisks': 'unavailable'}
        self.assertEqual('확인 불완전', cp.safe_consultation(encode(r))['assessment'])

    def test_clean_with_warning_is_never_reported_as_clean(self):
        r = report()
        r['assessment'] = r['consultation']['assessment'] = '관찰 범위 내 특이사항 없음'
        r['observations']['collectionStatus'] = {'physicalDisks': 'collected'}
        self.assertEqual('주의 필요', cp.safe_consultation(encode(r))['assessment'])
        r['consultation']['storageSignal'] = 'Windows 정상 신호 (보증 아님)'
        r['consultation']['reviewItems'] = []
        self.assertEqual('관찰 범위 내 특이사항 없음',
                         cp.safe_consultation(encode(r))['assessment'])

    def test_owner_local_folder_guard_blocks_known_sync_names_and_preserves_input(self):
        with tempfile.TemporaryDirectory(prefix='pc-care-p15-') as temp:
            root = Path(temp)
            source = root / 'report.json'
            data = encode()
            source.write_bytes(data)
            for name in ('OneDrive', 'OneDrive - Example', 'Dropbox',
                         'Google Drive', 'iCloudDrive', 'Box Sync'):
                folder = root / name
                folder.mkdir()
                with self.subTest(name=name), self.assertRaisesRegex(ValueError, 'BLOCKED'):
                    cp.create(data, folder / 'new-review')
                self.assertEqual([], list(folder.iterdir()))
            self.assertEqual(data, source.read_bytes())

    def test_existing_symlinked_parent_is_not_a_private_local_folder(self):
        with tempfile.TemporaryDirectory(prefix='pc-care-p15-') as temp:
            root = Path(temp)
            real = root / 'real'
            real.mkdir()
            alias = root / 'alias'
            try:
                alias.symlink_to(real, target_is_directory=True)
            except (OSError, NotImplementedError):
                self.skipTest('Symlink privilege unavailable on this OS')
            with self.assertRaisesRegex(ValueError, 'BLOCKED'):
                cp.create(encode(), alias / 'new-result')
            self.assertEqual([], list(real.iterdir()))

    def test_valid_pack_only_redacted_minimized_fields_and_no_privileged_actions(self):
        data = encode()
        with tempfile.TemporaryDirectory() as d:
            target = Path(d)/'new-packet'
            result = cp.create(data, target)
            self.assertEqual(result['status'], 'MATCHED_UNAPPROVED')
            self.assertEqual({p.name for p in target.iterdir()}, set(cp.FILE_NAMES))
            wire = b' '.join(p.read_bytes() for p in target.iterdir())
            for secret in (b'PRIVATE_USERNAME', b'PRIVATE_DRIVE_SERIAL', b'PRIVATE_REPORT_RAW',
                           b'PRIVATE_PROVIDER', b'PRIVATE_MESSAGE', b'PRIVATE_QUESTION', b'PRIVATE_C_USERS_SECRET'):
                self.assertNotIn(secret, wire)
            self.assertIn('REVIEW_HOLD'.encode(), wire)
            self.assertNotIn(b'<script', wire.lower())
            self.assertIn(b'@page{size:A4', wire)
            self.assertEqual(cp.verify(data,target)['files_match'],True)

    def test_changed_original_report_rejected_even_when_summary_would_stay_same(self):
        data = encode()
        with tempfile.TemporaryDirectory() as d:
            target = Path(d)/'case'
            cp.create(data,target)
            other = report();other['observations']['systemPath']='ALTERED_PRIVATE_PATH'
            self.assertEqual(cp.verify(encode(other), target)['status'], 'MISMATCH')

    def test_tamper_html_or_manifest_rejected(self):
        data=encode()
        with tempfile.TemporaryDirectory() as d:
            target=Path(d)/'case'
            cp.create(data,target)
            file=target/'case-summary.html'
            file.write_bytes(file.read_bytes().replace(b'AXMART', b'FORGED'))
            self.assertEqual(cp.verify(data,target)['status'],'MISMATCH')
            cp2=target/'case-manifest.json'
            cp2.write_bytes(b'{}')
            self.assertEqual(cp.verify(data,target)['status'],'MISMATCH')

    def test_refuse_malformed_unknown_approval_or_untrusted_event_without_files(self):
        variants=[]
        a=report();a['assessment']='장치 정상 인증';variants.append(a)
        a=report();a['consultation']['assessment']='확인 불완전';variants.append(a)
        a=report();a['consultation']['containsIdentifiers']=True;variants.append(a)
        a=report();a['mode']='auto-repair';variants.append(a)
        a=report();a['consultation']['reviewItems']=['PRIVATE_NOT_ALLOWLISTED'];variants.append(a)
        a=report();a['consultation']['recordedEvents'][0]['eventId']=True;variants.append(a)
        a=report();a['consultation']['recordedEvents'][0]['recordedUtc']='2026-02-30 10:00';variants.append(a)
        a=report();a['consultation']['storageSignal']='PRIVATE_UNKNOWN';variants.append(a)
        a=report();a['schemaVersion']=2;variants.append(a)
        with tempfile.TemporaryDirectory() as d:
            for i,variant in enumerate(variants):
                dest=Path(d)/str(i)
                with self.subTest(i=i), self.assertRaises(ValueError):
                    cp.create(encode(variant),dest)
                self.assertFalse(dest.exists())

    def test_refuse_existing_destination_and_leave_original_files_untouched(self):
        data=encode()
        with tempfile.TemporaryDirectory() as d:
            dest=Path(d)/'case'
            dest.mkdir()
            marker=dest/'keep.txt';marker.write_bytes(b'KEEP')
            with self.assertRaises(ValueError): cp.create(data,dest)
            self.assertEqual(marker.read_bytes(),b'KEEP')

    def test_reject_missing_unexpected_and_symlink_files(self):
        data=encode()
        with tempfile.TemporaryDirectory() as d:
            target=Path(d)/'case'; cp.create(data,target)
            (target/'extra.private').write_bytes(b'SECRET')
            with self.assertRaises(ValueError): cp.verify(data,target)
            (target/'extra.private').unlink()
            (target/'case-summary.json').unlink()
            with self.assertRaises(ValueError): cp.verify(data,target)
            alias=Path(d)/'alias.json'
            input_file=Path(d)/'original.json';input_file.write_bytes(data)
            try: alias.symlink_to(input_file)
            except OSError: return
            with self.assertRaises(ValueError): cp.read_local(alias,'.json',cp.MAX_SOURCE)

    def test_restrict_source_size_utf8_and_relative_paths(self):
        with tempfile.TemporaryDirectory() as d:
            root=Path(d)
            bad=root/'bad.json';bad.write_bytes(b'\xff')
            with self.assertRaises(ValueError): cp.safe_consultation(cp.read_local(bad,'.json',cp.MAX_SOURCE))
            with self.assertRaises(ValueError): cp.read_local(Path('some.json'),'.json',cp.MAX_SOURCE)
            huge=root/'huge.json';huge.write_bytes(b'x'*(cp.MAX_SOURCE+1))
            with self.assertRaises(ValueError): cp.read_local(huge,'.json',cp.MAX_SOURCE)

    def test_cli_synthetic_create_verify_mismatch_with_no_sensitive_stdout(self):
        with tempfile.TemporaryDirectory() as d:
            root=Path(d); source=root/'source.json';source.write_bytes(encode())
            target=root/'new-case'
            cmd=[sys.executable,str(HERE/'tools'/'casepack.py')]
            create=subprocess.run([*cmd,'create','--source',str(source),'--directory',str(target)],capture_output=True,text=True)
            self.assertEqual(create.returncode,0,create.stderr)
            result=json.loads(create.stdout);self.assertEqual(result['status'],'MATCHED_UNAPPROVED')
            verify=subprocess.run([*cmd,'verify','--source',str(source),'--directory',str(target)],capture_output=True,text=True)
            self.assertEqual(verify.returncode,0,verify.stderr)
            changed=report();changed['privacy']='PRIVATE_REPORT_ALTERED';source.write_bytes(encode(changed))
            mismatch=subprocess.run([*cmd,'verify','--source',str(source),'--directory',str(target)],capture_output=True,text=True)
            self.assertEqual(mismatch.returncode,2)
            self.assertEqual(json.loads(mismatch.stdout)['status'],'MISMATCH')
            for output in (create.stdout, verify.stdout,mismatch.stdout):
                self.assertNotIn('PRIVATE_',output)
                self.assertNotIn(str(root),output)

    def test_consistent_byte_identical_outputs_for_same_source(self):
        data=encode()
        with tempfile.TemporaryDirectory() as d:
            a,b=Path(d)/'a',Path(d)/'b'
            cp.create(data,a);cp.create(data,b)
            self.assertEqual([(a/n).read_bytes() for n in cp.FILE_NAMES],
                             [(b/n).read_bytes() for n in cp.FILE_NAMES])


if __name__=='__main__':
    unittest.main()
