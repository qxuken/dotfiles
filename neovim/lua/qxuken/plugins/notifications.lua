return {
  {
    'j-hui/fidget.nvim',
    event = 'VeryLazy',
    dependencies = {
      {
        'rcarriga/nvim-notify',
        config = function()
          local notify = require 'notify'
          notify.setup { render = 'minimal', fps = 144 }
          vim.notify = notify
        end,
      },
    },
    opts = {
      notification = {
        override_vim_notify = true,
        window = {
          winblend = 0,
        },
      },
    },
  },
}
