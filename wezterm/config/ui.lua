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
}

local intel_one_features = {
  "ss01", -- Programming ligatures
  -- "ss02", -- Arrow forms for less/equal and greater/equal combinations
  -- "ss03", -- www ligature
  "ss11", -- Raised colon (contextual with figures)
  -- "ss12", -- Raised colon (global)
  -- "salt", -- Raised colon (global)
  "locl", -- Localizations
  "ccmp", -- Glyph composition/decomposition rules
  -- "mark", -- Mark Attachment
  -- "numr", -- Numerator
  -- "dnom", -- Denominator
  -- "sups", -- Superscript
  -- "subs", -- Subscript
  -- "sinf", -- Scientific inferior
  "aalt", -- Access all alternates
}
local intel_one_font = {
  family = "Intel One Mono",
  harfbuzz_features = intel_one_features,
}

---@diagnostic disable-next-line: unused-local
local berkeley_font = {
  family = "Berkeley Mono Variable",
}

local config = {
  dark_theme = require("config.coloschemes.kanagawa-dragon"),
  light_theme = require("config.coloschemes.kanagawa-lotus"),
  line_height = 1.1,
  font_size = 15,
  font_order = {
    intel_one_font,
    fira_font,
    berkeley_font,
  },
}

local M = {}

M.theme = {
  light = 0,
  dark = 1,
}

M.get_appearance = function()
  if wezterm.gui and wezterm.gui.get_appearance() == "Light" then
    return M.theme.light
  else
    return M.theme.dark
  end
end

M.scheme_for_appearance = function()
  if M.get_appearance() == M.theme.dark then
    return config.dark_theme
  else
    return config.light_theme
  end
end

-- conforming to https://github.com/wez/wezterm/commit/e4ae8a844d8feaa43e1de34c5cc8b4f07ce525dd
M.apply_to_config = function(c)
  c.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
  c.enable_scroll_bar = false

  c.prefer_to_spawn_tabs = true

  local theme = M.scheme_for_appearance()
  if type(theme) == "string" then
    c.color_scheme = theme
    c.colors = wezterm.color.get_builtin_schemes()[theme]
  elseif type(theme) == "table" then
    for k, v in pairs(theme) do
      c[k] = v
    end
  end

  c.font_dirs = { "fonts" }
  c.font = wezterm.font_with_fallback(config.font_order)

  c.line_height = config.line_height
  c.font_size = config.font_size
  c.command_palette_font_size = 22.0
  c.command_palette_bg_color = c.colors.background
  c.command_palette_fg_color = c.colors.foreground
end

return M
