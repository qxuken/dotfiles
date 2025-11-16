const dotfiles_path      = path self .
const config_file_name   = "qd_config.yml"
const global_config_path = $dotfiles_path | path join "global_config.yml"

export def pwd       []: nothing -> path { $dotfiles_path } # Dotfiles location
def tmp-cache        []: nothing -> path { $dotfiles_path | path join .tmp }
def master-rec-path  []: nothing -> path { $dotfiles_path | path join master.rec }
def master-key-path  []: nothing -> path { $dotfiles_path | path join master.key }

const known_hosts  = [posix darwin ubuntu win windows]
const host_aliases = {darwin: posix, ubuntu: posix, windows: win}
def sys-host-name []: nothing -> string { sys host | get name }

def home-path [] { $env | get -o HOME | default { $env | get -o HOMEPATH | path expand } }
def interpolate-path []: list<string> -> path {
  each {|it|
    match $it {
      "%dotfiles%"            => (pwd)
      "%home%"                => (home-path)
      "%config%"              => (home-path | path join .config)
      "%application_support%" => (home-path | path join Library 'Application Support')
      "%local-appdata%"       => ($env.LOCALAPPDATA)
      "%appdata%"             => ($env.APPDATA)
      _                       => $it
    }
  }
  | path join
}

def global-config [src: path = $global_config_path] { open $src }
def get-configs [src: path = $dotfiles_path]: nothing -> list<path> {
  cd $src
  glob --no-dir $"*/($config_file_name)"
}
def load-config []: path -> record {
  let host = sys-host-name
  let parent = $in | path parse | get parent
  let config = open $in
  # Merge order is important
  | merge ($in
          | get -o --ignore-case ($host_aliases | get -o --ignore-case $host | default 'unknown')
          | default {})
  | merge ($in | get -o --ignore-case $host | default {})
  | merge deep --strategy append (global-config)
  | reject -o --ignore-case ...$known_hosts
  | upsert path { default [] | interpolate-path }
  | upsert include { default [] | each { interpolate-path } }
  { ...$config, name: ($parent | path basename), src: $parent }
}
def load-configs []: nothing -> list<record> { get-configs | each {load-config} }

def config-names     []: nothing -> list<string> { load-configs | get name }
def syncable-configs []: nothing -> list<string> { load-configs | where ($it.path | is-not-empty) | get name }
def config-file-path [name: string@config-names]: nothing -> path { $dotfiles_path | path join $name $config_file_name }

def format-file-list [--strip-path: path]: list<path> -> list<path> {
  each {path relative-to $strip_path} | where ($it | path type) == file
}
def files-list [--ignore: list<glob> = [], --encryption-globs: list<glob>]: path -> list<record> {
  let input = $in
  if ($input | is-empty) {
    error make {msg: "No path provided", help: "Config is missing path", label: {
      text: "Path is empty",
      span: (metadata $input).span
    }}
  }
  cd $input
  glob --exclude (["**/*.age" "**/qd_config.yml"] | append $ignore | append $encryption_globs) */**
  | format-file-list --strip-path $input
  | wrap path
  | insert encrypted false
  | append ($encryption_globs
            | append **/*.age
            | each --flatten {|it| glob --exclude $ignore $it}
            | format-file-list --strip-path $input
            | str replace -r ".age$" ""
            | wrap path
            | insert encrypted true)
}
# Pull local config files into dotfiles
export def pull [config_name: string@syncable-configs] {
  let config = config-file-path $config_name | load-config
  $config.path
  | files-list --ignore ($config.ignore?) --encryption-globs ($config.encrypt)
  | each {|it|
    let from = ($config.path | path join $it.path)
    let to = ($config.src | path join $it.path)
    if $it.encrypted {
      age --encrypt -R (master-rec-path) -o $"($to).age" $from
    } else {
      mkdir ($to | path parse | get parent)
      cp --force --preserve [mode, timestamps, xattr] $from $to
    }
  }
  | ignore
}
# Push stored config files into local
export def push [config_name: string@syncable-configs] {
  let config = config-file-path $config_name | load-config
  $config.src
  | files-list
  | each {|it|
    let from = ($config.src | path join $it.path)
    let to = ($config.path | path join $it.path)
    if $it.encrypted {
      age --decrypt -i (master-key-path) -o $to $"($from).age"
    } else {
      mkdir ($to | path parse | get parent)
      cp --force --preserve [mode, timestamps, xattr] $from $to
    }
  }
  | ignore
}

