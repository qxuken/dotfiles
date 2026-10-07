local qd = require("qd")

return {
  -- mise's global config lives in ~/.config/mise on every OS. Shims read it from
  -- there, so GUI apps that only borrow PATH (editors, kawoosh) get it too.
  path  = qd.path.config("mise"),
  brew  = { "mise" },
  scoop = { "mise" },
  nushell = { source = { "config.nu" }, env_source = { "env.nu" } },
  setup = {
    version = 1,
    after = function(m) qd.run("mise", "install") end,
  },
}
