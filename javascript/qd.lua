local qd = require("qd")

return {
  path  = qd.path.cache("javascript"),
  brew  = { "fnm" },
  scoop = { "fnm" },
  nushell = { source = { "config.nu" }, env_source = { "env.nu" } },
  setup = {
    version = 1,
    after = function(m) qd.run("fnm", "install", "--lts") end,
  },
}
