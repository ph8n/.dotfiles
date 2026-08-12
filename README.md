# Personal Nix configuration

Single-host macOS configuration inspired by Mitchell Hashimoto's Nix setup, with less abstraction.

## Ownership

- Determinate Nix owns the Nix installation, daemon, settings, and store.
- Standalone Home Manager owns personal packages and retained dotfiles/services.
- Mise owns fast-moving personal CLIs and convenient global runtimes.
- Project flakes own exact development dependencies.
- Homebrew owns GUI applications only.

## Dotfiles

- Hand-authored configuration is linked immutably from the Nix store: edit `~/nix-config`, then run `hm`.
- Settings that applications update themselves are writable links into `~/nix-config`, so changes appear in `dot status`.
- Credentials, sessions, caches, and generated state remain local and ignored.

## Commands

```sh
nix flake check ~/nix-config
hm          # apply Home Manager

dot status  # Git operations in ~/nix-config
dot diff
```

## Remaining work

- Add project flakes where removed global development tools are still needed.
- Package the personal `mark` and `hz` binaries with Nix.
- Move the existing yabai/skhd LaunchAgents into Home Manager without changing behavior.

## Future nix-darwin

nix-darwin is intentionally not enabled. When added, use Determinate's nix-darwin module with `determinateNix.enable = true` and keep the configuration single-host until another host actually exists.
