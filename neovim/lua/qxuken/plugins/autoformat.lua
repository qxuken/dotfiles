return {
  {
    'stevearc/conform.nvim',
    lazy = false,
    keys = {
      {
        '<leader>cf',
        function()
          require('conform').format { async = true, lsp_fallback = true }
        end,
        mode = '',
        desc = 'Format buffer',
      },
      {
        '<leader>pc',
        '<cmd>ConformInfo<cr>',
        mode = '',
        desc = '[Conform] Info',
      },
    },
    opts = {
      notify_on_error = false,
      format_after_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        local disable_filetypes = { c = true, cpp = true, html = true }
        return {
          timeout_ms = 7000,
          lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
        }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        go = { 'goimports', 'gofmt' },
        javascript = { 'prettierd', 'eslint_d' },
        typescript = { 'prettierd', 'eslint_d' },
        css = { 'prettierd', 'prettier' },
        templ = { 'templ' },
        sql = { 'sqlfmt', stop_after_first = true },
      },
    },
    init = function()
      vim.api.nvim_create_autocmd('User', {
        pattern = 'VeryLazy',
        callback = function()
          Snacks.toggle
            .new({
              id = 'global_autoformat',
              name = 'Global autoformat',
              get = function()
                return not vim.g.disable_autoformat
              end,
              set = function()
                vim.g.disable_autoformat = not vim.g.disable_autoformat
              end,
            })
            :map '<leader>wf'

          Snacks.toggle
            .new({
              id = 'buffer_autoformat',
              name = 'Buffer autoformat',
              get = function()
                return not vim.b.disable_autoformat
              end,
              set = function()
                vim.b.disable_autoformat = not vim.b.disable_autoformat
              end,
            })
            :map '<leader>bf'
        end,
      })
    end,
  },

  {
    'windwp/nvim-ts-autotag',
    opts = {
      aliases = {
        ['templ'] = 'html',
      },
    },
  },
}
