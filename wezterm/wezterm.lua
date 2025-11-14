local wezterm = require("wezterm")
local config_ui = require("config.ui")
local config_rendering = require("config.rendering")
local config_tabbar = require("config.tabbar")
local config_keybinds = require("config.keybinds")

local config = wezterm.config_builder()

if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	config.default_prog = { "nu", "-l" }
	-- elseif wezterm.target_triple == "aarch64-apple-darwin" then
	-- config.set_environment_variables = { XDG_CONFIG_HOME = "/Users/qxuken/.config/" }
end

-- config.window_background_opacity = 0.8

config_ui.apply_to_config(config)
config_rendering.apply_to_config(config)
config_tabbar.apply_to_config(config)
config_keybinds.apply_to_config(config)

return config
