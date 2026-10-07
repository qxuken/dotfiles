# https://www.nushell.sh/cookbook/external_completers.html
#
# Completer input is `$place.command`: the token list of the command under the
# cursor (after pipes, inside closures, after `;`), with aliases already expanded.
export def external_completer [] {
    let carapace_completer = {|spans: list<string>|
        carapace $spans.0 nushell ...$spans
        | from json
        | default []
        # on error carapace yields an `ERR` row; return null to fall back to file completion
        | if ($in | any {|row| $row.value == "ERR" }) { null } else { $in }
    }

    let fish_completer = {|spans: list<string>|
        # pass the line as an argument, never interpolate it into fish source
        fish --command 'complete --do-complete=$argv[1]' -- ($spans | str join " ")
        | lines
        | each {|line|
            let parts = $line | split row (char tab)
            {value: $parts.0, description: ($parts.1? | default "")}
        }
    }

    let main_completer = if $env.HOST_OS_NAME != "Windows" {
        $fish_completer
    } else {
        $carapace_completer
    }

    return {|place|
        let spans = $place.command

        match $spans.0 {
            # fish completes commits and branch names in a nicer way
            git                      => $main_completer
            brew                     => $main_completer
            node                     => $main_completer
            deno                     => $main_completer
            # carapace doesn't have completions for mise
            mise                     => $main_completer
            _                        => $carapace_completer
        } | do $in $spans
    }
}
