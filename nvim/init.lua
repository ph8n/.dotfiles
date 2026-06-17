vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.o.termguicolors = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.cursorline = true
vim.o.wrap = false
vim.o.scrolloff = 8
vim.o.sidescrolloff = 8
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.lazyredraw = true
vim.o.synmaxcol = 240
vim.o.clipboard = "unnamedplus"
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.expandtab = true
vim.o.smarttab = true
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.incsearch = true
vim.o.hlsearch = false
vim.o.swapfile = false
vim.o.backup = false
vim.o.undofile = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.completeopt = "menu,menuone,noselect,popup,fuzzy"
vim.o.complete = ".,w,b,u,t,o"
vim.o.autocomplete = true
vim.o.redrawtime = 1500
vim.o.list = true
vim.o.listchars = "tab:▸ ,trail:·,nbsp:␣"

local map = vim.keymap.set
local augroup = vim.api.nvim_create_augroup

local function toggle_quickfix()
  local quickfix = vim.fn.getqflist({ winid = 0 })
  if quickfix.winid ~= 0 then
    vim.cmd.cclose()
  else
    vim.cmd.copen()
  end
end

map("v", "<", "<gv", { silent = true, desc = "Indent left and keep selection" })
map("v", ">", ">gv", { silent = true, desc = "Indent right and keep selection" })
map("n", "<leader>h", vim.cmd.nohlsearch, { desc = "Clear search highlight" })
map("n", "<leader>uw", "<cmd>set wrap!<CR>", { desc = "Toggle line wrap" })
map("n", "<leader>ul", "<cmd>set number!<CR>", { desc = "Toggle line numbers" })
map("n", "<leader>uL", "<cmd>set relativenumber!<CR>", { desc = "Toggle relative line numbers" })
map("n", "<leader>us", "<cmd>set spell!<CR>", { desc = "Toggle spelling" })
map("n", "<leader>m", "<cmd>make<CR>", { desc = "Run make" })
map("n", "<leader>.", toggle_quickfix, { desc = "Toggle quickfix window" })
map("n", "]q", "<cmd>cnext<CR>", { desc = "Quickfix next item" })
map("n", "[q", "<cmd>cprev<CR>", { desc = "Quickfix previous item" })
map("n", "<leader>v", vim.cmd.vsplit, { desc = "Vertical split" })
map("n", "<leader>s", vim.cmd.split, { desc = "Horizontal split" })
map("n", "<leader>x", vim.cmd.close, { desc = "Close split" })
map("v", "J", ":m '>+1<CR>gv=gv", { silent = true, desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { silent = true, desc = "Move selection up" })
map("x", "<leader>p", '"_dP', { desc = "Paste without yanking replaced text" })
map("i", "<CR>", function()
  if vim.fn.pumvisible() == 1 and vim.fn.complete_info({ "selected" }).selected ~= -1 then
    return "<C-y>"
  end

  return "<CR>"
end, { expr = true, desc = "Accept completion or insert newline" })

local function gh(repo)
  return "https://github.com/" .. repo
end

vim.pack.add({
  { src = gh("projekt0n/github-nvim-theme"), name = "github-theme" },
  gh("nvim-treesitter/nvim-treesitter"),
  gh("ibhagwan/fzf-lua"),
  gh("nvim-tree/nvim-web-devicons"),
  gh("stevearc/oil.nvim"),
  gh("lewis6991/gitsigns.nvim"),
}, { confirm = false })

require("github-theme").setup({
  options = {
    transparent = true,
    terminal_colors = true,
    dim_inactive = false,
    styles = {
      comments = "italic",
    },
  },
  groups = {
    github_dark_high_contrast = {
      Pmenu = { bg = "#151515" },
      NormalFloat = { bg = "#151515" },
      FloatBorder = { bg = "#151515" },
    },
  },
})

vim.cmd.colorscheme("github_dark_high_contrast")

vim.api.nvim_set_hl(0, "StatusLine", { fg = "#e6edf3", bg = "#2d333b", bold = false })
vim.api.nvim_set_hl(0, "StatusLineNC", { fg = "#9da7b3", bg = "#22272e", bold = false })
vim.api.nvim_set_hl(0, "AxiomStatuslineFile", { fg = "#0d1117", bg = "#6cb6ff", bold = true })
vim.api.nvim_set_hl(0, "AxiomStatuslineMeta", { fg = "#e6edf3", bg = "#3b4252", bold = false })
vim.api.nvim_set_hl(0, "AxiomStatuslinePos", { fg = "#0d1117", bg = "#f2cc60", bold = true })
vim.api.nvim_set_hl(0, "AxiomTablineSel", { fg = "#0d1117", bg = "#6cb6ff", bold = true })
vim.api.nvim_set_hl(0, "AxiomTabline", { fg = "#e6edf3", bg = "#3b4252", bold = false })
vim.api.nvim_set_hl(0, "AxiomTablineFill", { fg = "#9da7b3", bg = "#22272e", bold = false })

local statusline = {}

function statusline.info()
  local branch = vim.b.gitsigns_head

  if type(branch) == "string" and branch ~= "" then
    return " git:" .. branch .. " "
  end

  return ""
end

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
  "%#AxiomStatuslineMeta#",
  "%{v:lua.axiom_statusline.info()}",
  "%#StatusLine#%=",
  "%#AxiomStatuslinePos# %l:%c %p%% ",
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup("axiom_treesitter", { clear = true }),
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

-- nvim-web-devicons loaded lazily with fzf-lua or oil.nvim

local devicons_loaded = false
local function ensure_devicons()
  if not devicons_loaded then
    require("nvim-web-devicons").setup({ default = true })
    devicons_loaded = true
  end
end

local fzf_loaded = false
local function load_fzf()
  ensure_devicons()
  if not fzf_loaded then
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
    fzf_loaded = true
  end
  return require("fzf-lua")
end

map("n", "<leader>f", function() load_fzf().files() end, { desc = "Find files" })
map("n", "<leader>/", function() load_fzf().live_grep() end, { desc = "Live grep" })
map("n", "<leader>,", function() load_fzf().buffers() end, { desc = "List buffers" })

local oil_loaded = false
map("n", "-", function()
  if not oil_loaded then
    ensure_devicons()
    require("oil").setup()
    oil_loaded = true
  end
  require("oil").open()
end, { desc = "Open parent directory" })

require("gitsigns").setup({
  signs = {
    add = { text = "+" },
    change = { text = "~" },
    delete = { text = "_" },
    topdelete = { text = "‾" },
    changedelete = { text = "~" },
  },
  update_debounce = 200,
  preview_config = {
    border = "single",
    row = 1,
  },
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns

    map("n", "]h", gs.next_hunk, { buffer = bufnr, desc = "Next git hunk" })
    map("n", "[h", gs.prev_hunk, { buffer = bufnr, desc = "Previous git hunk" })
    map("n", "<leader>g", gs.preview_hunk, { buffer = bufnr, desc = "Preview git hunk" })
  end,
})
