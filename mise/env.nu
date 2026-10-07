# Generated on every start: the script bakes in the PATH it was generated with.
# Without mise (before packages are installed) leave an empty module to `use`.
const mise_nu = $nu.cache-dir | path join mise.nu

mkdir ($mise_nu | path dirname)
if (which mise | is-empty) {
  "" | save -f $mise_nu
} else {
  ^mise activate nu | save -f $mise_nu
}
