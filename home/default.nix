{ ... }:

{
  imports = [
    ./files.nix
    ./packages.nix
    ./shell.nix
  ];

  home.username = "dp";
  home.homeDirectory = "/Users/dp";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
