def optimize-path [] {
    $env.PATH | each {|r| $r | path expand --no-symlink} | str downcase | where (path exists) | uniq | sort | str join (char esep)
}

