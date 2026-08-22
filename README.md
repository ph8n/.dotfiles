# Personal Nix configuration

Multi-host Home Manager configuration inspired by Mitchell Hashimoto's Nix setup, with less abstraction.

## Hosts

- `dp` — macOS workstation (`aarch64-darwin`, user `dp`)
- `box` — Ubuntu dev server (`x86_64-linux`, user `phongndo`)

## Ownership

- Determinate Nix owns the Nix installation, daemon, settings, and store.
- Standalone Home Manager owns personal packages and retained dotfiles/services.
- Mise owns fast-moving personal CLIs and convenient global runtimes; its
  config is shared verbatim between hosts.
- Project flakes own exact development dependencies.
- Homebrew owns GUI applications only on `dp`; `box` takes GUI apps from Nix.

## Layout

```
flake.nix                  # homeConfigurations.dp and homeConfigurations.box
machines/                  # per-host entry points
machines/box-bootstrap.sh  # once: groups, linger, uinput, drop extra gettys
machines/box-data.nix      # ~/code and ~/scratch onto /mnt/data
machines/immich.nix        # nixpkgs Immich, PostgreSQL, Redis as user services
home/                  # shared user config
home/darwin.nix        # yabai/skhd/karabiner-era packages, launchd agents, pass
home/linux.nix         # fonts, cage, foot, kanata, tty1 seat
kanata/                # keyboard remaps for box
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

## Monitor seat on box

`hm` installs Nix `cage`, `foot`, Mesa, fonts, and kanata.
The monitor is one login: `seat` (fullscreen `cage -s -d -- foot`).
Kanata is the Mac Karabiner layout (Caps tap Esc / hold Ctrl, Space symbols).
Muxer owns tabs/panes. SSH is the escape hatch if the seat fails.

Ubuntu cannot provide DRM or uinput from Home Manager. Once per machine:

```sh
~/nix-config/machines/box-bootstrap.sh
```

That sets `video`/`render`/`input`, lingering, and the uinput udev rule,
removes apt `cage`/`kitty`, and upgrades the host. Kanata starts at boot.

## Storage and Immich on box

Filesystems are Ubuntu host state. Processes come from nixpkgs and Home Manager.

- SSD root is 180G. The 4TB disk is `data-vg`: `/mnt/data` (~2.6T) and
  `/srv/photos` (1T). `~/code` and `~/scratch` are links.
- Immich, PostgreSQL (pgvector + vectorchord), and Redis run as lingering
  user services. Media is `/srv/photos`.
- Reach it on the tailnet only: `https://dp.tail5606b4.ts.net`

## Remaining work

- Add project flakes where removed global development tools are still needed.
- Package the personal `mark` and `hz` binaries with Nix.
