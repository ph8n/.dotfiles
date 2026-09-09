{
  pkgs,
  lib,
  ...
}:

let
  browserUseVersion = "0.13.10";
  agentCdpUrl = "http://127.0.0.1:9222";

  browserUseConfig = pkgs.writeText "browser-use-mcp-config.json" (
    builtins.toJSON {
      browser_profile.hydrogen = {
        id = "hydrogen";
        default = true;
        cdp_url = agentCdpUrl;
        headless = false;
        keep_alive = true;
      };
      llm = { };
      agent = { };
    }
  );

  browserUseMcp = pkgs.writeShellScriptBin "browser-use-mcp" ''
    if ! ${lib.getExe pkgs.curl} --silent --show-error --fail --max-time 2 \
      "${agentCdpUrl}/json/version" >/dev/null; then
      echo "browser-use-mcp: agent Chrome CDP is unavailable at ${agentCdpUrl}; start it with: chrome-agent" >&2
      exit 69
    fi

    export BROWSER_USE_CONFIG_PATH="${browserUseConfig}"
    exec ${lib.getExe' pkgs.uv "uvx"} \
      --python ${lib.getExe pkgs.python3} \
      --from 'browser-use[cli]==${browserUseVersion}' \
      browser-use --mcp
  '';

  hydrogenPreferences = pkgs.writeText "hydrogen-preferences.json" (
    builtins.toJSON {
      profile = {
        name = "Hydrogen";
        using_default_name = false;
      };
    }
  );

  chromeAgent = pkgs.writeShellScriptBin "chrome-agent" ''
    profile="$HOME/Library/Application Support/Hydrogen"
    for pid in $(/usr/bin/pgrep -x "Google Chrome"); do
      command=$(/bin/ps -p "$pid" -o command=)
      case "$command" in
        *"--user-data-dir=$profile"|*"--user-data-dir=$profile "*)
          asn=$(/usr/bin/lsappinfo -q -nonames find "pid=$pid")
          if [ -n "$asn" ]; then
            exec /usr/bin/lsappinfo -q -nonames requestfront "$asn" --immediate
          fi
          ;;
      esac
    done
    if /usr/sbin/lsof -nP -iTCP:9222 -sTCP:LISTEN >/dev/null 2>&1; then
      echo "chrome-agent: port 9222 is already occupied; close the browser using it first" >&2
      exit 69
    fi
    # Seed only a new profile; Chrome owns subsequent preference changes.
    if [ ! -e "$profile/Default/Preferences" ]; then
      /bin/mkdir -p "$profile/Default"
      /bin/cp ${hydrogenPreferences} "$profile/Default/Preferences"
      /bin/chmod u+w "$profile/Default/Preferences"
    fi
    exec /usr/bin/open -n -b com.google.Chrome --args \
      --user-data-dir="$profile" --remote-debugging-port=9222 \
      --no-first-run --no-default-browser-check
  '';
in
{
  home.packages =
    (with pkgs; [
      bat
      btop
      deadnix
      eza
      fd
      ffmpeg
      fzf
      # Native toolchain for T3 Code's npm/node-pty builds (Node itself stays on mise).
      gcc
      gh
      git
      git-lfs
      gnumake
      gnupg
      imagemagick
      jq
      jujutsu
      lazygit
      neovim
      nixd
      nixfmt
      nixfmt-tree
      pkg-config
      python3
      ripgrep
      statix
      tmux
      uv
      zellij
      zoxide
    ])
    ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      browserUseMcp
      chromeAgent
    ]
    # Linux-only packages; macOS gets 1Password CLI through Homebrew.
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux (
      with pkgs;
      [
        _1password-cli
        # Headless virtual GUI over SSH; no desktop environment or display manager.
        xpra
        xterm
        xvfb
      ]
    );
}
