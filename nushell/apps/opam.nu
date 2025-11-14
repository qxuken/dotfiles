def --env opam-env [] {
	let env_table = opam env --shell pwsh | sed -e 's/\$env://' -e "s/\'//g" | lines | split column ' = ' name value
	let opam_env = $env_table | reduce --fold {} {|it, acc| $acc | insert $it.name $it.value } 
	load-env $opam_env
}

# if not (which opam | is-empty) {
# 	opam-env
# }

