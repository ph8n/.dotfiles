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
local lsp_complete = "o,.,w,b,u,t"

local function lsp_completion_convert(item)
  if vim.lsp.protocol.CompletionItemKind[item.kind] then
    return {}
  end

  return { kind = "" }
end

map("v", "<", "<gv", { silent = true, desc = "Indent left and keep selection" })
map("v", ">", ">gv", { silent = true, desc = "Indent right and keep selection" })
map("n", "<leader>h", vim.cmd.nohlsearch, { desc = "Clear search highlight" })
map("n", "<leader>m", "<cmd>make<CR>", { desc = "Run make" })
map("n", "<leader>q", function()
  vim.diagnostic.setqflist({ open = true })
end, { desc = "Diagnostics to quickfix" })
map("n", "]q", "<cmd>cnext<CR>", { desc = "Quickfix next item" })
map("n", "[q", "<cmd>cprev<CR>", { desc = "Quickfix previous item" })
map("n", "<leader>v", vim.cmd.vsplit, { desc = "Vertical split" })
map("n", "<leader>s", vim.cmd.split, { desc = "Horizontal split" })
map("n", "<leader>x", vim.cmd.close, { desc = "Close split" })
map("t", "<Esc>", [[<C-\><C-n>]], { desc = "Exit terminal mode" })
map("v", "J", ":m '>+1<CR>gv=gv", { silent = true, desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { silent = true, desc = "Move selection up" })
map("x", "<leader>p", '"_dP', { desc = "Paste without yanking replaced text" })
map("i", "<C-Space>", function()
  vim.lsp.completion.get()
end, { desc = "Trigger completion" })
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
  gh("christoomey/vim-tmux-navigator"),
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
      StatusLine = {
        fg = "#c9c7cd",
        bg = "#1c1c1f",
        style = "NONE",
      },
      StatusLineNC = {
        fg = "#7f7d84",
        bg = "#151515",
        style = "NONE",
      },
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

local statusline = {}
local diagnostic_labels = {
  { severity = vim.diagnostic.severity.ERROR, label = "E" },
  { severity = vim.diagnostic.severity.WARN, label = "W" },
  { severity = vim.diagnostic.severity.INFO, label = "I" },
  { severity = vim.diagnostic.severity.HINT, label = "H" },
}

function statusline.info()
  local parts = {}
  local branch = vim.b.gitsigns_head

  if type(branch) == "string" and branch ~= "" then
    parts[#parts + 1] = "git:" .. branch
  end

  local counts = vim.diagnostic.count(0)
  local present = {}
  for _, item in ipairs(diagnostic_labels) do
    local count = counts[item.severity] or 0
    if count > 0 then
      present[#present + 1] = item.label .. count
    end
  end

  if #present > 0 then
    parts[#parts + 1] = table.concat(present, " ")
  end

  if #parts == 0 then
    return ""
  end

  return " " .. table.concat(parts, "  ") .. " "
end

_G.axiom_statusline = statusline

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

map("n", "<leader>f", fzf.files, { desc = "Find files" })
map("n", "<leader>/", fzf.live_grep, { desc = "Live grep" })
map("n", "<leader>,", fzf.buffers, { desc = "List buffers" })

local oil = require("oil")
oil.setup()

map("n", "-", oil.open, { desc = "Open parent directory" })

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

vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup("axiom_lsp", { clear = true }),
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    local opts = { buffer = ev.buf, silent = true }

    map("n", "gd", vim.lsp.buf.definition, opts)
    map("n", "gD", vim.lsp.buf.declaration, opts)
    map("n", "gr", vim.lsp.buf.references, opts)
    map("n", "gi", vim.lsp.buf.implementation, opts)
    map("n", "K", vim.lsp.buf.hover, opts)
    map("n", "<leader>rn", vim.lsp.buf.rename, opts)
    map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    map("n", "<leader>d", vim.diagnostic.open_float, opts)
    map("n", "[d", function()
      vim.diagnostic.jump({ count = -1 })
    end, opts)
    map("n", "]d", function()
      vim.diagnostic.jump({ count = 1 })
    end, opts)

    if client:supports_method("textDocument/completion") then
      vim.bo[ev.buf].complete = lsp_complete
      vim.lsp.completion.enable(true, client.id, ev.buf, { convert = lsp_completion_convert })
    end
  end,
})

vim.lsp.config("clangd", {
  cmd = {
    "xcrun",
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--query-driver=/usr/bin/clang++,/usr/bin/c++,/usr/bin/clang,/usr/bin/cc",
    "--header-insertion=never",
  },
})

vim.lsp.config("lua_ls", {
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = { enable = false },
    },
  },
})

vim.lsp.config("rust_analyzer", {
  settings = {
    ["rust-analyzer"] = {
      cargo = { allFeatures = true },
      checkOnSave = false,
      procMacro = { enable = true },
    },
  },
})

vim.lsp.enable("ast_grep")
vim.lsp.enable("astro")
vim.lsp.enable("bashls")
vim.lsp.enable("clangd")
vim.lsp.enable("cssls")
vim.lsp.enable("jsonls")
vim.lsp.enable("lua_ls")
vim.lsp.enable("mlir_lsp_server")
vim.lsp.enable("pyright")
vim.lsp.enable("racket_langserver")
vim.lsp.enable("ruff")
vim.lsp.enable("rust_analyzer")
vim.lsp.enable("svelte")
vim.lsp.enable("tailwindcss")
vim.lsp.enable("ts_ls")
vim.lsp.enable("yamlls")
vim.lsp.enable("zls")
