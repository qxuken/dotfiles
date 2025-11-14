const dotfiles_src = (path self .)
export def location [] { $dotfiles_src }
export def master-rec [] { $dotfiles_src | path join master.rec }
export def master-key [] { $dotfiles_src | path join master.key }

def sys-host-name [] { sys host | get name }
const host_aliases = {
  "Darwin": "posix"
}
const known_hosts = ['posix' 'darwin']

def home-path [] { $env.HOME }
def config-path [] { home-path | path join .config }
def application-support [] { home-path | path join 'Library' 'Application Support' }

def load-config [path: path] {
  let host = sys-host-name

  open $path
  # Merge order is important
  | merge deep ($in
                | get -o --ignore-case ($host_aliases
                | get -o --ignore-case $host)
                | default {})
  | merge deep ($in | get -o --ignore-case $host | default {})
  | transpose key value
  | where ($it.key | str downcase) not-in $known_hosts
  | transpose -rd
  | upsert src_path ($path | path parse | get parent)
  | update path { path-interpreter }
}
def get-configs [src: path] { $src | path expand | path join "**/qd_config.yml" | glob $in }
export def load-configs [src: path = $dotfiles_src] {
  get-configs $src | each { |it| load-config $it }
}

def path-interpreter []: list<string> -> path {
  $in
  | each { |it|
    match $it {
      "%home%" => (home-path),
      "%config%" => (config-path),
      "%application_support%" => (application-support),
      _ => $it
    }
  }
  | path join
}

export def local-pull [] { }
export def local-push [] { }

