local qd = require("qd")

return {
  ignore  = { "**/.git/**", "**/.gitignore", "**/.editorconfig", "**/.DS_Store" },
  include = { qd.path.dotfiles(".editorconfig") },
  encrypt = { "**/*.p12" },
  nushell = {
    -- dph / dpl / dst and their completions; `source`d, since `use` would
    -- namespace the aliases as `qd dph` and collide with the binary.
    source  = { qd.path.dotfiles("qd.nu") },
  },
}
