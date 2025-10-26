#!/usr/bin/env bash
# Create versioned rockspec from template

set -euo pipefail

VERSION="${1:-}"

if [ -z "$VERSION" ]; then
  echo "Error: Version argument required"
  echo "Usage: $0 <version>"
  exit 1
fi

ROCKSPEC_FILE="rockspecs/markdown-plus.nvim-${VERSION}-1.rockspec"

echo "Creating rockspec for version $VERSION..."

# Use awk for reliable rockspec creation
awk -v version="$VERSION" '
/^version = / { 
  print "version = \"" version "-1\""
  next 
}
/^  url = "git:\/\/github.com\/yousefhadder\/markdown-plus.nvim.git",?$/ {
  gsub(/,$/, "")
  print $0 ","
  print "  tag = \"v" version "\","
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
