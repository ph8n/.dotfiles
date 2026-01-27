local fzf = require("fzf-lua")

fzf.setup({
  winopts = {
    height = 0.85,
    width = 0.85,
    preview = {
      layout = "horizontal",
      vertical = "down:50%",
    },
  },
})

-- keymaps
vim.keymap.set("n", "<leader>f", fzf.files)
vim.keymap.set("n", "<leader>/", fzf.live_grep)
vim.keymap.set("n", "<leader>,", fzf.buffers)
