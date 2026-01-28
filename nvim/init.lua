vim.g.mapleader = " "
vim.g.maplocalleader = " "

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
      dofile(vim.fn.stdpath("config") .. "/colorscheme.lua")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "c", "cpp" },
      highlight = { enable = true },
      indent = { enable = false },
    },
  },
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      dofile(vim.fn.stdpath("config") .. "/fzf.lua")
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {},
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
  },
  {
	  "lewis6991/gitsigns.nvim",
	  config = function()
	    dofile(vim.fn.stdpath("config") .. "/git.lua")
	  end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      dofile(vim.fn.stdpath("config") .. "/lsp.lua")
    end,
  },
})

-- Core options
vim.o.termguicolors = true
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
vim.o.breakindent = true
