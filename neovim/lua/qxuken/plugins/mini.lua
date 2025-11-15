return {
  {
    'echasnovski/mini.nvim',
    version = false,
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - Visually select Around )paren
      --  - yinq - Yank Inside Next 'quote
      --  - ci'  - Change Inside 'quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - gaiw) - Surround Add Inner Word )Paren
      -- - gd'   - Surround Delete 'quotes
      -- - gr)'  - Surround Replace ) '
      require('mini.surround').setup {
        mappings = {
          add = 'gsa',
          delete = 'gsd',
          replace = 'gsr',
          find = 'gsf',
          find_left = 'gsF',
          highlight = 'gsh',
          update_n_lines = 'gsn',
        },
      }

      require('mini.align').setup()

      require('mini.pairs').setup()

      require('mini.jump').setup()

      require('mini.move').setup()

      -- local statusline = require 'mini.statusline'
      -- statusline.setup { use_icons = vim.g.have_nerd_font }
      -- ---@diagnostic disable-next-line: duplicate-set-field
      -- statusline.section_location = function()
      --   return '%2l:%-2v'
      -- end
    end,
  },
}
