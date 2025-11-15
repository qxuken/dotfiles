local function is_git_project()
  return vim.fn.isdirectory '.git' ~= 0
end

return {
  {
    'sindrets/diffview.nvim',
    cond = is_git_project,
    keys = {
      { '<leader>bh', '<cmd>DiffviewFileHistory %<CR>', desc = '[GitDiff] History' },
      { '<leader>wd', '<cmd>DiffviewOpen<CR>', desc = '[GitDiff] Diff' },
      { '<leader>wm', '<cmd>DiffviewOpen master...HEAD<CR>', desc = '[GitDiff] Diff with main' },
    },
    opts = {},
  },
  {
    'NeogitOrg/neogit',
    cond = is_git_project,
    keys = {
      { '<leader>bg', '<cmd>Neogit<CR>', desc = '[Neogit] Open' },
      { '<leader>bl', '<cmd>NeogitLogCurrent<CR>', desc = '[Neogit] File log' },
      { '<leader>wc', '<cmd>NeogitCommit<CR>', desc = '[Neogit] Commit' },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'sindrets/diffview.nvim',
      'ibhagwan/fzf-lua',
    },
    config = true,
  },
  {
    'lewis6991/gitsigns.nvim',
    lazy = false,
    cond = is_git_project,
    keys = {
      { ']h', '<cmd>Gitsigns next_hunk<CR>', desc = '[Git] Next hunk' },
      { '[h', '<cmd>Gitsigns prev_hunk<CR>', desc = '[Git] Prev hunk' },
      { '<leader>hrr', '<cmd>Gitsigns reset_hunk<CR>', desc = 'Reset hunk' },
      { '<leader>hd', '<cmd>Gitsigns diffthis<CR>', desc = 'Diff' },
      { '<leader>bS', '<cmd>Gitsigns stage_buffer<cr>', desc = 'Stage buffer' },
      { '<leader>hs', '<cmd>Gitsigns stage_hunk<cr>', desc = 'Stage hunk' },
      { '<leader>hu', '<cmd>Gitsigns undo_stage_hunk<cr>', desc = 'Unstage hunk' },
      { '<leader>hv', '<cmd>Gitsigns select_hunk<cr>', desc = 'Select hunk' },
    },
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  {
    'FabijanZulj/blame.nvim',
    opts = {},
    cond = is_git_project,
    dependencies = {
      'folke/snacks.nvim',
    },
    init = function()
      vim.api.nvim_create_autocmd('User', {
        pattern = 'VeryLazy',
        callback = function()
          Snacks.toggle
            .new({
              id = 'blame_virtual',
              name = '[GitBlame] Virtual',
              get = function()
                local blame = require 'blame'
                return blame.is_open() or false
              end,
              set = function()
                return vim.cmd 'BlameToggle virtual'
              end,
            })
            :map '<leader>bv'
          Snacks.toggle
            .new({
              id = 'blame_window',
              name = '[GitBlame] Window',
              get = function()
                local blame = require 'blame'
                return blame.is_open() or false
              end,
              set = function()
                return vim.cmd 'BlameToggle window'
              end,
            })
            :map '<leader>bw'
        end,
      })
    end,
  },
}
