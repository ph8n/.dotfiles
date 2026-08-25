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
      darwinSystem = "aarch64-darwin";
      linuxSystem = "x86_64-linux";
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
        system = darwinSystem;
        user = "dp";
      };

      box = mkSystem {
        name = "box";
        system = linuxSystem;
        user = "z";
      };

      qualityChecks =
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          format = pkgs.runCommand "nix-format-check" { nativeBuildInputs = [ pkgs.nixfmt-tree ]; } ''
            cp -R ${self} source
            chmod -R u+w source
            cd source
            treefmt --ci --tree-root . --walk filesystem
            touch $out
          '';

          lint =
            pkgs.runCommand "nix-lint-check"
              {
                nativeBuildInputs = with pkgs; [
                  deadnix
                  statix
                ];
              }
              ''
                statix check ${self}
                deadnix --fail ${self}
                touch $out
              '';
        };
    in
    {
      darwinConfigurations.darwin = darwin;
      nixosConfigurations.box = box;

      # Every target exposes its closure plus formatting and static analysis.
      checks.${darwinSystem} = {
        inherit (darwin) system;
      }
      // qualityChecks darwinSystem;
      checks.${linuxSystem} = {
        system = box.config.system.build.toplevel;
      }
      // qualityChecks linuxSystem;

      formatter.${darwinSystem} = nixpkgs.legacyPackages.${darwinSystem}.nixfmt-tree;
      formatter.${linuxSystem} = nixpkgs.legacyPackages.${linuxSystem}.nixfmt-tree;
    };
}
