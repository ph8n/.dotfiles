vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

for key, value in pairs({
  termguicolors = true,
  number = true,
  relativenumber = true,
  signcolumn = "yes",
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
  smarttab = true,
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
  autocomplete = false,
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
map("n", "]d", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Diagnostic next" })
map("n", "[d", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Diagnostic previous" })
map("n", "<leader>e", vim.diagnostic.open_float, { desc = "Diagnostic float" })
map("n", "<leader>q", vim.diagnostic.setqflist, { desc = "Diagnostics to quickfix" })
map("n", "<leader>v", "<cmd>vsplit<cr>", { desc = "Vertical split" })
map("n", "<leader>s", "<cmd>split<cr>", { desc = "Horizontal split" })
map("n", "<leader>x", "<cmd>close<cr>", { desc = "Close split" })
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
  { "neovim/nvim-lspconfig", lazy = false },
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    keys = {
      { "<leader>f", "<cmd>FzfLua files<cr>", desc = "Find files" },
      { "<leader>/", "<cmd>FzfLua live_grep<cr>", desc = "Live grep" },
      { "<leader>,", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
    },
    opts = {
      winopts = {
        height = 0.85,
        width = 0.85,
        preview = { layout = "horizontal" },
      },
    },
  },
  { "stevearc/oil.nvim", cmd = "Oil", keys = { { "-", "<cmd>Oil<cr>", desc = "Open parent" } }, opts = {} },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
      update_debounce = 200,
    },
  },
  {
    "saghen/blink.cmp",
    version = "*",
    event = "InsertEnter",
    opts = {
      keymap = { preset = "enter" },
      completion = {
        list = { selection = { preselect = false, auto_insert = false } },
      },
      cmdline = { enabled = false },
      sources = { default = { "lsp", "path", "buffer" } },
    },
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
  group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
vim.lsp.config("*", { capabilities = capabilities })

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("lsp_keymaps", { clear = true }),
  callback = function(args)
    local opts = function(desc)
      return { buffer = args.buf, desc = desc }
    end

    map("n", "gd", vim.lsp.buf.definition, opts("LSP definition"))
    map("n", "gD", vim.lsp.buf.declaration, opts("LSP declaration"))
    map("n", "gi", vim.lsp.buf.implementation, opts("LSP implementation"))
    map("n", "gr", vim.lsp.buf.references, opts("LSP references"))
    map("n", "gy", vim.lsp.buf.type_definition, opts("LSP type definition"))
    map("n", "K", vim.lsp.buf.hover, opts("LSP hover"))
    map("n", "<leader>rn", vim.lsp.buf.rename, opts("LSP rename"))
    map("n", "<leader>ca", vim.lsp.buf.code_action, opts("LSP code action"))
    map("n", "<leader>cf", function()
      vim.lsp.buf.format({ async = true })
    end, opts("LSP format"))
    map("n", "<leader>ds", vim.lsp.buf.document_symbol, opts("LSP document symbols"))
    map("n", "<leader>ws", vim.lsp.buf.workspace_symbol, opts("LSP workspace symbols"))
  end,
})

local servers = {}
local function add_lsp(name, cmd)
  if vim.fn.executable(cmd) == 1 then
    servers[#servers + 1] = name
    return true
  end
  return false
end

add_lsp("clangd", "clangd")
add_lsp("rust_analyzer", "rust-analyzer")
if not add_lsp("basedpyright", "basedpyright-langserver") and not add_lsp("pyright", "pyright-langserver") then
  add_lsp("ruff", "ruff")
end
add_lsp("ts_ls", "typescript-language-server")
add_lsp("zls", "zls")
if not add_lsp("texlab", "texlab") then
  add_lsp("digestif", "digestif")
end
if not add_lsp("marksman", "marksman") then
  add_lsp("markdown_oxide", "markdown-oxide")
end

vim.lsp.enable(servers)
