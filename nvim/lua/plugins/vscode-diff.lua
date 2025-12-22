return {
  "esmuellert/vscode-diff.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  cmd = "CodeDiff",
  keys = {
    { "<leader>.", "<cmd>CodeDiff<cr>", desc = "CodeDiff" },
  },
  config = function()
    require("vscode-diff").setup()
  end,
}
