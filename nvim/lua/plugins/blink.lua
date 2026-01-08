return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    opts = {
      keymap = { preset = "enter",
                 ["<C-space>"] = { "show" },
      },
      appearance = {
        nerd_font_variant = "mono",
      },
      completion = {
        menu = {
          auto_show = false
        },
        list = {
          selection = {
            preselect = false,
            auto_insert = false
          }
        },
        ghost_text = {
          enabled = true
        }
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer"},
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },
      signature = {
        enabled = true
      }
    },
  },
}
