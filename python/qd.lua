local qd = require("qd")

return {
  path  = qd.path.cache("python"),
  brew  = { "uv" },
  scoop = { "uv" },
  nushell = { source = { "config.nu" }, env_source = { "env.nu" } },
  setup = {
    version = 1,
    after = function(m) qd.run("uv", "python", "install", "3") end,
  },
}
