{
  description = "dp's personal Home Manager configuration";

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
      homeConfigurations.dp = mkHome {
        system = "aarch64-darwin";
        machine = "dp";
        module = ./machines/dp.nix;
      };

      homeConfigurations.box = mkHome {
        system = "x86_64-linux";
        machine = "box";
        module = ./machines/box.nix;
      };

      formatter.aarch64-darwin = fmt "aarch64-darwin";
      formatter.x86_64-linux = fmt "x86_64-linux";
    };
}
