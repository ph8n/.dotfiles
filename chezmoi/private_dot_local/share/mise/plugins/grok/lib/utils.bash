# Shared helpers for the grok asdf/mise plugin.
#
# xAI publishes Grok Build as a single binary on GCS, not a GitHub release.
# The mise registry maps `grok` to the http backend, which caches that file in
# http-tarballs and symlinks the install. This plugin copies the binary into
# $ASDF_INSTALL_PATH/bin so the install is a real directory.

GROK_ARTIFACT_BASE="${GROK_ARTIFACT_BASE:-https://storage.googleapis.com/grok-build-public-artifacts/cli}"
GROK_STABLE_URL="${GROK_STABLE_URL:-https://x.ai/cli/stable}"

grok_fail() {
  echo "grok asdf plugin: $1" >&2
  exit 1
}

# Platform keys used in the artifact name: macos|linux and x86_64|aarch64.
grok_os() {
  case "$(uname -s)" in
  Darwin) echo macos ;;
  Linux) echo linux ;;
  *) grok_fail "unsupported OS: $(uname -s) (mac and linux only)" ;;
  esac
}

grok_arch() {
  case "$(uname -m)" in
  x86_64 | amd64) echo x86_64 ;;
  arm64 | aarch64) echo aarch64 ;;
  *) grok_fail "unsupported architecture: $(uname -m)" ;;
  esac
}

grok_curl() {
  command -v curl >/dev/null 2>&1 || grok_fail "curl is required."
  # --retry-all-errors covers SSL connect failures (curl 35) on flaky links.
  curl -fsSL --retry 5 --retry-all-errors --retry-delay 2 --connect-timeout 15 "$@"
}

grok_latest_version() {
  local version
  version="$(grok_curl "$GROK_STABLE_URL" | tr -d '[:space:]')"
  [ -n "$version" ] || grok_fail "could not read a version from $GROK_STABLE_URL"
  printf '%s\n' "$version"
}

grok_binary_url() {
  local version="$1"
  printf '%s/grok-%s-%s-%s\n' "$GROK_ARTIFACT_BASE" "$version" "$(grok_os)" "$(grok_arch)"
}

# Download the published binary into $1 (directory) as grok.
grok_fetch() {
  local dest="$1" version="$2" base tmp
  base="$(grok_binary_url "$version")"
  mkdir -p "$dest"
  tmp="$(mktemp "$dest/grok.XXXXXX")"
  if grok_curl "${base}.gz" | gzip -dc >"$tmp" && [ -s "$tmp" ]; then
    mv "$tmp" "$dest/grok"
  else
    rm -f "$tmp"
    grok_curl "$base" -o "$dest/grok"
  fi
  [ -s "$dest/grok" ] || grok_fail "download of $base did not produce a grok binary"
  chmod 755 "$dest/grok"
}
