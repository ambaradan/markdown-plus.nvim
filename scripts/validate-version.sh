#!/usr/bin/env bash
# Validate version format and progression

set -euo pipefail

VERSION="${1:-}"

if [ -z "$VERSION" ]; then
  echo "Error: Version argument required"
  echo "Usage: $0 <version>"
  exit 1
fi

# Validate format (X.Y.Z)
if ! [[ "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: Version must be in format X.Y.Z (e.g., 1.3.0)"
  exit 1
fi

echo "✓ Version format is valid: $VERSION"

# Check if tag already exists
if git rev-parse "v${VERSION}" >/dev/null 2>&1; then
  echo "Error: Tag v${VERSION} already exists"
  exit 1
fi

echo "✓ Tag v${VERSION} does not exist yet"

# Validate version progression
LATEST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "0.0.0")
LATEST_VERSION=${LATEST_TAG#v}

echo "Latest version: $LATEST_VERSION"
echo "New version: $VERSION"

if [ "$VERSION" = "$LATEST_VERSION" ]; then
  echo "Error: New version must be different from latest version"
  exit 1
fi

# Use sort -V to check version ordering
HIGHER=$(printf "%s\n%s\n" "$LATEST_VERSION" "$VERSION" | sort -V | tail -1)
if [ "$HIGHER" != "$VERSION" ]; then
  echo "⚠️  Warning: New version ($VERSION) is not higher than latest ($LATEST_VERSION)"
  echo "This might be intentional for hotfixes, but please verify."
else
  echo "✓ Version progression is valid"
fi

echo "✓ All version checks passed"
