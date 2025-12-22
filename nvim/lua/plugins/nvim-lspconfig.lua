return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPost", "BufNewFile" },
  dependencies = {
    "mason.nvim",
    "mason-lspconfig.nvim",
    "b0o/schemastore.nvim",
  },
  opts = {
    inlay_hints = { enabled = true },
  },
  config = function()
    vim.api.nvim_set_hl(0, "LspInlayHint", { link = "Comment" })

    -- LSP keymaps on attach
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
        end

        map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")
        map("n", "K", vim.lsp.buf.hover, "Hover")
        map("n", "gK", vim.lsp.buf.signature_help, "Signature Help")
        map("i", "<C-k>", vim.lsp.buf.signature_help, "Signature Help")
        map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")
        map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
        map("n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, "Format")

        if client and client.supports_method("textDocument/inlayHint") then
          vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
        end

        if client and client.name == "clangd" then
          map("n", "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", "Clangd Switch Source/Header")
          map("n", "<leader>cA", "<cmd>ClangdAST<cr>", "Clangd AST")
          map("n", "<leader>ct", "<cmd>ClangdTypeHierarchy<cr>", "Clangd Type Hierarchy")
          map("n", "<leader>cs", "<cmd>ClangdSymbolInfo<cr>", "Clangd Symbol Info")
          map("n", "<leader>cm", "<cmd>ClangdMemoryUsage<cr>", "Clangd Memory Usage")
        end
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
    vim.lsp.config("html", {})

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
      "html",
    })
  end,
}
