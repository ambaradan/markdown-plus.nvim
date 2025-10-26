# Release Scripts

This directory contains reusable scripts for the release automation workflows.

## Scripts

### `validate-version.sh`
**Purpose**: Validates version format and progression  
**Usage**: `./validate-version.sh <version>`  
**Checks**:
- Version follows semver format (X.Y.Z)
- Tag doesn't already exist
- New version is higher than the latest (with warning for hotfixes)

**Example**:
```bash
./scripts/validate-version.sh 1.4.0
```

---

### `extract-changelog.py`
**Purpose**: Extracts unreleased changes from CHANGELOG.md  
**Usage**: `./extract-changelog.py <version>`  
**Output**: Unreleased changelog content (stdout)

**Example**:
```bash
./scripts/extract-changelog.py 1.4.0 > /tmp/changelog.txt
```

---

### `update-changelog.sh`
**Purpose**: Updates CHANGELOG.md with new version  
**Usage**: `./update-changelog.sh <version>`  
**Changes**:
- Moves Unreleased content to versioned section
- Adds new empty Unreleased section
- Adds version comparison links

**Example**:
```bash
./scripts/update-changelog.sh 1.4.0
```

---

### `create-rockspec.sh`
**Purpose**: Creates versioned rockspec from template  
**Usage**: `./create-rockspec.sh <version>`  
**Output**: Creates `rockspecs/markdown-plus.nvim-<version>-1.rockspec`

**Example**:
```bash
./scripts/create-rockspec.sh 1.4.0
```

---

### `create-release-notes.sh`
**Purpose**: Generates enhanced release notes with installation instructions  
**Usage**: `./create-release-notes.sh <version> <changelog_file>`  
**Output**: Formatted release notes (stdout)

**Example**:
```bash
./scripts/create-release-notes.sh 1.4.0 /tmp/changelog.txt > /tmp/release_notes.txt
```

---

### `cleanup-failed-release.sh`
**Purpose**: Cleans up artifacts after a failed release  
**Usage**: `./cleanup-failed-release.sh <version> [branch] [pr_number]`  
**Cleanup**:
- Deletes git tag (local and remote)
- Closes PR
- Deletes release branch
- Deletes GitHub release

**Example**:
```bash
./scripts/cleanup-failed-release.sh 1.4.0 release/v1.4.0 123
```

---

## Testing Scripts Locally

You can test these scripts locally before running the workflow:

```bash
# Test version validation
./scripts/validate-version.sh 1.4.0

# Test changelog extraction
./scripts/extract-changelog.py 1.4.0

# Test changelog update (on a test branch!)
git checkout -b test-scripts
./scripts/update-changelog.sh 1.4.0-test
git diff CHANGELOG.md

# Test rockspec creation
./scripts/create-rockspec.sh 1.4.0-test
cat rockspecs/markdown-plus.nvim-1.4.0-test-1.rockspec

# Test release notes
./scripts/extract-changelog.py 1.4.0-test > /tmp/test-changelog.txt
./scripts/create-release-notes.sh 1.4.0-test /tmp/test-changelog.txt

# Clean up test artifacts
git checkout main
git branch -D test-scripts
rm -f rockspecs/markdown-plus.nvim-1.4.0-test-1.rockspec
```

---

## Dependencies

### Required
- **bash** (any recent version)
- **python3** (3.6+)
- **git**
- **awk** (GNU awk recommended)
- **gh** (GitHub CLI) - for cleanup script only

### Optional
- **grep** with PCRE support (`-P` flag)

---

## Used By

These scripts are called by:
- `.github/workflows/create-release.yml` - Main release workflow
- Can be used manually for testing or troubleshooting

---

## Error Handling

All scripts:
- Use `set -euo pipefail` for strict error handling
- Exit with non-zero status on errors
- Provide descriptive error messages
- Validate input arguments

---

## Maintenance

When updating these scripts:
1. Test locally first (see "Testing Scripts Locally" above)
2. Update this README if behavior changes
3. Ensure scripts remain POSIX-compatible where possible
4. Keep scripts focused on single responsibilities
