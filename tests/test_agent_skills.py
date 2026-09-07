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

    def snapshot(self):
        return {str(p.relative_to(self.home)): (p.read_bytes(), p.stat().st_mtime_ns)
                for p in self.home.rglob('*') if p.is_file()}

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
        self.assertFalse((self.home / '.cursor/skills/one').exists())
        self.assertFalse((self.home / '.agents/skills/one').exists())

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
        self.assertTrue((self.home / '.codex/skills/one/SKILL.md').exists())
        for root in ['.cursor/skills', '.pi/agent/skills', '.agents/skills']:
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
        file.write_text(original + '/skill:two')
        with self.assertRaisesRegex(ValueError, 'Nonportable'):
            self.run_sync()


if __name__ == '__main__':
    unittest.main()
