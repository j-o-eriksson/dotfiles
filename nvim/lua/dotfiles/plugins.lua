-- Installs the plugins and sets them up. Language servers are in lsp.lua.

-- Build steps for plugins that need one. Registered before vim.pack.add() so they also run
-- for an install or update from the lockfile.
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    -- nvim-treesitter's queries only work with parsers that match them.
    if name == 'nvim-treesitter' and kind == 'update' then
      if not ev.data.active then
        vim.cmd.packadd('nvim-treesitter')
      end
      vim.cmd('TSUpdate')
    end
    local fzf = name == 'telescope-fzf-native.nvim' and kind ~= 'delete'
    if fzf and vim.fn.executable('make') == 1 then
      vim.system({ 'make' }, { cwd = ev.data.path }):wait()
    end
  end,
})

vim.pack.add({
  { src = 'https://github.com/catppuccin/nvim', name = 'catppuccin' },
  'https://github.com/nvim-mini/mini.nvim',
  {
    src = 'https://github.com/nvim-treesitter/nvim-treesitter',
    version = 'main',
  },
  'https://github.com/neovim/nvim-lspconfig',
  'https://github.com/mason-org/mason.nvim',
  'https://github.com/stevearc/conform.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
  'https://github.com/nvim-telescope/telescope.nvim',
  'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
  'https://github.com/nvim-telescope/telescope-ui-select.nvim',
  'https://github.com/lewis6991/gitsigns.nvim',
  'https://github.com/folke/flash.nvim',
})

vim.cmd.colorscheme('catppuccin')

require('mini.icons').setup()
-- Telescope takes its icons from nvim-web-devicons, which mini.icons stands in for.
require('mini.icons').mock_nvim_web_devicons()
require('mini.ai').setup({ n_lines = 500 })
require('mini.surround').setup()
require('mini.pairs').setup()
require('mini.files').setup()
require('mini.statusline').setup()
require('mini.statusline').section_location = function()
  return '%2l:%-2v'
end

require('telescope').setup({
  extensions = { ['ui-select'] = { require('telescope.themes').get_dropdown() } },
})
-- Only where it was compiled: without make, telescope keeps its own sorter.
pcall(require('telescope').load_extension, 'fzf')
require('telescope').load_extension('ui-select')

require('gitsigns').setup()
require('flash').setup()

-- Shipped with Neovim but not loaded by default: :Undotree and :DiffTool.
vim.cmd.packadd('nvim.undotree')
vim.cmd.packadd('nvim.difftool')

local parsers = {
  'bash', 'c', 'cmake', 'cpp', 'diff', 'dockerfile', 'gitignore', 'html', 'json', 'lua',
  'luadoc', 'make', 'markdown', 'markdown_inline', 'python', 'query', 'toml', 'vim', 'vimdoc',
  'yaml',
}
require('nvim-treesitter').install(parsers)
vim.api.nvim_create_autocmd('FileType', {
  callback = function(ev)
    if pcall(vim.treesitter.start, ev.buf) then
      vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})

require('conform').setup({
  -- From the project's venv: Python is formatted only while it's active.
  formatters_by_ft = { python = { 'isort', 'black' } },
  default_format_opts = { lsp_format = 'fallback' },
  format_on_save = function(buf)
    -- Not C/C++: without a .clang-format, clangd would restyle the whole file.
    if not vim.tbl_contains({ 'c', 'cpp' }, vim.bo[buf].filetype) then
      return { timeout_ms = 500 }
    end
  end,
  notify_on_error = false,
  notify_no_formatters = false,
})

-- Read by install/nvim-bootstrap.lua, which waits for these to be installed.
return { parsers = parsers }
