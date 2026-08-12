{ ... }:

{
  imports = [
    ./files.nix
    ./packages.nix
    ./services.nix
    ./shell.nix
  ];

  home.username = "dp";
  home.homeDirectory = "/Users/dp";
  home.stateVersion = "26.05";

  programs.home-manager.enable = true;
}
