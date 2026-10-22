#!/bin/zsh

# Creates the self-signed "DisplayVolumeKeys Signing" certificate and imports
# it into the login keychain. macOS ties the Accessibility approval to this
# certificate, so builds signed with it keep the approval across updates.
#
# The script also writes a password-protected .p12 file for the GitHub
# release workflow. Keep that file private and outside the repository.

set -euo pipefail

readonly NAME="DisplayVolumeKeys Signing"

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <output-directory>" >&2
  exit 64
fi

if /usr/bin/security find-identity -p codesigning 2>/dev/null | /usr/bin/grep -q "\"$NAME\""; then
  echo "A \"$NAME\" identity already exists in your keychain." >&2
  exit 1
fi

readonly OUT_DIR="${1:A}"
mkdir -p "$OUT_DIR"
chmod 700 "$OUT_DIR"

work_dir="$(/usr/bin/mktemp -d)"
trap '/bin/rm -rf "$work_dir"' EXIT

# Apple's LibreSSL writes PKCS#12 files that `security import` accepts.
/usr/bin/openssl req -x509 -newkey rsa:2048 -nodes -days 3650 \
  -subj "/CN=$NAME" \
  -addext "basicConstraints=critical,CA:false" \
  -addext "keyUsage=critical,digitalSignature" \
  -addext "extendedKeyUsage=critical,codeSigning" \
  -keyout "$work_dir/key.pem" -out "$work_dir/cert.pem" 2>/dev/null

password="$(/usr/bin/openssl rand -base64 24)"
p12="$OUT_DIR/DisplayVolumeKeys-signing.p12"
/usr/bin/openssl pkcs12 -export -name "$NAME" \
  -inkey "$work_dir/key.pem" -in "$work_dir/cert.pem" \
  -out "$p12" -passout "pass:$password"
chmod 600 "$p12"
print -r -- "$password" > "$OUT_DIR/DisplayVolumeKeys-signing.password"
chmod 600 "$OUT_DIR/DisplayVolumeKeys-signing.password"

/usr/bin/security import "$p12" -P "$password" -T /usr/bin/codesign

echo "Imported \"$NAME\" into the login keychain."
echo
echo "For signed GitHub releases, add these repository secrets:"
echo "  SIGNING_CERTIFICATE_P12:      base64 -i \"$p12\" | pbcopy"
echo "  SIGNING_CERTIFICATE_PASSWORD: pbcopy < \"$OUT_DIR/DisplayVolumeKeys-signing.password\""
