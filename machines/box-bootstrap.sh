#!/usr/bin/env bash
# Idempotent Ubuntu host state that Home Manager cannot own:
# groups, linger, uinput, hostname, extra gettys, leftover services,
# and a GC-safe tailscaled unit.
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  exec sudo "$0" "$@"
fi

target="${SUDO_USER:-phongndo}"
uid="$(id -u "$target")"
repo="$(cd "$(dirname "$0")/.." && pwd)"

install -m 644 "$repo/kanata/99-uinput.rules" /etc/udev/rules.d/99-uinput.rules
udevadm control --reload-rules
udevadm trigger /dev/uinput || true
usermod -aG video,render,input "$target"
loginctl enable-linger "$target"

if [ "$(hostnamectl --static)" != box ]; then
  hostnamectl set-hostname box
fi
if grep -q '^127.0.1.1' /etc/hosts; then
  sed -i 's/^127.0.1.1.*/127.0.1.1 box/' /etc/hosts
else
  printf '127.0.1.1 box\n' >>/etc/hosts
fi

for n in 2 3 4 5 6; do
  systemctl stop "autovt@tty${n}.service" "getty@tty${n}.service" 2>/dev/null || true
  systemctl mask "getty@tty${n}.service" || true
done

systemctl disable --now ModemManager.service 2>/dev/null || true

if ! command -v dockerd >/dev/null && ip link show docker0 >/dev/null 2>&1; then
  ip link delete docker0
fi

if command -v snap >/dev/null; then
  snap remove core24 2>/dev/null || true
fi
apt-get purge -y snapd 2>/dev/null || true

unit=/etc/systemd/system/tailscaled.service
if ! cmp -s "$repo/machines/tailscaled.service" "$unit"; then
  install -m 644 "$repo/machines/tailscaled.service" "$unit"
  systemctl daemon-reload
  systemctl restart tailscaled.service
fi
systemctl enable tailscaled.service

# Root's PATH does not include the Home Manager profile. Use the same
# stable symlink the tailscaled unit uses.
tailscale="/home/${target}/.nix-profile/bin/tailscale"
"$tailscale" set --operator="$target"

runtime="/run/user/${uid}"
if [ -d "$runtime" ]; then
  sudo -u "$target" env XDG_RUNTIME_DIR="$runtime" \
    systemctl --user restart immich-tailscale.service 2>/dev/null || true
fi

apt-get remove -y cage kitty kitty-doc kitty-terminfo kitty-shell-integration || true
apt-get autoremove -y

echo "done. host is box; kanata and tailscaled survive reboot"
