return {
  'qxuken/tasqer',
  config = function()
    local tasqer = require 'tasqer'
    tasqer.setup { log = function() end }
    tasqer.setup_wezterm_tasks()
    tasqer.start()
  end,
}
