local qd = require("qd")

return {
  -- qd-config.yml / qd-*init*.nu belong to the old Nushell tool; they stay in the
  -- repo until every machine has cut over, but never reach a destination. Phase 4
  -- deletes them, and this ignore list goes back to the four generic entries.
  ignore  = { "**/.git/**", "**/.gitignore", "**/.editorconfig", "**/.DS_Store", "**/qd-config.yml", "**/qd-init.nu", "**/qd-pre-init.nu" },
  include = { qd.path.dotfiles(".editorconfig") },
  encrypt = { "**/*.p12" },
  nushell = {
    -- config.nu holds the old `dotfiles ...` aliases. Machines still on the Nushell
    -- tool pick it up through global-config.yml, so it is deliberately not sourced
    -- here; qd.nu replaces it with dph / dpl / dst and completions.
    source  = { qd.path.dotfiles("qd.nu") },
  },
}
