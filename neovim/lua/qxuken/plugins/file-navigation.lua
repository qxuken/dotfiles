local function harpoon_with_quick_nav(n, other)
  local keys = other
  for i = 1, n do
    keys[#keys + 1] = {
      '<M-' .. i .. '>',
      function()
        require('harpoon'):list():select(i)
      end,
      desc = '[Harp] Select ' .. i .. ' item',
    }
    keys[#keys + 1] = {
      '<leader>e' .. i,
      function()
        require('harpoon'):list():select(i)
      end,
      desc = 'Select ' .. i .. ' item',
    }
  end
  return keys
end

return {
  {
    'stevearc/oil.nvim',
    dependencies = { { 'echasnovski/mini.icons', opts = {} } },
    keys = {
      { '-', '<CMD>Oil<CR>', desc = '[Oil] Open' },
    },
    config = function()
      -- helper function to parse output
      local function parse_output(proc)
        local result = proc:wait()
        local ret = {}
        if result.code == 0 then
          for line in vim.gsplit(result.stdout, '\n', { plain = true, trimempty = true }) do
            -- Remove trailing slash
            line = line:gsub('/$', '')
            ret[line] = true
          end
        end
        return ret
      end

      -- build git status cache
      local function new_git_status()
        return setmetatable({}, {
          __index = function(self, key)
            local ignore_proc = vim.system({ 'git', 'ls-files', '--ignored', '--exclude-standard', '--others', '--directory' }, {
              cwd = key,
              text = true,
            })
            local tracked_proc = vim.system({ 'git', 'ls-tree', 'HEAD', '--name-only' }, {
              cwd = key,
              text = true,
            })
            local ret = {
              ignored = parse_output(ignore_proc),
              tracked = parse_output(tracked_proc),
            }

            rawset(self, key, ret)
            return ret
          end,
        })
      end
      local git_status = new_git_status()

      -- Clear git status cache on refresh
      local refresh = require('oil.actions').refresh
      local orig_refresh = refresh.callback
      refresh.callback = function(...)
        git_status = new_git_status()
        orig_refresh(...)
      end

      require('oil').setup {
        columns = {
          'icon',
          -- 'permissions',
          -- 'size',
          -- 'mtime',
        },
        view_options = {
          -- show_hidden = true,
          is_hidden_file = function(name, bufnr)
            local dir = require('oil').get_current_dir(bufnr)
            local is_dotfile = vim.startswith(name, '.') and name ~= '..'
            -- if no local directory (e.g. for ssh connections), just hide dotfiles
            if not dir then
              return is_dotfile
            end
            -- dotfiles are considered hidden unless tracked
            if is_dotfile then
              return not git_status[dir].tracked[name]
            else
              -- Check if file is gitignored
              return git_status[dir].ignored[name]
            end
          end,
        },
        win_options = {
          cursorcolumn = false,
        },
        float = {
          -- padding = 1,
          border = 'rounded',
          win_options = {
            -- winblend = 1,
          },
        },
        keymaps = {
          ['gd'] = {
            desc = 'Toggle file detail view',
            callback = function()
              detail = not detail
              if detail then
                require('oil').set_columns { 'icon', 'permissions', 'size', 'mtime' }
              else
                require('oil').set_columns { 'icon' }
              end
            end,
          },
        },
      }
    end,
  },
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    keys = harpoon_with_quick_nav(9, {
      {
        '<leader>ea',
        function()
          require('harpoon'):list():add()
        end,
        desc = 'Add buffer',
      },
      {
        '<leader>ed',
        function()
          require('harpoon'):list():remove()
        end,
        desc = 'Remove buffer',
      },
      {
        '<leader>ee',
        function()
          local h = require 'harpoon'
          h.ui:toggle_quick_menu(h:list(), { height_in_lines = math.min(vim.fn.winheight(0), 24), ui_width_ratio = 0.85 })
        end,
        desc = 'Open ui',
      },
      {
        '[e',
        function()
          require('harpoon'):list():prev { ui_nav_wrap = true }
        end,
        desc = '[Harp] Go to prev',
      },
      {
        ']e',
        function()
          require('harpoon'):list():next { ui_nav_wrap = true }
        end,
        desc = '[Harp] Go to next',
      },
    }),
    config = true,
  },
  {
    'chentoast/marks.nvim',
    event = 'VeryLazy',
    opts = {},
  },
}
