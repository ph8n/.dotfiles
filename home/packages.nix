{
  pkgs,
  lib,
  ...
}:

let
  browserUseVersion = "0.13.10";
  heliumCdpUrl = "http://127.0.0.1:9222";

  browserUseConfig = pkgs.writeText "browser-use-mcp-config.json" (
    builtins.toJSON {
      browser_profile.helium = {
        id = "helium";
        default = true;
        cdp_url = heliumCdpUrl;
        headless = false;
        keep_alive = true;
      };
      llm = { };
      agent = { };
    }
  );

  browserUseMcp = pkgs.writeShellScriptBin "browser-use-mcp" ''
    if ! ${lib.getExe pkgs.curl} --silent --show-error --fail --max-time 2 \
      "${heliumCdpUrl}/json/version" >/dev/null; then
      echo "browser-use-mcp: Helium CDP is unavailable at ${heliumCdpUrl}; start Helium with: helium-cdp" >&2
      exit 69
    fi

    export BROWSER_USE_CONFIG_PATH="${browserUseConfig}"
    exec ${lib.getExe' pkgs.uv "uvx"} \
      --python ${lib.getExe pkgs.python3} \
      --from 'browser-use[cli]==${browserUseVersion}' \
      browser-use --mcp
  '';

  heliumCdp = pkgs.writeShellScriptBin "helium-cdp" ''
    personal_profile="$HOME/Library/Application Support/net.imput.helium"

    exec /usr/bin/open -b net.imput.helium --args \
      --user-data-dir="$personal_profile" --remote-debugging-port=9222
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
      heliumCdp
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
