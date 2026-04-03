local util = require("axiom.lsp_util")

return {
  cmd = { "astro-ls", "--stdio" },
  filetypes = { "astro" },
  root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
  init_options = {
    typescript = {},
  },
  before_init = function(_, config)
    local typescript = config.init_options and config.init_options.typescript
    if typescript and not typescript.tsdk and config.root_dir then
      typescript.tsdk = util.get_typescript_server_path(config.root_dir)
    end
  end,
}
