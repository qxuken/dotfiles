export def --env main [
    --domain (-d): string = ".youtube.com"   # domain assigned to every cookie
    --days: int = 365                        # expiry, days from now (0 = session)
]: string -> string {
    let header = $in
    let expiry = if $days == 0 {
        "0"
    } else {
        (date now) + ($days * 1day) | format date "%s"
    }

    let rows = (
        $header
        | split row "; "
        | where {|pair| $pair | str contains "=" }
        | each {|pair|
            let idx = ($pair | str index-of "=")
            let name = ($pair | str substring ..<$idx)
            let value = ($pair | str substring ($idx + 1)..)
            let secure = (
                if ($name | str starts-with "__Secure-") or ($name | str starts-with "__Host-") { "TRUE" } else { "FALSE" }
            )
            # domain  include_subdomains  path  secure  expires  name  value
            [$domain "TRUE" "/" $secure $expiry $name $value] | str join (char tab)
        }
    )

    ["# Netscape HTTP Cookie File"] | append $rows | str join "\n"
}
