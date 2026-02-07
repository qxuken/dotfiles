return {
  'qxuken/tasqer',
  config = function()
    local tasqer = require 'tasqer'
    tasqer.setup()
    tasqer.setup_wezterm_tasks()
    tasqer.start()
  end,
}
