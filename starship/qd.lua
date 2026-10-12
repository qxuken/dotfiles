local qd = require("qd")

-- The right prompt is unused, and nushell would run starship a second time for
-- it on every prompt. Comment out its block in `starship init nu` and leave it
-- empty, since without one nushell falls back to its own clock.
local function without_right_prompt(init)
  local out, n = init:gsub("\n(    PROMPT_COMMAND_RIGHT: {||\n.-\n    }\n)", function(block)
    return '\n    PROMPT_COMMAND_RIGHT: ""\n' .. block:gsub("([^\n]*)\n", "# %1\n")
  end)
  if n == 0 then
    qd.warn("starship: no PROMPT_COMMAND_RIGHT block in `starship init nu`; right prompt left on")
  end
  return out
end

return {
  path   = qd.path.config("starship"),
  brew   = { "starship" },
  scoop  = { "starship" },
  ignore = { "**/starship.nu" },
  nushell = { include = { "starship.nu" }, env_source = { "env.nu" } },
  setup = {
    version = 2,
    after = function(m)
      qd.write(qd.path.join(m.dest, "starship.nu"), without_right_prompt(qd.exec("starship", "init", "nu")))
    end,
  },
}
