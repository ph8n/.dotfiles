# Local Browser Use MCP

Home Manager owns `uv`, `browser-use-mcp`, and `chrome-agent`. Nix-darwin declares
Google Chrome through the existing Homebrew cask setup. Chezmoi reconciles
Executor's `browser_use` integration through its local management API; credentials
and browser data stay outside the repository.

```text
Pi -> Executor -> browser-use-mcp (stdio) -> CDP at 127.0.0.1:9222
```

Run `hm` to install changes. Start Executor and run `chrome-agent`.
For initial registration, both must be running; rerun `chezmoi apply` if the hook
reports that either is unavailable.

Helium is the personal browser; Google Chrome is the agent browser, with its own
Dock icon. The agent data directory is `~/Library/Application Support/Hydrogen`.
The launcher seeds the profile name `Hydrogen` only on first launch; Chrome owns
its subsequent preferences. Cookies, history, extensions and tabs stay separate
from personal Helium. Neither browser's data is tracked in this repository.
`alt-a` opens/focuses agent Chrome (`chrome-agent`); `alt-f` opens/focuses Helium.
The agent launcher identifies its running process by its data directory.
Browser Use can control all windows and tabs in the connected browser instance.
If another browser owns port 9222, Browser Use connects to that browser instead.
The launcher refuses to start if another process is listening on that port.
It does not close browsers or take over an occupied port.

Executor launches `/etc/profiles/per-user/dp/bin/browser-use-mcp`. The wrapper
checks CDP availability and runs Nix's `uvx` with Nix's Python:

```sh
uvx --python <Nix Python> --from 'browser-use[cli]==0.13.10' browser-use --mcp
```

Browser Use 0.13.10's native MCP server reads `cdp_url` through
`BROWSER_USE_CONFIG_PATH`; `BU_CDP_URL` alone does not configure that server.
The wrapper supplies a Nix-generated profile. No Chromium download or Browser Use
cloud credentials are required. Executor uses the standard `initialize`
handshake (`versionNegotiation: legacy`).

References: [pinned release](https://pypi.org/project/browser-use/0.13.10/),
[Browser Use MCP implementation](https://github.com/browser-use/browser-use/blob/0.13.10/browser_use/mcp/server.py),
[configuration loader](https://github.com/browser-use/browser-use/blob/0.13.10/browser_use/config.py),
[Executor MCP implementation](https://github.com/UsefulSoftwareCo/executor/tree/v1.6.8/packages/plugins/mcp).
