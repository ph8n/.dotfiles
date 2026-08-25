_:

{
  imports = [
    ./files.nix
    ./packages.nix
    ./shell.nix
  ];

  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
