# Apple release signing

Share one Developer ID Application certificate across GitHub repositories. Each `owner/repo` gets its own Apple app-specific password for notarization.

## Restore on a Mac

With the dotfiles age identity configured, run from `~/dotfiles`:

```nu
qd tag add apple-signing
qd push apple-signing
use ~/.config/apple-signing/signing.nu
```

## Initialize once

`signing init qxuken/kui qxuken/carnet` creates **one local file**, `~/.config/apple-signing/profiles.toml`. If `qd push` already restored that file, skip init.

1. Requires the restored `developer-id.p12` and stops if `profiles.toml` exists. Validates each `owner/repo` argument and lowercases it.
2. Prompts for the export password (hidden). Opens the existing .p12, compares its leaf certificate’s SHA-256 fingerprint with `developer-id.cer`, and checks expiry, the Developer ID Application name, and the team ID format.
3. Asks once for the Apple Account email, then prompts separately for each repository’s app-specific password (hidden). Enter a separately generated Apple password for each repo.
4. Writes the shared export password, default email, and a separate email/password entry for each repo. Password fields use reversible base64 (`*_b64`) to avoid literal password matches in casual searches. Anyone who can read the local TOML can recover them. Its permissions are owner-only (0600).

Run `qd pull apple-signing` to encrypt the profile into dotfiles, then commit the .age files. Recipients in `master.rec` can decrypt both the profile and the .p12 containing the signing key.

## Use

```nu
signing add qxuken/kawoosh        # prompt for this repo’s password
signing check qxuken/kawoosh      # validate the certificate and resolve the repo with gh
signing populate qxuken/kawoosh   # set or replace all six repository Actions secrets
qd pull apple-signing             # save the updated mapping
```

Populate sends `MACOS_CERTIFICATE_P12` (base64), `MACOS_CERTIFICATE_PASSWORD`, `MACOS_SIGN_IDENTITY`, `APPLE_TEAM_ID`, `APPLE_ID`, and `APPLE_APP_PASSWORD` to `gh` via stdin. The signing identity and team ID come from the certificate. Rerun populate after a partial failure or credential rotation. For an existing shared profile, run `signing add owner/repo` to give that repo a separate password, then populate it and pull the module. Other repos keep their existing credentials. The optional `--account name` selects the email from a named account in the installed TOML.
