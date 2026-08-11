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
    "phongndo/origin.nvim",
    lazy = false,
    priority = 1000,
    opts = { transparent = true },
    config = function(_, opts)
      require("origin").setup(opts)
      vim.cmd.colorscheme("origin")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    event = { "BufReadPost", "BufNewFile" },
    build = ":TSUpdate",
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "saghen/blink.cmp" },
    config = function()
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            telemetry = { enable = false },
            workspace = {
              checkThirdParty = false,
              library = { vim.env.VIMRUNTIME },
            },
          },
        },
      })
      vim.lsp.config("ts_ls", {
        init_options = {
          tsserver = {
            path = vim.fn.expand(
              "~/.local/share/mise/installs/npm-typescript/latest/lib/node_modules/typescript/lib/tsserver.js"
            ),
          },
        },
      })
      vim.lsp.enable({
        "bashls",
        "clangd",
        "cssls",
        "denols",
        "eslint",
        "html",
        "jsonls",
        "lua_ls",
        "marksman",
        "ruff",
        "rust_analyzer",
        "tailwindcss",
        "ts_ls",
        "ty",
        "yamlls",
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
        callback = function(args)
          local function lsp_map(lhs, rhs, desc)
            map("n", lhs, rhs, { buffer = args.buf, desc = desc })
          end

          lsp_map("gd", function() require("snacks.picker").lsp_definitions() end, "Goto definition")
          lsp_map("<leader>d", vim.diagnostic.open_float, "Line diagnostics")
          lsp_map("<leader>D", function() require("snacks.picker").diagnostics() end, "All diagnostics")
          lsp_map("<leader>cf", vim.lsp.buf.format, "Format buffer")
          lsp_map("<leader>ui", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }), { bufnr = 0 })
          end, "Toggle inlay hints")
        end,
      })
    end,
  },
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = {
      completion = { list = { selection = { preselect = false, auto_insert = false } } },
      signature = { enabled = true },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = {
      options = {
        theme = "auto",
        globalstatus = true,
        component_separators = "",
        section_separators = "",
      },
      sections = {
        lualine_x = { "encoding", "filetype" },
      },
    },
  },
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>e", function() require("snacks").explorer() end, desc = "File explorer" },
      { "<leader>f", function() require("snacks").picker.files() end, desc = "Find files" },
      { "<leader>/", function() require("snacks").picker.grep() end, desc = "Live grep" },
      { "<leader>,", function() require("snacks").picker.buffers() end, desc = "Buffers" },
    },
    opts = {
      explorer = { enabled = true },
      picker = {
        enabled = true,
        ui_select = true,
        layout = {
          preset = "default",
          layout = { backdrop = false },
        },
        sources = {
          files = { hidden = true },
          explorer = { hidden = true },
        },
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
  install = { colorscheme = { "origin" } },
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

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})
