{ pkgs, ... }:

{
  imports = [ ./hardware.nix ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Keep the Intel Wi-Fi adapter in its maximum-performance policy.
    extraModprobeConfig = "options iwlmvm power_scheme=1";
  };

  # Compress new writes without rewriting existing data during migration.
  fileSystems = {
    "/".options = [ "compress=zstd:3" ];
    "/home".options = [ "compress=zstd:3" ];
    "/nix".options = [ "compress=zstd:3" ];
  };

  networking = {
    hostName = "box";
    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };
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

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # Determinate's evaluator features are not enabled by the NixOS module,
    # because NixOS owns nix.conf instead of the Determinate installer.
    eval-cores = 0;
    lazy-trees = true;
  };

  # Keep a small system profile for recovery before Home Manager is introduced.
  environment.systemPackages = with pkgs; [
    gh
    git
    ghostty.terminfo
    mise
    neovim
  ];

  programs.nix-ld.enable = true;

  services = {
    xserver.xkb = {
      layout = "us";
      variant = "";
    };

    # Mirror the Mac's Karabiner layers on every detected keyboard.
    kanata = {
      enable = true;
      keyboards.phony.config = builtins.readFile ../../kanata/box.kbd;
    };

    # SSH is reachable only inside the tailnet and still requires the user's
    # declared public key.
    openssh = {
      enable = true;
      openFirewall = false;
      settings = {
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };

    # Establish the encrypted transport first. Authentication remains an
    # explicit interactive step so no tailnet credential enters the Nix store.
    tailscale = {
      enable = true;
      openFirewall = true;
    };
  };

  networking.firewall.interfaces.tailscale0.allowedTCPPorts = [ 22 ];

  # Preserve the version from the machine's original installation.
  system.stateVersion = "26.05";
}
