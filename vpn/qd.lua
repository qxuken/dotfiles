local qd = require("qd")

return {
  path    = qd.path.home("vpn"),
  brew    = { "openconnect" },
  scoop   = { "openconnect" },
  encrypt = { "**/*.p12", "**/config.yml" },
  nushell = { include = { "vpn.nu" } },
}
