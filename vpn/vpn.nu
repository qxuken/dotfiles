const src = (path self .)
const servers_file = ($src | path join config.yml)

def locations []: nothing -> string {
  open $servers_file | transpose key v | get key
}

export def conf [loc: string@locations] {
  open ($src | path join $servers_file)
  | get $loc
  | update cert {path expand}
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

