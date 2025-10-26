#!/usr/bin/env bash
# Create release pull request

set -euo pipefail

VERSION="${1:-}"
BRANCH="${2:-}"
TARGET_BRANCH="${3:-main}"
DRY_RUN="${4:-false}"
PUBLISH_TO_LUAROCKS="${5:-false}"

if [ -z "$VERSION" ] || [ -z "$BRANCH" ]; then
  echo "Error: Version and branch arguments required"
  echo "Usage: $0 <version> <branch> [target_branch] [dry_run] [publish_to_luarocks]"
  exit 1
fi

PR_BODY="Automated release PR for v${VERSION}

## Changes
- Updates CHANGELOG.md with v${VERSION} release notes
- Creates versioned rockspec: \`markdown-plus.nvim-${VERSION}-1.rockspec\`

## Pre-release Checks
✅ Tests passed
✅ Linting passed
✅ Formatting verified
✅ Version validation passed

---

$(if [ "$DRY_RUN" = "true" ]; then echo "🔍 **DRY RUN MODE** - This PR will NOT be auto-merged. Please review and merge manually."; else echo "🤖 This PR will be **auto-merged** after CI passes."; fi)

$(if [ "$TARGET_BRANCH" != "main" ]; then echo "⚠️ **TEST MODE** - Targeting branch: $TARGET_BRANCH"; fi)

After merge, the workflow will automatically:
1. Create git tag v${VERSION}
2. Create GitHub release with release notes
$(if [ "$PUBLISH_TO_LUAROCKS" = "true" ]; then echo "3. Publish to LuaRocks"; fi)"

PR_URL=$(gh pr create \
  --title "Release v${VERSION}" \
  --body "$PR_BODY" \
  --base "$TARGET_BRANCH" \
  --head "$BRANCH" \
  --label "release")

PR_NUMBER=$(echo "$PR_URL" | grep -oP '\d+$')

echo "pr_number=$PR_NUMBER"
echo "pr_url=$PR_URL"

echo "✓ Created PR #${PR_NUMBER}: $PR_URL"
