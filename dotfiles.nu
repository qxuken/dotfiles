const dotfiles_path      = path self .
const config_file_name   = "qd_config.yml"
const global_config_path = $dotfiles_path | path join "global_config.yml"
const master_rec_path    = $dotfiles_path | path join master.rec
const master_key_path    = $dotfiles_path | path join master.key
const tmp_path           = $dotfiles_path | path join .tmp
# Dotfiles location
export def pwd    []: nothing -> path { $dotfiles_path }
def make-tmp-file []: nothing -> path {
  mkdir $tmp_path
  let file = $tmp_path | path join (random uuid -v 7)
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
      "%local-appdata%"       => $env.LOCALAPPDATA
      "%appdata%"             => $env.APPDATA
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

def global-config []: nothing -> record { open $global_config_path }
def get-configs   []: nothing -> list<path> {
  cd $dotfiles_path
  glob --no-dir $"*/($config_file_name)"
}
# Config schema (per config dir):
# - src: path
# - dest: path
# - include: list<list<string>>   # path segments / tokens to interpolate
# - encrypt: list<glob>
# - ignore: list<glob>
# - dotfile_include: list<list<string>>
# - dotfile_source: list<list<string>>
# - dotfile_env_include: list<list<string>>
# - dotfile_env_source: list<list<string>>
# - brew: list<string | { name: string, tap: string } | {"%root%": ...}>
# - scoop: list<string | { name: string, bucket: string } | {"%root%": ...}>
# - <host> / <host-alias>: same structure for host-specific overrides
def load-config []: path -> record {
  let host = sys-host-name
  let parent = $in | path parse | get parent
  let raw_config = open $in

  let host_alias = (
    $host_aliases
    | get -o --ignore-case $host
    | default 'unknown'
  )

  # Merge order is important
  global-config
  | merge deep --strategy append $raw_config
  | merge ($raw_config | get -o --ignore-case $host_alias | default {})
  | merge ($raw_config | get -o --ignore-case $host | default {})
  | reject -o --ignore-case ...$known_hosts
  | upsert brew { default [] | interpolate-string-list-field $raw_config brew }
  | upsert scoop { default [] | interpolate-string-list-field $raw_config scoop }
  | upsert path { default [] | interpolate-path }
  | rename --column {path: dest}
  | upsert include {|c|
    $c.include? | default []
    | each {|row| $row | interpolate-path $c.dest }
  }
  | insert name ($parent | path basename)
  | insert src $parent
}
def config-src   []: [record -> path, record -> nothing] { $in.src? }
def config-dest  []: [record -> path, record -> nothing] { $in.dest? }
def load-configs []: nothing -> list<record> { get-configs | each {load-config} }
def config-names []: nothing -> list<string> { load-configs | get name }
def config-file-path [name: string@config-names]: nothing -> path { $dotfiles_path | path join $name $config_file_name }
# Load config to check structure
export def verify-config [config_name: string@config-names] { config-file-path $config_name | load-config }

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
export def compile-home-dotfile [] {
  let configs = load-configs
  $configs | each --flatten {|c| $c.dotfile_include? | default [] | each {interpolate-path ($c | config-dest)}} | uniq | each {|p| $"use ($p)"}
  | append ($configs | each --flatten {|c| $c.dotfile_source? | default [] | each {interpolate-path ($c | config-dest)}} | uniq | each {|p| $"source ($p)"})
  | str join (char newline)
  | save -f (home-path | path join .dotfiles.local.nu)

  $configs | each --flatten {|c| $c.dotfile_env_include? | default [] | each {interpolate-path ($c | config-dest)}} | uniq | each {|p| $"use ($p)"}
  | append ($configs | each --flatten {|c| $c.dotfile_env_source? | default [] | each {interpolate-path ($c | config-dest)}} | uniq | each {|p| $"source ($p)"})
  | str join (char newline)
  | save -f (home-path | path join .dotfiles-env.local.nu)
}

def syncable-configs []: nothing -> list<string> { load-configs | where ($it | config-dest | is-not-empty) | get name }
def path-strip [strip_path: path]: list<path> -> list<path> { each {path relative-to $strip_path} }
def files [--ignore: list<glob> = [], --encrypt: list<glob> = []]: path -> list<record> {
  let input = $in
  if ($input | is-empty) {
    error make {msg: "No path provided", help: "Config is missing path", label: {
      text: "Path is empty",
      span: (metadata $input).span
    }}
  }
  cd $input
  glob --no-dir --exclude (
    ["**/*.age" $"**/($config_file_name)"]
    | append $ignore | append $encrypt
  ) */**
  | path-strip $input
  | wrap path
  | insert encrypted false
  | append (
    $encrypt
    | append **/*.age
    | each --flatten {|it|
      glob --no-dir --exclude $ignore $it
    }
    | path-strip $input
    | str replace -r ".age$" ""
    | wrap path
    | insert encrypted true
  )
}
def files-in-src  []: record -> list<record> { config-src | files }
def files-in-dest []: record -> list<record> {
  let config = $in
  $config | config-dest
  | files --ignore ($config.ignore? | default []) --encrypt ($config.encrypt? | default [])
}
# Difference (INPUT ∖ ARG) - all extra files in INPUT as a result
def files-difference-with [exclude: list<record>]: list<record> -> list<record> {
  let exclude = $exclude | get path
  $in | where $it.path not-in $exclude
}

# Pull local config files into dotfiles
export def pull [
  config_name: string@syncable-configs
  --sync-with-remote (-s): string # Push updates to remote after pulling from local
  --no-recompile
] {
  let config = config-file-path $config_name | load-config
  let dest_files = $config | files-in-dest
  $dest_files
  | each {|it|
    let from = $config | config-dest | path join $it.path
    let to = $config | config-src | path join $it.path
    mkdir ($to | path parse | get parent)
    if $it.encrypted {
      let target = $"($to).age"
      let enc = {|| age --encrypt -R $master_rec_path -o $target $from }
      if not ($target | path exists) {
        do $enc
        return
      }
      let out = make-tmp-file
      age --decrypt -i $master_key_path -o $out $target
      if not (same-files $out $from) {
        do $enc
      }
      rm $out
    } else {
      cp --update $from $to
    }
  }
  $config | files-in-src | files-difference-with $dest_files | each {|it|
    let file_name = if $it.encrypted { $"($it.path).age" } else { $it.path }
    rm ($config | config-src | path join $file_name)
  }
  if ($sync_with_remote | is-not-empty) {
    remote-push $sync_with_remote
  }
  if not $no_recompile {
    compile-home-dotfile
  }
}
# Pull all local configs into dotfiles
export def pull-all [
  --sync-with-remote (-s): string # Push updates to remote after pulling from local
] {
  syncable-configs | each {|c| pull --no-recompile $c}
  if ($sync_with_remote | is-not-empty) {
    remote-push $sync_with_remote
  }
  compile-home-dotfile
}
# Push stored config files into local
export def push [
  config_name: string@syncable-configs
  --sync-with-remote (-s) # Pull remote updates before pushing to local
  --no-recompile
] {
  if $sync_with_remote {
    remote-pull
  }
  let config = config-file-path $config_name | load-config
  let is_first_push = not ($config | config-dest | path exists)
  let pre_init_script_path = $config | config-dest | path join qd_pre_init.nu
  if $is_first_push and ($pre_init_script_path | path exists) {
    nu $pre_init_script_path
  }
  let src_files = $config | files-in-src
  $src_files
  | each {|it|
    let from = $config | config-src | path join $it.path
    let to = $config | config-dest | path join $it.path
    mkdir ($to | path parse | get parent)
    if $it.encrypted {
      let out = make-tmp-file
      age --decrypt -i $master_key_path -o $out $"($from).age"
      cp --force $out $to
      rm $out
    } else {
      cp --update $from $to
    }
  }
  $config.include | each {|from|
    let to = $config | config-dest | path join ($from | path basename)
    cp --update $from $to
  }
  $config | files-in-dest | files-difference-with $src_files | each {|f| rm ($config | config-dest | path join $f.path)}
  let init_script_path = $config | config-dest | path join qd_init.nu
  if $is_first_push and ($init_script_path | path exists) {
    nu $init_script_path
  }
  if not $no_recompile {
    compile-home-dotfile
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
  syncable-configs | each {|c| push --no-recompile $c}
  compile-home-dotfile
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
export def brew-upgrade [] { load-brew-config | get packages | brew upgrade ...$in }

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
export def scoop-upgrade [] { load-scoop-config | get packages | scoop update ...$in }

# Install packages and push all configs
export def init [] {
  if (which brew | is-not-empty) {
    brew-install
  }
  if (which scoop | is-not-empty) {
    scoop-install
  }
  push-all
}

export def same-files [file1: path, file2: path]: nothing -> bool {
  (open -r $file1) == (open -r $file2)
}
