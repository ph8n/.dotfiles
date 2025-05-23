return {
  {
    "catppuccin/nvim",
    name = "catppuccin", -- Plugin name
    lazy = false, -- Ensure it loads eagerly
    priority = 1000, -- Load it early as it's a colorscheme
    config = function()
      require("catppuccin").setup({
        flavour = "mocha", -- Use mocha flavor
        transparent_background = true, -- Enable transparency
        show_end_of_buffer = true, -- Hide the '~' characters after the end of buffers
        term_colors = true, -- Enable terminal colors
        dim_inactive = {
          enabled = false, -- Don't dim inactive windows
          shade = "dark",
          percentage = 0.15,
        },
        no_italic = false, -- Allow italic text
        no_bold = false, -- Allow bold text
        no_underline = false, -- Allow underlined text
        styles = {
          comments = { "italic" },
          conditionals = { "italic" },
          loops = {},
          functions = {},
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
          operators = {},
        },
        color_overrides = {},
        custom_highlights = {},
        default_integrations = true,
        integrations = {
          cmp = true, -- Enable nvim-cmp integration
          gitsigns = true, -- Enable GitSigns integration
          nvimtree = true, -- Enable NvimTree integration
          treesitter = true, -- Enable Treesitter integration
          notify = false,
          mini = {
            enabled = true,
            indentscope_color = "",
          },
        },
      })
      -- Apply the colorscheme
      vim.cmd.colorscheme("catppuccin")
    end,
  },
}
