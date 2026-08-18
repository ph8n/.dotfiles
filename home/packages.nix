{ pkgs, ... }:

{
  # Personal tools: useful across projects and unrelated to a specific build.
  home.packages = with pkgs; [
    bat
    browserpass
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
    pass
    pinentry_mac
    ripgrep
    skhd
    tmux
    yabai
    zellij
    zoxide
  ];
}
