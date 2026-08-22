{ ... }:

{
  home.username = "phongndo";
  home.homeDirectory = "/home/phongndo";

  imports = [
    ../home/linux.nix
    ./box-data.nix
    ./immich.nix
  ];
}
