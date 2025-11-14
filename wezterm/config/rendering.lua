local wezterm = require("wezterm")

local M = {}

-- conforming to https://github.com/wez/wezterm/commit/e4ae8a844d8feaa43e1de34c5cc8b4f07ce525dd
M.apply_to_config = function(c)
	if wezterm.target_triple == "x86_64-pc-windows-msvc" then
		c.front_end = "WebGpu"
		c.webgpu_power_preference = "HighPerformance"
	end

	c.max_fps = 144
	c.animation_fps = 144
end

return M
