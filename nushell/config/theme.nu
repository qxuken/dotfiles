use ../themes/gruvbox-light-medium.nu
use ../themes/gruvbox-light-ls.nu
use ../themes/gruvbox-dark.nu
use ../themes/gruvbox-dark-ls.nu

# https://github.com/nushell/nu_scripts/tree/main/themes

def is-dark [] {
  if ("WSL_DISTRO_NAME" in $env) or ($env.HOST_OS_NAME == "Windows") {
    return true
  }
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

export def --env reload-theme [] {
  let is_dark = is-dark

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
export alias rt = reload-theme

rt
