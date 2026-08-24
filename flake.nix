{
  description = "dp's personal Nix configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      system = "aarch64-darwin";
      mkHome = import ./lib/mk-home.nix {
        inherit nixpkgs home-manager;
      };

      darwinHome = mkHome {
        name = "darwin";
        inherit system;
        modules = [
          ./home
          ./machines/darwin.nix
        ];
      };
    in
    {
      homeConfigurations.darwin = darwinHome;

      # Every declared target should expose its activation or system closure as
      # a check so `nix flake check --all-systems` evaluates them uniformly.
      checks.${system}.home = darwinHome.activationPackage;

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
