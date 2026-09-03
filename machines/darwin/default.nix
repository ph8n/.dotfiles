_:

{
  # Determinate manages the installed Nix daemon and store. nix-darwin owns
  # the surrounding macOS configuration without replacing that installation.
  nix.enable = false;

  system.stateVersion = 6;

  # Let nix-darwin provide the system shell and completion paths. Home Manager
  # owns the prompt and completion initialization, so do not run both twice.
  programs.zsh = {
    enable = true;
    enableBashCompletion = false;
    enableGlobalCompInit = false;
    promptInit = "";
  };
}
