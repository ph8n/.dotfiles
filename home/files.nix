{
  config,
  lib,
  pkgs,
  ...
}:

let
  configRoot = "${config.home.homeDirectory}/nix-config";
  alfredWorkflow = "Library/Application Support/Alfred/Alfred.alfredpreferences/workflows/user.workflow.63D398BB-A391-40E9-B356-24123A2B339E";

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
  xdg = {
    enable = true;

    configFile = lib.mkMerge [
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
    dataFile = {
      "mise/plugins/cursor-agent" = immutable ../mise/plugins/cursor-agent;
    };
  };

  home.file = lib.mkMerge [
    {
      ".bashrc".force = true;
      ".pi/agent/settings.json" = writable "pi/settings.json";
      ".zshenv" = immutable ./zshenv;
    }

    (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
      # Keep the shared Pi package path while the editable checkout remains
      # under ~/code on the Mac.
      "pi-extensions" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/code/pi-extensions";
        force = true;
      };

      # Alfred owns the workflow directory. Link its editable source files
      # individually so activation never has to replace that directory.
      "${alfredWorkflow}/focus-window.sh" = writable "alfred/appfocus/focus-window.sh";
      "${alfredWorkflow}/info.plist" = writable "alfred/appfocus/info.plist";
      "${alfredWorkflow}/list-windows.sh" = writable "alfred/appfocus/list-windows.sh";
    })
  ];
}
