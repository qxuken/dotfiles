local qd = require("qd")

return {
  path  = qd.host.windows and qd.path.appdata("helix") or qd.path.config("helix"),
  brew  = { "helix" },
  scoop = { "helix" },
}
