{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bat
    btop
    eza
    fd
    ffmpeg
    fzf
    gh
    git
    git-lfs
    gnupg
    herdr
    hunk
    imagemagick
    jq
    jujutsu
    lazygit
    mise
    neovim
    ripgrep
    tmux
    zellij
    zoxide
  ];
}
