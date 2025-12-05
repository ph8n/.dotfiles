return {
  -- Markdown preview
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = "markdown",
    build = function()
      local install_path = vim.fn.stdpath("data") .. "/lazy/markdown-preview.nvim/app"
      vim.fn.system({ "bash", "-c", "cd " .. install_path .. " && npm install && git checkout ." })
    end,
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    keys = {
      { "<leader>mp", "<cmd>MarkdownPreviewToggle<cr>", desc = "Markdown Preview" },
    },
  },

  -- LaTeX (VimTeX)
  {
    "lervag/vimtex",
    ft = "tex",
    init = function()
      vim.g.vimtex_view_method = "skim"
      vim.g.vimtex_compiler_method = "latexmk"
      vim.g.vimtex_quickfix_mode = 0
    end,
    keys = {
      { "<leader>ll", "<cmd>VimtexCompile<cr>", desc = "LaTeX Compile" },
      { "<leader>lv", "<cmd>VimtexView<cr>", desc = "LaTeX View" },
      { "<leader>lc", "<cmd>VimtexClean<cr>", desc = "LaTeX Clean" },
      { "<leader>lt", "<cmd>VimtexTocToggle<cr>", desc = "LaTeX TOC" },
    },
  },

  -- Typst preview
  {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    version = "1.*",
    build = function()
      require("typst-preview").update()
    end,
    keys = {
      { "<leader>tp", "<cmd>TypstPreview<cr>", desc = "Typst Preview" },
      { "<leader>ts", "<cmd>TypstPreviewStop<cr>", desc = "Typst Preview Stop" },
    },
  },
}
