"""Tests for the developer-only QA orchestrator, not Windows runtime proof."""
import importlib.util
import io
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
    def test_node_test_count_accepts_tap_and_spec_without_newer_reporter_flag(self):
        for summary in ('# tests 1\n', chr(0x2139)+' tests 1\n'):
            with self.subTest(summary=summary), TemporaryDirectory() as tmp:
                calls=[]
                def fake_cmd(name, argv, **kwargs):
                    calls.append((name, argv))
                    output='Ran 1 test\n' if name=='python-tests' else summary
                    return dict(name=name,status='pass',exit_code=0,output=output)
                with patch.object(preflight,'command',side_effect=fake_cmd),\
                     patch.object(preflight.shutil,'which',return_value='node'),\
                     patch.object(preflight,'JS_SCRIPTS',()),\
                     patch.object(preflight,'NODE_TESTS',('tests/one.cjs',)),\
                     patch.object(preflight.Path,'is_file',return_value=True):
                    result=preflight.run_qa(Path(tmp),windows_synthetic=False)
                node_stage=next(stage for stage in result['stages'] if stage['name']=='node-tests')
                node_call=next(argv for name,argv in calls if name=='node-tests')
                self.assertEqual(node_stage['tests'],1)
                self.assertNotIn('--test-reporter=tap',node_call)
    def test_qa_receipt_records_skipped_fixtures_without_private_output(self):
        # Both Node 18 TAP and newer Node SPEC summaries occur on supported hosts.
        for node_output in ('# tests 3\n# skipped 1\n', chr(0x2139)+' tests 3\n'+chr(0x2139)+' skipped 1\n'):
            with self.subTest(node_output=node_output), TemporaryDirectory() as tmp:
                def fake_cmd(name, argv, **kwargs):
                    output = ('Ran 4 tests in 0.01s\nOK (skipped=3)\n' if name=='python-tests'
                              else node_output if name=='node-tests' else '')
                    return dict(name=name,status='pass',exit_code=0,output=output)
                with patch.object(preflight,'command',side_effect=fake_cmd),\
                     patch.object(preflight.shutil,'which',return_value='node'),\
                     patch.object(preflight,'JS_SCRIPTS',()),\
                     patch.object(preflight,'NODE_TESTS',('tests/sample.cjs',)),\
                     patch.object(preflight.Path,'is_file',return_value=True):
                    result=preflight.run_qa(Path(tmp),windows_synthetic=False)
                by_name={stage['name']:stage for stage in result['stages']}
                self.assertEqual(by_name['python-tests']['skipped'],3)
                self.assertEqual(by_name['node-tests']['skipped'],1)
                receipt=preflight.safe_qa_receipt(result)
                sanitized={stage['name']:stage for stage in receipt['stages']}
                self.assertEqual(sanitized['python-tests']['skipped'],3)
                self.assertEqual(sanitized['node-tests']['skipped'],1)
                self.assertNotIn('output',str(receipt))
                self.assertNotEqual(receipt['status'],'pass')  # Windows suite not run.

        full=[{'name':'python-tests','status':'pass','tests':5,'skipped':True},
              {'name':'node-tests','status':'pass','tests':10,'skipped':11},
              {'name':'internal-zip','status':'pass'},
              {'name':'windows-powershell-51-synthetic','status':'pass'}]
        receipt=preflight.safe_qa_receipt({'status':'pass','stages':full})
        self.assertNotIn('skipped',receipt['stages'][0])  # bool is not an integer.
        self.assertNotIn('skipped',receipt['stages'][1])  # impossible count.
        self.assertEqual(receipt['status'],'pass')

    def test_empty_effective_coverage_cannot_pass_if_every_test_was_skipped(self):
        with TemporaryDirectory() as tmp:
            def fake_cmd(name, argv, **kwargs):
                if name=='python-tests':
                    output='Ran 2 tests in 0.01s\nOK (skipped=2)\n'
                elif name=='node-tests':
                    output='# tests 3\n# skipped 3\n'
                else:
                    output=''
                return dict(name=name,status='pass',exit_code=0,output=output)
            with patch.object(preflight,'command',side_effect=fake_cmd),\
                 patch.object(preflight.shutil,'which',return_value='node'),\
                 patch.object(preflight,'JS_SCRIPTS',()),\
                 patch.object(preflight,'NODE_TESTS',('tests/sample.cjs',)),\
                 patch.object(preflight.Path,'is_file',return_value=True):
                result=preflight.run_qa(Path(tmp),windows_synthetic=False)
            stages={stage['name']:stage for stage in result['stages']}
            self.assertEqual(stages['python-tests']['status'],'fail')
            self.assertEqual(stages['node-tests']['status'],'fail')
            self.assertEqual(stages['python-tests']['skipped'],2)
            self.assertEqual(stages['node-tests']['skipped'],3)
            self.assertEqual(result['status'],'fail')

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
            {'name':'node-tests','status':'pass','tests':True,
             'output':'PRIVATE-SECRET'},
            {'name':'internal-zip','status':'pass','output':'PRIVATE-SECRET'},
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
            self.assertEqual(loads(text)['stages'][1]['name'],'node-tests')
            self.assertNotIn('tests',loads(text)['stages'][1])
            self.assertEqual(loads(text)['scope'],'synthetic_only_no_live_diagnosis')

    def test_required_qa_matrix_prevents_missing_or_duplicate_passes(self):
        full=[
            {'name':'python-tests','status':'pass'},
            {'name':'node-tests','status':'pass'},
            {'name':'internal-zip','status':'pass'},
            {'name':'windows-powershell-51-synthetic','status':'pass'}
        ]
        validate=preflight.classify_full_qa_stages
        self.assertEqual(validate(full),'pass')
        self.assertEqual(validate(full[:-1]),'fail')
        self.assertEqual(validate(full+[full[-1]]),'fail')
        self.assertEqual(validate(full[:2]+[full[1]]+full[3:]),'fail')
        self.assertEqual(validate(full[:2]+[{'name':'unexpected','status':'pass'}]+full[3:]),'fail')
        partial=[*full[:-1],{'name':'windows-powershell-51-synthetic','status':'not-run'}]
        self.assertEqual(validate(partial),'partial')
        self.assertEqual(preflight.safe_qa_receipt({'status':'pass','stages':full[:-1]})['status'],'fail')
        self.assertEqual(preflight.safe_qa_receipt({'status':'partial','stages':partial})['status'],'partial')
        error=[full[0],{'name':'node-syntax:ui/history_compare.js','status':'fail'},full[2],full[3]]
        self.assertEqual(validate(error),'fail')
        error=[full[0],full[1],{'name':'internal-zip-verify','status':'fail'},full[3]]
        self.assertEqual(validate(error),'fail')
        # Intermediate stage success is NOT proof that node --test ran or
        # that the ZIP's manifest and SHA256 verification completed.
        node_syntax_only=[full[0],
            {'name':'node-syntax:ui/history_compare.js','status':'pass'},
            full[2],full[3]]
        self.assertEqual(validate(node_syntax_only),'fail')
        self.assertEqual(preflight.safe_qa_receipt(
            {'status':'pass','stages':node_syntax_only})['status'],'fail')
        zip_build_only=[full[0],full[1],
            {'name':'internal-zip-build','status':'pass'},full[3]]
        self.assertEqual(validate(zip_build_only),'fail')
        self.assertEqual(preflight.safe_qa_receipt(
            {'status':'pass','stages':zip_build_only})['status'],'fail')
        zip_verify_without_manifest=[full[0],full[1],
            {'name':'internal-zip-verify','status':'pass'},full[3]]
        self.assertEqual(validate(zip_verify_without_manifest),'fail')
        blocked_syntax=[full[0],
            {'name':'node-syntax:ui/history_compare.js','status':'blocked'},
            full[2],full[3]]
        self.assertEqual(validate(blocked_syntax),'blocked')
        blocked_build=[full[0],full[1],
            {'name':'internal-zip-build','status':'blocked'},full[3]]
        self.assertEqual(validate(blocked_build),'blocked')

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
    def test_console_output_escapes_characters_unavailable_in_host_encoding(self):
        text='bad '+chr(0xfffd)
        encoded=preflight.safe_console_text(text,'cp949')
        self.assertIn(r'\ufffd',encoded)
    def test_receipt_path_is_printable_on_legacy_console_with_unicode_directory(self):
        stages=[
            {'name':'python-tests','status':'pass','tests':1,'skipped':0},
            {'name':'node-tests','status':'pass','tests':1,'skipped':0},
            {'name':'internal-zip','status':'pass'},
            {'name':'windows-powershell-51-synthetic','status':'pass'},
        ]
        result={'status':'pass','stages':stages,'not_verified':preflight.NOT_VERIFIED,
                'warning':'synthetic only'}
        with TemporaryDirectory() as tmp:
            receipt_dir=Path(tmp)/('reports '+chr(0x1f9ea))
            buffer=io.BytesIO()
            writer=io.TextIOWrapper(buffer,encoding='cp949',errors='strict',write_through=True)
            with patch.object(preflight,'run_qa',return_value=result),\
                 patch.object(preflight.sys,'stdout',writer):
                self.assertEqual(preflight.main(['--root',str(MODULE_PATH.parent),
                                                 '--receipt-dir',str(receipt_dir)]),0)
            output=buffer.getvalue().decode('cp949')
            self.assertIn(r'\U0001f9ea',output)
            self.assertEqual(len(list(receipt_dir.glob('pc-care-qa-*.json'))),1)
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
