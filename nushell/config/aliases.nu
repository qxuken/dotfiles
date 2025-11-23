export alias la = ls -a
export alias ll = ls -al
export alias l = la

# take command from zsh
export def --env take [dir_name?: string] {
    let dir_name = if not ($dir_name | is-empty) { $dir_name } else { $in }
    mkdir $dir_name
    cd $dir_name
    l .. | where name == $"../($dir_name)"
}
export alias t = take

# # MacOS fix
# export alias nopen = open
# export alias open = ^open

