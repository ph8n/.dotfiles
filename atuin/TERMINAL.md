# Terminal context

- Declarative configuration lives in `~/nix-config`. Change the repository instead of generated files, then evaluate with `nix flake check --all-systems --no-build` and apply with `hm` (Home Manager plus `chezmoi apply`).
- Detect the current operating system before giving platform-specific advice. Targets are NixOS (`box`, user `z`) and nix-darwin (`darwin`, user `dp`).
- One owner per path. Home Manager owns personal packages, shell configuration, non-agent dotfiles, and user services. Chezmoi owns agent-tool files (configs, hooks, mise plugins, Pi skill copies). Determinate Nix owns Nix itself, mise owns fast-moving global tools and runtimes, project flakes own exact development dependencies, and Homebrew owns GUI applications on macOS.
- Prefer declarative, reproducible changes and reversible commands. Explain destructive, privileged, network-exposed, or security-sensitive operations first.
- Passwords are managed with `pass`. Prefer clipboard or process-scoped environment injection; never request, print, persist, or transmit passwords, tokens, private keys, Atuin encryption keys, or password-manager values.
- Shell history and recent terminal output may contain sensitive data. Access them only when required by the task and avoid repeating secrets in responses.
