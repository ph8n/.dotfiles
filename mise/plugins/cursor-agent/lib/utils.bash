# Shared helpers for the cursor-agent asdf/mise plugin.
#
# Cursor publishes the Agent CLI as a CDN tarball (not a single binary). The
# wrapper at cursor-agent execs a bundled node next to itself, so the full
# package must stay together. Only cursor-agent is exposed on PATH.
#
# Version discovery: the official installer at https://cursor.com/install
# bakes the current version into the download URL. There is no public
# version-history API.

CURSOR_CDN_BASE="${CURSOR_AGENT_CDN_BASE:-https://downloads.cursor.com}"

cursor_agent_fail() {
  echo "cursor-agent asdf plugin: $1" >&2
  exit 1
}

# Platform keys used in the CDN path: linux|darwin and x64|arm64.
cursor_agent_os() {
  case "$(uname -s)" in
  Darwin) echo darwin ;;
  Linux) echo linux ;;
  *) cursor_agent_fail "unsupported OS: $(uname -s) (mac and linux only)" ;;
  esac
}

cursor_agent_arch() {
  case "$(uname -m)" in
  x86_64 | amd64) echo x64 ;;
  arm64 | aarch64) echo arm64 ;;
  *) cursor_agent_fail "unsupported architecture: $(uname -m)" ;;
  esac
}

cursor_agent_curl() {
  command -v curl >/dev/null 2>&1 || cursor_agent_fail "curl is required."
  curl -fsSL "$@"
}

# Resolve the version currently published by the official installer.
cursor_agent_latest_version() {
  local version
  version="$(
    cursor_agent_curl https://cursor.com/install |
      sed -n 's|.*downloads\.cursor\.com/lab/\([^/]*\)/.*|\1|p' |
      head -n 1
  )"
  [ -n "$version" ] || cursor_agent_fail "could not parse a version from https://cursor.com/install"
  printf '%s\n' "$version"
}

cursor_agent_tarball_url() {
  local version="$1"
  printf '%s/lab/%s/%s/%s/agent-cli-package.tar.gz\n' \
    "$CURSOR_CDN_BASE" "$version" "$(cursor_agent_os)" "$(cursor_agent_arch)"
}

# Extract the published package into $1 (directory).
cursor_agent_fetch() {
  local dest="$1" version="$2" url
  url="$(cursor_agent_tarball_url "$version")"
  mkdir -p "$dest"
  cursor_agent_curl "$url" | tar --strip-components=1 -xzf - -C "$dest"
  [ -f "$dest/cursor-agent" ] || cursor_agent_fail "tarball from $url did not contain cursor-agent"
  chmod +x "$dest/cursor-agent"
}
