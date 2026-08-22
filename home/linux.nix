{
  lib,
  pkgs,
  ...
}:

let
  mesa = pkgs.mesa;
  cage = pkgs.cage.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace seat.c \
        --replace-fail 'wlr_keyboard_set_repeat_info(keyboard, 25, 600);' \
                       'wlr_keyboard_set_repeat_info(keyboard, 50, 200);'
    '';
  });
  seat = pkgs.writeShellApplication {
    name = "seat";
    runtimeInputs = [
      cage
      pkgs.foot
    ];
    text = ''
      export LIBGL_DRIVERS_PATH="${mesa}/lib/dri''${LIBGL_DRIVERS_PATH:+:$LIBGL_DRIVERS_PATH}"
      export __EGL_VENDOR_LIBRARY_DIRS="${mesa}/share/glvnd/egl_vendor.d''${__EGL_VENDOR_LIBRARY_DIRS:+:$__EGL_VENDOR_LIBRARY_DIRS}"
      export GBM_BACKENDS_PATH="${mesa}/lib/gbm''${GBM_BACKENDS_PATH:+:$GBM_BACKENDS_PATH}"
      export XDG_SESSION_TYPE=wayland
      export XKB_DEFAULT_LAYOUT=us
      mkdir -p "''${XDG_CACHE_HOME:-$HOME/.cache}"
      exec cage -s -d -- foot >>"''${XDG_CACHE_HOME:-$HOME/.cache}/seat.log" 2>&1
    '';
  };
in
{
  home.packages = [
    pkgs.pinentry-curses
    pkgs.jetbrains-mono
    pkgs.nerd-fonts.symbols-only
    pkgs.kanata
    pkgs.tailscale
    seat
  ];

  xdg.configFile."kanata/kanata.kbd".source = ../kanata/kanata.kbd;

  systemd.user.services.kanata = {
    Unit = {
      Description = "kanata keyboard remapper";
      After = [ "default.target" ];
      ConditionPathIsWritable = "/dev/uinput";
    };
    Service = {
      ExecStart = "${lib.getExe pkgs.kanata} --nodelay --cfg ${../kanata/kanata.kbd}";
      Restart = "always";
      RestartSec = "2";
    };
    Install.WantedBy = [ "default.target" ];
  };

  fonts.fontconfig.enable = true;

  programs.foot = {
    enable = true;
    settings = {
      main = {
        term = "foot";
        font = "JetBrains Mono:size=12, Symbols Nerd Font Mono:size=12";
        line-height = "18px";
        pad = "0x0";
        initial-window-mode = "fullscreen";
      };
      csd = {
        preferred = "none";
        size = "0";
      };
      cursor = {
        style = "block";
        blink = "no";
      };
      mouse.hide-when-typing = "yes";
      scrollback.lines = "20000";
      "colors-dark" = {
        background = "0a0b0a";
        foreground = "d0d0d8";
        regular0 = "0a0b0a";
        regular1 = "d0d0d8";
        regular2 = "d0d0d8";
        regular3 = "d0d0d8";
        regular4 = "d0d0d8";
        regular5 = "d0d0d8";
        regular6 = "d0d0d8";
        regular7 = "d0d0d8";
        bright0 = "868692";
        bright1 = "f0f0ff";
        bright2 = "f0f0ff";
        bright3 = "d0d0d8";
        bright4 = "d0d0d8";
        bright5 = "d0d0d8";
        bright6 = "d0d0d8";
        bright7 = "f0f0ff";
        selection-foreground = "d0d0d8";
        selection-background = "1a1a22";
      };
    };
  };

  programs.readline = {
    enable = true;
    variables = {
      bind-tty-special-chars = false;
      convert-meta = false;
      input-meta = true;
      output-meta = true;
    };
    bindings = {
      "\\C-?" = "backward-delete-char";
    };
  };

  programs.bash.profileExtra = ''
    if [ -z "''${WAYLAND_DISPLAY:-}" ] && [ -z "''${DISPLAY:-}" ] \
      && [ "''${XDG_VTNR:-}" = 1 ]; then
      exec ${lib.getExe seat}
    fi
  '';
}
