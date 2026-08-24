{
  config,
  lib,
  machine,
  pkgs,
  ...
}:

{
  home.shellAliases = {
    ls = "${lib.getExe pkgs.eza} --group-directories-first";

    # Git operations in this repository.
    dot = "git -C \"$HOME/.nix-config\"";

    # `machine` names the flake attribute this host activates.
    hm = "home-manager switch --flake \"$HOME/.nix-config#${machine}\"";
  };

  # Keep user-installed Cargo binaries available without mutating managed
  # shell startup files.
  home.sessionPath = [ "$HOME/.cargo/bin" ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    history.path = "$HOME/.zsh_history";
    initContent = lib.mkMerge [
      (lib.mkBefore ''
        # Run Atuin's PTY proxy before the regular shell integration so recent
        # command output is available to Atuin AI through the daemon.
        eval "$(${lib.getExe config.programs.atuin.package} pty-proxy init zsh)"
      '')
      (builtins.readFile ./zshrc)
    ];
  };

  # Keep Bash aligned with Zsh. The flake still owns PATH inside `nix develop`;
  # Home Manager contributes the same aliases, integrations, and Starship hook.
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
    initExtra = builtins.readFile ./bashrc;
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

      # Give Atuin AI useful terminal context and access to its unique history
      # features, but leave filesystem mutation and command execution to the
      # dedicated coding agents.
      ai = {
        enabled = true;
        yolo = false;

        opening = {
          send_cwd = true;
          send_last_command = true;
        };

        capabilities = {
          enable_history_search = true;
          enable_history_output = true;
          enable_file_tools = false;
          enable_command_execution = false;
        };
      };

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

      # `pass show` can print credentials and command substitutions can embed
      # secret-store paths. Keep all password-store invocations out of Atuin.
      history_filter = [ "\\bpass\\b" ];
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
