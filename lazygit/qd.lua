local qd = require("qd")

local path = qd.path.config("lazygit")
if qd.host.darwin then path = qd.path.app_support("lazygit") end
if qd.host.windows then path = qd.path.local_appdata("lazygit") end

return {
  path   = path,
  brew   = { "lazygit" },
  scoop  = { { name = "lazygit", bucket = "extras" } },
  ignore = { "**/state.yml", "**/github_pull_requests.json" },
  nushell = { source = { "config.nu" } },
}
