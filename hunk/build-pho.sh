#!/usr/bin/env bash
# Build Hunk from source with the custom "pho" theme.
# Based on Hunk's GitHub docs:
#   - source setup: bun install && bun run build:npm
#   - config theme key: ~/.config/hunk/config.toml -> theme = "pho"
# Usage: bash ~/.config/hunk/build-pho.sh
# Optional env:
#   HUNK_REPO=$HOME/dev/hunk     checkout location
#   HUNK_LINK=0                  skip npm link
#   HUNK_BUILD=0                 only patch the source tree

set -euo pipefail

HUNK_REPO="${HUNK_REPO:-$HOME/dev/hunk}"
HUNK_SRC_URL="https://github.com/modem-dev/hunk.git"
PHO_THEME_FILE="${PHO_THEME_FILE:-$HOME/.config/hunk/pho-theme.ts}"
PHO_THEME_FILE="${PHO_THEME_FILE/#\~/$HOME}"
HUNK_LINK="${HUNK_LINK:-1}"
HUNK_BUILD="${HUNK_BUILD:-1}"
export PHO_THEME_FILE

if [[ ! -f "$PHO_THEME_FILE" ]]; then
  echo "Missing pho theme fragment: $PHO_THEME_FILE" >&2
  exit 1
fi

echo "=== Cloning/updating hunk repo ==="
if [[ -d "$HUNK_REPO/.git" ]]; then
  cd "$HUNK_REPO"
  git fetch origin main
  # The pho source edits are generated below, so start from a clean upstream tree.
  git checkout -f main
  git reset --hard origin/main
else
  mkdir -p "$(dirname "$HUNK_REPO")"
  git clone "$HUNK_SRC_URL" "$HUNK_REPO"
  cd "$HUNK_REPO"
fi

echo "=== Applying pho theme ==="
python3 - <<'PY'
from pathlib import Path
import os
import re
import sys

root = Path.cwd()
pho_path = Path(os.environ["PHO_THEME_FILE"]).expanduser()
ui_path = root / "src" / "ui" / "themes.ts"
opentui_path = root / "src" / "opentui" / "themes.ts"
pierre_path = root / "src" / "ui" / "diff" / "pierre.ts"
opentui_test_path = root / "src" / "opentui" / "HunkDiffView.test.tsx"

missing = [str(path) for path in (ui_path, opentui_path, pierre_path) if not path.exists()]
if missing:
    sys.exit("Missing expected Hunk theme source file(s): " + ", ".join(missing))

# 1. Register the public theme name used by HunkDiffView/theme validation.
names = opentui_path.read_text()
match = re.search(r"HUNK_DIFF_THEME_NAMES\s*=\s*\[([^\]]*)\]\s*as const", names)
if not match:
    sys.exit(f"Could not find HUNK_DIFF_THEME_NAMES in {opentui_path}")

items = re.findall(r'"([^"]+)"', match.group(1))
if "pho" not in items:
    items.append("pho")
new_array = "HUNK_DIFF_THEME_NAMES = [" + ", ".join(f'\"{item}\"' for item in items) + "] as const"
names = names[: match.start()] + new_array + names[match.end() :]
opentui_path.write_text(names)
print(f"  ✓ registered pho in {opentui_path}")

if opentui_test_path.exists():
    opentui_test = opentui_test_path.read_text()
    opentui_test = opentui_test.replace(
        'expect(HUNK_DIFF_THEME_NAMES).toEqual(["graphite", "midnight", "paper", "ember"]);',
        'expect(HUNK_DIFF_THEME_NAMES).toEqual(["graphite", "midnight", "paper", "ember", "pho"]);',
    )
    opentui_test_path.write_text(opentui_test)
    print(f"  ✓ updated theme name test in {opentui_test_path}")

# 2. Insert/update the AppTheme entry.  The fragment is a THEMES-array item.
fragment = pho_path.read_text().strip()
fragment = re.sub(
    r"^// BEGIN pho custom theme\n|\n// END pho custom theme$",
    "",
    fragment,
).strip()
block = "\n  // BEGIN pho custom theme\n" + "\n".join(
    ("  " + line if line else "") for line in fragment.splitlines()
) + "\n  // END pho custom theme\n"

ui = ui_path.read_text()
marked = re.compile(r"\n\s*// BEGIN pho custom theme\n[\s\S]*?\n\s*// END pho custom theme\n?")
if marked.search(ui):
    ui = marked.sub(block, ui, count=1)
else:
    # Remove an older unmarked pho insertion, if present, before inserting the current fragment.
    unmarked = re.compile(
        r"\n\s*(?://[^\n]*\n\s*)*withLazySyntaxStyle\(\s*\{\s*id:\s*\"pho\"[\s\S]*?\n\s*\),\n?",
    )
    ui = unmarked.sub("\n", ui, count=1)
    insert_at = ui.rfind("\n];")
    if insert_at == -1:
        sys.exit(f"Could not find end of THEMES array in {ui_path}")
    ui = ui[:insert_at] + block + ui[insert_at:]

ui_path.write_text(ui)
print(f"  ✓ inserted/updated pho theme in {ui_path}")

# 3. Make Pierre/Shiki token colors flow through the active Hunk theme syntax palette.
#    Without this, highlighted code keeps Pierre's own orange/green/purple hues instead of
#    matching the user's Neovim-derived syntax colors.
remap_block = '''const PIERRE_TOKEN_COLOR_REMAPS = {
  dark: {
    "#ff678d": "keyword",
    "#ff6762": "keyword",
    "#5ecc71": "string",
    "#64d1db": "string",
    "#84848a": "comment",
    "#79797f": "punctuation",
    "#ffca00": "number",
    "#ffd452": "number",
    "#68cdf2": "number",
    "#08c0ef": "number",
    "#9d6afb": "function",
    "#d568ea": "type",
    "#61d5c0": "property",
    "#ffa359": "default",
    "#adadb1": "default",
    "#fbfbfb": "default",
    "#f44747": "keyword",
  },
  light: {
    "#fc2b73": "keyword",
    "#d52c36": "keyword",
    "#199f43": "string",
    "#17a5af": "string",
    "#84848a": "comment",
    "#79797f": "punctuation",
    "#d5a910": "number",
    "#1ca1c7": "number",
    "#08c0ef": "number",
    "#7b43f8": "function",
    "#c635e4": "type",
    "#16a994": "property",
    "#d47628": "default",
    "#070707": "default",
    "#f44747": "keyword",
  },
} as const;'''

pierre = pierre_path.read_text()
remap_pattern = re.compile(
    r"const\s+(?:RESERVED_PIERRE_TOKEN_COLORS|PIERRE_TOKEN_COLOR_REMAPS)\s*=\s*\{\n"
    r"\s*dark:\s*\{[\s\S]*?\n\s*\},\n"
    r"\s*light:\s*\{[\s\S]*?\n\s*\},\n"
    r"\s*\}\s*as const;"
)
pierre, replaced = remap_pattern.subn(remap_block, pierre, count=1)
if replaced != 1:
    sys.exit(f"Could not find Pierre token color remap block in {pierre_path}")

pierre = pierre.replace("RESERVED_PIERRE_TOKEN_COLORS", "PIERRE_TOKEN_COLOR_REMAPS")
pierre = pierre.replace("const reserved =", "const remapped =")
pierre = pierre.replace(
    "const resolvedColor = reserved ? theme.syntaxColors[reserved] : color;",
    "const resolvedColor = remapped ? theme.syntaxColors[remapped] : color;",
)
pierre_path.write_text(pierre)
print(f"  ✓ aligned Pierre syntax token colors in {pierre_path}")
PY

if [[ "$HUNK_BUILD" == "0" ]]; then
  echo "=== Skipping install/build because HUNK_BUILD=0 ==="
  exit 0
fi

echo "=== Installing dependencies ==="
# The postinstall hook is only for contributor git hooks; skip scripts so the
# theme build is not blocked by simple-git-hooks/package-manager edge cases.
bun install --ignore-scripts --linker hoisted
if [[ -f node_modules/bun/install.js && ! -x node_modules/bun/bin/bun.exe ]]; then
  (cd node_modules/bun && node install.js)
fi

echo "=== Building npm distribution ==="
bun run build:npm

if [[ "$HUNK_LINK" != "0" ]]; then
  echo "=== Linking custom hunk globally ==="
  npm link
else
  echo "=== Skipping npm link because HUNK_LINK=0 ==="
fi

cat <<EOF
=== Done! ===

Your config already selects the custom theme:
  $HOME/.config/hunk/config.toml -> theme = "pho"

Verify with:
  hunk diff --theme pho

If you skipped npm link, point the launcher at the custom build:
  export HUNK_BIN_PATH="$HUNK_REPO/dist/npm/main.js"
EOF
