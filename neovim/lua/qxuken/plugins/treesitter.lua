return {
  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    lazy = false,
    branch = 'main',
    opts = {},
    config = function(_, opts)
      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter').setup(opts)
    end,
  },

  {
    'ckolkey/ts-node-action',
    keys = {
      { '<leader>ct', '<CMD>NodeAction<CR>', desc = '[TreeSitter] Node Action' },
    },
    opts = {},
  },
}
