-- Leader key
vim.g.mapleader = " "

-- Disable animations
vim.g.snacks_animate = false

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Tabs & Indentation
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true

-- UI
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.cursorline = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.wrap = false
vim.opt.showmode = false

-- Splits
vim.opt.splitbelow = true
vim.opt.splitright = true

-- Undo persistence
vim.opt.undofile = true
vim.opt.undolevels = 10000

-- Clipboard
vim.opt.clipboard = "unnamedplus"

-- Misc
vim.opt.updatetime = 200
vim.opt.timeoutlen = 300
vim.opt.confirm = true
vim.opt.autoread = true
