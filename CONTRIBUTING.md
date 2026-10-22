# Contributing

Thanks for considering a contribution to DisplayVolumeKeys.

## Development setup

You need macOS 13 or later, Swift 6, and an Apple silicon Mac. Install
[`m1ddc`](https://github.com/waydabber/m1ddc) to test against a physical
DDC-capable display.

Build the app and run the portable unit/fail-safe checks with:

```sh
./build.sh
```

The resulting application is written to `dist/DisplayVolumeKeys.app`. Without
a signing certificate, use `DISPLAY_VOLUME_KEYS_SIGN_IDENTITY=- ./build.sh` or
create one with `scripts/create-signing-identity.sh` (see the README).

With a full Xcode installation, the XCTest target can also be run directly and
is run automatically by `./build.sh`:

```sh
swift test
```

The standalone `swift test` command requires Xcode because the Command Line
Tools package does not include the XCTest framework headers.

## Pull requests

- Keep changes focused and explain the user-facing behavior.
- Add or update verification coverage when changing core behavior.
- Run `./build.sh` before opening the pull request.
- Do not commit build output, signing certificates, or machine-specific files.

By contributing, you agree that your contribution is licensed under the MIT
License.

## Releasing

Releases are built and signed by the `Release` workflow with the
`DisplayVolumeKeys Signing` certificate. It needs these repository secrets:

- `SIGNING_CERTIFICATE_P12`: the base64-encoded `.p12` file written by
  `scripts/create-signing-identity.sh`
- `SIGNING_CERTIFICATE_PASSWORD`: its password
- `HOMEBREW_TAP_TOKEN` (optional): a fine-grained token with write access to
  the contents of `ari92p/homebrew-tap`, used to update the cask. Run the
  `Release` workflow manually to check the token without publishing anything.

Always sign releases with the same certificate. A new certificate makes macOS
ask every user to grant the Accessibility permission again.

To publish a release:

1. Raise `CFBundleShortVersionString` and `CFBundleVersion` in
   `Resources/Info.plist` and commit.
2. Tag the commit with the version and push the tag:

   ```sh
   git tag v1.0.0
   git push origin v1.0.0
   ```

The workflow checks that the tag matches `Info.plist`, builds and signs the
app, publishes the ZIP as a GitHub release and updates the Homebrew cask.
