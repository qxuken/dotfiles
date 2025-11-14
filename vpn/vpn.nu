const src = (path self .)
const servers_file = ($src | path join config.yml)

def locations []: nothing -> string {
  open $servers_file | transpose key v | get key
}

export def conf [loc: string@locations] {
  open ($src | path join servers.yml)
  | get $loc
  | update cert {path expand}
}

export def connect [loc: string@locations] {
  conf $loc
  | sudo openconnect --server $in.host --certificate $in.cert -p $in.user
}

export def netherlands [] {
  connect netherlands
}

export def germany [] {
  connect germany
}

