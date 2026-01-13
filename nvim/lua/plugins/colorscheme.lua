return {
  {
    "AlexvZyl/nordic.nvim",
    name = "nordic", -- Plugin name
    lazy = false, -- Ensure it loads eagerly
    priority = 1000, -- Load it early as it's a colorscheme
    config = function()
      require("nordic").setup({
        -- This callback can be used to override highlights before they are applied.
        on_highlight = function(highlights, palette)
          highlights.Pmenu.bg = "#191D24"
          highlights.NormalFloat.bg = "#151515"
        end,

        -- This callback can be used to override the colors used in the base palette.
        on_palette = function(palette) end,
        -- This callback can be used to override the colors used in the extended palette.
        after_palette = function(palette) end,

        -- Enable bold keywords.
        bold_keywords = false,
        -- Enable italic comments.
        italic_comments = true,
        -- Enable editor background transparency.
        transparent = {
          -- Enable transparent background.
          bg = true,
          -- Enable transparent background for floating windows.
          float = true,
        },
        -- Enable brighter float border.
        bright_border = true,
        -- Reduce the overall amount of blue in the theme (diverges from base Nord).
        reduced_blue = true,
        -- Swap the dark background with the normal one.
        swap_backgrounds = false,
        -- Cursorline options.  Also includes visual/selection.
        cursorline = {
          -- Bold font in cursorline.
          bold = false,
          -- Bold cursorline number.
          bold_number = true,
          -- Available styles: 'dark', 'light'.
          theme = "dark",
          -- Blending the cursorline bg with the buffer bg.
          blend = 0.85,
        },
        ts_context = {
          -- Enables dark background for treesitter-context window
          dark_background = true,
        },
      })
      -- Apply the colorscheme
      vim.cmd.colorscheme("nordic")
    end,
  },
}
