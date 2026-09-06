local qd = require("qd")

local path = qd.path.config("nushell")
if qd.host.darwin then path = qd.path.app_support("nushell") end
if qd.host.windows then path = qd.path.appdata("nushell") end

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
  },
}
