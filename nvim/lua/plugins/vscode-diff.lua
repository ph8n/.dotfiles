return {
  "esmuellert/vscode-diff.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  cmd = "CodeDiff",
  keys = {
    { "<leader>gv", "<cmd>CodeDiff<cr>", desc = "CodeDiff Explorer" },
    { "<leader>gf", "<cmd>CodeDiff file HEAD<cr>", desc = "CodeDiff current file vs HEAD" },
  },
  config = function()
    require("vscode-diff").setup({
      keymaps = {
        view = {
          quit = "q",
          toggle_explorer = "<leader>gD",
          next_hunk = "]c",
          prev_hunk = "[c",
          next_file = "]f",
          prev_file = "[f",
        },
        explorer = {
          select = "<CR>",
          hover = "K",
          refresh = "R",
        },
      },
    })
  end,
}
