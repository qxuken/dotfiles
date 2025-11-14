return {
  'nvim-neotest/neotest',
  lazy = true,
  event = 'VimEnter',
  dependencies = {
    'folke/which-key.nvim',
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'vim-test/vim-test',
    'nvim-neotest/neotest-vim-test',
    'nvim-neotest/neotest-jest',
    'mrcjkb/rustaceanvim',
    'fredrikaverpil/neotest-golang',
    'marilari88/neotest-vitest',
  },
  keys = {
    {
      '<leader>nf',
      function()
        require('neotest').run.run(vim.fn.expand '%')
      end,
      desc = 'Test File',
    },
    {
      '<leader>nn',
      function()
        require('neotest').run.run()
      end,
      desc = 'Test Nearest',
    },
    {
      '<leader>ns',
      function()
        require('neotest').run.stop()
      end,
      desc = 'Test Stop',
    },
    {
      '<leader>na',
      function()
        require('neotest').run.attach()
      end,
      desc = 'Test Attach',
    },
  },
  config = function()
    require('which-key').add {
      { '<leader>n', group = 'Neotest' },
    }

    require('neotest').setup {
      adapters = {
        require 'neotest-vitest',
        require 'neotest-jest' {
          env = { CI = 'true', FUNCTIONAL = 'true' },
          -- jestCommand = 'npm test --',
          -- jestConfigFile = 'custom.jest.config.ts',
          -- cwd = function()
          --   return vim.fn.getcwd()
          -- end,
        },
        require 'rustaceanvim.neotest',
        require 'neotest-golang',
        require 'neotest-vim-test' {
          ignore_file_types = { 'rust', 'go', 'javascript', 'typescript' },
        },
      },
    }
  end,
}
