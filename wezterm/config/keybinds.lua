local wezterm = require("wezterm")
local act = wezterm.action

local M = {}

-- conforming to https://github.com/wez/wezterm/commit/e4ae8a844d8feaa43e1de34c5cc8b4f07ce525dd
M.apply_to_config = function(c)
	c.leader = { key = "b", mods = "CTRL", timeout_milliseconds = 5000 }
	-- if wezterm.target_triple == "aarch64-apple-darwin" then
	-- c.leader = { key = "b", mods = "SUPER", timeout_milliseconds = 1000 }
	-- config.send_composed_key_when_right_alt_is_pressed = true
	-- config.use_ime = true
	-- end

	c.keys = {
		{ key = "LeftArrow", mods = "OPT", action = act.SendString("\x1bb") },
		{ key = "RightArrow", mods = "OPT", action = act.SendString("\x1bf") },
		{ key = "LeftArrow", mods = "CMD", action = wezterm.action({ SendString = "\x1bOH" }) },
		{ key = "RightArrow", mods = "CMD", action = wezterm.action({ SendString = "\x1bOF" }) },
		{ key = "F11", action = wezterm.action.ToggleFullScreen },
		{ key = "[", mods = "LEADER", action = act.SwitchWorkspaceRelative(-1) },
		{ key = "]", mods = "LEADER", action = act.SwitchWorkspaceRelative(1) },
		{ key = "9", mods = "LEADER", action = act.MoveTabRelative(-1) },
		{ key = "0", mods = "LEADER", action = act.MoveTabRelative(1) },
		{ key = "o", mods = "LEADER", action = act.ShowLauncher },
		{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
		{ key = "w", mods = "LEADER", action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES" }) },
		{ key = "K", mods = "CTRL", action = act.ActivatePaneDirection("Up") },
		{ key = "J", mods = "CTRL", action = act.ActivatePaneDirection("Down") },
		{ key = "L", mods = "CTRL", action = act.ActivatePaneDirection("Right") },
		{ key = "H", mods = "CTRL", action = act.ActivatePaneDirection("Left") },
		{ key = "s", mods = "LEADER", action = act.SplitPane({ direction = "Down" }) },
		{ key = "v", mods = "LEADER", action = act.SplitPane({ direction = "Right" }) },
		{ key = '"', mods = "LEADER|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
		{
			key = "n",
			mods = "LEADER",
			action = act.PromptInputLine({
				description = wezterm.format({
					{ Attribute = { Intensity = "Bold" } },
					{ Foreground = { AnsiColor = "Fuchsia" } },
					{ Text = "Enter name for new workspace" },
				}),
				action = wezterm.action_callback(function(window, pane, line)
					if line then
						window:perform_action(
							act.SwitchToWorkspace({
								name = line,
							}),
							pane
						)
					end
				end),
			}),
		},
		{
			key = "r",
			mods = "LEADER",
			action = act.PromptInputLine({
				description = wezterm.format({
					{ Attribute = { Intensity = "Bold" } },
					{ Foreground = { AnsiColor = "Fuchsia" } },
					{ Text = "Enter new name for tab" },
				}),
				action = wezterm.action_callback(function(window, pane, line)
					if line then
						window:active_tab():set_title(line)
					end
				end),
			}),
		},
	}
end

return M
