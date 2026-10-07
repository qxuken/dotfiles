use std "path add"

let fnm = fnm env --json | from json
# fnm links a fresh per-shell dir on every call; we use the shared one below, so drop it
if $env.HOST_OS_NAME != "Windows" { rm $fnm.FNM_MULTISHELL_PATH }
$fnm | reject FNM_MULTISHELL_PATH | load-env
$env.FNM_BIN = $env.FNM_DIR | path join bin
$env.FNM_MULTISHELL_PATH = $env.FNM_DIR | path join nodejs
path add $env.FNM_BIN
path add (if $env.HOST_OS_NAME == "Windows" {
  $env.FNM_MULTISHELL_PATH
} else {
  $env.FNM_MULTISHELL_PATH | path join bin
})

if ($env.HOME | path join .bun | path exists) {
  $env.BUN_INSTALL = $env.HOME | path join .bun
  if $env.HOST_OS_NAME != "Windows" {
    path add ($env.HOME | path join .bun/bin)
  }
}
