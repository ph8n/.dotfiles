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
    name = "github-theme",
    lazy = false,
    priority = 1000,
    config = function()
      require("github-theme").setup({
        options = {
          transparent = true,
          darken = {
            floats = false,
            sidebars = { enable = false },
          },
        },
      })

      local function apply_snacks_transparency()
        local groups = {
          "SnacksNormal",
          "SnacksNormalNC",
          "SnacksInputNormal",
          "SnacksInputBorder",
          "SnacksInputTitle",
        }
        for _, area in ipairs({ "", "Box", "Input", "List", "Preview" }) do
          for _, part in ipairs({ "", "Border", "Title", "Footer" }) do
            groups[#groups + 1] = "SnacksPicker" .. area .. part
          end
        end

        for _, group in ipairs(groups) do
          local highlight = vim.api.nvim_get_hl(0, { name = group, link = false })
          if next(highlight) then
            highlight.bg = "NONE"
            vim.api.nvim_set_hl(0, group, highlight)
          end
        end
      end

      local group = vim.api.nvim_create_augroup("github_theme_snacks", { clear = true })
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = group,
        pattern = "github_dark_high_contrast",
        callback = apply_snacks_transparency,
      })
      vim.cmd.colorscheme("github_dark_high_contrast")
      apply_snacks_transparency()
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
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })
      vim.lsp.config("lua_ls", {
        settings = { Lua = { telemetry = { enable = false } } },
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
          lsp_map("<leader>d", function() require("snacks.picker").diagnostics() end, "Diagnostics")
          lsp_map("<leader>cf", function() vim.lsp.buf.format({ bufnr = args.buf }) end, "Format buffer")
          lsp_map("<leader>ui", function()
            vim.lsp.inlay_hint.enable(
              not vim.lsp.inlay_hint.is_enabled({ bufnr = args.buf }),
              { bufnr = args.buf }
            )
          end, "Toggle inlay hints")
        end,
      })
    end,
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {},
  },
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    dependencies = { "rafamadriz/friendly-snippets" },
    opts = { signature = { enabled = true } },
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
      { "<leader>e", function() Snacks.explorer() end, desc = "File explorer" },
      { "<leader>f", function() Snacks.picker.files() end, desc = "Find files" },
      { "<leader>/", function() Snacks.picker.grep() end, desc = "Live grep" },
      { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
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

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
  callback = function(args)
    pcall(vim.treesitter.start, args.buf)
  end,
})
