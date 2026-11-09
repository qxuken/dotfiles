local qd = require("qd")

return {
  enabled = not qd.host.wsl,
  path = qd.path.home(".config", "kawoosh"),
  encrypt = { "fonts/BerkeleyMono/*.ttf" },
}
