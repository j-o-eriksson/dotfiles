-- All keymaps. Required at the end of init.lua, once the plugins they call are set up.

local map = vim.keymap.set
local builtin = require('telescope.builtin')
local gitsigns = require('gitsigns')
local files = require('mini.files')

map('n', '<Esc>', '<Cmd>nohlsearch<CR>')
map('i', '<Tab>', function()
  if vim.snippet.active({ direction = 1 }) then
    return '<Cmd>lua vim.snippet.jump(1)<CR>'
  end
  return '<Esc>'
end, { expr = true, desc = 'Escape, or next snippet placeholder' })
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
map('x', '<leader>y', '"+y', { desc = 'Yank to clipboard' })
map('n', '<leader>Y', '"+Y', { desc = 'Yank line to clipboard' })
map('x', 'J', ":m '>+1<CR>gv=gv", { desc = 'Move selection down' })
map('x', 'K', ":m '<-2<CR>gv=gv", { desc = 'Move selection up' })
map('n', '<C-h>', '<C-w>h', { desc = 'Focus left window' })
map('n', '<C-j>', '<C-w>j', { desc = 'Focus lower window' })
map('n', '<C-k>', '<C-w>k', { desc = 'Focus upper window' })
map('n', '<C-l>', '<C-w>l', { desc = 'Focus right window' })
map({ 'n', 'x', 'o' }, '<leader>jw', function()
  require('flash').jump()
end, { desc = 'Flash' })
map({ 'n', 'x' }, '<leader>f', function()
  require('conform').format({ async = true })
end, { desc = 'Format' })
map('n', '<C-t>', '<Cmd>Floaterminal<CR>', { desc = 'Toggle floating terminal' })
map('t', '<C-t>', function()
  vim.cmd.stopinsert()
  vim.schedule(function()
    vim.cmd('Floaterminal')
  end)
end, { desc = 'Toggle floating terminal' })

map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostics to location list' })
map('n', '<leader>dt', function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = 'Toggle diagnostics' })
map('n', '<leader>u', '<Cmd>Undotree<CR>', { desc = 'Toggle undo tree' })

-- Completion: <C-n>/<C-p> move and <C-y> accepts, as built in.
map('i', '<C-Space>', vim.lsp.completion.get, { desc = 'Show completion' })
map('i', '<C-k>', vim.lsp.buf.signature_help, { desc = 'Signature help' })

map('n', '<leader>sh', builtin.help_tags, { desc = 'Search help' })
map('n', '<leader>sk', builtin.keymaps, { desc = 'Search keymaps' })
map('n', '<leader>sf', builtin.find_files, { desc = 'Search files' })
map('n', '<leader>ss', builtin.builtin, { desc = 'Search pickers' })
map('n', '<leader>sw', builtin.grep_string, { desc = 'Search word under cursor' })
map('n', '<leader>sg', builtin.live_grep, { desc = 'Search by grep' })
map('n', '<leader>sd', builtin.diagnostics, { desc = 'Search diagnostics' })
map('n', '<leader>sr', builtin.resume, { desc = 'Resume last search' })
map('n', '<leader>s.', builtin.oldfiles, { desc = 'Search recent files' })
map('n', '<leader><leader>', builtin.buffers, { desc = 'Search buffers' })
map('n', '<leader>/', function()
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown({
    winblend = 10,
    previewer = false,
  }))
end, { desc = 'Fuzzy search in buffer' })
map('n', '<leader>s/', function()
  builtin.live_grep({ grep_open_files = true, prompt_title = 'Live Grep in Open Files' })
end, { desc = 'Search in open files' })
map('n', '<leader>sn', function()
  builtin.find_files({ cwd = vim.fn.stdpath('config') })
end, { desc = 'Search Neovim config' })

map('n', '\\', function()
  local file = vim.api.nvim_buf_get_name(0)
  files.open(vim.uv.fs_stat(file) and file or nil)
end, { desc = 'File explorer' })
vim.api.nvim_create_autocmd('User', {
  pattern = 'MiniFilesBufferCreate',
  callback = function(ev)
    map('n', '\\', files.close, { buffer = ev.data.buf_id, desc = 'Close file explorer' })
  end,
})

map('n', ']c', function()
  if vim.wo.diff then
    vim.cmd.normal({ ']c', bang = true })
  else
    gitsigns.nav_hunk('next')
  end
end, { desc = 'Next git change' })
map('n', '[c', function()
  if vim.wo.diff then
    vim.cmd.normal({ '[c', bang = true })
  else
    gitsigns.nav_hunk('prev')
  end
end, { desc = 'Previous git change' })
map('v', '<leader>hs', function()
  gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
end, { desc = 'Stage selected lines' })
map('v', '<leader>hr', function()
  gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
end, { desc = 'Reset selected lines' })
map('n', '<leader>hs', gitsigns.stage_hunk, { desc = 'Stage hunk' })
map('n', '<leader>hr', gitsigns.reset_hunk, { desc = 'Reset hunk' })
map('n', '<leader>hS', gitsigns.stage_buffer, { desc = 'Stage buffer' })
map('n', '<leader>hu', gitsigns.stage_hunk, { desc = 'Undo stage hunk' })
map('n', '<leader>hR', gitsigns.reset_buffer, { desc = 'Reset buffer' })
map('n', '<leader>hp', gitsigns.preview_hunk, { desc = 'Preview hunk' })
map('n', '<leader>hb', gitsigns.blame_line, { desc = 'Blame line' })
map('n', '<leader>hd', gitsigns.diffthis, { desc = 'Diff against index' })
map('n', '<leader>hD', function()
  gitsigns.diffthis('@')
end, { desc = 'Diff against last commit' })
map('n', '<leader>tb', gitsigns.toggle_current_line_blame, { desc = 'Toggle line blame' })
map('n', '<leader>tD', gitsigns.preview_hunk_inline, { desc = 'Toggle deleted lines' })

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local function lsp_map(keys, func, desc, mode)
      map(mode or 'n', keys, func, { buffer = ev.buf, desc = 'LSP: ' .. desc })
    end
    lsp_map('gd', builtin.lsp_definitions, 'Definition')
    lsp_map('gr', builtin.lsp_references, 'References')
    lsp_map('gri', builtin.lsp_implementations, 'Implementation')
    lsp_map('grt', builtin.lsp_type_definitions, 'Type definition')
    lsp_map('grD', vim.lsp.buf.declaration, 'Declaration')
    lsp_map('<leader>ds', builtin.lsp_document_symbols, 'Document symbols')
    lsp_map('gW', builtin.lsp_dynamic_workspace_symbols, 'Workspace symbols')
    lsp_map('<leader>rn', vim.lsp.buf.rename, 'Rename')
    lsp_map('<leader>ca', vim.lsp.buf.code_action, 'Code action', { 'n', 'x' })
    lsp_map('<leader>th', function()
      vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }))
    end, 'Toggle inlay hints')
  end,
})
