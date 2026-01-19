const src = (path self .)

export def lz [] {
  let config = match $env.TERM_APEARANCE {
    "Light" => ($src | path join "config-light.yml"),
    _ => ($src | path join "config.yml"),
  }
  lazygit --use-config-file=($config)
}
