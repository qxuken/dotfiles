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
def make-path []: list<string> -> path {
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
  | upsert path { default [] | make-path }
  | upsert include { default [] | each { make-path } }
  { ...$config, name: ($parent | path basename), src: $parent }
}
def load-configs []: nothing -> list<record> { get-configs | each {load-config} }

def config-names     []: nothing -> list<string> { load-configs | get name }
def syncable-configs []: nothing -> list<string> { load-configs | where ($it.path | is-not-empty) | get name }
def config-file-path [name: string@config-names]: nothing -> path { $dotfiles_path | path join $name $config_file_name }

def format-file-list [--strip-path: path]: list<path> -> list<path> {
  each {path relative-to $strip_path} | where ($it | path type) == file
}
def local-files [--ignore: list<glob> = [], --encryption-globs: list<glob>]: record -> record<normal: list<path>, to_encrypt: list<path>> {
  let local_path = $in.path
  if ($local_path | is-empty) {
    error make {msg: "No path provided", help: "Config is missing path", label: {
      text: "Path is empty",
      span: (metadata $local_path).span
    }}
  }
  cd $local_path
  {
    normal: (glob --exclude ($ignore | append $encryption_globs) */**
            | format-file-list --strip-path $local_path),
    to_encrypt: ($encryption_globs
                | each {|it| glob --exclude $ignore $it}
                | flatten
                | format-file-list --strip-path $local_path)
  }
}
def stored-files []: record -> record<normal: list<path>, to_decrypt: list<path>> {
  let stored_path = $in.src
  cd $stored_path
  {
    normal: (glob --exclude ["**/*.age" "**/qd_config.yml"] */** | format-file-list --strip-path $stored_path),
    to_decrypt: (glob **/*.age | format-file-list --strip-path $stored_path)
  }
}
# Pull local config files into dotfiles
export def pull [config_name: string@syncable-configs] {
  let config = config-file-path $config_name | load-config
  let files = $config | local-files --ignore $config.ignore? --encryption-globs $config.encrypt
  {...$config, files: $files}
}
# Push stored config files into local
export def push [config_name: string@syncable-configs] {
  let config = config-file-path $config_name | load-config
  let files = $config | stored-files
  {...$config, files: $files}
}

