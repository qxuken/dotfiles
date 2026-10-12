local qd = require("qd")

local path = qd.path.config("nushell")
if qd.host.darwin then path = qd.path.app_support("nushell") end
if qd.host.windows then path = qd.path.appdata("nushell") end

-- env.nu reads this instead of asking brew and gem on every launch.
local TOOL_PATHS = qd.path.cache("nushell", "tool-paths.json")

-- First line of a command's stdout, or nil when the command is missing or fails.
local function ask(cmd, ...)
  if not qd.which(cmd) then return nil end
  local ok, out = pcall(qd.exec, cmd, ...)
  if not ok then
    qd.warn("nushell: %s", out)
    return nil
  end
  local line = out:match("^%s*(.-)%s*$")
  if line == "" then return nil end
  return line
end

local function json_list(items)
  local quoted = {}
  for i, s in ipairs(items) do
    quoted[i] = '"' .. s:gsub('[\\"]', "\\%0") .. '"'
  end
  return "[" .. table.concat(quoted, ", ") .. "]"
end

return {
  path   = path,
  brew   = { "nushell" },
  scoop  = { "nu" },
  ignore = { "**/history.txt", "**/plugin.msgpackz", "**/vendor/**" },
  setup = {
    version = 1,
    before = function(m)
      for _, f in ipairs({ ".dotfiles-env.local.nu", ".dotfiles.local.nu", ".local.nu" }) do
        local p = qd.path.home(f)
        if not qd.exists(p) then qd.write(p, "") end
      end
    end,
    -- Rerun on every push so a brew or ruby upgrade is picked up by the next `qd push`.
    push = function(m)
      if qd.host.windows then return end
      local library_path, bin = {}, {}
      local prefix = ask("brew", "--prefix")
      if prefix then library_path[#library_path + 1] = qd.path.join(prefix, "lib") end
      local gemdir = ask("gem", "environment", "gemdir")
      if gemdir then bin[#bin + 1] = qd.path.join(gemdir, "bin") end
      qd.write(TOOL_PATHS, string.format(
        '{\n  "library_path": %s,\n  "path": %s\n}\n',
        json_list(library_path), json_list(bin)
      ))
    end,
  },
}
