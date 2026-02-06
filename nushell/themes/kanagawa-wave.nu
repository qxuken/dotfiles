# Kanagawa Wave theme for Nushell
# https://github.com/rebelot/kanagawa.nvim

# Retrieve the theme settings
export def main [] {
    return {
        binary: '#957FB8'
        block: '#7E9CD8'
        cell-path: '#DCD7BA'
        closure: '#6A9589'
        custom: '#DCD7BA'
        duration: '#E6C384'
        float: '#D27E99'
        glob: '#DCD7BA'
        int: '#957FB8'
        list: '#6A9589'
        nothing: '#C34043'
        range: '#E6C384'
        record: '#6A9589'
        string: '#98BB6C'

        bool: {|| if $in { '#7AA89F' } else { '#E6C384' } }

        datetime: {|| (date now) - $in |
            if $in < 1hr {
                { fg: '#C34043' attr: 'b' }
            } else if $in < 6hr {
                '#C34043'
            } else if $in < 1day {
                '#E6C384'
            } else if $in < 3day {
                '#98BB6C'
            } else if $in < 1wk {
                { fg: '#98BB6C' attr: 'b' }
            } else if $in < 6wk {
                '#6A9589'
            } else if $in < 52wk {
                '#7E9CD8'
            } else { 'dark_gray' }
        }

        filesize: {|e|
            if $e == 0b {
                '#DCD7BA'
            } else if $e < 1mb {
                '#6A9589'
            } else {{ fg: '#7E9CD8' }}
        }

        shape_and: { fg: '#957FB8' attr: 'b' }
        shape_binary: { fg: '#957FB8' attr: 'b' }
        shape_block: { fg: '#7E9CD8' attr: 'b' }
        shape_bool: '#7AA89F'
        shape_closure: { fg: '#6A9589' attr: 'b' }
        shape_custom: '#98BB6C'
        shape_datetime: { fg: '#6A9589' attr: 'b' }
        shape_directory: '#6A9589'
        shape_external: '#6A9589'
        shape_external_resolved: '#7AA89F'
        shape_externalarg: { fg: '#98BB6C' attr: 'b' }
        shape_filepath: '#6A9589'
        shape_flag: { fg: '#7E9CD8' attr: 'b' }
        shape_float: { fg: '#D27E99' attr: 'b' }
        shape_garbage: { fg: '#FFFFFF' bg: '#E82424' attr: 'b' }
        shape_glob_interpolation: { fg: '#6A9589' attr: 'b' }
        shape_globpattern: { fg: '#6A9589' attr: 'b' }
        shape_int: { fg: '#957FB8' attr: 'b' }
        shape_internalcall: { fg: '#6A9589' attr: 'b' }
        shape_keyword: { fg: '#957FB8' attr: 'b' }
        shape_list: { fg: '#6A9589' attr: 'b' }
        shape_literal: '#7E9CD8'
        shape_match_pattern: '#98BB6C'
        shape_matching_brackets: { attr: 'u' }
        shape_nothing: '#C34043'
        shape_operator: '#C0A36E'
        shape_or: { fg: '#957FB8' attr: 'b' }
        shape_pipe: { fg: '#957FB8' attr: 'b' }
        shape_range: { fg: '#E6C384' attr: 'b' }
        shape_raw_string: { fg: '#DCD7BA' attr: 'b' }
        shape_record: { fg: '#6A9589' attr: 'b' }
        shape_redirection: { fg: '#957FB8' attr: 'b' }
        shape_signature: { fg: '#98BB6C' attr: 'b' }
        shape_string: '#98BB6C'
        shape_string_interpolation: { fg: '#6A9589' attr: 'b' }
        shape_table: { fg: '#7E9CD8' attr: 'b' }
        shape_vardecl: { fg: '#7E9CD8' attr: 'u' }
        shape_variable: '#957FB8'

        foreground: '#DCD7BA'
        background: '#1F1F28'
        cursor: '#C8C093'

        empty: '#7E9CD8'
        header: { fg: '#98BB6C' attr: 'b' }
        hints: '#727169'
        leading_trailing_space_bg: { attr: 'n' }
        row_index: { fg: '#98BB6C' attr: 'b' }
        search_result: { fg: '#C34043' bg: '#DCD7BA' }
        separator: '#DCD7BA'
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
