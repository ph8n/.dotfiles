return {
  "p00f/clangd_extensions.nvim",
  ft = { "c", "cpp", "objcpp", "cuda", "proto" },
  dependencies = { "neovim/nvim-lspconfig" },
  config = function()
    require("clangd_extensions").setup({})
    vim.lsp.config("clangd", {
      cmd = {
        "clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--function-arg-placeholders",
        "--fallback-style=llvm",
      },
    })
    vim.lsp.enable("clangd")
  end,
}
