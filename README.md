# nix-config

Nix owns the machine, packages, shell, and non-agent dotfiles.
Chezmoi owns agent-tool configs under `~/.config` (`chezmoi/`).
Home Manager activation runs `chezmoi apply` on both NixOS and macOS.

```sh
hm
nix flake check --all-systems --no-build
```
