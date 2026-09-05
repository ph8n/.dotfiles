# nix-config

One owner per path.

- **Nix / Home Manager** owns the machine, packages, shell, user services, and non-agent dotfiles.
- **Chezmoi** owns agent-tool files: configs, hooks, mise plugins, and Pi skill copies into other agents (`chezmoi/`).
- Home Manager writes `~/.config/chezmoi/chezmoi.toml`, runs `chezmoi apply`, then `mise install` so plugins exist before tools are installed. Nothing else in Nix may write a chezmoi destination.
- Chezmoi reads the live tree at `chezmoi/`, not a Nix generation.

```sh
hm
nix flake check --all-systems --no-build
```
