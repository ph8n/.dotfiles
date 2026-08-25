{ ... }:

{
  users.users.z = {
    isNormalUser = true;
    description = "phony";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };
}
