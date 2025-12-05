return {
  "echasnovski/mini.nvim",
  version = false,
  config = function()
    require("mini.pairs").setup()
    require("mini.icons").setup()
  end,
}
