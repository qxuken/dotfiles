local qd = require("qd")

return {
  enabled = not qd.tag("wsl"),
  path    = qd.path.config("wezterm"),
  brew    = { "wezterm@nightly" },
  scoop   = { { name = "wezterm-nightly", bucket = "versions" } },
  encrypt = { "**/fonts/BerkleyMono/*.ttf" },
}
