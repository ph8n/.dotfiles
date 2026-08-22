#!/usr/bin/env bash
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  exec sudo "$0" "$@"
fi

target="${SUDO_USER:-phongndo}"
repo="$(cd "$(dirname "$0")/.." && pwd)"

install -m 644 "$repo/kanata/99-uinput.rules" /etc/udev/rules.d/99-uinput.rules
udevadm control --reload-rules
udevadm trigger /dev/uinput || true
usermod -aG video,render,input "$target"
loginctl enable-linger "$target"

apt-get remove -y cage kitty kitty-doc kitty-terminfo kitty-shell-integration || true
apt-get autoremove -y
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

echo "done. next boot starts kanata on its own"
