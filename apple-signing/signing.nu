# qd imports this module as "signing". Credentials exist in its installed directory.
const root = (path self .)
const profiles_path = ($root | path join .profiles.secret.toml)

def canonical [repo: string] {
    if $repo !~ '^[A-Za-z0-9][A-Za-z0-9-]*/[A-Za-z0-9_.-]+$' {
        error make {msg: "Expected a GitHub owner/repo"}
    }
    $repo | str lowercase
}

# Use the macOS system LibreSSL for Keychain exports encrypted with RC2-40.
def inspect-cert [password: string] {
    let cert = ($root | path join developer-id.cer)
    let bundle = ($root | path join developer-id.p12)
    let leaf = (($password + (char nl)) | ^/usr/bin/openssl pkcs12 -in $bundle -passin stdin -clcerts -nokeys | complete)
    if $leaf.exit_code != 0 {
        let reason = ($leaf.stderr | str trim)
        error make {msg: $"Could not read the signing export: ($reason)"}
    }
    let expected = (^/usr/bin/openssl x509 -inform DER -in $cert -noout -fingerprint -sha256)
    let actual = ($leaf.stdout | ^/usr/bin/openssl x509 -noout -fingerprint -sha256)
    if $expected != $actual { error make {msg: "The PKCS#12 leaf differs from developer-id.cer"} }
    let valid = (^/usr/bin/openssl x509 -inform DER -in $cert -checkend 0 -noout | complete)
    if $valid.exit_code != 0 { error make {msg: "Developer ID certificate expired"} }
    let fields = (^/usr/bin/openssl x509 -inform DER -in $cert -noout -subject -nameopt sep_multiline,utf8
        | lines | each { str trim } | parse "{key}={value}")
    let identity = ($fields | where key == CN | first | get value)
    let team = ($fields | where key == OU | first | get value)
    if not ($identity | str starts-with 'Developer ID Application: ') or $team !~ '^[A-Z0-9]{10}$' {
        error make {msg: "Expected an Apple Developer ID Application identity"}
    }
    {identity: $identity, team: $team}
}

def encode-field [row: record, key: string] {
    if $key not-in $row { return $row }
    $row | insert $"($key)_b64" ($row | get $key | encode base64) | reject $key
}

# Accept the original plaintext field until the profile is next saved.
def read-password [row: record, key: string] {
    let encoded = $"($key)_b64"
    if $encoded in $row {
        $row | get $encoded | decode base64 | decode utf-8
    } else { $row | get $key }
}

def save-profiles [profiles: record] {
    mut stored = (encode-field $profiles certificate_password)
    for section in [accounts repositories] {
        mut rows = ($stored | get $section)
        for name in ($rows | columns) {
            let row = ($rows | get $name)
            if ($row | describe) != string {
                $rows = ($rows | upsert $name (encode-field $row app_password))
            }
        }
        $stored = ($stored | update $section $rows)
    }
    let tmp = (mktemp --tmpdir-path $root '.profiles-XXXXXXXX')
    try {
        $stored | to toml | save --force --raw $tmp
        mv -f $tmp $profiles_path
    } catch {
        rm -f $tmp
        error make {msg: "Could not save signing profiles"}
    }
}

def prompt-profile [name: string, email: string] {
    let password = (input -s $"Apple app-specific password for ($name): " | str trim)
    if ($password | is-empty) { error make {msg: $"A password is required for ($name)"} }
    {email: $email, app_password: $password}
}

# Initialize the installed credential store and bind one or more repositories.
export def init [repo: string, ...others: string] {
    if not (($root | path join developer-id.p12) | path exists) {
        error make {msg: "Restore the signing module with qd push first"}
    }
    if ($profiles_path | path exists) { error make {msg: "Already initialized. Use signing add for another repository."} }
    let names = ([$repo] | append $others | each {|r| canonical $r } | uniq)
    let pwd = (input -s 'PKCS#12 export password: ')
    inspect-cert $pwd | ignore
    let email = (input 'Apple Account email: ' | str trim)
    if ($email | is-empty) { error make {msg: "Apple Account email is required"} }
    mut repos = {}
    for name in $names {
        $repos = ($repos | upsert $name (prompt-profile $name $email))
    }
    save-profiles {certificate_password: $pwd, accounts: {default: {email: $email}}, repositories: $repos}
}

# Older profiles reference a named account. New entries hold the repo's credentials.
def repo-profile [config: record, name: string] {
    let entry = ($config.repositories | get $name)
    if ($entry | describe) == string { $config.accounts | get $entry } else { $entry }
}

# Add a repository or replace its local notarization password.
export def add [repo: string, --account: string] {
    let name = (canonical $repo)
    let config = (open $profiles_path)
    let email = if $account != null {
        if $account not-in $config.accounts { error make {msg: "Unknown notarization account"} }
        $config.accounts | get $account | get email
    } else if $name in $config.repositories {
        repo-profile $config $name | get email
    } else { $config.accounts.default.email }
    let repositories = ($config.repositories | upsert $name (prompt-profile $name $email))
    save-profiles ($config | update repositories $repositories)
}

def credentials [repo: string] {
    let name = (canonical $repo)
    let config = (open $profiles_path)
    if $name not-in $config.repositories { error make {msg: $"Run signing add ($name) first"} }
    let account = (repo-profile $config $name)
    let pwd = (read-password $config certificate_password)
    let cert = (inspect-cert $pwd)
    {
        MACOS_CERTIFICATE_P12: (open --raw ($root | path join developer-id.p12) | encode base64)
        MACOS_CERTIFICATE_PASSWORD: $pwd
        MACOS_SIGN_IDENTITY: $cert.identity
        APPLE_TEAM_ID: $cert.team
        APPLE_ID: $account.email
        APPLE_APP_PASSWORD: (read-password $account app_password)
    }
}

# Validate local inputs and repository access. Prints public metadata only.
export def check [repo: string] {
    let name = (canonical $repo)
    let secrets = (credentials $name)
    let target = (^gh repo view $"github.com/($name)" --json nameWithOwner --jq .nameWithOwner)
    if ($target | str lowercase) != $name { error make {msg: "GitHub resolved a different repository"} }
    {repository: $target, identity: $secrets.MACOS_SIGN_IDENTITY, team: $secrets.APPLE_TEAM_ID}
}

# Set repository Actions secrets. Each write is independently retryable.
export def populate [repo: string] {
    let target = (check $repo | get repository)
    let secrets = (credentials $target)
    for entry in ($secrets | transpose name value) {
        print $"Setting ($entry.name) on ($target)"
        let result = ($entry.value | ^gh secret set $entry.name --repo $"github.com/($target)" | complete)
        if $result.exit_code != 0 { error make {msg: $"GitHub could not set ($entry.name) on ($target); rerun populate after resolving access"} }
    }
}
