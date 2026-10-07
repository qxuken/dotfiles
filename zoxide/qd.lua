local qd = require("qd")

return {
  path   = qd.path.cache("zoxide"),
  brew   = { "zoxide" },
  scoop  = { "zoxide" },
  ignore = { "**/zoxide.nu" },
  nushell = { source = { "zoxide.nu" } },
  setup = {
    version = 2,
    after = function(m)
      qd.write(qd.path.join(m.dest, "zoxide.nu"), qd.exec("zoxide", "init", "nushell"))
    end,
  },
}
