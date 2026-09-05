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
  # Nix owns the machine, packages, shell, and non-agent dotfiles.
  # Chezmoi owns agent-tool configs under ~/.config (see ../chezmoi).
  # PI_CODING_AGENT_DIR is set here and in mise so Linux and macOS both
  # load Pi from XDG instead of ~/.pi.
  home = {
    sessionVariables = {
      PI_CODING_AGENT_DIR = piConfigDir;
      MISE_IGNORED_CONFIG_PATHS = "${chezmoiSource}/dot_config/mise/config.toml.tmpl";
    };

    # writeBoundary has already placed chezmoi.toml. Apply the source tree
    # noninteractively so `hm` on NixOS and darwin-rebuild on macOS both
    # install agent configs, including the Pi package list.
    activation.chezmoiApply = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      old_pi="${config.home.homeDirectory}/.pi/agent"
      new_pi="${piConfigDir}"
      if [ -d "$old_pi" ] && [ ! -e "$new_pi/.migrated-from-dot-pi" ]; then
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p "$new_pi"
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/cp -a --no-clobber "$old_pi"/. "$new_pi"/ || true
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/touch "$new_pi/.migrated-from-dot-pi"
      fi
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
