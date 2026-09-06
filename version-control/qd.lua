local qd = require("qd")

return {
  path  = qd.path.cache("version-control"),
  brew  = { "git", "fossil" },
  scoop = { "git", "fossil" },
  files = {
    { src = ".gitconfig", dest = qd.path.home(".gitconfig"), enabled = not qd.tag("work") },
  },
  nushell = { source = { "config.nu" } },
}
