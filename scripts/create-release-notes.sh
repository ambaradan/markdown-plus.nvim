#!/usr/bin/env bash
# Create enhanced release notes

set -euo pipefail

VERSION="${1:-}"
CHANGELOG_CONTENT="${2:-}"

# Extract repository info from git remote or use defaults
REPO_PATH=$(git remote get-url origin 2>/dev/null | grep -oP 'github\.com[:/]\K[^/]+/[^/]+' | sed 's/\.git$//' || echo "YousefHadder/markdown-plus.nvim")

if [ -z "$VERSION" ]; then
  echo "Error: Version argument required"
  echo "Usage: $0 <version> <changelog_content_file>"
  exit 1
fi

PREV_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "v0.0.0")

cat << EOF
$(cat "$CHANGELOG_CONTENT" 2>/dev/null || echo "Release v${VERSION}")

---

## Installation

### Via LuaRocks
\`\`\`bash
luarocks install markdown-plus.nvim ${VERSION}
\`\`\`

### Via lazy.nvim
\`\`\`lua
{
  "${REPO_PATH}",
  version = "v${VERSION}",
  ft = "markdown",
  config = function()
    require("markdown-plus").setup()
  end,
}
\`\`\`

### Via packer.nvim
\`\`\`lua
use {
  "${REPO_PATH}",
  tag = "v${VERSION}",
  ft = "markdown",
}
\`\`\`

---

**Full Changelog**: https://github.com/YousefHadder/markdown-plus.nvim/compare/${PREV_VERSION}...v${VERSION}
EOF
