vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--completion-style=none",
    "--header-insertion=never",
  },
})
vim.lsp.enable("clangd")

vim.lsp.config("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {
      cargo = { allFeatures = true },
      checkOnSave = false,
    },
  },
})
vim.lsp.enable("rust_analyzer")

vim.lsp.config("zls", {})
vim.lsp.enable("zls")

vim.lsp.config("pyright", {
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
      },
    },
  },
})
vim.lsp.enable("pyright")

vim.lsp.config("tsserver", {
  init_options = {
    preferences = {
      includeCompletionsForModuleExports = false,
    },
  },
})
vim.lsp.enable("tsserver")

-- navigation-only keymaps
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "gr", vim.lsp.buf.references)
vim.keymap.set("n", "gi", vim.lsp.buf.implementation)
vim.keymap.set("n", "K",  vim.lsp.buf.hover)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
