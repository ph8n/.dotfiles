{ pkgs, ... }:

# Minimal NixOS host. Storage, Immich, Home Manager, and the monitor
# seat come back later as their own modules.

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "box";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Los_Angeles";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  users.users.box = {
    isNormalUser = true;
    description = "phony";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    # Concurrent agent builds; do not advertise every logical CPU to each job.
    max-jobs = 4;
    cores = 2;
  };

  boot.kernel.sysctl = {
    "fs.inotify.max_user_instances" = 1024;
    "fs.inotify.max_user_watches" = 1048576;
    "fs.inotify.max_queued_events" = 32768;
  };

  environment.systemPackages = with pkgs; [
    git
    ghostty.terminfo
    mise
    neovim
  ];

  programs.nix-ld.enable = true;

  # Identity-based SSH on the tailnet. No OpenSSH daemon yet.
  services.tailscale = {
    enable = true;
    openFirewall = true;
    extraSetFlags = [
      "--ssh"
      "--operator=box"
    ];
  };

  networking.firewall = {
    checkReversePath = "loose";
    trustedInterfaces = [ "tailscale0" ];
  };

  system.stateVersion = "26.05";
}
