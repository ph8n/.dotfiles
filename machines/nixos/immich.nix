{ pkgs, ... }:

let
  composeFile = ./immich/docker-compose.yml;
in
{
  # Immich's officially supported Docker Compose deployment is newer than the
  # native Nixpkgs package currently pinned by this flake.
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  environment.systemPackages = [
    pkgs.docker-compose
    pkgs.e2fsprogs
  ];

  systemd.tmpfiles.rules = [
    "d /var/lib/immich 0700 root root -"
    "d /srv/photos/immich 0750 root root -"
    "d /srv/data/files 0750 z users -"
  ];

  systemd.services.immich-compose = {
    description = "Immich Docker Compose stack";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [
      "docker.service"
      "network-online.target"
      "srv-photos.mount"
    ];
    requires = [
      "docker.service"
      "srv-photos.mount"
    ];

    path = [
      pkgs.docker
      pkgs.docker-compose
    ];

    preStart = ''
      if [ ! -s /var/lib/immich/.env ]; then
        echo "Create /var/lib/immich/.env before starting Immich" >&2
        exit 1
      fi
      install -m 0644 ${composeFile} /var/lib/immich/docker-compose.yml
    '';

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      WorkingDirectory = "/var/lib/immich";
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose up -d --remove-orphans";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose stop";
      TimeoutStartSec = 0;
      TimeoutStopSec = "2min";
    };
  };
}
