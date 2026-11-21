-- Run by nvim.sh after init.lua, which installs the plugins and starts installing parsers and
-- language servers in the background: waits for those, then exits non-zero if any failed.

require('nvim-treesitter').install(require('dotfiles.plugins').parsers):wait(600000)

local registry = require('mason-registry')
local servers = vim.tbl_values(require('dotfiles.lsp').servers)
local done = vim.wait(600000, function()
  for _, name in ipairs(servers) do
    if not registry.is_installed(name) or registry.get_package(name):is_installing() then
      return false
    end
  end
  return true
end, 1000)

vim.cmd(done and 'qa' or 'cq')
