# Personal Nix configuration

Home Manager configuration for `dp` (`aarch64-darwin`).

## Ownership

- Standalone Home Manager owns personal packages and retained dotfiles/services.
- Mise owns fast-moving personal CLIs and convenient global runtimes.
- Project flakes own exact development dependencies.
- Homebrew owns GUI applications.

## Layout

```
flake.nix                  # homeConfigurations.dp
machines/dp.nix            # Home Manager entry for the Mac
home/                      # user config
home/darwin.nix            # yabai/skhd/karabiner-era packages, launchd agents, pass
```

## Dotfiles

- Hand-authored configuration is linked immutably from the Nix store: edit `~/nix-config`, then run `hm`.
- Settings that applications update themselves are writable links into `~/nix-config`, so changes appear in `dot status`.
- Credentials, sessions, caches, and generated state remain local and ignored.

## Commands

```sh
nix flake check ~/nix-config

hm          # apply this host's Home Manager generation

dot status  # Git operations in ~/nix-config
dot diff
```
