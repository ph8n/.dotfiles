require("gitsigns").setup({

  signs = {
    add          = { text = "+" },
    change       = { text = "~" },
    delete       = { text = "_" },
    topdelete    = { text = "‾" },
    changedelete = { text = "~" },
  },

  signcolumn = true,
  numhl = false,
  linehl = false,
  word_diff = false,

  current_line_blame = false,

  watch_gitdir = {
    interval = 1000,
    follow_files = true,
  },

  update_debounce = 200,
  max_file_length = 40000,

  preview_config = {
    border = "single",
    style = "minimal",
    relative = "cursor",
    row = 1,
    col = 1,
  },

  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    vim.keymap.set("n", "]h", gs.next_hunk, { buffer = bufnr })
    vim.keymap.set("n", "[h", gs.prev_hunk, { buffer = bufnr })

    vim.keymap.set("n", "<leader>g", gs.preview_hunk, { buffer = bufnr })
  end,
})
