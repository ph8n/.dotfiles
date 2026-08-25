{ ... }:

{
  # Determinate manages the installed Nix daemon and store. nix-darwin owns
  # the surrounding macOS configuration without replacing that installation.
  nix.enable = false;

  system.stateVersion = 6;

  # Let nix-darwin provide the system shell hooks; Home Manager owns dp's Zsh
  # configuration itself.
  programs.zsh.enable = true;
}
