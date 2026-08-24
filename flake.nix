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
      mkHome =
        {
          system,
          module,
          machine,
        }:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          extraSpecialArgs = { inherit machine; };
          modules = [
            ./home
            module
          ];
        };

      fmt =
        system:
        (import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        }).nixfmt-tree;
    in
    {
      nixosConfigurations.box = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./machines/box ];
      };

      homeConfigurations.dp = mkHome {
        system = "aarch64-darwin";
        machine = "dp";
        module = ./machines/dp.nix;
      };

      formatter.aarch64-darwin = fmt "aarch64-darwin";
      formatter.x86_64-linux = fmt "x86_64-linux";
    };
}
