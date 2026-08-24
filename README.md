# Personal Nix configuration

Multi-host configuration inspired by Mitchell Hashimoto's Nix setup, with less abstraction.

## Hosts

- `dp` — macOS workstation (`aarch64-darwin`, user `dp`)
- `box` — NixOS server (`x86_64-linux`, user `box`)

## Ownership

- NixOS owns the kernel, disks, networking, Nix, and system services on `box`.
- Standalone Home Manager owns personal packages and retained dotfiles/services on `dp`.
- Mise owns fast-moving personal CLIs and convenient global runtimes; its
  config is shared verbatim between hosts.
- Project flakes own exact development dependencies.
- Homebrew owns GUI applications only on `dp`.

## Layout

```
flake.nix                  # nixosConfigurations.box and homeConfigurations.dp
machines/box/              # NixOS host: boot, user, Tailscale
machines/dp.nix            # Home Manager entry for the Mac
home/                      # shared user config (Mac today; box later)
home/darwin.nix            # yabai/skhd/karabiner-era packages, launchd agents, pass
home/linux.nix             # fonts, cage, foot, kanata, tty1 seat (not wired yet)
kanata/                    # keyboard remaps for box
```

## Dotfiles

- Hand-authored configuration is linked immutably from the Nix store: edit `~/.nix-conf`, then run `hm` on `dp`.
- Settings that applications update themselves are writable links into `~/.nix-conf`, so changes appear in `dot status`.
- Credentials, sessions, caches, and generated state remain local and ignored.
- Mac-only apps (Ghostty, Zed, Karabiner, yabai, skhd) stay off `box`.

## Commands

```sh
nix flake check ~/.nix-conf

# box
sudo nixos-rebuild switch --flake ~/.nix-conf#box

# dp
hm          # apply this host's Home Manager generation

dot status  # Git operations in ~/.nix-conf
dot diff
```

On `dp`, `box` is `ssh box`: Tailscale MagicDNS name `box.tail5606b4.ts.net`, user `box`.

## Remaining work on box

- Mount `data-vg` (`/mnt/data`, `/srv/photos`) and restore `~/storage` / `~/scratch`.
- Run Immich, PostgreSQL, and Redis as NixOS services.
- Import Home Manager as a NixOS module for user packages and dotfiles.
- Bring back the monitor seat (`cage`, `foot`, kanata).
- Add project flakes where removed global development tools are still needed.
- Package the personal `mark` and `hz` binaries with Nix.
