const dotfiles_path      = path self .
const config_file_name   = "qd_config.yml"
const global_config_path = $dotfiles_path | path join "global_config.yml"

export def pwd       []: nothing -> path { $dotfiles_path } # Dotfiles location
def master-rec-path  []: nothing -> path { $dotfiles_path | path join master.rec }
def master-key-path  []: nothing -> path { $dotfiles_path | path join master.key }
def tmp              []: nothing -> path { $dotfiles_path | path join .tmp }
def tmp-file         []: nothing -> path {
  let dir = tmp
  mkdir $dir
  let file = $dir | path join (random uuid -v 7)
  touch $file
  $file
}

const known_hosts  = [posix darwin ubuntu win windows]
const host_aliases = {darwin: posix, ubuntu: posix, windows: win}
def sys-host-name []: nothing -> string { sys host | get name }

def home-path [] { "~" | path expand }
def interpolate-path [path?: string]: list<string> -> path {
  $in | each {|it|
    match $it {
      "%dotfiles%"            => (pwd)
      "%path%"                => $path
      "%dotfiles-cache%"      => (home-path | path join .dotfiles_cache)
      "%home%"                => (home-path)
      "%config%"              => (home-path | path join .config)
      "%application-support%" => (home-path | path join Library 'Application Support')
      "%local-appdata%"       => ($env.LOCALAPPDATA)
      "%appdata%"             => ($env.APPDATA)
      _                       => $it
    }
  }
  | path join
}

def interpolate-string-list-field [config: record, field: string]: [
  list<string> -> list<string>
  list<any> -> list<any>
] {
  each --flatten {|it|
    match $it {
      "%root%" => ($config | get $field)
      _        => $it
    }
  }
}

def global-config [src: path = $global_config_path] { open $src }
def get-configs [src: path = $dotfiles_path]: nothing -> list<path> {
  cd $src
  glob --no-dir $"*/($config_file_name)"
}
def load-config []: path -> record {
  let host = sys-host-name
  let parent = $in | path parse | get parent
  let raw_config = open $in
  $raw_config
  # Merge order is important
  | merge ($in
          | get -o --ignore-case ($host_aliases | get -o --ignore-case $host | default 'unknown')
          | default {})
  | merge ($in | get -o --ignore-case $host | default {})
  | merge deep --strategy append (global-config)
  | reject -o --ignore-case ...$known_hosts
  | upsert brew { default [] | interpolate-string-list-field $raw_config brew }
  | upsert scoop { default [] | interpolate-string-list-field $raw_config scoop }
  | upsert path { default [] | interpolate-path }
  | upsert include {|conf| $conf.include? | default [] | each {|row| $row | interpolate-path $conf.path } }
  | insert name ($parent | path basename)
  | insert src $parent
}
def load-configs []: nothing -> list<record> { get-configs | each {load-config} }
def config-names []: nothing -> list<string> { load-configs | get name }

# Pull remote updates
export def remote-pull [] {
  cd $dotfiles_path
  fossil update
}
# Push updates to remote
export def remote-push [message: string] {
  cd $dotfiles_path
  fossil addremove
  fossil commit --comment $message
}
# Uncommited diff
export def remote-diff [] {
  cd $dotfiles_path
  fossil diff
}

# Compile dotfile
export def compile-dotfile [] {
  let config = load-configs
  $config | each --flatten {|it| $it.dotfile_include? | default [] | each {interpolate-path $it.path?}} | uniq | each {|it| $"use ($it)"}
  | append ($config | each --flatten {|it| $it.dotfile_source? | default [] | each {interpolate-path $it.path?}} | uniq | each {|it| $"source ($it)"})
  | str join (char newline)
  | save -f (home-path | path join .dotfiles.local.nu)

  $config | each --flatten {|it| $it.dotfile_env_include? | default [] | each {interpolate-path $it.path?}} | uniq | each {|it| $"use ($it)"}
  | append ($config | each --flatten {|it| $it.dotfile_env_source? | default [] | each {interpolate-path $it.path?}} | uniq | each {|it| $"source ($it)"})
  | str join (char newline)
  | save -f (home-path | path join .dotfiles-env.local.nu)
}

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
export def pull [
  config_name: string@syncable-configs
  --sync-with-remote (-s): string # Push updates to remote after pulling from local
  --no-recomplie
] {
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
      cp --update $from $to
    }
  }
  if ($sync_with_remote | is-not-empty) {
    remote-push $sync_with_remote
  }
  if not $no_recomplie {
    compile-dotfile
  }
}
# Pull all local configs into dotfiles
export def pull-all [
  --sync-with-remote (-s): string # Push updates to remote after pulling from local
] {
  syncable-configs | each {|c| pull --no-recomplie $c}
  if ($sync_with_remote | is-not-empty) {
    remote-push $sync_with_remote
  }
  compile-dotfile
}
# Push stored config files into local
export def push [
  config_name: string@syncable-configs
  --sync-with-remote (-s) # Pull remote updates before pushing to local
  --no-recomplie
] {
  if $sync_with_remote {
    remote-pull
  }
  let config = config-file-path $config_name | load-config
  let is_first_push = not ($config.path | path exists)
  let pre_init_script_path = $config.path | path join qd_pre_init.nu
  if $is_first_push and ($pre_init_script_path | path exists) {
    nu $pre_init_script_path
  }
  $config.src | files-list | each {|it|
    let from = ($config.src | path join $it.path)
    let to = ($config.path | path join $it.path)
    mkdir ($to | path parse | get parent)
    if $it.encrypted {
      let out = tmp-file
      age --decrypt -i (master-key-path) -o $out $"($from).age"
      cp --force $out $to
      rm $out
    } else {
      cp --update $from $to
    }
  }
  $config.include | each {|from|
    let to = $config.path | path join ($from | path basename)
    cp --update $from $to
  }
  let init_script_path = $config.path | path join qd_init.nu
  if $is_first_push and ($init_script_path | path exists) {
    nu $init_script_path
  }
  if not $no_recomplie {
    compile-dotfile
  }
  ignore
}
# Push all stored configs into local
export def push-all [
  --sync-with-remote (-s) # Pull remote updates before pushing to local
] {
  if $sync_with_remote {
    remote-pull
  }
  syncable-configs | each {|c| push --no-recomplie $c}
  compile-dotfile
}

def load-brew-config []: nothing -> record<packages: list<string>, taps: list<string>> {
  load-configs
  | get brew
  | flatten
  | each {|it|
    if ($it | describe) == "string" {
    {
        name: $it
        tap: null
      }
    } else {
      $it
    }
  }
  | uniq-by name
  | {
    packages: ($in | get name)
    taps: ($in | get tap | uniq | where (is-not-empty))
  }
}
# Install packages from list
export def brew-install [] {
  let config = load-brew-config
  $config | get taps | each {|it| brew tap $it}
  brew install ...($config | get packages)
}
# Upgrade packages from list
export def brew-upgrade [] {
  load-brew-config | get packages | brew upgrade ...$in
}

def load-scoop-config []: nothing -> record<packages: list<string>, buckets: list<string>> {
  load-configs
  | get scoop
  | flatten
  | each {|it|
    if ($it | describe) == "string" {
    {
        name: $it
        bucket: main
      }
    } else {
      $it
    }
  }
  | uniq-by name
  | {
    packages: ($in | each {|it| $"($it.bucket)/($it.name)"})
    buckets: ($in | get bucket | uniq)
  }
}
# Install packages from list
export def scoop-install [] {
  let config = load-scoop-config
  $config.buckets  | each {|buck| scoop bucket add $buck}
  $config.packages | scoop install ...$in
}
# Upgrade packages from list
export def scoop-upgrade [] {
  load-scoop-config | get packages | scoop update ...$in
}

# Install packages and push all configs
def init [] {
  if (which brew | is-not-empty) {
    brew-install
  }
  if (which scoop | is-not-empty) {
    scoop-install
  }
  push-all
}
