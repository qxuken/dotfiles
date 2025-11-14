export def into-webp []: [
    string -> nothing
    cell-path -> nothing
] {
    let components = $in | path expand | path parse
    magick $in $"($components.parent | path join $components.stem).webp"
}
