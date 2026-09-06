# Nushell integration for qd. `use` this file from your config.
#
#   use ~/dotfiles/qd.nu *

def "nu-complete qd modules" [] { ^qd __complete modules | lines }
def "nu-complete qd all-modules" [] { ^qd __complete all-modules | lines }

# Repo → machine
export extern "qd push" [
  ...modules: string@"nu-complete qd modules"
  --sync (-s)      # pull the git remote first
  --dry-run
  --no-remove
  --no-compile
  --force
]
# Machine → repo
export extern "qd pull" [
  ...modules: string@"nu-complete qd modules"
  --sync (-s): string  # commit and push with this message
  --dry-run
  --no-remove
  --no-compile
]
export extern "qd status" [
  ...modules: string@"nu-complete qd modules"
  --pull
  --json
]
export extern "qd show" [
  module?: string@"nu-complete qd all-modules"
  --all
  --format: string
]

export alias dph = qd push
export alias dpl = qd pull
export alias dst = qd status
