#!/usr/bin/env bash
# Update CHANGELOG.md with new version

set -euo pipefail

VERSION="${1:-}"

if [ -z "$VERSION" ]; then
  echo "Error: Version argument required"
  echo "Usage: $0 <version>"
  exit 1
fi

DATE=$(date +%Y-%m-%d)
TMP_FILE=$(mktemp)

# Extract repository path from git remote
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
if [ -n "$REMOTE_URL" ]; then
  REPO_PATH=$(echo "$REMOTE_URL" | grep -oP 'github\.com[:/]\K[^/]+/[^/]+' | sed 's/\.git$//' || echo "YousefHadder/markdown-plus.nvim")
else
  REPO_PATH="YousefHadder/markdown-plus.nvim"
fi

echo "Updating CHANGELOG.md for version $VERSION..."

# Update the changelog
awk -v version="$VERSION" -v date="$DATE" '
/^## \[Unreleased\]$/ {
  # Add new empty Unreleased section
  print "## [Unreleased]\n"
  print "---\n"
  # Add the new version section
  print "## [" version "] - " date
  in_unreleased = 1
  next
}
/^## \[/ && in_unreleased {
  # End of unreleased section, continue normally
  in_unreleased = 0
}
{ print }
' CHANGELOG.md > "$TMP_FILE"

# Add version comparison link if not already present
if ! grep -q "^\[${VERSION}\]:" "$TMP_FILE"; then
  # Get the previous version from changelog
  PREV_VERSION=$(grep -oP '^\[\K[0-9]+\.[0-9]+\.[0-9]+(?=\]:)' "$TMP_FILE" | head -1)
  
  if [ -n "$PREV_VERSION" ]; then
    # Insert new link before the first existing version link
    sed -i "/^\[${PREV_VERSION}\]:/i [${VERSION}]: https://github.com/${REPO_PATH}/compare/v${PREV_VERSION}...v${VERSION}" "$TMP_FILE"
  else
    # If no previous version found, just append
    echo "[${VERSION}]: https://github.com/${REPO_PATH}/releases/tag/v${VERSION}" >> "$TMP_FILE"
  fi
fi

# Replace original file
mv "$TMP_FILE" CHANGELOG.md

echo "✓ Updated CHANGELOG.md"
echo ""
echo "First 30 lines:"
head -30 CHANGELOG.md
