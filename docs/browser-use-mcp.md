# Local Browser Use MCP

Home Manager owns `uv`, `browser-use-mcp`, `helium-cdp`, and `helium-personal`. Chezmoi reconciles
Executor's `browser_use` integration through its local management API; credentials
and browser data stay outside the repository.

```text
Pi -> Executor -> browser-use-mcp (stdio) -> CDP at 127.0.0.1:9222
```

Run `hm` to install changes. Start Executor and run `helium-cdp`.
For initial registration, both must be running; rerun `chezmoi apply` if the hook
reports that either is unavailable.

The launcher uses the separate agent data directory
`~/Library/Application Support/Helium-Agent`, whose current profile is named
`false`. Cookies, history, extensions and tabs remain separate from your personal
profile. Browser data and the display name are owned by Helium, outside this repo.
`alt-a` focuses the agent browser (`helium-cdp`); `alt-f` focuses the personal
browser (`helium-personal`). Each launcher identifies the running process by its
data directory and starts that browser only if it is not already running.
Browser Use can control all windows and tabs in the connected browser instance.
If another browser owns port 9222, Browser Use connects to that browser instead.
The launcher does not close browsers or take over an occupied port.

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
