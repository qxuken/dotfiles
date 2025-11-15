const dotfiles_src = (path self .)
export def location [] { $dotfiles_src }
export def master-rec [] { $dotfiles_src | path join master.rec }
export def master-key [] { $dotfiles_src | path join master.key }

const host_aliases = {
  Darwin: posix
  Windows: win
}
const known_hosts = [posix darwin win windows]
def sys-host-name [] { sys host | get name }

def home-path [] { $env | get -o HOME | default { $env | get -o HOMEPATH | path expand }  }
def config-path [] { home-path | path join .config }
def application-support [] { home-path | path join Library 'Application Support' }
def appdata [] { $env.APPDATA }
def local-appdata [] { $env.LOCALAPPDATA }
def path-interpreter []: list<string> -> path {
  $in
  | each { |it|
    match $it {
      "%home%" => (home-path)
      "%config%" => (config-path)
      "%application_support%" => (application-support)
      "%local-appdata%" => (local-appdata)
      "%appdata%" => (appdata)
      _ => $it
    }
  }
  | path join
}

def load-config [host: string, path: path] {
  open $path
  # Merge order is important
  | merge deep ($in
                | get -o --ignore-case ($host_aliases | get -o --ignore-case $host | default 'unknown')
                | default {})
  | merge deep ($in | get -o --ignore-case $host | default {})
  | reject -o --ignore-case ...$known_hosts
  | upsert path {|row| if ($row | get -o path | is-not-empty) { $row.path | path-interpreter } }
}
def get-configs [src: path] {
  $src | path expand | path join * qd_config.yml | str replace --all "\\" "/" | glob $in
}
export def load-configs [src: path = $dotfiles_src] {
  let host = sys-host-name
  get-configs $src | each { |path|
    let parent = ($path | path parse | get parent)
    mut ctx = { name: ($parent | path basename), src: $parent }
    { ...$ctx, config: (load-config $host $path) }
  }
}

export def local-pull [] { }
export def local-push [] { }

