-- Required first from init.lua: the leader has to be set before any keymap uses it.

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.o.list = true
vim.o.listchars = 'tab:» ,trail:·,nbsp:␣'
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true
vim.o.winborder = 'rounded'
-- No row reserved for the command line; ui.lua shows it and messages in floats instead.
vim.o.cmdheight = 0
-- `gr` (references) starts like the built-in gr… keys, so it waits this long for more.
vim.o.timeoutlen = 300
-- How long the cursor rests before lsp.lua highlights the symbol under it.
vim.o.updatetime = 250
-- LSP completion pops up as you type, set up by the LspAttach handler in lsp.lua.
vim.o.completeopt = 'menuone,noselect,popup,fuzzy'
