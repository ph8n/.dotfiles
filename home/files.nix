{
  config,
  lib,
  pkgs,
  ...
}:

let
  configRoot = "${config.home.homeDirectory}/nix-config";

  immutable = source: {
    inherit source;
    force = true;
  };

  writable = relative: {
    source = config.lib.file.mkOutOfStoreSymlink "${configRoot}/${relative}";
    force = true;
  };
in
{
  xdg.enable = true;

  xdg.configFile = lib.mkMerge [
    {
      "atuin/TERMINAL.md" = immutable ../atuin/TERMINAL.md;
      "herdr/config.toml" = immutable ../herdr/config.toml;
      "hunk/build-pho.sh" = immutable ../hunk/build-pho.sh;
      "hunk/config.toml" = immutable ../hunk/config.toml;
      "hunk/pho-theme.ts" = immutable ../hunk/pho-theme.ts;
      "mark/config.toml" = immutable ../mark/config.toml;
      "mise/config.toml" = immutable ../mise/config.toml;
      "nvim/init.lua" = immutable ../nvim/init.lua;
      "opencode/opencode.json" = immutable ../opencode/opencode.json;
      "opencode/themes/mellow.json" = immutable ../opencode/themes/mellow.json;
      "starship.toml" = immutable ../starship/starship.toml;

      "btop/btop.conf" = writable "btop/btop.conf";
      "gh/config.yml" = writable "gh/config.yml";
      "nvim/lazy-lock.json" = writable "nvim/lazy-lock.json";
    }

    (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      "ghostty/config" = immutable ../ghostty/config;
      "ghostty/themes/mono" = immutable ../ghostty/themes/mono;
      "karabiner/karabiner.json" = writable "karabiner/karabiner.json";
      "launchd/skhd-runner" = immutable ../launchd/skhd-runner;
      "launchd/yabai-runner" = immutable ../launchd/yabai-runner;
      "skhd/focus-previous-app" = immutable ../skhd/focus-previous-app;
      "skhd/skhdrc" = immutable ../skhd/skhdrc;
      "yabai/apps.tsv" = immutable ../yabai/apps.tsv;
      "yabai/focus-bundle" = immutable ../yabai/focus-bundle;
      "yabai/focus-or-open" = immutable ../yabai/focus-or-open;
      "yabai/focus-space" = immutable ../yabai/focus-space;
      "yabai/move-window-to-space" = immutable ../yabai/move-window-to-space;
      "yabai/safe-yabai" = immutable ../yabai/safe-yabai;
      "yabai/yabairc" = immutable ../yabai/yabairc;
      "zed/keymap.json" = writable "zed/keymap.json";
      "zed/settings.json" = writable "zed/settings.json";
      "zed/themes/pho.json" = writable "zed/themes/pho.json";
    })
  ];

  # Local mise plugins that are not published as git repos. mise discovers
  # these under XDG data; the installed CLI versions remain mise-owned.
  xdg.dataFile = {
    "mise/plugins/cursor-agent" = immutable ../mise/plugins/cursor-agent;
  };

  home.file.".zshenv" = immutable ./zshenv;
}
