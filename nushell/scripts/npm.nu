# Retrieve sorted history for npm package
export def version-history [package_name: string] {
    npm show --json $package_name
    | from json
    | get time
    | transpose version published_at
    | update published_at {|it| $it.published_at | into datetime}
    | sort-by published_at
}
