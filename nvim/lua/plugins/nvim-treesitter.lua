return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  event = { "BufReadPost", "BufNewFile" },
  opts = {
    ensure_installed = {
      "c",
      "cpp",
      "lua",
      "rust",
      "python",
      "go",
      "zig",
      "json",
      "yaml",
      "toml",
      "markdown",
      "markdown_inline",
      "latex",
      "typst",
      "bash",
      "vim",
      "vimdoc",
      "query",
    },
    auto_install = true,
    highlight = { enable = true },
    indent = { enable = true },
    textobjects = {
      select = {
        enable = true,
        lookahead = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
          ["ic"] = "@class.inner",
        },
      },
    },
  },
  config = function(_, opts)
    require("nvim-treesitter.config").setup(opts)
  end,
}
