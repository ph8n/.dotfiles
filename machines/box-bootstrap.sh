#!/usr/bin/env bash
# Idempotent Ubuntu host state that Home Manager cannot own:
# groups, linger, uinput, hostname, agent performance limits, extra gettys,
# leftover services, and a GC-safe tailscaled unit.
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  exec sudo "$0" "$@"
fi

target="${SUDO_USER:-phongndo}"
uid="$(id -u "$target")"
repo="$(cd "$(dirname "$0")/.." && pwd)"

sysctl_source="$repo/machines/box-sysctl.conf"
sysctl_target=/etc/sysctl.d/90-box-performance.conf
if ! cmp -s "$sysctl_source" "$sysctl_target"; then
  install -m 644 "$sysctl_source" "$sysctl_target"
  sysctl -p "$sysctl_target"
fi

nix_source="$repo/machines/nix.custom.conf"
nix_target=/etc/nix/nix.custom.conf
if ! cmp -s "$nix_source" "$nix_target"; then
  install -m 644 "$nix_source" "$nix_target"
  systemctl restart nix-daemon.service
fi

authorized_keys="/home/$target/.ssh/authorized_keys"
install -d -m 700 -o "$target" -g "$target" "/home/$target/.ssh"
if [ ! -s "$authorized_keys" ]; then
  echo "refusing key-only SSH: $authorized_keys is empty or missing" >&2
  exit 1
fi
chown "$target:$target" "$authorized_keys"
chmod 600 "$authorized_keys"

sshd_source="$repo/machines/sshd-hardening.conf"
sshd_target=/etc/ssh/sshd_config.d/10-box-hardening.conf
if ! cmp -s "$sshd_source" "$sshd_target"; then
  sshd_backup=$(mktemp)
  sshd_had_target=0
  if [ -e "$sshd_target" ]; then
    cp -a "$sshd_target" "$sshd_backup"
    sshd_had_target=1
  fi
  install -m 644 "$sshd_source" "$sshd_target"
  if ! /usr/sbin/sshd -t; then
    if [ "$sshd_had_target" -eq 1 ]; then
      cp -a "$sshd_backup" "$sshd_target"
    else
      rm -f "$sshd_target"
    fi
    rm -f "$sshd_backup"
    echo "invalid sshd configuration; restored previous state" >&2
    exit 1
  fi
  rm -f "$sshd_backup"
  systemctl reload ssh.service
fi

# Expose OpenSSH only to the tailnet and the two local fallback networks.
# The fixed UDP port preserves direct Tailscale connections through UFW.
ufw default deny incoming
ufw default allow outgoing
ufw allow in on tailscale0 to any port 22 proto tcp
ufw allow from 192.168.4.0/22 to any port 22 proto tcp
ufw allow from 192.168.8.0/24 to any port 22 proto tcp
ufw allow 41641/udp
ufw --force enable

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

# The AX210's direct 5 GHz path is substantially faster than Ethernet through
# the wireless bridge. Let NetworkManager roam among APs, prefer Wi-Fi, and
# retain systemd-networkd's metric-100 Ethernet route as failover.
wifi_connection=$(nmcli -g GENERAL.CONNECTION device show wlp1s0 2>/dev/null || true)
if [ -n "$wifi_connection" ] && [ "$wifi_connection" != "--" ]; then
  nmcli connection modify "$wifi_connection" \
    connection.autoconnect yes \
    802-11-wireless.band "" \
    802-11-wireless.bssid "" \
    ipv4.route-metric 50 \
    ipv6.route-metric 50
fi

# Neither network manager needs to block boot. Services tolerate the network
# coming up asynchronously, and Tailscale reconnects automatically.
systemctl disable --now \
  NetworkManager-wait-online.service \
  systemd-networkd-wait-online.service 2>/dev/null || true

# This is bare metal with direct SATA disks: prevent Ubuntu's cloud/SAN
# defaults from spawning installers or a multipath daemon.
systemctl disable --now \
  lxd-installer.socket \
  multipathd.service \
  multipathd.socket 2>/dev/null || true
systemctl mask \
  NetworkManager-wait-online.service \
  systemd-networkd-wait-online.service \
  lxd-installer.socket \
  multipathd.service \
  multipathd.socket >/dev/null 2>&1 || true

# A hand-written Nix BlueZ unit was left behind and cannot claim the system
# D-Bus name. This host intentionally uses no Bluetooth devices.
systemctl disable --now bluetooth.service 2>/dev/null || true
rm -f \
  /etc/systemd/system/bluetooth.service \
  /etc/systemd/system/dbus-org.bluez.service \
  /etc/systemd/system/multi-user.target.wants/bluetooth.service
systemctl daemon-reload
systemctl reset-failed

if ! command -v dockerd >/dev/null && ip link show docker0 >/dev/null 2>&1; then
  ip link delete docker0
fi

if command -v snap >/dev/null; then
  snap remove core24 2>/dev/null || true
fi
apt-get purge -y snapd open-vm-tools lxd-agent-loader 2>/dev/null || true
apt-get install -y smartmontools lm-sensors iw

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

echo "done. host is box; agent limits, kanata, and tailscaled survive reboot"
