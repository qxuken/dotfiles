return {
  {
    'saghen/blink.cmp',
    event = 'InsertEnter',
    version = 'v0.*',
    build = 'cargo build --release',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          if vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp CC=gcc'
        end)(),
        keys = {
          {
            '<C-L>',
            function()
              local ls = require 'luasnip'
              if ls.expand_or_locally_jumpable() then
                ls.expand_or_jump()
              end
            end,
            silent = true,
            mode = { 'i', 's' },
          },
          {
            '<C-K>',
            function()
              local ls = require 'luasnip'
              if ls.locally_jumpable(-1) then
                ls.jump(-1)
              end
            end,
            silent = true,
            mode = { 'i', 's' },
          },
        },
        dependencies = {
          {
            'rafamadriz/friendly-snippets',
            config = function()
              require('luasnip.loaders.from_vscode').lazy_load()
            end,
          },
        },
      },
      'folke/lazydev.nvim',
      -- Intresting plugin but leave it commented for better days
      -- {
      --   'Kaiser-Yang/blink-cmp-dictionary',
      --   dependencies = { 'nvim-lua/plenary.nvim' },
      -- },
    },
    opts = {
      snippets = {
        expand = function(snippet)
          require('luasnip').lsp_expand(snippet)
        end,
        active = function(filter)
          if filter and filter.direction then
            return require('luasnip').jumpable(filter.direction)
          end
          return require('luasnip').in_snippet()
        end,
        jump = function(direction)
          require('luasnip').jump(direction)
        end,
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer', 'lazydev' },
        providers = {
          lsp = {
            async = true,
          },
          buffer = {
            opts = {
              get_bufnrs = function()
                return vim.tbl_filter(function(bufnr)
                  return vim.bo[bufnr].buftype == ''
                end, vim.api.nvim_list_bufs())
              end,
            },
          },
          lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink' },
        },
      },
      completion = {
        menu = { border = 'rounded' },
        accept = {
          auto_brackets = {
            enabled = false,
          },
        },
        documentation = {
          window = { border = 'rounded' },
          auto_show = true,
          auto_show_delay_ms = 200,
        },
      },
      -- In favor of ray-x/lsp_signature.nvim
      signature = { enabled = false, window = { border = 'rounded' } },
    },
  },

  {
    'danymat/neogen',
    config = { snippet_engine = 'luasnip' },
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
      },
    },
  },
}
