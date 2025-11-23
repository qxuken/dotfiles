# https://www.nushell.sh/cookbook/external_completers.html#alias-completions
export def external_completer [] {
    let zoxide_completer = {|spans|
        $spans | skip 1 | zoxide query -l ...$in | lines | where {|x| $x != $env.PWD}
    }

    let carapace_completer = {|spans: list<string>|
        carapace $spans.0 nushell ...$spans
        | from json
        | if ($in | default [] | where value =~ '^-.*ERR$' | is-empty) { $in } else { null }
    }

    let fish_completer = {|spans|
        fish --command $'complete "--do-complete=($spans | str join " ")"'
        | from tsv --flexible --noheaders --no-infer
        | rename value description
    }

    let main_completer = if $env.HOST_OS_NAME != "Windows" {
        $fish_completer
    } else {
        $carapace_completer
    }

    return {|spans|
        let expanded_alias = scope aliases
        | where name == $spans.0
        | get -o 0.expansion
        let spans = if $expanded_alias != null {
            $spans
            | skip 1
            | prepend ($expanded_alias | split row ' ' | take 1)
        } else {
            $spans
        }

        match $spans.0 {
            # carapace completions are incorrect for nu
            nu                       => $main_completer
            # fish completes commits and branch names in a nicer way
            git                      => $main_completer
            brew                     => $main_completer
            node                     => $main_completer
            deno                     => $main_completer
            bun                      => $main_completer
            yarn                     => $main_completer
            # carapace doesn't have completions for asdf
            asdf                     => $main_completer
            # use zoxide completions for zoxide commands
            __zoxide_z | __zoxide_zi => $zoxide_completer
            _                        => $carapace_completer
        } | do $in $spans
    }
}
