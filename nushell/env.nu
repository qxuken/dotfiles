use std "path add"

const env_conf_path = path self .

$env.HOME = $env.HOME? | default ("~" | path expand)

$env.NU_LIB_DIRS = [
  ($env_conf_path | path join scripts)
  ($env_conf_path | path join virtual-environments)
]

$env.NU_PLUGIN_DIRS = [
  ($env_conf_path | path join plugins)
  ($env.HOME | path join .cargo bin)
  ($nu.current-exe | path dirname)
]

$env.HOST_OS_NAME = (sys host | get name)
# NOTE: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
  "PATH": {
    from_string: {|s| $s | split row (char esep) | path expand --no-symlink}
    to_string: {|v| $v | path expand --no-symlink | str join (char esep)}
  }
  "Path": {
    from_string: {|s| $s | split row (char esep) | path expand --no-symlink}
    to_string: {|v| $v | path expand --no-symlink | str join (char esep)}
  }
}

if $env.HOST_OS_NAME != "Windows" {
  $env.PATH = $env.PATH
    | split row (char esep)
    | prepend (
      [
        ("/" | path join usr local bin)
        ("/" | path join opt homebrew bin)
        ("/" | path join opt homebrew opt ruby bin)
        ("/" | path join home linuxbrew .linuxbrew bin)
        ("/" | path join home linuxbrew .linuxbrew opt ruby bin)
        ($env.HOME | path join bin)
        ($env.HOME | path join .local bin)
        ($env.HOME | path join .cargo bin)
        ($env.HOME | path join go bin)
      ]
      | where (path exists)
    )

  if (which brew | is-not-empty) {
    $env.LIBRARY_PATH = $env
    | get LIBRARY_PATH -o
    | default ''
    | split row (char esep)
    | where {is-not-empty}
    | append (brew --prefix | path join lib)
    | str join (char esep)
  }

  if (which gem | is-not-empty) {
    path add (gem environment gemdir)
  }
}

source ~/.dotfiles-env.local.nu
