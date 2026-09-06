local qd = require("qd")

local pkgs = { "git", "jq", "ripgrep", "fd", "fzf", "zoxide", "resvg", "yazi" }

return {
  path  = qd.host.windows and qd.path.appdata("yazi", "config") or qd.path.config("yazi"),
  brew  = qd.host.ubuntu and qd.list(pkgs, "xclip", "xsel") or pkgs,
  scoop = pkgs,
  nushell = { source = { "config.nu" } },
}
