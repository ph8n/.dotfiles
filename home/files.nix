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
      "mark/config.toml" = immutable ../mark/config.toml;
      "mise/config.toml" = immutable ../mise/config.toml;
      "nvim/init.lua" = immutable ../nvim/init.lua;
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
    })
  ];

  # Local mise plugins that are not published as git repos. mise discovers
  # these under XDG data; the installed CLI versions remain mise-owned.
  xdg.dataFile = {
    "mise/plugins/cursor-agent" = immutable ../mise/plugins/cursor-agent;
  };

  home.file.".zshenv" = immutable ./zshenv;
}
