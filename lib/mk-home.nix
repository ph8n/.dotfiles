{ nixpkgs, home-manager }:

{
  name,
  system,
  modules,
  extraSpecialArgs ? { },
}:

home-manager.lib.homeManagerConfiguration {
  pkgs = import nixpkgs {
    inherit system;
    config.allowUnfree = true;
  };

  inherit modules;

  extraSpecialArgs = {
    configurationName = name;
  }
  // extraSpecialArgs;
}
