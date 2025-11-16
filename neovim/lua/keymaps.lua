local set = vim.keymap.set

set('n', '<leader>Q', '<cmd>qa<CR>', { desc = 'Quit vim' })
-- Fix for wsl
set('v', '<C-B>', '<C-V>', { desc = 'Visual block' })

-- Keybinds to make split navigation easier.
set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Diagnostic keymaps
set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous Diagnostic message' })
set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next Diagnostic message' })
-- replaced by fzf
set('n', '<C-e>', vim.diagnostic.open_float, { desc = 'Show diagnostic Error messages' })
-- set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic Quickfix list' })

-- Quickfix keymaps
set('n', '[q', '<cmd>cprev<CR>', { desc = 'Go to prev Quickfix item' })
set('n', ']q', '<cmd>cnext<CR>', { desc = 'Go to next Quickfix item' })

-- Tabs keymaps
set('n', '[t', '<cmd>tabp<CR>', { desc = 'Go to prev tab' })
set('n', ']t', '<cmd>tabn<CR>', { desc = 'Go to next tab' })
set('n', '<leader>tq', '<cmd>tabc<CR>', { desc = 'Close tab' })

-- Buffer keymaps
set('n', '[b', '<cmd>bprevious<CR>', { desc = 'Go to prev Buffer' })
set('n', ']b', '<cmd>bnext<CR>', { desc = 'Go to next Buffer' })
set('n', '<leader>bp', '<cmd>bprevious<CR>', { desc = 'Prev Buffer' })
set('n', '<leader>bn', '<cmd>bnext<CR>', { desc = 'Next Buffer' })

-- Convenient save
set({ 'i', 'v' }, '<C-s>', '<Esc><cmd>w<CR>')
set('n', '<C-s>', '<cmd>w<CR>')

-- Goto keymaps
set({ 'n', 'v' }, 'gh', '^', { desc = 'Go to start of the line' })
set({ 'n', 'v' }, 'gl', '$', { desc = 'Go to end of the line' })

-- Yank dirs and file path
set('n', '<leader>yp', function()
  vim.fn.setreg('+', vim.fn.expand '%:.')
end, { desc = 'Copy file path' })
set('n', '<leader>yP', function()
  vim.fn.setreg('+', vim.fn.expand '%:p:.')
end, { desc = 'Copy file full path' })
set('n', '<leader>yd', function()
  vim.fn.setreg('+', vim.fn.expand '%:.:h')
end, { desc = 'Copy directory path' })
set('n', '<leader>yD', function()
  vim.fn.setreg('+', vim.fn.expand '%:p:h')
end, { desc = 'Copy directory full path' })
set('n', '<leader>yn', function()
  vim.fn.setreg('+', vim.fn.expand '%:t')
end, { desc = 'Copy file name' })
set('n', '<leader>yN', function()
  vim.fn.setreg('+', vim.fn.expand '%:t:r')
end, { desc = 'Copy file name(without extension)' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Replaced with snacks from folke
-- set('n', '<leader>bd', function()
--   local current_buf = vim.fn.bufnr()
--   vim.cmd 'silent! bprevious'
--   vim.cmd('silent! bdelete' .. current_buf)
-- end, { desc = 'Buffer delete' })
-- set('n', '<leader>bo', function()
--   local current_buf = vim.fn.bufnr()
--   local current_win = vim.fn.win_getid()
--   local bufs = vim.fn.getbufinfo { buflisted = 1 }
--   for _, buf in ipairs(bufs) do
--     if buf.bufnr ~= current_buf then
--       vim.cmd('silent! bdelete ' .. buf.bufnr)
--     end
--   end
--   vim.fn.win_gotoid(current_win)
-- end, { silent = true, desc = 'Buffers delete Other' })
