{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    history.path = "$HOME/.zsh_history";
    initContent = builtins.readFile ./zshrc;
  };

  # Keep development Bash predictable: the flake owns its environment while
  # Home Manager contributes only completion, history behavior, and Starship.
  programs.bash = {
    enable = true;
    enableCompletion = true;
    historyControl = [
      "ignoredups"
      "ignorespace"
    ];
    shellOptions = [
      "checkwinsize"
      "histappend"
    ];
    initExtra = ''
      # Nix runs a development shell's shellHook after Bash reads .bashrc, so
      # IN_NIX_SHELL is not available yet during normal initialization. Capture
      # the originating flake once, immediately before Starship draws the first
      # prompt, instead of wrapping `nix develop`.
      _nix_capture_flake_root() {
        [[ -n "''${IN_NIX_SHELL:-}" && -z "''${_NIX_FLAKE_ROOT_CAPTURED:-}" ]] || return 0

        local root="$PWD"
        while [[ "$root" != "/" && ! -f "$root/flake.nix" ]]; do
          root="''${root%/*}"
          [[ -n "$root" ]] || root="/"
        done

        if [[ -f "$root/flake.nix" ]]; then
          export NIX_FLAKE_ROOT="$root"
        else
          unset NIX_FLAKE_ROOT
        fi
        _NIX_FLAKE_ROOT_CAPTURED=1
      }
      starship_precmd_user_func=_nix_capture_flake_root
    '';
  };

  programs.atuin = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;

    # Keep Atuin's generated config fully declarative.
    forceOverwriteSettings = true;

    settings = {
      auto_sync = true;
      sync_frequency = "5m";
      search_mode = "daemon-fuzzy";

      # Ctrl-R searches globally; up-arrow starts in the current directory.
      filter_mode = "global";
      filter_mode_shell_up_key_binding = "directory";
      workspaces = true;

      style = "compact";
      inline_height = 20;
      inline_height_shell_up_key_binding = 10;
      show_preview = true;
      max_preview_height = 4;

      exit_mode = "return-query";
      enter_accept = false;
      keymap_mode = "auto";
      secrets_filter = true;
    };

    # Home Manager manages the daemon as a launchd agent on macOS.
    daemon = {
      enable = true;
      logLevel = "warn";
    };
  };

  # Zsh initializes Starship explicitly; Home Manager initializes it for Bash.
  programs.starship = {
    enable = true;
    enableZshIntegration = false;
    enableBashIntegration = true;
  };
}
