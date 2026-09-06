local qd = require("qd")

return {
  path  = qd.path.cache("completers"),
  brew  = { "carapace", "fish" },
  scoop = { { name = "carapace-bin", bucket = "extras" } },
  nushell = { source = { "config.nu" }, env_source = { "env.nu" } },
}
