return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local lint = require("lint")

    local by_ft = {}
    local function add(filetypes, linters)
      for _, filetype in ipairs(filetypes) do
        by_ft[filetype] = linters
      end
    end

    add({ "javascript", "javascriptreact", "typescript", "typescriptreact", "svelte" }, { "eslint_d" })
    add({ "python" }, { "ruff" })
    add({ "lua" }, { "luacheck" })
    add({ "c", "cpp", "objc", "objcpp" }, { "clangtidy" })
    add({ "rust" }, { "clippy" })
    add({ "go" }, { "golangcilint" })
    add({ "zig" }, { "zig" })
    add({ "json" }, { "jsonlint" })
    add({ "yaml" }, { "yamllint" })
    add({ "toml" }, { "tombi" })
    add({ "markdown" }, { "markdownlint" })
    add({ "tex", "plaintex" }, { "chktex" })
    add({ "typst" }, { "typos" })
    add({ "sh", "bash", "zsh" }, { "shellcheck" })
    add({ "html" }, { "htmlhint" })

    lint.linters_by_ft = by_ft

    local lint_augroup = vim.api.nvim_create_augroup("Lint", { clear = true })
    vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        lint.try_lint()
      end,
    })

    vim.keymap.set("n", "<leader>cl", function()
      lint.try_lint()
    end, { desc = "Lint" })
  end,
}
