#!/bin/zsh

# Sets the version and checksum of the Homebrew cask in ari92p/homebrew-tap.

set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <cask-file> <version> <sha256>" >&2
  exit 64
fi

readonly CASK="$1" VERSION="$2" SHA256="$3"

if [[ ! "$VERSION" =~ '^[0-9]+\.[0-9]+\.[0-9]+$' || ! "$SHA256" =~ '^[0-9a-f]{64}$' ]]; then
  echo "Invalid version or checksum." >&2
  exit 64
fi

/usr/bin/sed -i '' -E \
  -e "s/^  version \"[^\"]*\"/  version \"$VERSION\"/" \
  -e "s/^  sha256 \"[^\"]*\"/  sha256 \"$SHA256\"/" \
  "$CASK"

/usr/bin/grep -q "^  version \"$VERSION\"$" "$CASK"
/usr/bin/grep -q "^  sha256 \"$SHA256\"$" "$CASK"
