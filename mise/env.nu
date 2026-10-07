# Generated on every start: the script bakes in the PATH it was generated with.
# Without mise (before packages are installed) leave an empty module to `use`.
const mise_nu = $nu.cache-dir | path join mise.nu

mkdir ($mise_nu | path dirname)
if (which mise | is-empty) {
  "" | save -f $mise_nu
} else {
  # The `mise` wrapper is a nu command, so tab completion would stop at its own
  # signature; send it to the external completer (fish) like the bare binary.
  ^mise activate nu
  | str replace "export def --env --wrapped main" "@complete external\nexport def --env --wrapped main"
  | save -f $mise_nu
}
