vim.g.mapleader = " "
vim.g.maplocalleader = " "

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
vim.o.completeopt = "menu,menuone,noselect"
vim.o.redrawtime = 1500
vim.o.list = true
vim.o.listchars = "tab:▸ ,trail:·,nbsp:␣"

-- Core keymaps
vim.keymap.set("v", "<", "<gv", { silent = true })
vim.keymap.set("v", ">", ">gv", { silent = true })
vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>")
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("x", "<leader>p", '"_dP')

-- LSP servers
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
  "ruff",
  "rust_analyzer",
  "svelte",
  "tailwindcss",
  "ts_ls",
  "yamlls",
  "zls",
}

-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Plugins
require("lazy").setup({
  {
    "AlexvZyl/nordic.nvim",
    priority = 1000,
    config = function()
      local nordic = require("nordic")

      nordic.setup({
        bold_keywords = false,
        italic_comments = true,
        reduced_blue = true,
        bright_border = true,

        transparent = {
          bg = true,
          float = true,
        },

        on_highlight = function(highlights)
          highlights.Pmenu.bg = "#191D24"
          highlights.NormalFloat.bg = "#151515"
        end,
      })

      vim.cmd.colorscheme("nordic")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      local ts = require("nvim-treesitter")
      local parsers = {
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
      ts.install(parsers, { summary = false }):wait(30000)
      -- Enable treesitter highlighting for all filetypes
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "*",
        callback = function(args)
          local lang = args.match
          pcall(vim.treesitter.start, args.buf, lang)
        end,
      })
      vim.api.nvim_create_user_command("TSInstallAll", function()
        ts.install(parsers):wait(60000)
      end, { desc = "Install configured treesitter parsers" })
    end,
  },
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
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
    end,
  },
  {
    "stevearc/oil.nvim",
    opts = {},
    dependencies = { { "nvim-tree/nvim-web-devicons", opts = {} } },
    lazy = false,
    keys = {
      { "-", "<CMD>Oil<CR>", desc = "Open parent directory" },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    config = function()
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

          vim.keymap.set("n", "]h", gs.next_hunk, { buffer = bufnr })
          vim.keymap.set("n", "[h", gs.prev_hunk, { buffer = bufnr })

          vim.keymap.set("n", "<leader>g", gs.preview_hunk, { buffer = bufnr })
        end,
      })
    end,
  },
  {
    "saghen/blink.cmp",
    dependencies = "rafamadriz/friendly-snippets",
    version = "*",
    opts = {
      keymap = { preset = "default" },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
      },
      completion = {
        list = {
          selection = { preselect = false, auto_insert = true },
        },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
    },
    opts_extend = { "sources.default" },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "saghen/blink.cmp" },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local o = { buffer = ev.buf, silent = true }
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, o)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, o)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, o)
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, o)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, o)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, o)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, o)
          vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, o)
          vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, o)
          vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, o)
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
          "clangd",
          "--background-index",
          "--clang-tidy",
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
    end,
  },
})
