return {
  "lervag/vimtex",
  ft = "tex",
  init = function()
    vim.g.vimtex_view_method = "skim"
    vim.g.vimtex_compiler_method = "latexmk"
    vim.g.vimtex_quickfix_mode = 0
  end,
  keys = {
    { "<leader>uc", "<cmd>VimtexCompile<cr>", desc = "LaTeX Compile" },
    { "<leader>ul", "<cmd>VimtexView<cr>", desc = "LaTeX View" },
    { "<leader>ux", "<cmd>VimtexClean<cr>", desc = "LaTeX Clean" },
  },
}
