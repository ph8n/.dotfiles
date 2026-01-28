vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local o = { buffer = ev.buf, silent = true }

    vim.keymap.set("n", "gd", vim.lsp.buf.definition, o)
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, o)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, o)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, o)
    vim.keymap.set("n", "K",  vim.lsp.buf.hover, o)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, o)
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, o)
    vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, o)
    vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, o)
    vim.keymap.set("n", "]d", vim.diagnostic.goto_next, o)
  end,
})

vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=never",
		"--completion-style=detailed",
  },
  root_markers = {
    "compile_commands.json",
    ".git",
  },
})

vim.lsp.enable("clangd")

vim.lsp.config("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {
      cargo = { allFeatures = true },
      checkOnSave = false,
      procMacro = { enable = true },
    },
  },
})
vim.lsp.enable("rust_analyzer")
