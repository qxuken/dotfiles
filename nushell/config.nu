# Nushell Config File
#
# Only overrides live here; everything else is Nushell's built-in default.
# See `config nu --doc` for every option and its default.

use ./config/keybinds.nu [keybinds]
use ./config/menus.nu [menus]

$env.config.show_banner = false
$env.config.edit_mode = 'vi'
$env.config.use_kitty_protocol = true # keyboard enhancement protocol, only where the terminal supports it

$env.config.cursor_shape = {
    emacs: line
    vi_insert: block
    vi_normal: underscore
}

$env.config.completions.algorithm = 'fuzzy'

$env.config.shell_integration.osc9_9 = ($env.HOST_OS_NAME == 'Windows')
# NOTE: Open issue https://github.com/nushell/nushell/issues/5585
$env.config.shell_integration.osc133 = ("WEZTERM_PANE" not-in $env and "WSL_DISTRO_NAME" not-in $env)

$env.config.hooks.env_change.PWD = [{|before, after|
    if ('FNM_DIR' in $env) and ([.nvmrc .node-version] | path exists | any { |it| $it }) {
        fnm use --install-if-missing
    }
}]

$env.config.menus = $menus
$env.config.keybindings = $keybinds

use ./config/aliases.nu *
source ./config/theme.nu

source ~/.dotfiles.local.nu
source ~/.local.nu
