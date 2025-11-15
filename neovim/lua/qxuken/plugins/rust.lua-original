local function capitalize_and_concat(str)
  local parts = {}
  for part in string.gmatch(str, '([^_]+)') do
    table.insert(parts, part)
  end

  for i, part in ipairs(parts) do
    parts[i] = string.upper(string.sub(part, 1, 1)) .. string.sub(part, 2)
  end

  return table.concat(parts, ' ')
end

vim.g.rustaceanvim = {
  server = {
    on_attach = function(client, bufnr)
      client.config.capabilities = require('blink.cmp').get_lsp_capabilities(client.config.capabilities)

      vim.keymap.set('n', '<leader>Gd', function()
        vim.cmd.RustLsp 'debuggables'
      end, { desc = '[RustLsp] Debug' })
      vim.keymap.set('n', '<leader>GD', function()
        vim.cmd.RustLsp { 'debuggables', bang = true }
      end, { desc = '[RustLsp] Debug Previous target' })
      vim.keymap.set('n', '<leader>Gh', function()
        vim.cmd.RustLsp 'debuggables'
      end, {
        desc = '[RustLsp] Run',
      })
      vim.keymap.set('n', '<leader>GH', function()
        vim.cmd.RustLsp { 'debuggables', bang = true }
      end, {
        desc = '[RustLsp] Run Previous target',
      })
    end,
  },
}

return {
  {
    'mrcjkb/rustaceanvim',
    version = '^5',
    ft = 'rs',
  },
  {
    'saecki/crates.nvim',
    tag = 'stable',
    ft = 'toml',
    dependencies = {
      'saghen/blink.cmp',
    },
    config = function()
      require('crates').setup {
        completion = {
          crates = {
            enabled = true,
            max_results = 8,
            min_chars = 3,
          },
        },
        popup = {
          border = 'rounded',
        },
        lsp = {
          enabled = true,
          on_attach = function(client, bufnr)
            client.config.capabilities = require('blink.cmp').get_lsp_capabilities(client.config.capabilities)
          end,
          actions = true,
          completion = true,
          hover = true,
        },
      }

      vim.api.nvim_create_autocmd('BufRead', {
        group = vim.api.nvim_create_augroup('CmpSourceCargo', { clear = true }),
        pattern = 'Cargo.toml',
        callback = function(event)
          require('which-key').add {
            { '<leader>cr', group = 'Crate' },
          }

          local crates = require 'crates'
          local bind_fn = function(opts)
            local keymap = opts[1]
            local fn = opts[2]
            return vim.keymap.set(opts.mode or 'n', keymap, crates[fn], {
              desc = opts.desc or capitalize_and_concat(fn),
              silent = true,
              buffer = event.buf,
            })
          end
          bind_fn { '<leader>crt', 'toggle' }
          bind_fn { '<leader>crr', 'reload' }

          bind_fn { '<leader>crv', 'show_versions_popup' }
          bind_fn { '<leader>crf', 'show_features_popup' }
          bind_fn { '<leader>crd', 'show_dependencies_popup' }

          bind_fn { '<leader>cri', 'update_crate' }
          bind_fn { '<leader>crI', 'upgrade_crate' }
          bind_fn { '<leader>cru', 'update_crates' }
          bind_fn { '<leader>crU', 'upgrade_crates' }
          bind_fn { '<leader>cra', 'update_all_crates' }
          bind_fn { '<leader>crA', 'upgrade_all_crates' }

          bind_fn { '<leader>crx', 'expand_plain_crate_to_inline_table' }
          bind_fn { '<leader>crX', 'extract_crate_into_table' }

          bind_fn { '<leader>crH', 'open_homepage' }
          bind_fn { '<leader>crR', 'open_repository' }
          bind_fn { '<leader>crD', 'open_documentation' }
          bind_fn { '<leader>crC', 'open_crates_io' }
        end,
      })
    end,
  },
}
