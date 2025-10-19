#!/bin/bash

# Release script for markdown-plus.nvim
# Usage: ./scripts/release.sh v1.0.0

set -e # Exit on error

VERSION=$1

if [ -z "$VERSION" ]; then
    echo "❌ Error: Version number required"
    echo "Usage: ./scripts/release.sh v1.0.0"
    exit 1
fi

# Validate version format
if [[ ! $VERSION =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "❌ Error: Invalid version format. Use vX.Y.Z (e.g., v1.0.0)"
    exit 1
fi

echo "🚀 Creating release $VERSION for markdown-plus.nvim"
echo ""

# Check if on main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "❌ Error: Not on main branch (currently on $CURRENT_BRANCH)"
    echo "   Run: git checkout main"
    exit 1
fi

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "❌ Error: You have uncommitted changes"
    echo "   Commit or stash them first"
    exit 1
fi

# Pull latest changes
echo "📥 Pulling latest changes from origin/main..."
git pull origin main

# Check if tag already exists
if git rev-parse "$VERSION" >/dev/null 2>&1; then
    echo "❌ Error: Tag $VERSION already exists"
    echo "   To recreate: git tag -d $VERSION && git push origin :refs/tags/$VERSION"
    exit 1
fi

# Create annotated tag
echo "🏷️  Creating tag $VERSION..."
git tag -a "$VERSION" -m "Release $VERSION"

# Push tag
echo "⬆️  Pushing tag to GitHub..."
git push origin "$VERSION"

echo ""
echo "✅ Tag $VERSION created and pushed successfully!"
echo ""

# Try to create GitHub release with gh CLI
if command -v gh &>/dev/null; then
    echo "🎉 Creating GitHub release with gh CLI..."

    # Extract version from tag for title
    VERSION_NUM=${VERSION#v}

    if [ -f "CHANGELOG.md" ]; then
        # Create release with changelog
        gh release create "$VERSION" \
            --title "$VERSION - Release" \
            --notes-file CHANGELOG.md \
            --latest

        echo ""
        echo "✅ GitHub release created successfully!"
        echo "   View at: https://github.com/YousefHadder/markdown-plus.nvim/releases/tag/$VERSION"
    else
        # Create release with auto-generated notes
        gh release create "$VERSION" \
            --title "$VERSION - Release" \
            --generate-notes \
            --latest

        echo ""
        echo "✅ GitHub release created with auto-generated notes!"
        echo "   Edit at: https://github.com/YousefHadder/markdown-plus.nvim/releases/edit/$VERSION"
    fi
else
    echo "ℹ️  GitHub CLI (gh) not found"
    echo ""
    echo "To create the release manually:"
    echo "1. Go to: https://github.com/YousefHadder/markdown-plus.nvim/releases/new"
    echo "2. Select tag: $VERSION"
    echo "3. Set title: $VERSION - Release"
    echo "4. Copy release notes from CHANGELOG.md"
    echo "5. Click 'Publish release'"
fi

echo ""
echo "📋 Next steps:"
echo "   1. Update README.md if needed"
echo "   2. Start working on next version in CHANGELOG.md"
echo "   3. Announce the release! 🎊"
