# Personal terminal context

- This is a personal macOS system using Zsh, Nix, and standalone Home Manager.
- Declarative configuration lives in `~/.nix-config`. Prefer changing that repository and running `nix flake check ~/.nix-config` followed by `hm`; do not edit generated files in `~/.config` directly.
- Determinate Nix owns Nix itself, Home Manager owns personal packages and configuration, mise owns fast-moving personal CLIs and global runtimes, project flakes own exact development dependencies, and Homebrew owns GUI applications only.
- Prefer reversible commands. Clearly explain destructive, privileged, or security-sensitive operations before suggesting them.
- Passwords are managed with `pass`. Prefer `pass -c` or process-scoped environment injection; never request, print, persist, or send passwords, tokens, private keys, Atuin encryption keys, or password-manager values.
- Atuin history and recent command output may contain sensitive data. Read either only when it is relevant to the user's request.
