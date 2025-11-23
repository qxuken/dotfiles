const src = path self .

$env.NU_LIB_DIRS = $env.NU_LIB_DIRS
  | append ($src | path join completions)
  | append ($src | path join virtual-environments)
