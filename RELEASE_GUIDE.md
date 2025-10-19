# Release Guide for markdown-plus.nvim

This guide explains how to create and publish releases for markdown-plus.nvim.

## Prerequisites

1. ✓ Git installed and configured
2. ✓ GitHub CLI (`gh`) installed (optional but recommended)
3. ✓ Push access to the repository
4. ✓ All changes committed and pushed to `main` branch

## Release Checklist

Before creating a release, ensure:

- [ ] All tests pass
- [ ] Documentation is up to date (`doc/markdown-plus.txt`)
- [ ] CHANGELOG.md is updated with new features/fixes
- [ ] README.md reflects current functionality
- [ ] No uncommitted changes (`git status` is clean)

## Release Process

### Option 1: Using GitHub CLI (Recommended)

The fastest way to create a release:

```bash
# 1. Make sure you're on main and up to date
git checkout main
git pull origin main

# 2. Create and push a tag
git tag -a v1.0.0 -m "Release v1.0.0: Initial stable release"
git push origin v1.0.0

# 3. Create GitHub release with changelog
gh release create v1.0.0 \
  --title "v1.0.0 - Initial Release" \
  --notes-file CHANGELOG.md \
  --latest

# Alternative: Open browser to edit release notes
gh release create v1.0.0 --generate-notes --draft --web
```

### Option 2: Using Git + GitHub Web Interface

Step-by-step manual process:

#### Step 1: Create a Git Tag

```bash
# 1. Make sure you're on main
git checkout main
git pull origin main

# 2. Create an annotated tag (replace v1.0.0 with your version)
git tag -a v1.0.0 -m "Release v1.0.0: Initial stable release"

# 3. Push the tag to GitHub
git push origin v1.0.0

# View your tags
git tag -l
```

#### Step 2: Create GitHub Release

1. Go to your repository on GitHub: https://github.com/YousefHadder/markdown-plus.nvim
2. Click on **"Releases"** (right sidebar)
3. Click **"Draft a new release"**
4. Fill in the form:
   - **Tag**: Select `v1.0.0` (or type it if not pushed yet)
   - **Target**: `main` branch
   - **Title**: `v1.0.0 - Initial Release`
   - **Description**: Copy from CHANGELOG.md or write release notes
5. Check **"Set as the latest release"**
6. Click **"Publish release"**

#### Step 3: Verify Release

```bash
# Check that tag exists
git tag -l

# View tag details
git show v1.0.0

# Fetch and verify on GitHub
gh release list  # if you have gh CLI
```

## Versioning Strategy

This project follows [Semantic Versioning](https://semver.org/):

- **MAJOR** (v2.0.0): Breaking changes, incompatible API changes
- **MINOR** (v1.1.0): New features, backward compatible
- **PATCH** (v1.0.1): Bug fixes, backward compatible

### Version Examples

- `v1.0.0` - Initial stable release
- `v1.1.0` - Added new feature (task list toggling)
- `v1.1.1` - Fixed bug in list renumbering
- `v2.0.0` - Changed keymap prefix (breaking change)

## Release Notes Template

When creating a release, use this template:

```markdown
## 🎉 What's New in v1.0.0

### ✨ Features
- **Headers**: Navigate, promote/demote, generate TOC
- **Lists**: Auto-continuation, smart indentation, renumbering
- **Formatting**: Toggle bold, italic, strikethrough, code

### 🐛 Bug Fixes
- Fixed list operations entering insert mode correctly
- Fixed TOC duplicate prevention

### 📚 Documentation
- Complete help file (`:help markdown-plus`)
- API documentation for developers

### 🔧 Technical
- Context-aware keymaps
- Buffer-local mappings
- Zero configuration required

## Installation

```lua
{
  'YousefHadder/markdown-plus.nvim',
  ft = 'markdown',
  opts = {},
}
```

## Full Changelog

See [CHANGELOG.md](CHANGELOG.md) for complete details.
```

## Automation with GitHub Actions (Optional)

Create `.github/workflows/release.yml` to automate releases:

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          body_path: CHANGELOG.md
          draft: false
          prerelease: false
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Quick Commands Reference

```bash
# Create and push tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# Delete tag (if needed)
git tag -d v1.0.0
git push origin :refs/tags/v1.0.0

# List all tags
git tag -l

# Create release with gh CLI
gh release create v1.0.0 --title "v1.0.0" --notes-file CHANGELOG.md

# View releases
gh release list

# Delete release (if needed)
gh release delete v1.0.0
```

## After Release

1. ✓ Update README.md to reference the new version
2. ✓ Tweet/share the release (optional)
3. ✓ Update package manager registries if applicable
4. ✓ Start working on next version in CHANGELOG.md under `[Unreleased]`

## Package Manager Registries

### LuaRocks (Optional)

If you want to publish to LuaRocks:

1. Create account on luarocks.org
2. Create `markdown-plus.nvim-1.0.0-1.rockspec`
3. Upload: `luarocks upload markdown-plus.nvim-1.0.0-1.rockspec`

### Mason Registry (Optional)

For Mason.nvim integration, submit PR to:
https://github.com/williamboman/mason-registry

## Troubleshooting

### Tag already exists
```bash
# Delete local tag
git tag -d v1.0.0

# Delete remote tag
git push origin :refs/tags/v1.0.0

# Recreate tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

### Release not showing as latest
- Edit the release on GitHub
- Check "Set as the latest release"
- Save

### Wrong target branch
- Delete the release (not the tag)
- Recreate release selecting correct target

## Resources

- [GitHub Releases Documentation](https://docs.github.com/en/repositories/releasing-projects-on-github)
- [Semantic Versioning](https://semver.org/)
- [Keep a Changelog](https://keepachangelog.com/)
- [GitHub CLI Releases](https://cli.github.com/manual/gh_release)

---

**Ready to release?** Follow Option 1 or Option 2 above!
