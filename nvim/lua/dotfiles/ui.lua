-- UI: the command line in a box mid-screen, a notice while a macro records, a floating
-- terminal, and a brief highlight of yanked and pasted text.

local ui2 = require('vim._core.ui2')
-- Experimental: messages and the cmdline without "Press ENTER" prompts. With no command-line
-- row ('cmdheight' 0), messages go to a float that fades.
ui2.enable({ msg = { targets = 'msg' } })

-- ui2 shows the command line in a window below the statusline, and sets 'cmdheight' to make
-- room for it while open. Wrapping its show handler moves that window to a box mid-screen and
-- takes the row back before the screen redraws. Patches ui2's internals, so a nightly update
-- can break it.
local cmdline = require('vim._core.ui2.cmdline')
local cmdline_show = cmdline.cmdline_show
cmdline.cmdline_show = function(...)
  cmdline_show(...)
  local width = math.floor(vim.o.columns * 0.6)
  vim.api.nvim_win_set_config(ui2.wins.cmd, {
    relative = 'editor',
    row = math.floor(vim.o.lines / 2) - 2,
    col = math.floor((vim.o.columns - width) / 2),
    width = width,
    border = 'rounded',
  })
  if vim.o.cmdheight ~= 0 then
    vim._with({ noautocmd = true, o = { splitkeep = 'screen' } }, function()
      vim.o.cmdheight = 0
    end)
  end
end

-- 'cmdheight' 0 leaves no row for the usual "recording @q", so it gets a box of its own.
local recording = -1
vim.api.nvim_create_autocmd('RecordingEnter', {
  callback = function()
    local text = 'recording @' .. vim.fn.reg_recording()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, { text })
    recording = vim.api.nvim_open_win(buf, false, {
      relative = 'editor',
      anchor = 'SE',
      row = vim.o.lines - 1,
      col = vim.o.columns,
      width = #text,
      height = 1,
      style = 'minimal',
      border = 'none',
      focusable = false,
    })
  end,
})
vim.api.nvim_create_autocmd('RecordingLeave', {
  callback = function()
    if vim.api.nvim_win_is_valid(recording) then
      vim.api.nvim_win_close(recording, true)
    end
  end,
})

-- Floating terminal; hiding it keeps the shell running.
local term = { buf = -1, win = -1 }
vim.api.nvim_create_user_command('Floaterminal', function()
  if vim.api.nvim_win_is_valid(term.win) then
    return vim.api.nvim_win_hide(term.win)
  end
  if not vim.api.nvim_buf_is_valid(term.buf) then
    term.buf = vim.api.nvim_create_buf(false, true)
  end
  local width, height = math.floor(vim.o.columns * 0.8), math.floor(vim.o.lines * 0.8)
  term.win = vim.api.nvim_open_win(term.buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = 'minimal',
  })
  if vim.bo[term.buf].buftype ~= 'terminal' then
    vim.cmd.terminal('zsh')
  end
  vim.cmd.startinsert()
end, { desc = 'Toggle floating terminal' })

vim.api.nvim_create_autocmd({ 'TextYankPost', 'TextPutPost' }, {
  callback = function()
    vim.hl.hl_op()
  end,
})
