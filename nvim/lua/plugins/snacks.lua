local function preview_cmd(cmd)
  local ok = pcall(vim.cmd, cmd)
  if not ok then
    vim.notify("Preview command not available: " .. cmd, vim.log.levels.WARN)
  end
end

local function preview_primary()
  local ft = vim.bo.filetype
  if ft == "markdown" then
    preview_cmd("MarkdownPreviewToggle")
  elseif ft == "typst" then
    preview_cmd("TypstPreview")
  elseif ft == "tex" then
    preview_cmd("VimtexView")
  else
    vim.notify("No preview action for filetype: " .. ft, vim.log.levels.INFO)
  end
end

local function preview_stop()
  local ft = vim.bo.filetype
  if ft == "markdown" then
    preview_cmd("MarkdownPreviewStop")
  elseif ft == "typst" then
    preview_cmd("TypstPreviewStop")
  elseif ft == "tex" then
    preview_cmd("VimtexClean")
  else
    vim.notify("No preview action for filetype: " .. ft, vim.log.levels.INFO)
  end
end

local function preview_compile()
  local ft = vim.bo.filetype
  if ft == "tex" then
    preview_cmd("VimtexCompile")
  else
    vim.notify("LaTeX compile only applies to tex buffers", vim.log.levels.INFO)
  end
end

return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  opts = {
    -- Core
    picker = { enabled = true },
    notifier = { enabled = true },
    input = { enabled = true },

    -- Performance
    bigfile = { enabled = true },
    quickfile = { enabled = true },

    -- UI
    indent = { enabled = true },
    scope = { enabled = true },
    zen = { enabled = true },
  },
  keys = {
    -- Find
    { "<leader><space>", function() Snacks.picker.files() end, desc = "Find Files" },
    { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
    { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
    { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
    { "<leader>fg", function() Snacks.picker.git_files() end, desc = "Find Git Files" },
    { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent Files" },
    { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config" },

    -- Search
    { "<leader>sg", function() Snacks.picker.grep() end, desc = "Grep" },
    { "<leader>sw", function() Snacks.picker.grep_word() end, desc = "Grep Word" },
    { "<leader>sb", function() Snacks.picker.lines() end, desc = "Buffer Lines" },
    { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
    { "<leader>sh", function() Snacks.picker.help() end, desc = "Help" },
    { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
    { "<leader>sr", function() Snacks.picker.resume() end, desc = "Resume" },

    -- Git
    { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status" },
    { "<leader>gc", function() Snacks.picker.git_log() end, desc = "Git Commits" },
    { "<leader>gb", function() Snacks.picker.git_branches() end, desc = "Git Branches" },
    { "<leader>gB", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "v" } },

    -- Diagnostics
    { "<leader>sd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },

    -- LSP
    { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
    { "gr", function() Snacks.picker.lsp_references() end, desc = "References" },
    { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
    { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto Type Definition" },
    { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "Document Symbols" },
    { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "Workspace Symbols" },
    { "<leader>cR", function() Snacks.rename.rename_file() end, desc = "Rename File" },

    -- Buffer
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },

    -- Zen
    { "<leader>z", function() Snacks.zen() end, desc = "Zen Mode" },
    { "<leader>Z", function() Snacks.zen.zoom() end, desc = "Zoom" },

    -- Preview (Markdown/Typst/LaTeX/Diff)
    { "<leader>pp", preview_primary, desc = "Preview Toggle/View" },
    { "<leader>ps", preview_stop, desc = "Preview Stop/Clean" },
    { "<leader>pc", preview_compile, desc = "LaTeX Compile" },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Toggles
        Snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
        Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
        Snacks.toggle.diagnostics():map("<leader>ud")
        Snacks.toggle.inlay_hints():map("<leader>uh")
        Snacks.toggle.option("conceallevel", { off = 0, on = 2 }):map("<leader>uc")
        Snacks.toggle.indent():map("<leader>ug")
        Snacks.toggle.dim():map("<leader>uD")
      end,
    })
  end,
}
