local qd = require("qd")

-- Node itself comes from the mise module.
return {
  path  = qd.path.cache("javascript"),
  nushell = { source = { "config.nu" }, env_source = { "env.nu" } },
}
