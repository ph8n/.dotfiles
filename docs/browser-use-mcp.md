# Local Browser Use MCP

Home Manager owns `uv`, `browser-use-mcp`, and `helium-cdp`. Chezmoi reconciles
Executor's `browser_use` integration through its local management API; credentials
and browser data stay outside the repository.

```text
Pi -> Executor -> browser-use-mcp (stdio) -> CDP at 127.0.0.1:9222
```

Run `hm` to install changes. Start Executor and run `helium-cdp`.
For initial registration, both must be running; rerun `chezmoi apply` if the hook
reports that either is unavailable.

The agent shares your personal Helium browser and its existing data directory,
`~/Library/Application Support/net.imput.helium`. There is no agent browser or
separate profile. Browser Use can access your open tabs and signed-in sites and
can interfere with your browsing; that sharing is intentional.
`alt-f` focuses Helium, or starts it with CDP if it is closed. `alt-a` is unbound.
If Helium was started from the Dock without CDP, quit it and reopen with `alt-f`
or `helium-cdp`; launch flags cannot be added to an already-running browser.
The wrapper requires Helium to own port 9222, so it will not connect to Chrome
left running on that port. It never closes your browser automatically.

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
