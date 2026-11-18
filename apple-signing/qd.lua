local qd = require("qd")

return {
  enabled = qd.host.darwin and qd.tag("apple-signing"),
  path = qd.path.home(".config", "apple-signing"),
  encrypt = { "**/*.p12", "**/.profiles.secret.toml" },
  ignore = { "**/.profiles-*" },
  nushell = { include = { "signing.nu" } },
  setup = {
    version = 1,
    before = function(m)
      qd.exec("mkdir", "-p", m.dest)
      qd.exec("chmod", "700", m.dest)
    end,
    push = function(m)
      qd.exec("chmod", "700", m.dest)
      for _, name in ipairs({ "developer-id.p12", ".profiles.secret.toml" }) do
        local file = qd.path.join(m.dest, name)
        if qd.exists(file) then qd.exec("chmod", "600", file) end
      end
    end,
  },
}
