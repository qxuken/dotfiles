return {
  {
    'f-person/auto-dark-mode.nvim',
    opts = true,
  },
  {
    'Shatur/neovim-ayu',
    name = 'ayu',
    priority = 1000,
    config = function()
      require('ayu').setup {
        mirage = false, -- Set to `true` to use `mirage` variant instead of `dark` for dark background.
        terminal = false, -- Set to `false` to let terminal manage its own colors.
        overrides = {},
      }
      require('ayu').colorscheme()
    end,
  },
}
