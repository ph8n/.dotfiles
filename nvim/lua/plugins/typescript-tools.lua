return {
  "pmizio/typescript-tools.nvim",
  ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  config = function()
    require("typescript-tools").setup({
      settings = {
        separate_diagnostic_server = true,
        publish_diagnostic_on = "insert_leave",
        tsserver_file_preferences = {
          includeCompletionsForModuleExports = true,
          includeCompletionsForImportStatements = true,
          includeInlayEnumMemberValueHints = true,
          includeInlayFunctionLikeReturnTypeHints = true,
          includeInlayFunctionParameterTypeHints = true,
          includeInlayParameterNameHints = "all",
          includeInlayParameterNameHintsWhenArgumentMatchesName = false,
          includeInlayPropertyDeclarationTypeHints = true,
          includeInlayVariableTypeHints = true,
        },
      },
    })
  end,
}
