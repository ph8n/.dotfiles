"""Exercise the generated Home Manager reload hook without touching the live desktop."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

REPO = Path(__file__).resolve().parents[1]


@unittest.skipUnless(os.uname().sysname == 'Darwin', 'requires Darwin Nix packages')
class SkhdActivationTests(unittest.TestCase):
    def test_reload_after_config_change(self):
        config = json.loads(subprocess.check_output([
            'nix', 'eval', '--json', f'path:{REPO}#darwinConfigurations.darwin',
            '--apply', '''host: {
              activation = host.config.home-manager.users.dp.home.activation.onFilesChange;
              bash = "${host.pkgs.bash}/bin/bash";
              skhd = "${host.pkgs.skhd}/bin/skhd";
            }''',
        ], text=True))
        self.assertIn('linkGeneration', config['activation']['after'])

        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            probe = root / 'pgrep'
            probe.write_text('#!/bin/sh\nexit "$TEST_RUNNING_EXIT"\n')
            probe.chmod(0o755)
            reload = root / 'skhd'
            reload.write_text('#!/bin/sh\nprintf "%s\\n" "$*" >> "$TEST_RELOAD_LOG"\n')
            reload.chmod(0o755)
            log = root / 'reload.log'
            # Keep Home Manager's real changed-file and dry-run dispatch; replace
            # only the process probe and daemon command at the OS boundary.
            activation = config['activation']['data'].replace(
                '/usr/bin/pgrep', str(probe),
            ).replace(config['skhd'], str(reload))

            for changed, running, dry_run, expected in [
                (True, True, False, ['--reload']),
                (False, True, False, []),
                (True, False, False, []),
                (True, True, True, []),
            ]:
                with self.subTest(changed=changed, running=running, dry_run=dry_run):
                    log.write_text('')
                    script = '\n'.join([
                        'set -e',
                        'unset DRY_RUN VERBOSE',
                        'declare -A changedFiles',
                        f'changedFiles[.config/skhd/skhdrc]={int(changed)}',
                        'export DRY_RUN=1' if dry_run else ':',
                        activation,
                    ])
                    subprocess.run([config['bash'], '-c', script], check=True, env={
                        **os.environ,
                        'TEST_RUNNING_EXIT': '0' if running else '1',
                        'TEST_RELOAD_LOG': str(log),
                    }, capture_output=True, text=True)
                    self.assertEqual(log.read_text().splitlines(), expected)


if __name__ == '__main__':
    unittest.main()
