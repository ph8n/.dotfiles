{
  pkgs,
  unstablePkgs,
  lib,
  ...
}:

{
  home.packages =
    (with pkgs; [
      bat
      btop
      chezmoi
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
      unstablePkgs.mise
      neovim
      nixd
      nixfmt
      nixfmt-tree
      pkg-config
      python3
      ripgrep
      statix
      tmux
      zellij
      zoxide
    ])
    # Headless virtual GUI over SSH via Xpra (Linux-only);
    # no desktop environment or display manager.
    ++ lib.optionals pkgs.stdenv.hostPlatform.isLinux (
      with pkgs;
      [
        xpra
        xterm
        xvfb
      ]
    );
}
