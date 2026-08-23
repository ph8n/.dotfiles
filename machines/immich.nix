{
  config,
  lib,
  pkgs,
  ...
}:

# Native Immich from nixpkgs. No Docker.
# Ubuntu still owns the filesystems; this module owns the processes.

let
  media = "/srv/photos";
  fastData = "${config.home.homeDirectory}/.local/share/immich/data";
  pgdata = "${fastData}/pgdata";
  redisDir = "${fastData}/redis";
  mlCache = "${fastData}/ml-cache";
  runDir = "${config.home.homeDirectory}/.local/share/immich/run";

  postgresql = pkgs.postgresql.withPackages (ps: [
    ps.pgvector
    ps.vectorchord
  ]);

  dirs = pkgs.writeShellApplication {
    name = "immich-dirs";
    runtimeInputs = [ pkgs.coreutils ];
    text = ''
      mkdir -p ${lib.escapeShellArg pgdata} \
        ${lib.escapeShellArg redisDir} \
        ${lib.escapeShellArg mlCache} \
        ${lib.escapeShellArg media} \
        ${lib.escapeShellArg runDir}
    '';
  };

  postgres = pkgs.writeShellApplication {
    name = "immich-postgres";
    runtimeInputs = [ postgresql ];
    text = ''
      ${lib.getExe dirs}
      if [ ! -s ${lib.escapeShellArg pgdata}/PG_VERSION ]; then
        initdb -D ${lib.escapeShellArg pgdata} \
          --locale=C.UTF-8 \
          --auth-local=trust \
          --auth-host=reject \
          --no-instructions
      fi
      exec postgres \
        -D ${lib.escapeShellArg pgdata} \
        -k ${lib.escapeShellArg runDir} \
        -c listen_addresses= \
        -c unix_socket_directories=${lib.escapeShellArg runDir} \
        -c shared_preload_libraries=vchord.so
    '';
  };

  postgresSetup = pkgs.writeShellApplication {
    name = "immich-postgres-setup";
    runtimeInputs = [ postgresql ];
    text = ''
      export PGHOST=${lib.escapeShellArg runDir}
      until pg_isready -q -d postgres; do sleep 0.2; done
      if ! psql -d postgres -tAc "SELECT 1 FROM pg_database WHERE datname='immich'" | grep -qx 1; then
        createdb immich
      fi
      psql -d immich -v ON_ERROR_STOP=1 <<'SQL'
      CREATE EXTENSION IF NOT EXISTS unaccent;
      CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
      CREATE EXTENSION IF NOT EXISTS cube;
      CREATE EXTENSION IF NOT EXISTS earthdistance;
      CREATE EXTENSION IF NOT EXISTS pg_trgm;
      CREATE EXTENSION IF NOT EXISTS vector;
      CREATE EXTENSION IF NOT EXISTS vchord CASCADE;
      SQL
    '';
  };

  redis = pkgs.writeShellApplication {
    name = "immich-redis";
    runtimeInputs = [ pkgs.redis ];
    text = ''
      ${lib.getExe dirs}
      exec redis-server \
        --port 0 \
        --bind 127.0.0.1 \
        --unixsocket ${lib.escapeShellArg runDir}/redis.sock \
        --unixsocketperm 600 \
        --dir ${lib.escapeShellArg redisDir} \
        --daemonize no \
        --supervised no \
        --save 60 1000
    '';
  };

  publishImmich = pkgs.writeShellApplication {
    name = "publish-immich";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.jq
      pkgs.tailscale
    ];
    text = ''
      for _ in $(seq 1 60); do
        if tailscale status --json 2>/dev/null \
          | jq -e '.BackendState == "Running"' >/dev/null; then
          exec tailscale serve --bg http://127.0.0.1:2283
        fi
        sleep 1
      done
      echo "Tailscale did not become ready within 60 seconds" >&2
      exit 1
    '';
  };

  unit =
    {
      description,
      exec,
      after ? [ ],
      requires ? [ ],
      extra ? { },
    }:
    {
      Unit = {
        Description = description;
        After = after;
        Requires = requires;
      };
      Service = {
        Type = "simple";
        ExecStart = exec;
        Restart = "on-failure";
        RestartSec = "3";
      }
      // extra;
      Install.WantedBy = [ "default.target" ];
    };
in
{
  systemd.user.startServices = "sd-switch";

  systemd.user.services.immich-postgres = unit {
    description = "Immich PostgreSQL";
    exec = lib.getExe postgres;
    extra.ExecStartPost = "${lib.getExe postgresSetup}";
  };

  systemd.user.services.immich-redis = unit {
    description = "Immich Redis";
    exec = lib.getExe redis;
  };

  systemd.user.services.immich-machine-learning = unit {
    description = "Immich machine learning";
    exec = lib.getExe pkgs.immich.machine-learning;
    extra = {
      # Agent builds are the interactive workload; background indexing yields.
      Nice = "5";
      CPUWeight = "25";
      IOWeight = "25";
      Environment = [
        "MACHINE_LEARNING_WORKERS=1"
        "MACHINE_LEARNING_WORKER_TIMEOUT=120"
        "MACHINE_LEARNING_CACHE_FOLDER=${mlCache}"
        "XDG_CACHE_HOME=${mlCache}"
        "IMMICH_HOST=127.0.0.1"
        "IMMICH_PORT=3003"
      ];
    };
  };

  systemd.user.services.immich-server = unit {
    description = "Immich server";
    exec = lib.getExe pkgs.immich;
    after = [
      "immich-postgres.service"
      "immich-redis.service"
      "immich-machine-learning.service"
    ];
    requires = [
      "immich-postgres.service"
      "immich-redis.service"
    ];
    extra = {
      Environment = [
        "PATH=${
          lib.makeBinPath [
            postgresql
            pkgs.gzip
          ]
        }"
        "DB_URL=postgresql:///immich?host=${runDir}"
        "REDIS_SOCKET=${runDir}/redis.sock"
        "IMMICH_HOST=127.0.0.1"
        "IMMICH_PORT=2283"
        "IMMICH_MEDIA_LOCATION=${media}"
        "IMMICH_MACHINE_LEARNING_URL=http://127.0.0.1:3003"
        # QSV via oneVPL no longer initializes on Skylake. VAAPI is tested.
        "LIBVA_DRIVER_NAME=iHD"
        "LIBVA_DRIVERS_PATH=${pkgs.intel-media-driver}/lib/dri"
      ];
    };
  };

  # Needs `sudo tailscale set --operator=$USER` from box-bootstrap.sh.
  systemd.user.services.immich-tailscale = {
    Unit = {
      Description = "Publish Immich on Tailscale";
      After = [ "immich-server.service" ];
      Requires = [ "immich-server.service" ];
    };
    Service = {
      Type = "oneshot";
      RemainAfterExit = true;
      TimeoutStartSec = "75";
      Restart = "on-failure";
      RestartSec = "5";
      ExecStart = lib.getExe publishImmich;
    };
    Install.WantedBy = [ "default.target" ];
  };
}
