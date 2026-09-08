"""Run: python3 -m unittest discover -s tests -p 'test_agent_skills.py' -v"""
import contextlib
import importlib.machinery
import importlib.util
import io
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import unittest

REPO = Path(__file__).resolve().parents[1]
TOOL = REPO / 'chezmoi/private_dot_local/bin/executable_sync-agent-skills'
loader = importlib.machinery.SourceFileLoader('skill_sync', str(TOOL))
spec = importlib.util.spec_from_loader(loader.name, loader)
sync = importlib.util.module_from_spec(spec)
sys.dont_write_bytecode = True  # The tool's chezmoi source directory must stay artifact-free.
loader.exec_module(sync)
CONFIG = json.loads((REPO / 'chezmoi/dot_config/agent-skills/targets.json').read_text())


class SyncTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='skill sync ')
        self.base = Path(self.temp.name).resolve()
        self.home = self.base / 'home with spaces'
        self.source = self.base / 'canonical source'
        self.source.mkdir()
        subprocess.run(['git', 'init', '-q', str(self.source)], check=True)
        (self.source / 'LICENSE').write_text('license\n')
        (self.source / 'THIRD_PARTY_NOTICES.md').write_text('attribution\n')
        self.add_skill('one')
        self.add_skill('two', manual=True)
        self.legacy = {}

    def tearDown(self):
        self.temp.cleanup()

    def add_skill(self, name, manual=False):
        folder = self.source / 'skills' / name
        (folder / 'scripts').mkdir(parents=True)
        (folder / 'SKILL.md').write_text(f'---\nname: {name}\ndescription: Test skill\n' +
                                       ('disable-model-invocation: true\n' if manual else '') +
                                       '---\n\nKeep every substantive instruction.\n')
        (folder / 'scripts/helper.sh').write_text('echo support\n')
        subprocess.run(['git', '-C', str(self.source), 'add', '.'], check=True)

    def run_sync(self, dry=False):
        with contextlib.redirect_stdout(io.StringIO()):
            sync.sync(self.home, self.source, CONFIG, self.legacy, dry)

    def snapshot(self, root=None):
        root = self.home if root is None else root
        return {str(p.relative_to(root)): (p.read_bytes(), p.stat().st_mtime_ns)
                for p in root.rglob('*') if p.is_file()}

    def test_pi_checkout_is_read_only_and_not_a_distribution_target(self):
        self.assertEqual(CONFIG['source'], 'code/pi-extensions')
        self.assertEqual(CONFIG['targets'], {
            'claude': {'path': '.claude/skills', 'adapter': 'standard'},
            'codex': {'path': '.codex/skills', 'adapter': 'codex'},
            'cursor': {'path': '.cursor/skills', 'adapter': 'standard'},
            'copilot': {'path': '.copilot/skills', 'adapter': 'standard'},
            'opencode': {'path': '.config/opencode/skills', 'adapter': 'explicit-guard'},
            'grok': {'path': '.grok/skills', 'adapter': 'standard'},
            'dsh': {'path': '.dsh/skills', 'adapter': 'standard'},
        })
        # Model the real layout: Pi owns a full package inside HOME, not just skills.
        source = self.home / CONFIG['source']
        source.parent.mkdir(parents=True)
        shutil.move(str(self.source), source)
        self.source = source
        for name in ['src/index.ts', 'themes/origin.json', 'package.json']:
            path = source / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text('Pi-owned content\n')
        before = self.snapshot(source)
        self.run_sync()
        self.run_sync()
        self.assertEqual(before, self.snapshot(source))
        self.assertFalse((self.home / '.pi/agent/skills').exists())
        self.assertTrue((self.home / '.codex/skills/one/SKILL.md').exists())

    def test_compatibility_aliases_rejected_before_writes(self):
        config = json.loads(json.dumps(CONFIG))
        config['targets']['cursor'] = {'via': 'claude', 'legacy_path': '.cursor/skills'}
        with self.assertRaisesRegex(ValueError, 'Each agent requires its own path and adapter'):
            sync.sync(self.home, self.source, config, self.legacy)
        self.assertFalse(self.home.exists())

    def test_source_overlap_rejected_for_install_and_cleanup_before_any_writes(self):
        source = self.home / CONFIG['source']
        source.parent.mkdir(parents=True)
        shutil.move(str(self.source), source)
        self.source = source
        before = self.snapshot()
        for path in ['code/pi-extensions', 'code/pi-extensions/skills', 'code', '.']:
            for kind in ['install', 'legacy-cleanup']:
                with self.subTest(path=path, kind=kind):
                    config = json.loads(json.dumps(CONFIG))
                    if kind == 'install':
                        config['targets']['invalid'] = {'path': path, 'adapter': 'standard'}
                    else:
                        config['legacy_cleanup'].append(path)
                    with self.assertRaisesRegex(ValueError, 'overlaps read-only source checkout'):
                        sync.sync(self.home, self.source, config, self.legacy)
                    self.assertEqual(before, self.snapshot())

    def test_install_idempotent_render_and_support(self):
        self.run_sync()
        before = self.snapshot()
        self.run_sync()
        self.assertEqual(before, self.snapshot())
        for target in CONFIG['targets'].values():
            if 'path' not in target:
                continue
            root = self.home / target['path']
            self.assertEqual(sorted(p.parent.name for p in root.rglob('SKILL.md')), ['one', 'two'])
            self.assertEqual((root / 'one/scripts/helper.sh').read_text(), 'echo support\n')
            self.assertEqual((root / 'one/THIRD_PARTY_NOTICES.md').read_text(), 'attribution\n')
            self.assertIn('Keep every substantive instruction.', (root / 'two/SKILL.md').read_text())
            self.assertNotIn('/skill:', (root / 'two/SKILL.md').read_text())
        canonical = sync.load_source(self.source)
        for entry in CONFIG['targets'].values():
            if 'adapter' not in entry:
                continue
            for files in canonical.values():
                rendered = sync.render(files, entry['adapter'])
                self.assertEqual(rendered, sync.render(files, entry['adapter']))
                original_body = files['SKILL.md'].split(b'\n---\n', 1)[1]
                self.assertTrue(rendered['SKILL.md'].endswith(original_body))
        self.assertIn('allow_implicit_invocation: false', (self.home / '.codex/skills/two/agents/openai.yaml').read_text())
        self.assertIn(sync.GUARD, (self.home / '.config/opencode/skills/two/SKILL.md').read_text())
        self.assertTrue((self.home / '.cursor/skills/one').exists())
        self.assertFalse((self.home / '.agents/skills/one').exists())

    def test_pi_invocations_adapted_in_copies_without_changing_source(self):
        skill = self.source / 'skills/one'
        (skill / 'SKILL.md').write_text((skill / 'SKILL.md').read_text() +
                                      'Run `/skill:two`, then the `/skill:name` skills.\n')
        (skill / 'scripts/helper.sh').write_text('# Generated by /skill:wizard.\necho support\n')
        (skill / 'reference.md').write_text('Consult `/skill:domain-modeling`.\n')
        (skill / 'payload.bin').write_bytes(b'\x00/skill:two\xff')
        (self.source / 'THIRD_PARTY_NOTICES.md').write_text('Attribution for /skill:two.\n')
        subprocess.run(['git', '-C', str(self.source), 'add', '.'], check=True)
        before = self.snapshot(self.source)
        self.run_sync()
        self.assertEqual(before, self.snapshot(self.source))
        for target in CONFIG['targets'].values():
            if 'path' not in target:
                continue
            root = self.home / target['path'] / 'one'
            self.assertIn('Run `two`, then the `name` skills.', (root / 'SKILL.md').read_text())
            self.assertEqual((root / 'scripts/helper.sh').read_text(), '# Generated by wizard.\necho support\n')
            self.assertEqual((root / 'reference.md').read_text(), 'Consult `domain-modeling`.\n')
            self.assertEqual((root / 'payload.bin').read_bytes(), b'\x00/skill:two\xff')
            self.assertEqual((root / 'THIRD_PARTY_NOTICES.md').read_bytes(),
                             (self.source / 'THIRD_PARTY_NOTICES.md').read_bytes())
        installed = self.snapshot()
        self.run_sync()
        self.assertEqual(installed, self.snapshot())

    def test_update_delete_rename_and_manual_survives(self):
        self.run_sync()
        manual = self.home / '.codex/skills/my-own'
        manual.mkdir()
        (manual / 'SKILL.md').write_text('mine')
        file = self.source / 'skills/one/SKILL.md'
        file.write_text(file.read_text() + 'Updated instructions.\n')
        self.run_sync()
        self.assertIn('Updated instructions.', (self.home / '.codex/skills/one/SKILL.md').read_text())
        shutil.rmtree(self.source / 'skills/one')
        self.add_skill('renamed')
        self.run_sync()
        self.assertFalse((self.home / '.codex/skills/one').exists())
        self.assertTrue((self.home / '.codex/skills/renamed/SKILL.md').exists())
        self.assertEqual((manual / 'SKILL.md').read_text(), 'mine')

    def test_selected_inventory_prunes_all_targets_without_changing_agent_layout(self):
        selected = {'grill-me', 'grilling', 'handoff', 'teach', 'wizard',
                    'diagnosing-bugs', 'research', 'resolving-merge-conflicts',
                    'writing-for-agents', 'codebase-design', 'yeet', 'autopilot'}
        for name in selected:
            self.add_skill(name, manual=name in {'yeet', 'autopilot'})
        self.run_sync()
        builtin = self.home / '.codex/skills/.system/vendor/SKILL.md'
        builtin.parent.mkdir(parents=True)
        builtin.write_text('vendor-owned')
        for name in ['one', 'two']:
            shutil.rmtree(self.source / 'skills' / name)
        source_before = self.snapshot(self.source)
        self.run_sync()
        for target in CONFIG['targets'].values():
            if 'path' not in target:
                continue
            root = self.home / target['path']
            self.assertEqual({p.parent.name for p in root.glob('*/SKILL.md')}, selected)
            state = json.loads((root / sync.STATE).read_text())
            self.assertEqual(set(state), selected)
        self.assertEqual(builtin.read_text(), 'vendor-owned')
        self.assertTrue((self.home / '.cursor/skills').exists())
        self.assertFalse((self.home / '.pi/agent/skills').exists())
        self.assertEqual(source_before, self.snapshot(self.source))
        installed = self.snapshot()
        self.run_sync()
        self.assertEqual(installed, self.snapshot())

    def test_restore_manual_publishing_skills_across_all_targets(self):
        self.assertEqual(CONFIG['targets']['claude'], {'path': '.claude/skills', 'adapter': 'standard'})
        self.assertEqual(CONFIG['targets']['cursor'], {'path': '.cursor/skills', 'adapter': 'standard'})
        for name in ['yeet', 'autopilot']:
            self.add_skill(name, manual=True)
        self.run_sync()
        for name in ['yeet', 'autopilot']:
            shutil.rmtree(self.source / 'skills' / name)
        self.run_sync()
        for target in CONFIG['targets'].values():
            if 'path' in target:
                for name in ['yeet', 'autopilot']:
                    self.assertFalse((self.home / target['path'] / name).exists())
        for name in ['yeet', 'autopilot']:
            self.add_skill(name, manual=True)
        self.run_sync()
        for target in CONFIG['targets'].values():
            if 'path' not in target:
                continue
            for name in ['yeet', 'autopilot']:
                root = self.home / target['path'] / name
                self.assertIn('disable-model-invocation: true', (root / 'SKILL.md').read_text())
                self.assertIn('Keep every substantive instruction.', (root / 'SKILL.md').read_text())
                if target['adapter'] == 'codex':
                    self.assertIn('allow_implicit_invocation: false', (root / 'agents/openai.yaml').read_text())
                elif target['adapter'] == 'explicit-guard':
                    self.assertIn(sync.GUARD, (root / 'SKILL.md').read_text())
                else:
                    self.assertEqual((root / 'SKILL.md').read_bytes(),
                                     (self.source / 'skills' / name / 'SKILL.md').read_bytes())
        installed = self.snapshot()
        self.run_sync()
        self.assertEqual(installed, self.snapshot())
        self.assertFalse((self.home / '.pi/agent/skills').exists())
        self.assertTrue((self.home / '.cursor/skills').exists())

    def test_sync_preserves_native_configs_runtime_and_unowned_skills(self):
        protected = []
        for target in CONFIG['targets'].values():
            root = self.home / target['path']
            for relative in ['settings.json', 'config.toml', 'auth.json', 'sessions/example.jsonl']:
                file = root.parent / relative
                file.parent.mkdir(parents=True, exist_ok=True)
                file.write_text('Agent-owned fixture; must not be touched.\n')
                protected.append(file)
            manual = root / 'personal/SKILL.md'
            manual.parent.mkdir(parents=True)
            manual.write_text('Unowned personal skill\n')
            protected.append(manual)
        pi_settings = self.home / '.pi/agent/settings.json'
        pi_settings.parent.mkdir(parents=True)
        pi_settings.write_text('Pi bootstrap fixture\n')
        protected.append(pi_settings)
        before = {p: (p.read_bytes(), p.stat().st_mtime_ns) for p in protected}
        self.run_sync()
        shutil.rmtree(self.source / 'skills/one')
        self.run_sync()
        self.assertEqual(before, {p: (p.read_bytes(), p.stat().st_mtime_ns) for p in protected})
        self.assertFalse((self.home / '.pi/agent/skills').exists())
        self.assertFalse((self.home / '.agents/skills').exists())

    def test_claude_unowned_collision_blocks_all_target_writes(self):
        collision = self.home / '.claude/skills/one'
        collision.mkdir(parents=True)
        (collision / 'SKILL.md').write_text('user-owned Claude skill')
        before = self.snapshot()
        with self.assertRaisesRegex(ValueError, 'Unowned skill collision'):
            self.run_sync()
        self.assertEqual(before, self.snapshot())
        self.assertFalse((self.home / '.codex').exists())

    def test_missing_source_and_dry_run_never_delete(self):
        self.run_sync()
        before = self.snapshot()
        file = self.source / 'skills/one/SKILL.md'
        file.write_text(file.read_text() + 'new')
        self.run_sync(dry=True)
        self.assertEqual(before, self.snapshot())
        self.source = self.base / 'missing'
        with contextlib.redirect_stderr(io.StringIO()) as message:
            self.run_sync()
        self.assertIn('Existing skills untouched', message.getvalue())
        self.assertEqual(before, self.snapshot())

    def test_collision_preflight_and_modified_copy(self):
        collision = self.home / '.grok/skills/one'
        collision.mkdir(parents=True)
        (collision / 'SKILL.md').write_text('user version')
        with self.assertRaisesRegex(ValueError, 'Unowned skill collision'):
            self.run_sync()
        self.assertFalse((self.home / '.codex').exists())
        shutil.rmtree(collision)
        self.run_sync()
        (self.home / '.grok/skills/one/extra.txt').write_text('user addition')
        with self.assertRaisesRegex(ValueError, 'Modified managed'):
            self.run_sync()

    def test_legacy_adoption_and_cleanup_exact_only(self):
        old = sync.tree(self.source / 'skills/one')
        self.legacy = {'one': sync.hashes(old)}
        for root in ['.codex/skills', '.cursor/skills', '.pi/agent/skills', '.agents/skills']:
            shutil.copytree(self.source / 'skills/one', self.home / root / 'one')
        unrelated = self.home / '.agents/skills/manual'
        unrelated.mkdir()
        (unrelated / 'SKILL.md').write_text('unrelated')
        self.run_sync()
        for root in ['.codex/skills', '.cursor/skills']:
            self.assertTrue((self.home / root / 'one/SKILL.md').exists())
            self.assertIn('one', json.loads((self.home / root / sync.STATE).read_text()))
        for root in ['.pi/agent/skills', '.agents/skills']:
            self.assertFalse((self.home / root / 'one').exists())
        self.assertTrue((unrelated / 'SKILL.md').exists())

    def test_symlinks_rejected(self):
        self.home.mkdir()
        (self.home / '.codex').symlink_to(self.base / 'elsewhere')
        with self.assertRaisesRegex(ValueError, 'symlink'):
            self.run_sync()
        (self.home / '.codex').unlink()
        (self.source / 'skills/one/SKILL.md').unlink()
        (self.source / 'skills/one/SKILL.md').symlink_to(self.source / 'skills/two/SKILL.md')
        with self.assertRaisesRegex(ValueError, 'symlink'):
            self.run_sync()

    def test_integrity_missing_duplicate_untracked_secret_and_pi_syntax(self):
        file = self.source / 'skills/one/SKILL.md'
        original = file.read_text()
        file.unlink()
        with self.assertRaisesRegex(ValueError, 'Missing SKILL.md'):
            self.run_sync()
        file.write_text(original)
        second = self.source / 'skills/two/SKILL.md'
        second.write_text(second.read_text().replace('name: two', 'name: one'))
        with self.assertRaisesRegex(ValueError, 'Duplicate canonical'):
            self.run_sync()
        second.write_text(second.read_text().replace('name: one', 'name: two'))
        extra = self.source / 'skills/one/auth.json'
        extra.write_text('{}')
        with self.assertRaisesRegex(ValueError, 'Untracked'):
            self.run_sync()
        subprocess.run(['git', '-C', str(self.source), 'add', '.'], check=True)
        with self.assertRaisesRegex(ValueError, 'Forbidden'):
            self.run_sync()
        extra.unlink()
        file.write_text(original + '/skill:')
        before = self.snapshot()
        with self.assertRaisesRegex(ValueError, 'Nonportable'):
            self.run_sync()
        self.assertEqual(before, self.snapshot())


if __name__ == '__main__':
    unittest.main()
