local qd = require("qd")

local pkgs = { "git", "fzf", "ripgrep", "fd", "cmake", "llvm", "fnm", "neovim" }

return {
  path  = qd.host.windows and qd.path.local_appdata("nvim") or qd.path.config("nvim"),
  brew  = qd.host.ubuntu and qd.list(pkgs, "xclip", "xsel") or pkgs,
  scoop = pkgs,
  nushell = { source = { "config.nu" }, env_source = { "env.nu" } },
  setup = {
    version = 1,
    after = function(m) qd.run("fnm", "install", "--lts") end,
  },
}
