{ pkgs, unstablePkgs, ... }:

{
  home.packages = with pkgs; [
    bat
    btop
    deadnix
    eza
    fd
    ffmpeg
    fzf
    gh
    git
    git-lfs
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
    ripgrep
    statix
    tmux
    zellij
    zoxide
  ];
}
