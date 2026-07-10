vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

for key, value in pairs({
  termguicolors = true,
  number = true,
  relativenumber = true,
  signcolumn = "auto",
  cursorline = true,
  wrap = false,
  scrolloff = 8,
  sidescrolloff = 8,
  updatetime = 250,
  timeoutlen = 300,
  clipboard = "unnamedplus",
  tabstop = 2,
  shiftwidth = 2,
  softtabstop = 2,
  expandtab = true,
  autoindent = true,
  ignorecase = true,
  smartcase = true,
  incsearch = true,
  hlsearch = false,
  swapfile = false,
  backup = false,
  undofile = true,
  splitbelow = true,
  splitright = true,
  completeopt = "menu,menuone,noselect",
  list = true,
  listchars = "tab:▸ ,trail:·,nbsp:␣",
}) do
  vim.o[key] = value
end

local map = vim.keymap.set

local function toggle_quickfix()
  if vim.fn.getqflist({ winid = 0 }).winid ~= 0 then
    vim.cmd.cclose()
  else
    vim.cmd.copen()
  end
end

map("v", "<", "<gv", { silent = true, desc = "Indent left" })
map("v", ">", ">gv", { silent = true, desc = "Indent right" })
map("n", "<leader>h", vim.cmd.nohlsearch, { desc = "Clear search" })
map("n", "<leader>uw", "<cmd>set wrap!<cr>", { desc = "Toggle wrap" })
map("n", "<leader>ul", "<cmd>set number!<cr>", { desc = "Toggle number" })
map("n", "<leader>uL", "<cmd>set relativenumber!<cr>", { desc = "Toggle relativenumber" })
map("n", "<leader>us", "<cmd>set spell!<cr>", { desc = "Toggle spell" })
map("n", "<leader>m", "<cmd>make<cr>", { desc = "Make" })
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })
map("n", "<leader>.", toggle_quickfix, { desc = "Toggle quickfix" })
map("n", "]q", "<cmd>cnext<cr>", { desc = "Quickfix next" })
map("n", "[q", "<cmd>cprev<cr>", { desc = "Quickfix previous" })
map("v", "J", ":m '>+1<cr>gv=gv", { silent = true, desc = "Move selection down" })
map("v", "K", ":m '<-2<cr>gv=gv", { silent = true, desc = "Move selection up" })
map("x", "<leader>p", '"_dP', { desc = "Paste without yanking replaced text" })

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    error("lazy.nvim install failed:\n" .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "projekt0n/github-nvim-theme",
    lazy = false,
    priority = 1000,
    opts = {
      options = {
        transparent = true,
        terminal_colors = true,
        styles = { comments = "italic" },
      },
    },
    config = function(_, opts)
      require("github-theme").setup(opts)
      vim.cmd.colorscheme("github_dark_high_contrast")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
  },
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>f", function() Snacks.picker.files() end, desc = "Find files" },
      { "<leader>/", function() Snacks.picker.grep() end, desc = "Live grep" },
      { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
    },
    opts = {
      picker = {
        enabled = true,
        layout = { preset = "default" },
      },
    },
  },
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    keys = { { "-", "<cmd>Oil<cr>", desc = "Open parent" } },
    opts = {},
  },
}, {
  defaults = { lazy = true },
  checker = { enabled = false },
  change_detection = { enabled = false, notify = false },
  install = { colorscheme = { "github_dark_high_contrast" } },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

vim.api.nvim_set_hl(0, "StatusLine", { fg = "#e6edf3", bg = "#2d333b", bold = false })
vim.api.nvim_set_hl(0, "StatusLineNC", { fg = "#9da7b3", bg = "#22272e", bold = false })
vim.api.nvim_set_hl(0, "AxiomStatuslineFile", { fg = "#0d1117", bg = "#6cb6ff", bold = true })
vim.api.nvim_set_hl(0, "AxiomStatuslinePos", { fg = "#0d1117", bg = "#f2cc60", bold = true })
vim.api.nvim_set_hl(0, "AxiomTablineSel", { fg = "#0d1117", bg = "#6cb6ff", bold = true })
vim.api.nvim_set_hl(0, "AxiomTabline", { fg = "#e6edf3", bg = "#3b4252", bold = false })
vim.api.nvim_set_hl(0, "AxiomTablineFill", { fg = "#9da7b3", bg = "#22272e", bold = false })

local statusline = {}

function statusline.tabline()
  local parts = {}
  local current = vim.api.nvim_get_current_tabpage()

  for i, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local win = vim.api.nvim_tabpage_get_win(tab)
    local buf = vim.api.nvim_win_get_buf(win)
    local label

    if vim.bo[buf].buftype == "terminal" then
      label = "terminal"
    else
      local name = vim.api.nvim_buf_get_name(buf)
      label = name ~= "" and vim.fn.fnamemodify(name, ":t") or "[No Name]"
    end

    if vim.bo[buf].modified then
      label = label .. " +"
    end

    label = label:gsub("%%", "%%%%")
    parts[#parts + 1] = tab == current and "%#AxiomTablineSel#" or "%#AxiomTabline#"
    parts[#parts + 1] = "%" .. i .. "T " .. label .. " "
  end

  parts[#parts + 1] = "%#AxiomTablineFill#%T%="
  return table.concat(parts)
end

_G.axiom_statusline = statusline

vim.o.tabline = "%!v:lua.axiom_statusline.tabline()"
vim.o.statusline = table.concat({
  "%#AxiomStatuslineFile# %<%t%m%r ",
  "%#StatusLine#%=",
  "%#AxiomStatuslinePos# %l:%c %p%% ",
})

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})
