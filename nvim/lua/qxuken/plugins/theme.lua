return {
  {
    'f-person/auto-dark-mode.nvim',
    opts = true,
  },
  {
    'catppuccin/nvim',
    name = 'catppuccin',
    priority = 1000,
    config = function()
      require('catppuccin').setup {
        transparent_background = false,
        show_end_of_buffer = true,
        integrations = {
          blink_cmp = true,
          diffview = true,
          fidget = true,
          harpoon = true,
          mason = true,
          neotest = true,
          notify = true,
          snacks = {
            enabled = true,
          },
          which_key = true,
          render_markdown = true,
        },
        custom_highlights = function(colors)
          return {
            FloatBorder = { bg = colors.mantle, fg = colors.blue },
            NormalFloat = { bg = colors.mantle },
            BlinkCmpMenu = { bg = colors.mantle },
            BlinkCmpMenuBorder = { bg = colors.mantle, fg = colors.blue },
            BlinkCmpDoc = { bg = colors.mantle, fg = colors.blue },
            BlinkCmpDocBorder = { bg = colors.mantle, fg = colors.blue },
            BlinkCmpDocSeparator = { bg = colors.mantle, fg = colors.lavender },
          }
        end,
      }
      vim.cmd 'colorscheme catppuccin'
    end,
  },
}
