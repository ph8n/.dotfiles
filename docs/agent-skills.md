# Agent ownership and skill distribution

## Ownership boundary

- **pi-extensions** owns Pi's complete package: extensions, commands, theme, and
  canonical shared skill bundles. Pi loads `~/code/pi-extensions` directly.
- **nix-config / chezmoi** owns Pi's native settings template at
  `chezmoi/dot_pi/agent/settings.json.tmpl`, including its package pointer, and
  selected preferences in the same directory: `private_fast-mode.json` (off) and
  `private_pi-fff.json` (`override`). The
  `private_` prefix installs each native filename with mode 0600. Applying chezmoi restores
  these values after interactive changes. It does not mirror Pi resources or
  write into the package checkout. Compaction settings are not overridden: Pi 0.85.1
  defaults to auto-compaction enabled, approximately 20k retained recent tokens,
  and a 16,384-token reserve. The removed context extension has no managed preference.
- **Other agents** use their own native configuration roots. Chezmoi installs
  adapted shared skills into each agent's own skills directory; no agent's
  installation is used as another agent's managed source.
- **Nix / Home Manager** owns machine configuration and non-agent files. Its only
  agent handoff is chezmoi activation; it must not also own agent destinations.
- Credentials, sessions, caches, diagnostics, vendor bundles, and other unmanaged
  runtime state remain local to their owning agent. Skill distribution never
  copies them; only the selected Pi preferences above are managed by chezmoi.

The authoritative installation/adapter table is
[`targets.json`](../chezmoi/dot_config/agent-skills/targets.json):

| Agent | Configuration root | Shared skill installation |
| --- | --- | --- |
| Pi | `~/.pi/agent` native settings/state; package in `~/code/pi-extensions` | Package `skills/` only |
| Claude Code | `~/.claude` | `~/.claude/skills` |
| Codex | `~/.codex` | `~/.codex/skills` |
| Cursor | `~/.cursor` | `~/.cursor/skills` |
| Copilot | `~/.copilot` | `~/.copilot/skills` |
| OpenCode | `~/.config/opencode` | `~/.config/opencode/skills` |
| Grok | `~/.grok` | `~/.grok/skills` |
| DeepSeek Harness | `~/.dsh` | `~/.dsh/skills` |

These are default roots; alternate agent-home/XDG settings require updating the
single target table. Do not relocate credentials to change skill discovery.
Nothing is installed into `~/.agents/skills` or `~/.pi/agent/skills`, because Pi
would discover duplicate package resources. Exact-hash cleanup of old copies in
those roots is migration only. Compatibility `via` targets are rejected.

## Updating skills

Edit canonical skills in `~/code/pi-extensions/skills`. Review and `git add` new
skill/supporting files before distribution: the reconciler reads **Git-tracked
files using their working-tree contents**, not arbitrary checkout files.

```sh
sync-agent-skills --dry-run
sync-agent-skills
```

Every `chezmoi apply` runs the same reconciler through `run_after`, so edits in the
separate package checkout are picked up even when chezmoi files are unchanged.
Review unrelated `chezmoi diff` output before a whole-home apply. The command also
supports `--source`, `--home`, and `--config`; use a disposable HOME for probes.
Home Manager supplies Python 3 and Git on its restricted activation PATH.

Pi changes become active after `/reload`. Use only `/skill:<name>` in Pi, including
`/skill:yeet` and `/skill:autopilot`; there are no shorthand skill aliases. Both
publishing workflows are manual-only. Publishing does not automatically start
merge-readiness monitoring, and autopilot never merges the PR.

## Portability and discovery limits

Bundles retain supporting resources, `LICENSE`, and `THIRD_PARTY_NOTICES.md`.
Pi-specific invocation references become semantic skill names in distributed
Markdown/shell copies only; the canonical package is unchanged.

- Claude Code, Cursor, Grok, and DSH retain native manual-invocation metadata.
- Codex also receives `agents/openai.yaml` with
  `policy.allow_implicit_invocation: false` for manual skills.
- OpenCode ignores that frontmatter policy, so its adapter adds an explicit-request
  instruction guard. This is not enforced access control.
- Copilot receives the policy metadata; discovery alone does not prove runtime
  automatic-invocation suppression.

Native roots establish **installation ownership, not complete discovery isolation**.
Cursor also scans Claude/Codex/Grok/shared compatibility roots. Its native personal
copy precedes matching compatibility copies, but the CLI has no supported switch
for disabling all compatibility discovery. Its separately bundled
`skills-cursor/autopilot` can coexist in the model catalog. Leave vendor files
untouched; do not claim a zero-duplicate catalog. Other agents may also support
compatibility roots; keep their native installations authoritative rather than
creating cross-agent config links. Claude must restart if its top-level skills
directory was created after the session began.

The shared autopilot adaptation derives from Cursor's bundled skill; its standalone
redistribution license remains unverified. Preserve the notice and review rights
before publishing the bundle.

## Reconciliation safeguards

All destinations are preflighted before writes. Overlapping source/install/cleanup
paths, untracked support files, symlinks, runtime/secret paths, duplicate skill
names, and invalid invocation syntax are rejected. A missing checkout preserves
existing installations with an actionable message.

`.pi-extensions-skills.json` records file hashes per owned skill. Unowned collisions
and modified managed copies stop reconciliation without overwriting them. Move a
reported modified copy aside or restore it, then rerun. Unrelated personal skills,
configs, credentials, and vendor bundles are outside the reconciler's ownership.

`legacy.json` is a fixed hash-only migration allowlist, not another content source.
Keep removed names for exact adoption/cleanup; never refresh it from arbitrary live
copies to bypass a conflict. Deletion unlinks only owned files and empty directories.
A process lock and atomic file replacement protect cooperating writers; a crash
mid-skill may leave a partial copy that the next run refuses to overwrite.

## Validation

```sh
python3 -B -m unittest discover -s tests -v
```

Tests cover exact native target ownership, the single Pi bootstrap, read-only Pi
package boundaries, config/runtime preservation, adapters, add/remove/restore,
legacy adoption, collisions, and idempotence. Integration checks evaluate Home
Manager ownership for both hosts and exercise activation in a disposable HOME;
they do not activate the user's real home.

Native discovery references: [Pi](https://github.com/earendil-works/pi-mono/blob/main/packages/coding-agent/docs/skills.md),
[Claude Code](https://code.claude.com/docs/en/skills),
[Codex](https://developers.openai.com/codex/skills/),
[Cursor](https://cursor.com/docs/skills),
[Copilot](https://docs.github.com/en/copilot/how-tos/copilot-cli/customize-copilot/add-skills),
[OpenCode](https://opencode.ai/docs/skills/), and
[Grok](https://docs.x.ai/build/features/skills-plugins-marketplaces).
DSH's installed `@deepseek-ai/dsh-skill-filesystem` README describes its native
roots and invocation policy. Session probes, audits, captured results, and logs
are disposable, not repository documentation or distribution inputs.
