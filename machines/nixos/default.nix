{ pkgs, ... }:

{
  imports = [ ./hardware.nix ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Compress new writes without rewriting existing data during migration.
  fileSystems."/".options = [ "compress=zstd:3" ];
  fileSystems."/home".options = [ "compress=zstd:3" ];
  fileSystems."/nix".options = [ "compress=zstd:3" ];

  networking = {
    hostName = "box";
    networkmanager.enable = true;
  };

  time.timeZone = "America/Los_Angeles";

  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
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
  };

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Keep a small system profile for recovery before Home Manager is introduced.
  environment.systemPackages = with pkgs; [
    gh
    git
    ghostty.terminfo
    mise
    neovim
  ];

  programs.nix-ld.enable = true;

  # SSH is reachable only inside the tailnet and still requires the user's
  # declared public key.
  services.openssh = {
    enable = true;
    openFirewall = false;
    settings = {
      KbdInteractiveAuthentication = false;
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 22 ];

  # Establish the encrypted transport first. Authentication remains an
  # explicit interactive step so no tailnet credential enters the Nix store.
  services.tailscale = {
    enable = true;
    openFirewall = true;
  };

  # Preserve the version from the machine's original installation.
  system.stateVersion = "26.05";
}
