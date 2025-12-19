return {
  "chomosuke/typst-preview.nvim",
  ft = "typst",
  version = "1.*",
  build = function()
    require("typst-preview").update()
  end,
  keys = {
    { "<leader>ut", "<cmd>TypstPreview<cr>", desc = "Typst Preview" },
    { "<leader>us", "<cmd>TypstPreviewStop<cr>", desc = "Typst Preview Stop" },
  },
}
