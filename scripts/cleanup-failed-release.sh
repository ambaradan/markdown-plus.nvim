#!/usr/bin/env bash
# Cleanup after failed release

set -euo pipefail

VERSION="${1:-}"
BRANCH="${2:-}"
PR_NUMBER="${3:-}"

if [ -z "$VERSION" ]; then
  echo "Error: Version argument required"
  echo "Usage: $0 <version> [branch] [pr_number]"
  exit 1
fi

echo "⚠️  Cleaning up failed release for v${VERSION}..."

# Delete the tag if it was created
if git rev-parse "v${VERSION}" >/dev/null 2>&1; then
  echo "Deleting tag v${VERSION}..."
  git push --delete origin "v${VERSION}" 2>/dev/null || true
  git tag -d "v${VERSION}" 2>/dev/null || true
fi

# Close the PR if it was created
if [ -n "$PR_NUMBER" ]; then
  echo "Closing PR #${PR_NUMBER}..."
  gh pr close "$PR_NUMBER" --comment "Closing due to workflow failure. Please check logs and retry." 2>/dev/null || true
fi

# Delete the branch if it was created
if [ -n "$BRANCH" ]; then
  echo "Deleting branch ${BRANCH}..."
  git push --delete origin "$BRANCH" 2>/dev/null || true
fi

# Delete the GitHub release if it was created
echo "Attempting to delete GitHub release (if exists)..."
gh release delete "v${VERSION}" --yes 2>/dev/null || true

echo "✓ Cleanup complete. Please fix issues and try again."
