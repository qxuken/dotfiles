use ../themes/gruvbox-light-medium.nu
use ../themes/gruvbox-light-ls.nu
use ../themes/gruvbox-dark.nu
use ../themes/gruvbox-dark-ls.nu

# https://github.com/nushell/nu_scripts/tree/main/themes
#
# Startup never talks to the terminal. `term query` reads raw stdin until the
# terminator, so keys typed before the terminal answers break the prefix check,
# abort config loading, and leave the reply sitting in the line editor. It also
# has no timeout. Instead the appearance comes from sources that cannot hang:
# an env var handed down by wezterm (see wezterm/config/ui.lua) or a parent
# shell, then the OS setting. The OSC 11 query is only used by an explicit
# `reload-theme`, which runs at an idle prompt where typeahead is not a problem.

# Ask the terminal for its background colour (OSC 11). Only safe at an idle prompt.
def query-is-dark []: nothing -> bool {
  let terminator = if ($env.HOST_OS_NAME == 'Darwin' and (("WEZTERM_UNIX_SOCKET" in $env) or ("ITERM_PROFILE" in $env) or ("GHOSTTY_BIN_DIR" in $env))) or $env.HOST_OS_NAME == "Linux" or ("ZED_TERM" in $env) or ("VSCODE_NONCE" in $env) {
    ansi st
  } else {
    char bel
  }
  let res = term query $"(ansi osc)11;?(ansi st)" --prefix $"(ansi osc)11;" --terminator $terminator
  | decode
  | parse "rgb:{r}/{g}/{b}"
  | into record
  let r = $res.r | str substring 0..1 | into int --radix 16
  let g = $res.g | str substring 0..1 | into int --radix 16
  let b = $res.b | str substring 0..1 | into int --radix 16
  let brightness = ($r * 299 + $g * 587 + $b * 114) / 1000
  $brightness < 128
}

# Work out the appearance without touching the tty. Cheapest source first.
def detect-is-dark []: nothing -> bool {
  let handed_down = $env.TERM_APEARANCE? | default ""
  if $handed_down in ["Dark" "Light"] {
    return ($handed_down == "Dark")
  }
  if "WSL_DISTRO_NAME" in $env {
    return true
  }
  match ($env.HOST_OS_NAME? | default (sys host | get name)) {
    "Windows" => true
    # Exits non-zero (no output) when the system is in light mode.
    "Darwin" => {
      ((^defaults read -g AppleInterfaceStyle | complete).stdout | str trim) == "Dark"
    }
    "Linux" => {
      if (which gsettings | is-empty) { return true }
      (^gsettings get org.gnome.desktop.interface color-scheme | complete).stdout
      | str contains "prefer-dark"
    }
    _ => true
  }
}

def --env apply-theme [is_dark: bool] {
  if $is_dark {
    $env.TERM_APEARANCE = "Dark"
    $env.config.color_config = gruvbox-dark
    $env.LS_COLORS = $gruvbox_dark_ls.colors
  } else {
    $env.TERM_APEARANCE = "Light"
    $env.config.color_config = gruvbox-light-medium
    $env.LS_COLORS = $gruvbox_light_ls.colors
  }
}

# Re-detect the appearance. Asks the terminal directly when attached to one,
# since the handed-down TERM_APEARANCE goes stale after the terminal switches
# appearance. Use --no-query to skip the OSC 11 round trip.
export def --env reload-theme [--no-query (-n)] {
  let is_dark = if $no_query or not (is-terminal --stdin) {
    detect-is-dark
  } else {
    try { query-is-dark } catch { detect-is-dark }
  }
  apply-theme $is_dark
}
export alias rt = reload-theme

apply-theme (try { detect-is-dark } catch { true })
