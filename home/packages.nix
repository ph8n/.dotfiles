{ pkgs, ... }:

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
    mise
    neovim
    nixd
    nixfmt-tree
    ripgrep
    statix
    tmux
    zellij
    zoxide
  ];
}
