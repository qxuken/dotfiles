# Kanagawa Dragon theme for Nushell
# https://github.com/rebelot/kanagawa.nvim

# Retrieve the theme settings
export def main [] {
    return {
        binary: '#8992a7'
        block: '#8ba4b0'
        cell-path: '#c5c9c5'
        closure: '#6A9589'
        custom: '#c5c9c5'
        duration: '#c4b28a'
        float: '#a292a3'
        glob: '#c5c9c5'
        int: '#8992a7'
        list: '#6A9589'
        nothing: '#C34043'
        range: '#c4b28a'
        record: '#6A9589'
        string: '#8a9a7b'

        bool: {|| if $in { '#8ea4a2' } else { '#c4b28a' } }

        datetime: {|| (date now) - $in |
            if $in < 1hr {
                { fg: '#C34043' attr: 'b' }
            } else if $in < 6hr {
                '#C34043'
            } else if $in < 1day {
                '#c4b28a'
            } else if $in < 3day {
                '#8a9a7b'
            } else if $in < 1wk {
                { fg: '#8a9a7b' attr: 'b' }
            } else if $in < 6wk {
                '#6A9589'
            } else if $in < 52wk {
                '#8ba4b0'
            } else { 'dark_gray' }
        }

        filesize: {|e|
            if $e == 0b {
                '#c5c9c5'
            } else if $e < 1mb {
                '#6A9589'
            } else {{ fg: '#8ba4b0' }}
        }

        shape_and: { fg: '#8992a7' attr: 'b' }
        shape_binary: { fg: '#8992a7' attr: 'b' }
        shape_block: { fg: '#8ba4b0' attr: 'b' }
        shape_bool: '#8ea4a2'
        shape_closure: { fg: '#6A9589' attr: 'b' }
        shape_custom: '#8a9a7b'
        shape_datetime: { fg: '#6A9589' attr: 'b' }
        shape_directory: '#6A9589'
        shape_external: '#6A9589'
        shape_external_resolved: '#8ea4a2'
        shape_externalarg: { fg: '#8a9a7b' attr: 'b' }
        shape_filepath: '#6A9589'
        shape_flag: { fg: '#8ba4b0' attr: 'b' }
        shape_float: { fg: '#a292a3' attr: 'b' }
        shape_garbage: { fg: '#FFFFFF' bg: '#E82424' attr: 'b' }
        shape_glob_interpolation: { fg: '#6A9589' attr: 'b' }
        shape_globpattern: { fg: '#6A9589' attr: 'b' }
        shape_int: { fg: '#8992a7' attr: 'b' }
        shape_internalcall: { fg: '#6A9589' attr: 'b' }
        shape_keyword: { fg: '#8992a7' attr: 'b' }
        shape_list: { fg: '#6A9589' attr: 'b' }
        shape_literal: '#8ba4b0'
        shape_match_pattern: '#8a9a7b'
        shape_matching_brackets: { attr: 'u' }
        shape_nothing: '#C34043'
        shape_operator: '#c4746e'
        shape_or: { fg: '#8992a7' attr: 'b' }
        shape_pipe: { fg: '#8992a7' attr: 'b' }
        shape_range: { fg: '#c4b28a' attr: 'b' }
        shape_raw_string: { fg: '#c5c9c5' attr: 'b' }
        shape_record: { fg: '#6A9589' attr: 'b' }
        shape_redirection: { fg: '#8992a7' attr: 'b' }
        shape_signature: { fg: '#8a9a7b' attr: 'b' }
        shape_string: '#8a9a7b'
        shape_string_interpolation: { fg: '#6A9589' attr: 'b' }
        shape_table: { fg: '#8ba4b0' attr: 'b' }
        shape_vardecl: { fg: '#8ba4b0' attr: 'u' }
        shape_variable: '#8992a7'

        foreground: '#c5c9c5'
        background: '#181616'
        cursor: '#C8C093'

        empty: '#8ba4b0'
        header: { fg: '#8a9a7b' attr: 'b' }
        hints: '#737c73'
        leading_trailing_space_bg: { attr: 'n' }
        row_index: { fg: '#8a9a7b' attr: 'b' }
        search_result: { fg: '#C34043' bg: '#c5c9c5' }
        separator: '#c5c9c5'
    }
}

# Update the Nushell configuration
export def --env "set color_config" [] {
    $env.config.color_config = (main)
}

# Update terminal colors
export def "update terminal" [] {
    let theme = (main)

    # Set terminal colors
    let osc_screen_foreground_color = '10;'
    let osc_screen_background_color = '11;'
    let osc_cursor_color = '12;'
        
    $"
    (ansi -o $osc_screen_foreground_color)($theme.foreground)(char bel)
    (ansi -o $osc_screen_background_color)($theme.background)(char bel)
    (ansi -o $osc_cursor_color)($theme.cursor)(char bel)
    "
    # Line breaks above are just for source readability
    # but create extra whitespace when activating. Collapse
    # to one line and print with no-newline
    | str replace --all "\n" ''
    | print -n $"($in)\r"
}

export module activate {
    export-env {
        set color_config
        update terminal
    }
}

# Activate the theme when sourced
use activate
