use std "path add"

if ($env.HOME | path join .bun | path exists) {
  $env.BUN_INSTALL = $env.HOME | path join .bun
  if $env.HOST_OS_NAME != "Windows" {
    path add ($env.HOME | path join .bun/bin)
  }
}
