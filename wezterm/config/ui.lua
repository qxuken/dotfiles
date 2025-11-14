local wezterm = require("wezterm")

local fira_features = {
	"zero",
	"cv01",
	"cv02",
	"cv06",
	"ss05",
	"ss03",
	"cv16",
	"cv31",
	"cv29",
	"cv30",
	"ss08",
	"cv24",
	"ss09",
	"cv25",
	"cv26",
	"cv32",
	"cv27",
	"cv28",
	"ss06",
}
local fira_font = {
	family = "FiraMono Nerd Font",
	harfbuzz_features = fira_features,
	weight = "Medium",
}

local berkeley_font = {
	family = "Berkeley Mono Variable",
	-- weight = "DemiBold",
}

local config = {
	darkTheme = "Catppuccin Mocha (Gogh)",
	lightTheme = "Catppuccin Latte (Gogh)",
	font_size = 18.5,
	font_family = berkeley_font,
}

local M = {}

M.get_appearance = function()
	if wezterm.gui then
		return wezterm.gui.get_appearance() == "Light" and "Light" or "Dark"
	end
	return "Dark"
end

M.scheme_for_appearance = function()
	if M.get_appearance():find("Dark") then
		return config.darkTheme
	else
		return config.lightTheme
	end
end

-- conforming to https://github.com/wez/wezterm/commit/e4ae8a844d8feaa43e1de34c5cc8b4f07ce525dd
M.apply_to_config = function(c)
	c.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
	c.enable_scroll_bar = false

	-- nightly only for now
	-- c.native_macos_fullscreen_mode = false
	-- c.macos_fullscreen_extend_behind_notch = true

	local theme = M.scheme_for_appearance()
	c.color_scheme = theme
	c.colors = wezterm.color.get_builtin_schemes()[theme]

	c.font_dirs = { "fonts" }
	c.font = wezterm.font_with_fallback({
		config.font_family,
		berkeley_font,
		fira_font,
	})

	c.font_size = config.font_size
	c.command_palette_font_size = 22.0
	c.command_palette_bg_color = c.colors.background
	c.command_palette_fg_color = c.colors.foreground
end

return M
