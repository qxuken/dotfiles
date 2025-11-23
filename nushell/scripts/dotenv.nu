export def --env load [] {
    open .env | lines | parse "{key}={value}" | reduce --fold {} {|row| merge {$row.key: $row.value}} | load-env
}
