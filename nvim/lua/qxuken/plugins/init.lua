return {
  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',
  --
  -- "gc" to comment visual regions/lines
  { 'numToStr/Comment.nvim', opts = {} },

  {
    'mbbill/undotree',
    keys = {
      { '<leader>u', '<cmd>UndotreeToggle<cr>', desc = '[UndoTree] Toggle' },
    },
  },

  -- Effortlessly open the URL under the cursor
  {
    'sontungexpt/url-open',
    branch = 'mini',
    cmd = 'URLOpenUnderCursor',
    keys = {
      { 'gx', '<cmd>URLOpenUnderCursor<cr>', desc = '[Link] Go to' },
    },
    config = function()
      local status_ok, url_open = pcall(require, 'url-open')
      if not status_ok then
        return
      end
      url_open.setup {}
    end,
  },

  {
    'laytan/cloak.nvim',
    opts = {
      cloak_character = vim.g.have_nerd_font and '🔑' or '*',
      patterns = {
        {
          file_pattern = '.env',
          cloak_pattern = '=.+',
          replace = nil,
        },
        {
          file_pattern = 'vault.yml',
          cloak_pattern = ':.+',
          replace = nil,
        },
      },
    },
  },

  {
    'marcussimonsen/let-it-snow.nvim',
    cmd = 'LetItSnow',
    opts = {
      delay = 500,
    },
  },
}
