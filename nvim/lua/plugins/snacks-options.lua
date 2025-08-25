return {
  {
    "folke/snacks.nvim",
    opts = {
      scroll = { enabled = false },
      terminal = { enabled = false },
      picker = {
        matcher = { frecency = true },
        toggles = { hidden = "p" },
        win = {
          input = {
            keys = {
              ["<a-p>"] = { "toggle_hidden", mode = { "n", "i" } },
            },
          },
        },
      },
    },
  },
}
