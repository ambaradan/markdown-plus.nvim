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

# Verify GitHub CLI is authenticated (for PR and release operations)
if [ -n "$PR_NUMBER" ] || [ -n "$BRANCH" ]; then
  if ! gh auth status >/dev/null 2>&1; then
    echo "⚠️  Warning: GitHub CLI is not authenticated"
    echo "Some cleanup operations may fail (PR close, release delete)"
  fi
fi

echo "⚠️  Cleaning up failed release for v${VERSION}..."

# Delete the tag if it was created
if git rev-parse "v${VERSION}" >/dev/null 2>&1; then
  echo "Deleting tag v${VERSION}..."
  git push --delete origin "v${VERSION}" 2>/dev/null || true
  git tag -d "v${VERSION}" 2>/dev/null || true
fi

# Close the PR if it was created
if [ -n "$PR_NUMBER" ] && [ "$PR_NUMBER" != "null" ]; then
  echo "Closing PR #${PR_NUMBER}..."
  if gh pr close "$PR_NUMBER" --comment "Closing due to workflow failure. Please check logs and retry." 2>/dev/null; then
    echo "✓ Closed PR #${PR_NUMBER}"
  else
    echo "⚠️  Could not close PR #${PR_NUMBER} (may already be closed)"
  fi
fi

# Delete the branch if it was created
if [ -n "$BRANCH" ] && [ "$BRANCH" != "null" ] && [ "$BRANCH" != "" ]; then
  echo "Deleting branch ${BRANCH}..."
  if git push --delete origin "$BRANCH" 2>/dev/null; then
    echo "✓ Deleted remote branch ${BRANCH}"
  else
    echo "⚠️  Could not delete remote branch ${BRANCH} (may not exist)"
  fi
  
  # Also delete local branch if we're not currently on it
  CURRENT_BRANCH="$(git rev-parse --abbrev-ref HEAD)"
  if [ "$CURRENT_BRANCH" != "$BRANCH" ]; then
    if git branch -D "$BRANCH" 2>/dev/null; then
      echo "✓ Deleted local branch ${BRANCH}"
    else
      echo "⚠️  Could not delete local branch ${BRANCH} (may not exist or is checked out)"
    fi
  fi
fi

# Delete the GitHub release if it was created
echo "Attempting to delete GitHub release (if exists)..."
gh release delete "v${VERSION}" --yes 2>/dev/null || true

echo "✓ Cleanup complete. Please fix issues and try again."
