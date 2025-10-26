#!/usr/bin/env bash
# Create versioned rockspec from template

set -euo pipefail

VERSION="${1:-}"

# Extract repository info from git remote or use defaults
REPO_OWNER=$(git remote get-url origin 2>/dev/null | grep -oP 'github\.com[:/]\K[^/]+(?=/[^/]+(\.git)?$)' || echo "yousefhadder")
REPO_NAME=$(git remote get-url origin 2>/dev/null | grep -oP 'github\.com[:/][^/]+/\K[^/]+' | sed 's/\.git$//' || echo "markdown-plus.nvim")

if [ -z "$VERSION" ]; then
  echo "Error: Version argument required"
  echo "Usage: $0 <version>"
  exit 1
fi

ROCKSPEC_FILE="rockspecs/${REPO_NAME}-${VERSION}-1.rockspec"

echo "Creating rockspec for version $VERSION..."

# Use awk for reliable rockspec creation
awk -v version="$VERSION" -v owner="$REPO_OWNER" -v repo="$REPO_NAME" '
/^version = / { 
  print "version = \"" version "-1\""
  next 
}
/^  url = "git:\/\/github.com\/.*\.git",?$/ {
  has_comma = /,$/
  print "  url = \"git://github.com/" owner "/" repo ".git\"" (has_comma ? "," : "")
  next
}
/^  tag = "v.*",?$/ {
  has_comma = /,$/
  print "  tag = \"v" version "\"" (has_comma ? "," : "")
  next
}
{ print }
' rockspecs/markdown-plus.nvim-scm-1.rockspec > "$ROCKSPEC_FILE"

# Validate the rockspec was created correctly
if ! grep -q "version = \"${VERSION}-1\"" "$ROCKSPEC_FILE"; then
  echo "Error: Version not updated in rockspec"
  exit 1
fi

if ! grep -q "tag = \"v${VERSION}\"" "$ROCKSPEC_FILE"; then
  echo "Error: Tag not added to rockspec"
  exit 1
fi

echo "✓ Rockspec created and validated: $ROCKSPEC_FILE"
echo ""
cat "$ROCKSPEC_FILE"
