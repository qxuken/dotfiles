# `mise activate nu` puts the shims dir first in PATH and, from the first prompt
# on, swaps in the real bin dirs of the versions the current directory wants.
# Processes that never reach a prompt (`nu -c`, editors borrowing PATH) keep the
# shims, which resolve the version from their own working directory.
#
# Its export-env resets PATH to the copy baked in by env.nu, so put back
# anything added to PATH after that.
let path_before_mise = $env.PATH
use ($nu.cache-dir | path join mise.nu)
$env.PATH = $env.PATH | append ($path_before_mise | where $it not-in $env.PATH)
