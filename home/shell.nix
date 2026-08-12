{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = false;
    history.path = "$HOME/.zsh_history";
    initContent = builtins.readFile ./zshrc;
    profileExtra = builtins.readFile ./zprofile;
  };

  # Zsh initializes Starship explicitly in the preserved personal configuration.
  programs.starship = {
    enable = true;
    enableZshIntegration = false;
  };
}
