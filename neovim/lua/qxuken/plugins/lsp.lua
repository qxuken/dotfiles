return {
  {
    'mason-org/mason.nvim',
    lazy = false,
    dependencies = {
      'neovim/nvim-lspconfig',
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      'mfussenegger/nvim-dap',
      'j-hui/fidget.nvim',
      'saghen/blink.cmp',
      'folke/snacks.nvim',
      {
        'ray-x/lsp_signature.nvim',
        event = 'InsertEnter',
        opts = {},
      },
      { 'folke/neoconf.nvim', config = true },
      { 'folke/lazydev.nvim', ft = 'lua', opts = {} },
    },
    keys = {
      { '<leader>pm', '<cmd>Mason<cr>', desc = 'Mason' },
      { '<leader>pl', '<cmd>LspInfo<cr>', desc = '[Lsp] info' },
    },
    config = function()
      vim.filetype.add { extension = { templ = 'templ' } }

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('qx-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = '[LSP] ' .. desc })
          end

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('gd', function()
            Snacks.picker.lsp_definitions(with_picker_config())
          end, 'Goto Definition')

          -- Find references for the word under your cursor.
          map('gr', function()
            Snacks.picker.lsp_references(with_picker_config())
          end, 'Goto References')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gI', function()
            Snacks.picker.lsp_implementations(with_picker_config())
          end, 'Goto Implementation')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('<leader>D', function()
            Snacks.picker.lsp_type_definitions(with_picker_config())
          end, 'Type Definition')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('<leader>bs', function()
            Snacks.picker.lsp_symbols(with_picker_config())
          end, 'Buffer Symbols')
          map('<leader>cs', function()
            Snacks.picker.lsp_symbols(with_picker_config())
          end, 'Buffer Symbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('<leader>ws', function()
            Snacks.picker.lsp_workspace_symbols(with_picker_config())
          end, 'Workspace Symbols')

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>r', vim.lsp.buf.rename, 'Rename')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>ca', vim.lsp.buf.code_action, 'Code Action')

          map('<leader>cF', vim.lsp.buf.format, 'Code Format')

          -- toggle builtin hint inlay
          -- Replaced with snacks from folke
          -- map('<leader>cI', function()
          --   vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          -- end, 'Toggle Inlay Hint')

          map('K', function()
            vim.lsp.buf.hover { border = 'rounded' }
          end, 'Hover Documentation')

          map('gD', vim.lsp.buf.declaration, 'Goto Declaration')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end
        end,
      })

      local servers = {
        sqlls = {},
        sqlfmt = {},
        clangd = {},
        goimports = {},
        gopls = {},
        templ = {},
        delve = {},
        html = {
          filetypes = { 'html', 'templ' },
        },
        htmx = {
          filetypes = { 'html', 'templ' },
        },
        cssls = {},
        tailwindcss = {
          filetypes = { 'templ', 'astro', 'javascript', 'typescript', 'javascriptreact', 'typescriptreact', 'react' },
          init_options = { userLanguages = { templ = 'html' } },
        },
        codelldb = {},
        -- Disabled due to rustacean plugin
        -- rust_analyzer = {},
        -- ts_ls = {},
        eslint = {},
        eslint_d = {},
        prettier = {},
        prettierd = {},
        jsonls = {},
        fixjson = {},
        markdown_oxide = {},
        lua_ls = {
          -- cmd = {...},
          -- filetypes = { ...},
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
        stylua = {},
      }
      local non_installable_servers = {
        nushell = {},
        gdscript = {},
      }

      require('mason').setup()

      local ensure_installed = vim.tbl_keys(servers or {})
      require('mason-tool-installer').setup {
        ensure_installed = ensure_installed,
      }
      require('mason-lspconfig').setup {
        automatic_enable = true,
      }

      local all_servers = vim.tbl_extend('error', servers, non_installable_servers)
      for server_name in pairs(non_installable_servers) do
        vim.lsp.enable(server_name)
      end
      for server_name, server_opt in pairs(all_servers) do
        if not vim.tbl_isempty(server_opt) then
          vim.lsp.config(server_name, server_opt)
        end
      end
    end,
  },
  {
    'mfussenegger/nvim-dap',
    event = 'VeryLazy',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'theHamsta/nvim-dap-virtual-text',
      'nvim-neotest/nvim-nio',
    },
    config = function()
      require('dapui').setup {}
      require('nvim-dap-virtual-text').setup {}
      local dap, dapui = require 'dap', require 'dapui'
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
    end,
    keys = {
      {
        '<leader>Gb',
        function()
          require('dap').toggle_breakpoint()
        end,
        desc = 'Toggle Breakpoint',
      },
      {
        '<leader>Gc',
        function()
          require('dap').continue()
        end,
        desc = 'Continue Execution',
      },
      {
        '<leader>Gq',
        function()
          require('dap').terminate()
        end,
        desc = 'Stop Execution',
      },
      {
        '<leader>GR',
        function()
          require('dap').restart()
        end,
        desc = 'Restart',
      },
      {
        '<leader>Gp',
        function()
          require('dap').step_back()
        end,
        desc = 'Step Back',
      },
      {
        '<leader>Go',
        function()
          require('dap').step_over()
        end,
        desc = 'Step Over',
      },
      {
        '<leader>Gi',
        function()
          require('dap').step_into()
        end,
        desc = 'Step Into',
      },
      {
        '<leader>Gr',
        function()
          require('dap').repl.open()
        end,
        desc = 'Repl Open',
      },
      {
        '<leader>Ge',
        function()
          require('dapui').eval()
        end,
        desc = 'Eval Cursor',
      },
      {
        '<leader>Gu',
        function()
          require('dapui').toggle()
        end,
        desc = 'Toggle ui',
      },
    },
  },
}
