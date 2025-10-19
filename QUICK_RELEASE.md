# Quick Release Instructions

## 🚀 Create Your First Release (v1.0.0)

### The Fastest Way (Using the Script)

```bash
# 1. Commit and push all your changes
git add CHANGELOG.md RELEASE_GUIDE.md QUICK_RELEASE.md scripts/
git commit -m "docs: add release documentation"
git push origin main

# 2. Run the release script
./scripts/release.sh v1.0.0
```

That's it! The script will:
- ✓ Validate you're on `main` with no uncommitted changes
- ✓ Create and push the git tag
- ✓ Create the GitHub release (if you have `gh` CLI)

### Manual Method (If Script Doesn't Work)

```bash
# 1. Create and push tag
git tag -a v1.0.0 -m "Release v1.0.0: Initial stable release"
git push origin v1.0.0

# 2. Go to GitHub and create release
# Visit: https://github.com/YousefHadder/markdown-plus.nvim/releases/new
# - Choose tag: v1.0.0
# - Title: v1.0.0 - Initial Release
# - Copy description from CHANGELOG.md
# - Click "Publish release"
```

### Using GitHub CLI (Recommended)

If you have `gh` CLI installed:

```bash
# Install gh CLI if needed (macOS)
brew install gh

# Login once
gh auth login

# Create tag and release in one go
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
gh release create v1.0.0 --title "v1.0.0 - Initial Release" --notes-file CHANGELOG.md --latest
```

## 📋 Pre-Release Checklist

Before running the release:

- [ ] All changes committed and pushed
- [ ] CHANGELOG.md updated with new features
- [ ] Documentation up to date (doc/markdown-plus.txt)
- [ ] README.md reflects current state
- [ ] Tests passing (if you have any)

## 🎯 What Happens After Release?

1. **Tag Created**: `v1.0.0` tag pushed to GitHub
2. **Release Published**: Visible at https://github.com/YousefHadder/markdown-plus.nvim/releases
3. **Users Can Install**: Using lazy.nvim:
   ```lua
   {
     'YousefHadder/markdown-plus.nvim',
     tag = 'v1.0.0',  -- They can pin to this version
     ft = 'markdown',
   }
   ```

## 🔄 Future Releases

For version 1.1.0 (new features):
```bash
./scripts/release.sh v1.1.0
```

For version 1.0.1 (bug fixes):
```bash
./scripts/release.sh v1.0.1
```

For version 2.0.0 (breaking changes):
```bash
./scripts/release.sh v2.0.0
```

## ⚠️ Troubleshooting

**"Tag already exists"**
```bash
git tag -d v1.0.0
git push origin :refs/tags/v1.0.0
./scripts/release.sh v1.0.0
```

**"You have uncommitted changes"**
```bash
git add .
git commit -m "Your commit message"
./scripts/release.sh v1.0.0
```

**"Not on main branch"**
```bash
git checkout main
./scripts/release.sh v1.0.0
```

## 📚 More Details

See `RELEASE_GUIDE.md` for comprehensive documentation.

---

**Ready?** Run: `./scripts/release.sh v1.0.0`
