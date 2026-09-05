{
  config,
  lib,
  pkgs,
  ...
}:

let
  configRoot = "${config.home.homeDirectory}/nix-config";
  chezmoiSource = "${configRoot}/chezmoi";
  piConfigDir = "${config.xdg.configHome}/pi";
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
  # One owner per path (Hashimoto-style).
  # Nix/HM: machine, packages, shell, user services, non-agent dots.
  # Chezmoi: agent-tool files. Do not also set these via home.file or
  # xdg.configFile:
  #   ~/.codex ~/.copilot ~/.cursor ~/.grok
  #   ~/.config/{herdr,mark,mise,opencode,pi,pi-extensions}
  #   ~/.local/share/mise/plugins
  #
  # Chezmoi reads the live tree at ~/nix-config/chezmoi, not a Nix
  # generation. Roll back Nix and agent files stay as last applied.
  #
  # PI_CODING_AGENT_DIR: HM injects it into login shells; mise [env]
  # injects it into GUI/tool processes that do not source HM session vars.
  # MISE_IGNORED_CONFIG_PATHS must live in the environment (not mise
  # config) so mise never parses the chezmoi template as TOML.
  home = {
    sessionVariables = {
      PI_CODING_AGENT_DIR = piConfigDir;
      MISE_IGNORED_CONFIG_PATHS = "${chezmoiSource}/dot_config/mise/config.toml.tmpl";
    };

    # HM's only chezmoi coupling: after writeBoundary has placed
    # chezmoi.toml, apply the agent tree. Agent migrations and skill
    # copies live in chezmoi run scripts, not here.
    activation.chezmoiApply = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD ${lib.getExe pkgs.chezmoi} apply \
        --source "${chezmoiSource}" \
        --destination "${config.home.homeDirectory}" \
        --force \
        --no-tty
    '';

    file = lib.mkMerge [
      {
        ".bashrc".force = true;
        ".zshenv" = immutable ./zshenv;
      }

      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
        # Alfred owns the workflow directory. Link its editable source files
        # individually so activation never has to replace that directory.
        "${alfredWorkflow}/focus-window.sh" = writable "alfred/appfocus/focus-window.sh";
        "${alfredWorkflow}/info.plist" = writable "alfred/appfocus/info.plist";
        "${alfredWorkflow}/list-windows.sh" = writable "alfred/appfocus/list-windows.sh";
      })
    ];
  };

  xdg = {
    enable = true;

    configFile = lib.mkMerge [
      {
        "atuin/TERMINAL.md" = immutable ../atuin/TERMINAL.md;
        # Bootstrap only. Chezmoi owns every other agent-adjacent file.
        "chezmoi/chezmoi.toml" = {
          text = ''
            sourceDir = "${chezmoiSource}"
          '';
          force = true;
        };
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
  };
}
