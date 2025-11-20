const src = (path self .)
const config_path = ($src | path join config.yml)

def locations []: nothing -> string {
  open $config_path
  | reject pbr
  | transpose key v
  | get key
}

export def pbr-reload [] {
  open ($src | path join $config_path)
  | get pbr
  | run-external ssh $in.host $in.app reload
}

export def conf [loc: string@locations] {
  open ($src | path join $config_path)
  | get $loc
  | update cert {|it| $src | path join $it.cert}
}

export def connect [loc: string@locations] {
  let config = conf $loc
  sudo openconnect --server $config.host --certificate $config.cert -p $config.user
}

export def netherlands [] {
  connect netherlands
}

export def germany [] {
  connect germany
}
