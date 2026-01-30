vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.o.termguicolors = true

local mason_servers = {
  "asm_lsp",
  "ast_grep",
  "astro",
  "bashls",
  "cssls",
  "jsonls",
  "lua_ls",
  "pyright",
  "ruff",
  "svelte",
  "tailwindcss",
  "ts_ls",
  "yamlls",
  "zls",
}

vim.g.lsp_servers = {
  "clangd",
  "rust_analyzer",
  "zls",
  "pyright",
  "ruff",
  "ts_ls",
  "tailwindcss",
  "cssls",
  "bashls",
  "jsonls",
  "yamlls",
  "lua_ls",
  "ast_grep",
  "astro",
  "svelte",
  "mlir_lsp_server",
  "asm_lsp",
}

-- lazy.nvim bootstrap
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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
    opts = {
      ensure_installed = {
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
      },
      highlight = { enable = true },
      indent = { enable = false },
    },
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
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = mason_servers,
    },
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
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
    "neovim/nvim-lspconfig",
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
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, o)
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, o)
        end,
      })

      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=never",
          "--completion-style=detailed",
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

      local servers = vim.g.lsp_servers or {
        "clangd",
        "rust_analyzer",
        "zls",
        "pyright",
        "ruff",
        "ts_ls",
        "tailwindcss",
        "cssls",
        "bashls",
        "jsonls",
        "yamlls",
        "lua_ls",
        "ast_grep",
        "astro",
        "svelte",
        "mlir_lsp_server",
        "asm_lsp",
      }

      for _, server in ipairs(servers) do
        vim.lsp.enable(server)
      end
    end,
  },
})

vim.filetype.add({
  extension = {
    ll = "llvm",
    mlir = "mlir",
  },
})

-- Core options
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.updatetime = 200
vim.o.wrap = false
vim.o.clipboard = "unnamedplus"
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.softtabstop = 2
vim.o.expandtab = false
vim.o.smarttab = true
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.cursorline = true
