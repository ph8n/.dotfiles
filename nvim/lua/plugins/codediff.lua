return {
  "esmuellert/codediff.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  cmd = "CodeDiff",
  keys = {
    { "<leader>.", "<cmd>CodeDiff<cr>", desc = "Open CodeDiff" },
  },
}
