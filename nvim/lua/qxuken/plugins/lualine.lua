return {
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('lualine').setup {
        options = {
          theme = 'catppuccin',
          component_separators = '',
          section_separators = { left = '', right = '' },
        },
        sections = {
          lualine_b = {
            {
              'filename',
              path = 1,
              shorting_target = 60,
            },
          },
          lualine_c = {
            '%=',
          },
        },
        extensions = { 'quickfix', 'oil', 'nvim-dap-ui', 'lazy', 'mason', 'fzf' },
      }
    end,
  },
}
