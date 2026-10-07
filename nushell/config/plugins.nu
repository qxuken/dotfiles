# Re-register every plugin against the binaries shipped next to the running
# `nu`. A registration pins the resolved binary path, so upgrading nushell
# (e.g. a new Homebrew Cellar dir) leaves plugins pointing at the old build.
export def plugin-reload [] {
    let dir = $nu.current-exe | path dirname
    let ext = if $nu.os-info.name == "windows" { ".exe" } else { "" }
    let result = plugin list | each {|p|
        let bin = $dir | path join $"nu_plugin_($p.name)($ext)"
        if ($bin | path exists) {
            plugin add $bin
            {name: $p.name, status: reloaded, filename: $bin}
        } else {
            {name: $p.name, status: missing, filename: $bin}
        }
    }
    print "Start a new shell (`exec nu`) to load the new builds."
    $result
}
