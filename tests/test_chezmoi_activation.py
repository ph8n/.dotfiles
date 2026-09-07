"""Exercise the native Home Manager chezmoi handoff in a disposable HOME.

Requires nix and git. Builds (but never activates) the native home generation.
Run: python3 -B -m unittest discover -s tests -p test_chezmoi_activation.py -v
"""
import json
from pathlib import Path
import platform
import re
import shutil
import subprocess
import tempfile
import unittest

REPO = Path(__file__).resolve().parents[1]


class ChezmoiActivationTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        host, user, home = {
            'Linux': ('nixosConfigurations.box', 'z', '/home/z'),
            'Darwin': ('darwinConfigurations.darwin', 'dp', '/Users/dp'),
        }[platform.system()]
        generation = subprocess.check_output([
            'nix', 'build', '--no-link', '--print-out-paths',
            f'path:{REPO}#{host}.config.home-manager.users.{user}.home.activationPackage',
        ], text=True).strip()
        activation = (Path(generation) / 'activate').read_text()
        # Use the generated PATH and actual handoff, not the test runner's shell
        # environment (which hides missing activation dependencies).
        cls.path = re.search(r'^export PATH="([^"]+)"', activation, re.M)[1]
        marker = '_iNote "Activating %s" "chezmoiApply"\n'
        cls.handoff = activation.split(marker, 1)[1].split('\n_iNote ', 1)[0]
        cls.real_home = home

    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='hm activation ')
        self.addCleanup(self.temp.cleanup)
        self.home = Path(self.temp.name).resolve() / 'home with spaces'
        self.home.mkdir()
        source = self.home / 'nix-config/chezmoi'
        source.mkdir(parents=True)
        # Only the skill-sync slice of the live tree is needed for this seam.
        for relative in [
            'run_after_sync-agent-skills.sh.tmpl',
            'private_dot_local/bin/executable_sync-agent-skills',
            'dot_config/agent-skills/targets.json',
            'dot_config/agent-skills/legacy.json',
        ]:
            destination = source / relative
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copyfile(REPO / 'chezmoi' / relative, destination)
        self.config = json.loads((source / 'dot_config/agent-skills/targets.json').read_text())
        canonical = self.home / self.config['source']
        skill = canonical / 'skills/activation-test/SKILL.md'
        skill.parent.mkdir(parents=True)
        skill.write_text('---\nname: activation-test\ndescription: Activation fixture\n---\n\nRun `/skill:research`.\n')
        self.skill = skill
        (canonical / 'LICENSE').write_text('Test license\n')
        (canonical / 'THIRD_PARTY_NOTICES.md').write_text('Test notices\n')
        subprocess.run(['git', 'init', '-q', str(canonical)], check=True)
        subprocess.run(['git', '-C', str(canonical), 'add', '.'], check=True)

    def apply(self, dry_run=False):
        result = subprocess.run([
            'bash', '--noprofile', '--norc', '-euc',
            self.handoff.replace(self.real_home, str(self.home)),
        ], env={
            'HOME': str(self.home),
            'PATH': self.path,
            'DRY_RUN_CMD': 'echo' if dry_run else '',
        }, cwd=self.home, capture_output=True, text=True)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        return result

    def test_clean_activation_and_repeated_apply(self):
        self.apply()
        installed = []
        for target in self.config['targets'].values():
            if 'path' not in target:
                continue
            root = self.home / target['path']
            skill = root / 'activation-test/SKILL.md'
            self.assertEqual(skill.read_bytes(), self.skill.read_bytes().replace(b'/skill:', b''))
            self.assertIn('activation-test', json.loads((root / '.pi-extensions-skills.json').read_text()))
            installed.extend(path for path in root.rglob('*') if path.is_file())
        before = {p: (p.read_bytes(), p.stat().st_mtime_ns) for p in installed}
        self.apply()
        self.assertEqual(before, {p: (p.read_bytes(), p.stat().st_mtime_ns) for p in installed})
        # An edit outside chezmoi must still reconcile on the next apply.
        self.skill.write_text(self.skill.read_text() + 'Updated.\n')
        self.apply()
        for path in installed:
            if path.name == 'SKILL.md':
                self.assertEqual(path.read_bytes(), self.skill.read_bytes().replace(b'/skill:', b''))

    def test_dry_run_does_not_apply_files_or_skills(self):
        self.apply(dry_run=True)
        self.assertFalse((self.home / '.local').exists())
        self.assertFalse((self.home / '.config').exists())
        for target in self.config['targets'].values():
            if 'path' in target:
                self.assertFalse((self.home / target['path']).exists())


if __name__ == '__main__':
    unittest.main()
