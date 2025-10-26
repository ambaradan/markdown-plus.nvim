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

# Verify GitHub CLI is authenticated
if ! gh auth status >/dev/null 2>&1; then
  echo "Error: GitHub CLI is not authenticated"
  echo "Please run 'gh auth login' or set GH_TOKEN environment variable"
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

# Check that PR_URL is non-empty and looks like a GitHub PR URL
if [[ -z "$PR_URL" || ! "$PR_URL" =~ ^https://github\.com/[^/]+/[^/]+/pull/[0-9]+$ ]]; then
  echo "Error: Failed to create PR or unexpected output from gh pr create: '$PR_URL'"
  exit 1
fi

PR_NUMBER=$(echo "$PR_URL" | grep -oP '\d+$')

echo "pr_number=$PR_NUMBER"
echo "pr_url=$PR_URL"

echo "✓ Created PR #${PR_NUMBER}: $PR_URL"
