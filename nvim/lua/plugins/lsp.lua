return {
  -- Schema store for JSON/YAML
  { "b0o/schemastore.nvim", lazy = true },

  -- Mason
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {},
  },

  -- Mason-lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "mason.nvim" },
    opts = {
      ensure_installed = {
        "clangd",
        "lua_ls",
        "rust_analyzer",
        "basedpyright",
        "ruff",
        "gopls",
        "zls",
        "jsonls",
        "yamlls",
        "taplo",
        "marksman",
        "texlab",
        "tinymist",
        "bashls",
        "svelte",
        "tailwindcss",
        "copilot",
      },
      automatic_installation = true,
    },
  },

  -- LSP Config
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "mason.nvim",
      "mason-lspconfig.nvim",
      "b0o/schemastore.nvim",
    },
    config = function()
      -- LSP keymaps on attach
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
          end

          map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
          map("n", "K", vim.lsp.buf.hover, "Hover")
          map("n", "gK", vim.lsp.buf.signature_help, "Signature Help")
          map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
          map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
          map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
        end,
      })

      -- Server configs
      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim", "Snacks" } },
          },
        },
      })

      vim.lsp.config("jsonls", {
        settings = {
          json = {
            schemas = require("schemastore").json.schemas(),
            validate = { enable = true },
          },
        },
      })

      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            schemaStore = { enable = false, url = "" },
            schemas = require("schemastore").yaml.schemas(),
          },
        },
      })

      vim.lsp.config("svelte", {})

      vim.lsp.config("tailwindcss", {})

      vim.lsp.config("copilot", {})

      -- Enable servers (clangd handled by clangd_extensions)
      vim.lsp.enable({
        "lua_ls",
        "basedpyright",
        "ruff",
        "rust_analyzer",
        "gopls",
        "zls",
        "jsonls",
        "yamlls",
        "taplo",
        "marksman",
        "texlab",
        "tinymist",
        "bashls",
        "svelte",
        "tailwindcss",
        "copilot",
      })
    end,
  },

  -- Clangd extensions
  {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp", "objcpp", "cuda", "proto" },
    dependencies = { "neovim/nvim-lspconfig" },
    config = function()
      require("clangd_extensions").setup({})
      vim.lsp.config("clangd", {
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
        },
      })
      vim.lsp.enable("clangd")
    end,
  },
}
