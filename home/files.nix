{ config, ... }:

let
  configRoot = "${config.home.homeDirectory}/nix-config";

  immutable = source: {
    inherit source;
    force = true;
  };

  # Use for settings that an application may update itself. The live target is
  # writable and points directly back into this repository.
  writable = relative: {
    source = config.lib.file.mkOutOfStoreSymlink "${configRoot}/${relative}";
    force = true;
  };
in
{
  xdg.enable = true;

  xdg.configFile = {
    # Hand-authored, immutable configuration. Edit the source and run `hm`.
    "atuin/TERMINAL.md" = immutable ../atuin/TERMINAL.md;
    "cmux/settings.json" = immutable ../cmux/settings.json;
    "ghostty/config" = immutable ../ghostty/config;
    "ghostty/themes/mono" = immutable ../ghostty/themes/mono;
    "herdr/config.toml" = immutable ../herdr/config.toml;
    "hunk/build-pho.sh" = immutable ../hunk/build-pho.sh;
    "hunk/config.toml" = immutable ../hunk/config.toml;
    "hunk/pho-theme.ts" = immutable ../hunk/pho-theme.ts;
    "launchd/skhd-runner" = immutable ../launchd/skhd-runner;
    "launchd/yabai-runner" = immutable ../launchd/yabai-runner;
    "mark/config.toml" = immutable ../mark/config.toml;
    "mise/config.toml" = immutable ../mise/config.toml;
    "nvim/init.lua" = immutable ../nvim/init.lua;
    "opencode/opencode.json" = immutable ../opencode/opencode.json;
    "opencode/themes/mellow.json" = immutable ../opencode/themes/mellow.json;
    "skhd/focus-previous-app" = immutable ../skhd/focus-previous-app;
    "skhd/skhdrc" = immutable ../skhd/skhdrc;
    "starship.toml" = immutable ../starship/starship.toml;
    "yabai/apps.tsv" = immutable ../yabai/apps.tsv;
    "yabai/focus-bundle" = immutable ../yabai/focus-bundle;
    "yabai/focus-or-open" = immutable ../yabai/focus-or-open;
    "yabai/focus-space" = immutable ../yabai/focus-space;
    "yabai/move-window-to-space" = immutable ../yabai/move-window-to-space;
    "yabai/safe-yabai" = immutable ../yabai/safe-yabai;
    "yabai/yabairc" = immutable ../yabai/yabairc;

    # Writable settings. Application changes land directly in ~/nix-config and
    # become visible in `dot status`; generated companion state remains ignored.
    "btop/btop.conf" = writable "btop/btop.conf";
    "gh/config.yml" = writable "gh/config.yml";
    "karabiner/karabiner.json" = writable "karabiner/karabiner.json";
    "nvim/lazy-lock.json" = writable "nvim/lazy-lock.json";
    "zed/keymap.json" = writable "zed/keymap.json";
    "zed/settings.json" = writable "zed/settings.json";
    "zed/themes/pho.json" = writable "zed/themes/pho.json";
  };

  home.file.".zshenv" = immutable ./zshenv;
}
