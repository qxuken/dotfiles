local qd = require("qd")

return {
  path   = qd.path.config("starship"),
  brew   = { "starship" },
  scoop  = { "starship" },
  ignore = { "**/starship.nu" },
  nushell = { include = { "starship.nu" }, env_source = { "env.nu" } },
  setup = {
    version = 1,
    after = function(m)
      qd.write(qd.path.join(m.dest, "starship.nu"), qd.exec("starship", "init", "nu"))
    end,
  },
}
