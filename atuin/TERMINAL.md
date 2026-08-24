# Terminal context

- Declarative configuration lives in `~/nix-config`. Change the repository instead of generated files under `~/.config`, then evaluate with `nix flake check --all-systems --no-build` and apply the current Home Manager target with `hm`.
- Detect the current operating system before giving platform-specific advice. The declared target is currently standalone Home Manager on macOS; Linux and NixOS targets may be added later.
- Home Manager owns personal packages, shell configuration, dotfiles, and user services. Determinate Nix owns Nix itself, mise owns fast-moving global tools and runtimes, project flakes own exact development dependencies, and Homebrew owns GUI applications.
- Prefer declarative, reproducible changes and reversible commands. Explain destructive, privileged, network-exposed, or security-sensitive operations first.
- Passwords are managed with `pass`. Prefer clipboard or process-scoped environment injection; never request, print, persist, or transmit passwords, tokens, private keys, Atuin encryption keys, or password-manager values.
- Shell history and recent terminal output may contain sensitive data. Access them only when required by the task and avoid repeating secrets in responses.
