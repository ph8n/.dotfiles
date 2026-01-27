local nordic = require("nordic")

nordic.setup({
  bold_keywords = false,
  italic_comments = true,
  reduced_blue = true,
  bright_border = true,

  transparent = {
    bg = true,
    float = true,
  },

  on_highlight = function(highlights)
    highlights.Pmenu.bg = "#191D24"
    highlights.NormalFloat.bg = "#151515"
  end,
})

vim.cmd.colorscheme("nordic")
