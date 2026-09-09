"""Read-only integration checks; requires nix and chezmoi on PATH."""
import json
import posixpath
from pathlib import Path
import subprocess
import tempfile
import unittest

REPO = Path(__file__).resolve().parents[1]
HOSTS = {
    'darwin': ('darwinConfigurations.darwin', 'dp'),
    'linux': ('nixosConfigurations.box', 'z'),
}
PROJECTION = '''c: {
  files = map (f: f.target) (builtins.attrValues c.home.file);
  activation = builtins.mapAttrs (_: v: v.after) c.home.activation;
  activationTools = map (p: p.pname) c.home.extraActivationPath;
}'''


def overlaps(left, right):
    left, right = posixpath.normpath(left), posixpath.normpath(right)
    return left == right or left.startswith(right + '/') or right.startswith(left + '/')


class BoundaryTests(unittest.TestCase):
    def test_overlap_detection(self):
        self.assertTrue(overlaps('.config/opencode', '.config/opencode/config.json'))
        self.assertTrue(overlaps('.codex/skills/one', '.codex/skills'))
        self.assertTrue(overlaps('.config/a/../mise/config.toml', '.config/mise/config.toml'))
        self.assertFalse(overlaps('.config/mise-other', '.config/mise'))

    def test_pi_bootstrap_points_to_one_package_without_resource_mirrors(self):
        template = (REPO / 'chezmoi/dot_pi/agent/settings.json.tmpl').read_text()
        settings = json.loads(template[template.index('{\n'):].replace('{{ .chezmoi.homeDir }}', '/home/test'))
        self.assertEqual(settings['packages'].count('/home/test/code/pi-extensions'), 1)
        for resource in ['skills', 'extensions', 'themes']:
            self.assertNotIn(resource, settings, 'Pi resources belong to the package, not chezmoi mirrors')
        self.assertTrue(settings['enableSkillCommands'])

    def test_pi_preferences_for_both_hosts(self):
        expected = {
            'fast-mode.json': {'version': 1, 'enabled': False},
            'pi-fff.json': {'mode': 'override'},
        }
        for os_name in HOSTS:
            with self.subTest(os=os_name), tempfile.TemporaryDirectory() as temporary:
                home = Path(temporary) / 'home'
                home.mkdir()
                command = [
                    'chezmoi', '--source', str(REPO / 'chezmoi'),
                    '--destination', str(home), '--config', '/dev/null', '--config-format', 'toml',
                    '--cache', str(Path(temporary) / 'cache'),
                    '--persistent-state', str(Path(temporary) / 'state.boltdb'),
                    '--override-data', json.dumps({'chezmoi': {'os': os_name}}),
                ]
                managed = subprocess.check_output(command + [
                    'managed', '--include', 'files', '--path-style', 'relative',
                ], text=True).splitlines()
                settings_path = '.pi/agent/settings.json'
                self.assertIn(settings_path, managed)
                settings = json.loads(subprocess.check_output(
                    command + ['cat', str(home / settings_path)], text=True,
                ))
                self.assertNotIn('compaction', settings, 'Use native Pi compaction defaults')
                self.assertNotIn('.pi/agent/context.json', managed)
                for name, value in expected.items():
                    relative = f'.pi/agent/{name}'
                    self.assertIn(relative, managed)
                    rendered = subprocess.check_output(command + ['cat', str(home / relative)], text=True)
                    self.assertEqual(json.loads(rendered), value)
                for name in ['auth.json', 'sessions/example.jsonl', 'mcp-cache.json', 'models-store.json']:
                    self.assertNotIn(f'.pi/agent/{name}', managed)

    def test_ownership_and_activation_for_both_hosts(self):
        skills = json.loads((REPO / 'chezmoi/dot_config/agent-skills/targets.json').read_text())
        # Include destinations managed by the sync script, not just chezmoi itself.
        skill_paths = [skills['source'], *skills['legacy_cleanup']]
        skill_paths.extend(target['path'] for target in skills['targets'].values())

        for os_name, (host, user) in HOSTS.items():
            with self.subTest(host=host), tempfile.TemporaryDirectory() as temporary:
                home = Path(temporary) / 'home'
                home.mkdir()
                managed = subprocess.check_output([
                    'chezmoi', '--source', str(REPO / 'chezmoi'),
                    '--destination', str(home), '--config', '/dev/null', '--config-format', 'toml',
                    '--cache', str(Path(temporary) / 'cache'),
                    '--persistent-state', str(Path(temporary) / 'state.boltdb'),
                    '--override-data', json.dumps({'chezmoi': {'os': os_name}}),
                    'managed', '--include', 'files,symlinks', '--path-style', 'relative',
                ], text=True).splitlines()
                self.assertIn('.config/mise/config.toml', managed)
                config = json.loads(subprocess.check_output([
                    'nix', 'eval', '--json',
                    f'path:{REPO}#{host}.config.home-manager.users.{user}',
                    '--apply', PROJECTION,
                ], text=True))
                collisions = [
                    (hm, agent) for hm in config['files'] for agent in managed + skill_paths
                    if overlaps(hm, agent)
                ]
                self.assertEqual(collisions, [], 'Home Manager must not own agent destinations')
                self.assertIn('.config/chezmoi/chezmoi.toml', config['files'])
                self.assertIn('linkGeneration', config['activation']['chezmoiApply'])
                self.assertIn('chezmoiApply', config['activation']['miseInstall'])
                self.assertIn('python3', config['activationTools'])
                self.assertIn('git', config['activationTools'])


if __name__ == '__main__':
    unittest.main()
