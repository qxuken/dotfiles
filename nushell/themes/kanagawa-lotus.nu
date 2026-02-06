# Kanagawa Lotus theme for Nushell
# https://github.com/rebelot/kanagawa.nvim

# Retrieve the theme settings
export def main [] {
    return {
        binary: '#624c83'
        block: '#4d699b'
        cell-path: '#545464'
        closure: '#597b75'
        custom: '#545464'
        duration: '#de9800'
        float: '#b35b79'
        glob: '#545464'
        int: '#624c83'
        list: '#597b75'
        nothing: '#c84053'
        range: '#de9800'
        record: '#597b75'
        string: '#6f894e'

        bool: {|| if $in { '#5e857a' } else { '#de9800' } }

        datetime: {|| (date now) - $in |
            if $in < 1hr {
                { fg: '#c84053' attr: 'b' }
            } else if $in < 6hr {
                '#c84053'
            } else if $in < 1day {
                '#de9800'
            } else if $in < 3day {
                '#6f894e'
            } else if $in < 1wk {
                { fg: '#6f894e' attr: 'b' }
            } else if $in < 6wk {
                '#597b75'
            } else if $in < 52wk {
                '#4d699b'
            } else { 'dark_gray' }
        }

        filesize: {|e|
            if $e == 0b {
                '#545464'
            } else if $e < 1mb {
                '#597b75'
            } else {{ fg: '#4d699b' }}
        }

        shape_and: { fg: '#624c83' attr: 'b' }
        shape_binary: { fg: '#624c83' attr: 'b' }
        shape_block: { fg: '#4d699b' attr: 'b' }
        shape_bool: '#5e857a'
        shape_closure: { fg: '#597b75' attr: 'b' }
        shape_custom: '#6f894e'
        shape_datetime: { fg: '#597b75' attr: 'b' }
        shape_directory: '#597b75'
        shape_external: '#597b75'
        shape_external_resolved: '#5e857a'
        shape_externalarg: { fg: '#6f894e' attr: 'b' }
        shape_filepath: '#597b75'
        shape_flag: { fg: '#4d699b' attr: 'b' }
        shape_float: { fg: '#b35b79' attr: 'b' }
        shape_garbage: { fg: '#FFFFFF' bg: '#e82424' attr: 'b' }
        shape_glob_interpolation: { fg: '#597b75' attr: 'b' }
        shape_globpattern: { fg: '#597b75' attr: 'b' }
        shape_int: { fg: '#624c83' attr: 'b' }
        shape_internalcall: { fg: '#597b75' attr: 'b' }
        shape_keyword: { fg: '#624c83' attr: 'b' }
        shape_list: { fg: '#597b75' attr: 'b' }
        shape_literal: '#4d699b'
        shape_match_pattern: '#6f894e'
        shape_matching_brackets: { attr: 'u' }
        shape_nothing: '#c84053'
        shape_operator: '#836f4a'
        shape_or: { fg: '#624c83' attr: 'b' }
        shape_pipe: { fg: '#624c83' attr: 'b' }
        shape_range: { fg: '#de9800' attr: 'b' }
        shape_raw_string: { fg: '#545464' attr: 'b' }
        shape_record: { fg: '#597b75' attr: 'b' }
        shape_redirection: { fg: '#624c83' attr: 'b' }
        shape_signature: { fg: '#6f894e' attr: 'b' }
        shape_string: '#6f894e'
        shape_string_interpolation: { fg: '#597b75' attr: 'b' }
        shape_table: { fg: '#4d699b' attr: 'b' }
        shape_vardecl: { fg: '#4d699b' attr: 'u' }
        shape_variable: '#624c83'

        foreground: '#545464'
        background: '#f2ecbc'
        cursor: '#43436c'

        empty: '#4d699b'
        header: { fg: '#6f894e' attr: 'b' }
        hints: '#8a8980'
        leading_trailing_space_bg: { attr: 'n' }
        row_index: { fg: '#6f894e' attr: 'b' }
        search_result: { fg: '#c84053' bg: '#545464' }
        separator: '#545464'
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
