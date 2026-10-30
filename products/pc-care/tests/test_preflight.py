"""Tests for the developer-only QA orchestrator, not Windows runtime proof."""
import importlib.util
from pathlib import Path
from tempfile import TemporaryDirectory
import sys
import unittest
from unittest.mock import patch

MODULE_PATH = Path(__file__).resolve().parents[1] / 'tools/preflight.py'
spec=importlib.util.spec_from_file_location('pc_care_preflight',MODULE_PATH)
preflight=importlib.util.module_from_spec(spec)
sys.modules[spec.name]=preflight
spec.loader.exec_module(preflight)

class PreflightTests(unittest.TestCase):
    def test_missing_source_and_node_fail_closed(self):
        with TemporaryDirectory() as tmp:
            with patch.object(preflight.shutil,'which',return_value=None):
                result=preflight.run_qa(Path(tmp),windows_synthetic=False)
            self.assertEqual(result['status'],'fail')
            by_name={s['name']:s['status'] for s in result['stages']}
            self.assertEqual(by_name['node-tests'],'blocked')
            self.assertEqual(by_name['internal-zip'],'blocked')
            self.assertEqual(by_name['windows-powershell-51-synthetic'],'not-run')
            self.assertIn('actual Windows',result['warning'])
    def test_nonwindows_skips_windows_only_not_core_failure(self):
        with TemporaryDirectory() as tmp:
            root=Path(tmp)
            def fake_cmd(name,*args,**kwargs):
                return dict(name=name,status='pass',exit_code=0,output='')
            with patch.object(preflight,'command',side_effect=fake_cmd),\
                 patch.object(preflight.shutil,'which',return_value='/usr/bin/node'),\
                 patch.object(preflight,'JS_SCRIPTS',()),\
                 patch.object(preflight,'NODE_TESTS',()),\
                 patch.object(preflight.tempfile,'TemporaryDirectory',side_effect=TemporaryDirectory),\
                 patch.object(preflight.Path,'is_file',return_value=True):
                # We only test the reporting rules; a missing real ZIP remains a failure.
                result=preflight.run_qa(root,windows_synthetic=False)
            self.assertEqual(result['status'],'fail')
            self.assertEqual(result['stages'][-1]['status'],'not-run')
    def test_status_requires_native_windows_stage(self):
        classify = preflight.classify_qa_status
        self.assertEqual(classify([]), 'fail')
        self.assertEqual(classify([{'status':'pass'},{'status':'pass'}]), 'pass')
        self.assertEqual(classify([{'status':'pass'},{'status':'not-run'}]), 'partial')
        self.assertEqual(classify([{'status':'pass'},{'status':'blocked'}]), 'blocked')
        self.assertEqual(classify([{'status':'fail'},{'status':'not-run'}]), 'fail')
        self.assertEqual(classify([{'status':'unsupported'}]), 'fail')

    def test_main_reports_partial_without_claiming_pass(self):
        stages = [
            {'name':'python-tests','status':'pass'},
            {'name':'node-tests','status':'pass'},
            {'name':'internal-zip','status':'pass'},
            {'name':'windows-powershell-51-synthetic','status':'not-run'}
        ]
        result={'status':preflight.classify_qa_status(stages),
                'stages':stages,'not_verified':preflight.NOT_VERIFIED,
                'warning':'actual Windows/WinRE not verified'}
        with patch.object(preflight,'run_qa',return_value=result):
            self.assertEqual(preflight.main(['--root',str(MODULE_PATH.parent)]),2)

    def test_sanitized_qa_receipt_contains_only_known_metadata(self):
        from json import loads
        raw={'status':'partial','stages':[
            {'name':'python-tests','status':'pass','tests':77,
             'output':'PRIVATE USER\\\\HOST event log and C:\\\\Users\\\\Private'},
            {'name':'private-stolen-username','status':'pass','tests':True,
             'output':'PRIVATE-SECRET'},
            {'name':'windows-powershell-51-synthetic','status':'not-run',
             'output':'PRIVATE-SECRET'}
        ],'warning':'PRIVATE-SECRET'}
        with TemporaryDirectory() as tmp:
            dest=Path(tmp)/'QA_RESULTS'
            first=preflight.write_qa_receipt(raw,dest)
            second=preflight.write_qa_receipt(raw,dest)
            self.assertNotEqual(first,second)
            self.assertTrue(first.is_file())
            self.assertTrue(second.is_file())
            text=first.read_text(encoding='utf-8')
            self.assertNotIn('PRIVATE',text)
            self.assertNotIn('C:\\\\Users',text)
            self.assertNotIn('output',text)
            self.assertNotIn('warning',text)
            self.assertEqual(loads(text)['status'],'partial')
            self.assertEqual(loads(text)['stages'][0]['tests'],77)
            self.assertEqual(loads(text)['stages'][1]['name'],'unknown')
            self.assertNotIn('tests',loads(text)['stages'][1])
            self.assertEqual(loads(text)['scope'],'synthetic_only_no_live_diagnosis')

    def test_receipt_fails_closed_on_status_mismatch_and_unsupported_states(self):
        result={'status':'pass','stages':[
            {'name':'node-tests','status':'fail','tests':1},
            {'name':'other:private','status':'unrecognized'}
        ]}
        safe=preflight.safe_qa_receipt(result)
        self.assertEqual(safe['status'],'fail')
        self.assertEqual(safe['stages'][1],{'name':'unknown','status':'fail'})
        self.assertIn('WinRE',str(safe['unverified']))

    def test_receipt_refuses_symlink_directory(self):
        with TemporaryDirectory() as tmp:
            source=Path(tmp)/'real'
            source.mkdir()
            link=Path(tmp)/'alias'
            try:
                link.symlink_to(source,target_is_directory=True)
            except (OSError,NotImplementedError):
                self.skipTest('Symlink creation unavailable')
            with self.assertRaisesRegex(ValueError,'symlink'):
                preflight.write_qa_receipt({'status':'pass','stages':[{'name':'node-tests','status':'pass'}]},link)
            self.assertEqual(list(source.iterdir()),[])

    def test_command_reports_failure_and_bounds_output(self):
        with TemporaryDirectory() as tmp:
            cmd=preflight.command('negative',[sys.executable,'-c',
                'import sys;print("x"*6000);sys.exit(7)'],cwd=Path(tmp))
            self.assertEqual(cmd['status'],'fail')
            self.assertEqual(cmd['exit_code'],7)
            self.assertLessEqual(len(cmd['output']),5000)
    def test_no_release_or_repair_commands_are_in_runner(self):
        source=MODULE_PATH.read_text(encoding='utf-8')
        for forbidden in ('--run-readonly','RUN_SAFE_REPAIR.cmd','--publish',
                          'git push','subprocess.Popen','shell=True'):
            self.assertNotIn(forbidden,source)
        self.assertIn('TemporaryDirectory',source)
        self.assertIn('test_*.py',source)
        self.assertIn('tests/test_history_batch.cjs',source)

if __name__=='__main__':
    unittest.main(verbosity=2)
