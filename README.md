# nix-config

One owner per path.

- **Nix / Home Manager** owns the machine, packages, shell, user services, and non-agent dotfiles.
- **Chezmoi** owns agent-tool files: configs, hooks, mise plugins, and ownership-tracked canonical skill distribution (`chezmoi/`).
- Home Manager writes `~/.config/chezmoi/chezmoi.toml`, runs `chezmoi apply`, then `mise install` so plugins exist before tools are installed. Nothing else in Nix may write a chezmoi destination.
- Chezmoi reads the live tree at `chezmoi/`, not a Nix generation.

```sh
hm
nix flake check --all-systems --no-build
python3 -B -m unittest discover -s tests -p test_agent_skills.py -v
```

## Agent skills

Canonical instructions and resources live only in `~/code/pi-extensions/skills`.
Pi discovers the checkout through its package manifest, not a mirrored skill directory.
Every `chezmoi apply` runs `~/.local/bin/sync-agent-skills`; using `run_after` (not
`run_onchange`) makes edits in the other checkout sufficient to trigger reconciliation.
The optional command also supports `--dry-run`, `--source`, `--home`, and `--config`.
Python 3 is already supplied by Home Manager/mise.

The single path/adapter table is `chezmoi/dot_config/agent-skills/targets.json`:
Codex, Copilot, OpenCode, Grok, and DeepSeek Harness receive real directories;
Cursor uses its native Codex compatibility discovery rather than another mirror.
No output goes into `~/.agents/skills`, where Pi would discover duplicates.
All agents can be provisioned before their executables are installed.

The sync reads working-tree contents of **Git-tracked** canonical skill files.
Review and `git add` newly created skills/supporting files before distribution.
Nested resources and license/attribution notices travel with each skill.
Codex receives manual-invocation policy sidecars; OpenCode gets a descriptive
explicit-request guard because it ignores that frontmatter policy.

`legacy.json` is a fixed hash-only allowlist of the old sync's audited copies
(including their old formatting), not another content tree. It authorizes exact
adoption/cleanup only. Subsequent ownership is recorded per destination in
`.pi-extensions-skills.json`. Unowned collisions and locally modified managed skills
stop reconciliation before writes; move the reported copy aside or restore it,
then rerun. A missing checkout leaves existing skills untouched with a message.
Never refresh the legacy allowlist from arbitrary live directories to bypass a conflict.

**Limits:** Cursor CLI cannot currently isolate compatibility skill roots via a
supported config setting and also bundles its own `autopilot`. This remaining
built-in/personal collision is documented, not fixed by deleting Cursor-owned files,
renaming Codex's skill, or relocating credentials. OpenCode's manual-invocation guard
is an instruction rather than enforced access control. Nondefault agent homes/XDG
roots require updating the target table. Existing unrelated live config drift should
be reviewed in `chezmoi diff` before a real apply.

Full audit, per-skill classifications, primary sources, and native validation results:
`~/code/pi-extensions/docs/agent-skills.md`.
