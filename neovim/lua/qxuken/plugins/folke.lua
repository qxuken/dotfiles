---@param conf? snacks.picker.Config
function with_picker_config(conf)
  local picker_config = {
    layout = {
      preset = 'vertical',
      fullscreen = true,
      -- layout = {
      --   width = 0.9,
      --   max_width = 130,
      --   height = 0.95,
      -- },
      -- preset = 'sidebar',
      -- layout = {
      --   width = 0.4,
      -- },
    },
    formatters = {
      file = {
        -- filename_first = true,
        truncate = vim.o.columns,
      },
    },
  }

  if conf ~= nil and not vim.tbl_isempty(conf) then
    return vim.tbl_extend('force', picker_config, conf)
  else
    return picker_config
  end
end

return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      bufdelete = { enabled = true },
      dim = {
        enabled = true,
        animate = {
          easing = 'outSine',
          duration = { step = 15, total = 250 },
        },
      },
      scope = { enabled = true },
      toggle = { enabled = true },
      animate = { fps = 144 },
      image = { enabled = true },
      explorer = { enabled = true },
      picker = {
        enabled = true,
      },
    },
    init = function()
      vim.api.nvim_create_autocmd('User', {
        pattern = 'VeryLazy',
        callback = function()
          Snacks.toggle.dim():map '<leader>d'
          Snacks.toggle.inlay_hints():map '<leader>cI'
        end,
      })
    end,
    keys = {
      {
        '<leader>bd',
        function()
          local s = require 'snacks'
          Snacks.bufdelete.delete()
        end,
        desc = '[Buffer] delete',
      },
      {
        '<leader>bo',
        function()
          Snacks.bufdelete.other()
        end,
        desc = '[Buffers] Delete Other',
      },
      {
        '<leader>bO',
        function()
          Snacks.bufdelete.other { force = true }
        end,
        desc = '[Buffers] Delete Other(Force)',
      },
      {
        '<leader>R',
        function()
          Snacks.rename.rename_file()
        end,
        desc = 'Rename File',
      },

      {
        '<leader>sp',
        function()
          Snacks.picker(with_picker_config())
        end,
        silent = true,
        desc = 'Open Search Picker',
      },
      {
        '<leader>sh',
        function()
          Snacks.picker.help(with_picker_config())
        end,
        silent = true,
        desc = 'Search Help',
      },
      {
        '<leader>f',
        function()
          Snacks.picker.files(with_picker_config())
        end,
        silent = true,
        desc = 'Search Files',
      },
      {
        '<leader>E',
        function()
          Snacks.picker.explorer()
        end,
        silent = true,
        desc = 'Search Explorer',
      },
      {
        '<leader>g',
        function()
          Snacks.picker.grep(with_picker_config())
        end,
        silent = true,
        desc = 'Search by Grep',
      },
      {
        '<leader>sg',
        function()
          local dir = string.match(vim.fn.expand '%:.:h', '(%w+)')
          Snacks.picker.grep(with_picker_config { cwd = dir })
        end,
        desc = 'Search by Grep Buffer Level One',
      },
      {
        '<leader>sG',
        function()
          local dir = vim.fn.expand '%:.:h'
          Snacks.picker.grep(with_picker_config { cwd = dir })
        end,
        desc = 'Search by Grep Buffer Dir',
      },
      {
        '<leader>sr',
        function()
          Snacks.picker.resume(with_picker_config())
        end,
        silent = true,
        desc = 'Search Resume',
      },
      {
        '<leader><leader>',
        function()
          Snacks.picker.buffers(with_picker_config())
        end,
        silent = true,
        desc = 'Find Buffers',
      },
      {
        '<leader>.',
        function()
          Snacks.picker.smart(with_picker_config())
        end,
        silent = true,
        desc = 'Smart find',
      },
      {
        '<leader>m',
        function()
          Snacks.picker.marks(with_picker_config())
        end,
        silent = true,
        desc = 'Search Marks',
      },
      {
        '<leader>/',
        function()
          Snacks.picker.lines(with_picker_config())
        end,
        silent = true,
        desc = 'Fuzzily Search Buffer',
      },
      {
        '<leader>sn',
        function()
          local dir = vim.fn.stdpath 'config'
          Snacks.picker.files(with_picker_config { cwd = dir })
        end,
        desc = 'Search Neovim files',
      },
    },
  },

  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    keys = {
      {
        '<leader>sT',
        function()
          Snacks.picker.todo_comments(with_picker_config())
        end,
        desc = '[TODO] Search All',
      },
      {
        '<leader>st',
        function()
          Snacks.picker.todo_comments(with_picker_config { keywords = { 'TODO', 'FIX', 'FIXME' } })
        end,
        desc = '[TODO] Search (TODO,FIX,FIXME) only',
      },
    },
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = {},
  },

  {
    'folke/persistence.nvim',
    event = 'BufReadPre', -- this will only start session saving when an actual file was opened
    config = true,
    keys = {
      {
        '<leader>wr',
        function()
          require('persistence').load()
        end,
        desc = 'Restore session',
      },
      {
        '<leader>wR',
        function()
          require('persistence').select()
        end,
        desc = 'Pick session',
      },
    },
  },

  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    keys = {
      {
        '<leader>?',
        function()
          require('which-key').show { global = false }
        end,
        desc = 'Buffer Local Keymaps (which-key)',
      },

      -- NOTE: Not realy for this plugin but why not)
      { '<leader>pp', '<cmd>Lazy<cr>', desc = '[Lazy] open' },
    },
    config = function()
      require('which-key').setup { preset = 'helix' }

      -- Document existing key chains
      require('which-key').add {
        { '<leader>b', group = 'Buffer/Blame' },
        { '<leader>c', group = 'Code' },
        { '<leader>d', group = 'Document' },
        { '<leader>s', group = 'Search' },
        { '<leader>t', group = 'Tabs' },
        { '<leader>w', group = 'Workspace' },
        { '<leader>h', group = 'Git hunks' },
        { '<leader>e', group = 'Harpoon', icon = '󱡀' },
        { '<leader>p', group = 'Plugins' },
        { '<leader>G', group = 'Debug' },
        { '<leader>y', group = 'Copy', icon = '󰆏' },
        { ']', group = 'Next' },
        { '[', group = 'Prev' },
        { 'z', group = 'Fold' },
      }
    end,
  },
  'folke/lazydev.nvim',
  'folke/neoconf.nvim',
}
