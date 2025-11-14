export def env-has [key: string]: nothing -> bool {
    $env | get -o $key | is-not-empty
}
