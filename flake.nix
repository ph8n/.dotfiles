{
  description = "dp's personal Nix configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      nix-darwin,
      ...
    }:
    let
      system = "aarch64-darwin";
      mkSystem = import ./lib/mk-system.nix {
        inherit
          self
          nixpkgs
          nixpkgs-unstable
          home-manager
          nix-darwin
          ;
      };

      darwin = mkSystem {
        name = "darwin";
        inherit system;
        user = "dp";
      };
    in
    {
      darwinConfigurations.darwin = darwin;

      # Every declared target exposes its system closure as a check.
      checks.${system}.system = darwin.system;

      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
