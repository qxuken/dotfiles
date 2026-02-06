return {
  {
    'f-person/auto-dark-mode.nvim',
    opts = true,
  },
  {
    'rebelot/kanagawa.nvim',
    name = 'kanagawa',
    priority = 1000,
    config = function()
      require('kanagawa').setup {
        compile = true,
        undercurl = true,
        commentStyle = { italic = false },
        -- functionStyle = {},
        keywordStyle = { italic = true },
        statementStyle = { bold = false },
        -- typeStyle = {},
        transparent = false, -- do not set background color
        dimInactive = true, -- dim inactive window `:h hl-NormalNC`
        -- terminalColors = true, -- define vim.g.terminal_color_{0,17}
        -- colors = { -- add/modify theme and palette colors
        --   palette = {},
        --   theme = { wave = {}, lotus = {}, dragon = {}, all = {} },
        -- },
        -- overrides = function(colors) -- add/modify highlights
        --   return {}
        -- end,
        -- theme = 'wave', -- Load "wave" theme
        background = { -- map the value of 'background' option to a theme
          dark = 'dragon', -- "dragon" | "wave"
          light = 'lotus',
        },
      }
      vim.cmd 'colorscheme kanagawa'
    end,
  },
}
