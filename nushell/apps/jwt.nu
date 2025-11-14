module completions {

  # A super fast CLI tool to decode and encode JWTs built in Rust
  export extern jwt [
    --help(-h)                # Print help
    --version(-V)             # Print version
  ]

  def "nu-complete jwt encode algorithm" [] {
    [ "HS256" "HS384" "HS512" "RS256" "RS384" "RS512" "PS256" "PS384" "PS512" "ES256" "ES384" "EDDSA" ]
  }

  def "nu-complete jwt encode type" [] {
    [ "jwt" ]
  }

  # Encode new JWTs
  export extern "jwt encode" [
    --alg(-A): string@"nu-complete jwt encode algorithm" # the algorithm to use for signing the JWT
    --kid(-k): string         # the kid to place in the header
    --typ(-t): string@"nu-complete jwt encode type" # the type of token being encoded
    json?: string             # the json payload to encode
    --payload(-P): string     # a key=value pair to add to the payload
    --exp(-e): string         # the time the token should expire, in seconds or a systemd.time string
    --iss(-i): string         # the issuer of the token
    --sub(-s): string         # the subject of the token
    --aud(-a): string         # the audience of the token
    --jti: string             # the jwt id of the token
    --nbf(-n): string         # the time the JWT should become valid, in seconds or a systemd.time string
    --no-iat                  # prevent an iat claim from being automatically added
    --no-typ                  # prevent typ from being added to the header
    --secret(-S): string      # the secret to sign the JWT with. Prefix with @ to read from a file or b64: to use base-64 encoded bytes
    --out(-o): path           # The path of the file to write the result to (suppresses default standard output)
    --keep-payload-order      # prevent re-ordering of payload keys
    --help(-h)                # Print help
    --version(-V)             # Print version
  ]

  def "nu-complete jwt decode algorithm" [] {
    [ "HS256" "HS384" "HS512" "RS256" "RS384" "RS512" "PS256" "PS384" "PS512" "ES256" "ES384" "EDDSA" ]
  }

  # Decode a JWT
  export extern "jwt decode" [
    jwt: string               # The JWT to decode. Provide '-' to read from STDIN
    --alg(-A): string@"nu-complete jwt decode algorithm" # The algorithm used to sign the JWT
    --date: string            # Display unix timestamps as ISO 8601 dates [default: UTC] [possible values: UTC, Local, Offset (e.g. -02:00)]
    --secret(-S): string      # The secret to validate the JWT with. Prefix with @ to read from a file or b64: to use base-64 encoded bytes
    --json(-j)                # Render the decoded JWT as JSON
    --ignore-exp              # Ignore token expiration date (`exp` claim) during validation
    --out(-o): path           # The path of the file to write the result to (suppresses default standard output, implies JSON format)
    --help(-h)                # Print help
    --version(-V)             # Print version
  ]

  def "nu-complete jwt completion shell" [] {
    [ "bash" "elvish" "fish" "powershell" "zsh" "nushell" ]
  }

  # Print completion
  export extern "jwt completion" [
    shell: string@"nu-complete jwt completion shell" # the shell to generate completions for
    --help(-h)                # Print help
    --version(-V)             # Print version
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "jwt help" [
  ]

  # Encode new JWTs
  export extern "jwt help encode" [
  ]

  # Decode a JWT
  export extern "jwt help decode" [
  ]

  # Print completion
  export extern "jwt help completion" [
  ]

  # Print this message or the help of the given subcommand(s)
  export extern "jwt help help" [
  ]

}

export use completions *
