#!/usr/bin/env bash
# Create versioned rockspec from template

set -euo pipefail

VERSION="${1:-}"

# Extract repository info from git remote or use defaults
REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "")
if [ -n "$REMOTE_URL" ]; then
  REPO_OWNER=$(echo "$REMOTE_URL" | grep -oP 'github\.com[:/]\K[^/]+(?=/[^/]+(\.git)?$)' || echo "yousefhadder")
  REPO_NAME=$(echo "$REMOTE_URL" | grep -oP 'github\.com[:/][^/]+/\K[^/]+' | sed 's/\.git$//' || echo "markdown-plus.nvim")
else
  REPO_OWNER="yousefhadder"
  REPO_NAME="markdown-plus.nvim"
fi

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
  # Update URL and add tag on the next line
  print "  url = \"git://github.com/" owner "/" repo ".git\","
  print "  tag = \"v" version "\","
  next
}
/^  tag = "v.*",?$/ {
  # Skip existing tag line since we already added it above
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
