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

map("v", "<", "<gv", { silent = true, desc = "Indent left and keep selection" })
map("v", ">", ">gv", { silent = true, desc = "Indent right and keep selection" })
map("n", "<leader>h", function()
  vim.cmd.nohlsearch()
end, { desc = "Clear search highlight" })
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
  gh("neovim/nvim-lspconfig"),
}, { confirm = false })

vim.api.nvim_create_user_command("PackUpdate", function()
  vim.pack.update()
end, { desc = "Update vim.pack plugins" })

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

local treesitter_parsers = {
  "c",
  "cpp",
  "rust",
  "zig",
  "python",
  "javascript",
  "typescript",
  "tsx",
  "html",
  "css",
  "svelte",
  "astro",
  "llvm",
  "mlir",
  "json",
  "yaml",
  "toml",
  "asm",
  "csv",
}

local ok_treesitter, treesitter = pcall(require, "nvim-treesitter")
if ok_treesitter then
  pcall(function()
    treesitter.install(treesitter_parsers, { summary = false }):wait(30000)
  end)

  vim.api.nvim_create_autocmd("FileType", {
    group = augroup("axiom_treesitter", { clear = true }),
    callback = function(args)
      pcall(vim.treesitter.start, args.buf)
    end,
  })

  vim.api.nvim_create_user_command("TSInstallAll", function()
    treesitter.install(treesitter_parsers, { summary = false }):wait(60000)
  end, { desc = "Install configured treesitter parsers" })
end

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

require("oil").setup({})

map("n", "-", function()
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

    map("n", "]h", gs.next_hunk, { buffer = bufnr, desc = "Next git hunk" })
    map("n", "[h", gs.prev_hunk, { buffer = bufnr, desc = "Previous git hunk" })
    map("n", "<leader>g", gs.preview_hunk, { buffer = bufnr, desc = "Preview git hunk" })
  end,
})

local lsp_servers = {
  "ast_grep",
  "astro",
  "bashls",
  "clangd",
  "cssls",
  "jsonls",
  "lua_ls",
  "mlir_lsp_server",
  "pyright",
  "racket_langserver",
  "ruff",
  "rust_analyzer",
  "svelte",
  "tailwindcss",
  "ts_ls",
  "yamlls",
  "zls",
}

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
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end
  end,
})

vim.lsp.config("ast_grep", {
  cmd = { "ast-grep", "lsp" },
})

vim.lsp.config("astro", {
  cmd = { "astro-ls", "--stdio" },
})

vim.lsp.config("bashls", {
  cmd = { "bash-language-server", "start" },
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

vim.lsp.config("cssls", {
  cmd = { "vscode-css-language-server", "--stdio" },
})

vim.lsp.config("jsonls", {
  cmd = { "vscode-json-language-server", "--stdio" },
})

vim.lsp.config("lua_ls", {
  cmd = { "lua-language-server" },
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

vim.lsp.config("mlir_lsp_server", {
  cmd = { "mlir-lsp-server" },
})

vim.lsp.config("pyright", {
  cmd = { "pyright-langserver", "--stdio" },
})

vim.lsp.config("ruff", {
  cmd = { "ruff", "server" },
})

vim.lsp.config("rust_analyzer", {
  cmd = { "rust-analyzer" },
  settings = {
    ["rust-analyzer"] = {
      cargo = { allFeatures = true },
      checkOnSave = false,
      procMacro = { enable = true },
    },
  },
})

vim.lsp.config("svelte", {
  cmd = { "svelteserver", "--stdio" },
})

vim.lsp.config("tailwindcss", {
  cmd = { "tailwindcss-language-server", "--stdio" },
})

vim.lsp.config("ts_ls", {
  cmd = { "typescript-language-server", "--stdio" },
  init_options = { hostInfo = "neovim" },
})

vim.lsp.config("yamlls", {
  cmd = { "yaml-language-server", "--stdio" },
})

vim.lsp.config("zls", {
  cmd = { "zls" },
})

for _, server in ipairs(lsp_servers) do
  vim.lsp.enable(server)
end
