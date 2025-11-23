export alias gf = git fetch
export alias gs = git status
export alias gp = git push
export alias gg = git pull
export alias gc = git commit
export alias ga = git add

export alias f   = fossil
export alias fo  = fossil open ./repo.fossil    # Open ./repo.fossil file
export alias fu  = fossil update                # Used for pulling and checkouting branches
export alias fa  = fossil addremove             # Add files
export alias fc  = fossil commit                # Create new revision
export alias fbn = fossil branch new            # Create new branch
export def fb [] { fossil diff | bat }          # Pipe output of a diff to bat
export def fn [] { fossil diff | nvim }         # Pipe output of a diff to neovim
# Initialize new fossil repo
export def fi [repo: cell-path = ./repo.fossil] {
    fossil new $repo
    fossil open -f -k $repo
}
