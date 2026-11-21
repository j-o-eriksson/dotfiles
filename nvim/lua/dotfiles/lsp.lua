-- Language servers: installed by Mason, configured on top of nvim-lspconfig.

-- By lspconfig name, with the Mason package that provides each.
local servers = {
  clangd = 'clangd',
  ty = 'ty',
  lua_ls = 'lua-language-server',
}
require('mason').setup()
local registry = require('mason-registry')
registry.refresh(function()
  for _, name in pairs(servers) do
    if not registry.is_installed(name) then
      registry.get_package(name):install()
    end
  end
end)

-- Knows the Neovim API, for editing this config.
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      runtime = { version = 'LuaJIT' },
      workspace = { library = { vim.env.VIMRUNTIME } },
    },
  },
})

-- A project with scripts/clangd.sh runs clangd through it (e.g. inside its build container).
-- Started in such a project, every file under it uses that project's clangd, nested
-- submodules included.
vim.lsp.config('clangd', {
  root_dir = function(bufnr, on_dir)
    local cwd = vim.fn.getcwd()
    local root = vim.fs.root(bufnr, vim.lsp.config.clangd.root_markers)
    -- A file of no project of its own, such as a system header clangd.sh copied to the host,
    -- belongs to the project that opened it.
    if
        vim.uv.fs_stat(cwd .. '/scripts/clangd.sh')
        and (vim.fs.relpath(cwd, vim.api.nvim_buf_get_name(bufnr)) or not root)
    then
      return on_dir(cwd)
    end
    on_dir(root)
  end,
  cmd = function(dispatchers, config)
    local wrapper = config.root_dir and config.root_dir .. '/scripts/clangd.sh'
    local cmd = (wrapper and vim.uv.fs_stat(wrapper)) and { wrapper } or { 'clangd' }
    return vim.lsp.rpc.start(cmd, dispatchers)
  end,
})

vim.lsp.enable(vim.tbl_keys(servers))
vim.diagnostic.config({ virtual_text = true, severity_sort = true })

local word_chars = {}
for char in ('abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_'):gmatch('.') do
  table.insert(word_chars, char)
end
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    local provider = client.server_capabilities.completionProvider
    if provider then
      -- Servers only trigger after characters such as "." or "::"; this also opens the
      -- popup while typing a name. 'autocomplete' can't: the LSP 'omnifunc' is async.
      local chars = provider.triggerCharacters or {}
      provider.triggerCharacters = vim.list.unique(vim.list_extend(chars, word_chars))
      vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
    end

    -- Highlights every use of the symbol under the cursor once it rests ('updatetime').
    if client:supports_method('textDocument/documentHighlight') then
      local group = vim.api.nvim_create_augroup('dotfiles.highlight.' .. ev.buf, {})
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        group = group,
        buffer = ev.buf,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        group = group,
        buffer = ev.buf,
        callback = vim.lsp.buf.clear_references,
      })
      vim.api.nvim_create_autocmd('LspDetach', {
        group = group,
        buffer = ev.buf,
        callback = function()
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds({ group = group, buffer = ev.buf })
        end,
      })
    end
  end,
})

-- Read by install/nvim-bootstrap.lua, which waits for these to be installed.
return { servers = servers }
