{
  self,
  nixpkgs,
  home-manager,
  nix-darwin,
}:

{
  name,
  system,
  user,
  modules ? [ ],
}:

let
  isDarwin = nixpkgs.lib.hasSuffix "-darwin" system;
  platform = if isDarwin then "darwin" else "nixos";
  systemBuilder = if isDarwin then nix-darwin.lib.darwinSystem else nixpkgs.lib.nixosSystem;
  machineConfig = ../machines + "/${platform}";
  userSystemConfig = ../users + "/${user}/${platform}.nix";
  userHomeConfig = ../users + "/${user}/home-manager.nix";
  homeManagerModule =
    if isDarwin then
      home-manager.darwinModules.home-manager
    else
      home-manager.nixosModules.home-manager;
  rebuildCommand = if isDarwin then "darwin-rebuild" else "nixos-rebuild";
in
systemBuilder {
  inherit system;

  specialArgs = {
    inherit
      name
      system
      user
      isDarwin
      ;
  };

  modules = [
    machineConfig
    userSystemConfig

    {
      nixpkgs.config.allowUnfree = true;
      system.configurationRevision = self.rev or self.dirtyRev or null;
    }

    homeManagerModule
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = {
          configurationName = name;
          inherit rebuildCommand;
        };
        users.${user} = import userHomeConfig;
      };
    }
  ]
  ++ modules;
}
