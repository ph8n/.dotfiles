{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    history.path = "$HOME/.zsh_history";
    initContent = builtins.readFile ./zshrc;
  };

  # Keep development Bash predictable: the flake owns its environment while
  # Home Manager contributes only completion, history behavior, and Starship.
  programs.bash = {
    enable = true;
    enableCompletion = true;
    historyControl = [
      "ignoredups"
      "ignorespace"
    ];
    shellOptions = [
      "checkwinsize"
      "histappend"
    ];
    initExtra = ''
      # Remember the flake that created this development shell. Starship uses
      # this fixed root to warn when the shell moves outside its repository.
      if [[ -n "''${IN_NIX_SHELL:-}" ]]; then
        _nix_flake_root="$PWD"
        while [[ "$_nix_flake_root" != "/" && ! -f "$_nix_flake_root/flake.nix" ]]; do
          _nix_flake_root="''${_nix_flake_root%/*}"
          [[ -n "$_nix_flake_root" ]] || _nix_flake_root="/"
        done

        if [[ -f "$_nix_flake_root/flake.nix" ]]; then
          export NIX_FLAKE_ROOT="$_nix_flake_root"
        else
          unset NIX_FLAKE_ROOT
        fi
        unset _nix_flake_root
      fi
    '';
  };

  # Zsh initializes Starship explicitly; Home Manager initializes it for Bash.
  programs.starship = {
    enable = true;
    enableZshIntegration = false;
    enableBashIntegration = true;
  };
}
