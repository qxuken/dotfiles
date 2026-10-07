local qd = require("qd")

-- clangd's user config: macOS reads it from ~/Library/Preferences.
local path = qd.path.config("clangd")
if qd.host.darwin then path = qd.path.home("Library", "Preferences", "clangd") end
if qd.host.windows then path = qd.path.local_appdata("clangd") end

return {
  path = path,
}
