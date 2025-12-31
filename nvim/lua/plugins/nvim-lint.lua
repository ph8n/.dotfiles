return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPost", "BufNewFile", "BufWritePost" }, -- add BufWritePost for consistency
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      lua = { "luacheck" },
      python = { "ruff" },
      rust = { "clippy" },
      go = { "golangcilint" },
      c = { "clangtidy" },
      cpp = { "clangtidy" },
      objc = { "clangtidy" },
      objcpp = { "clangtidy" },
      json = { "jsonlint" },
      yaml = { "yamllint" },
      toml = { "tombi" },
      markdown = { "markdownlint" },
      tex = { "chktex" },
      plaintex = { "chktex" },
      typst = { "typos" },
      sh = { "shellcheck" },
      bash = { "shellcheck" },
      zsh = { "shellcheck" },
      html = { "htmlhint" },
    }

    local lint_augroup = vim.api.nvim_create_augroup("Lint", { clear = true })
    vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
      group = lint_augroup,
      callback = function()
        -- defer to avoid blocking UI
        vim.defer_fn(function()
          lint.try_lint(nil, { ignore_errors = true })
        end, 1)
      end,
    })

    vim.keymap.set("n", "<leader>cl", function()
      lint.try_lint(nil, { ignore_errors = true })
    end, { desc = "Lint" })
  end,
}
