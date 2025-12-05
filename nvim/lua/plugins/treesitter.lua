return {
  {
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
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },

  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    opts = {},
  },
}
