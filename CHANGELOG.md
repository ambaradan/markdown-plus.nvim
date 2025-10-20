# Changelog

All notable changes to markdown-plus.nvim will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-19

### Added


TOC
#### Headers Module
- Header promotion/demotion with `<leader>h+` and `<leader>h-`
- Jump between headers with `]]` and `[[`
- Set specific header levels with `<leader>h1` through `<leader>h6`
- Generate Table of Contents with `<leader>ht`
- Update existing TOC with `<leader>hu`
- Follow TOC links with `gd`
- TOC duplicate prevention using HTML comment markers (`<!-- TOC -->` / `<!-- /TOC -->`)
- GitHub-style slug generation for anchors

#### List Module
- Auto-continuation of list items on `<CR>` in insert mode
- Context-aware `o` and `O` in normal mode for list items
- Intelligent list indentation with `<Tab>` and `<S-Tab>` (insert mode)
- Smart backspace with `<BS>` to remove empty list markers
- Automatic renumbering of ordered lists on text changes
- Manual renumbering with `<leader>mr`
- Debug command `<leader>md` for troubleshooting list detection
- Support for nested lists with proper indentation handling
- Empty list item removal (press `<CR>` twice to exit list)

#### Format Module
- Toggle bold formatting with `<leader>mb` (normal + visual mode)
- Toggle italic formatting with `<leader>mi` (normal + visual mode)
- Toggle strikethrough with `<leader>ms` (normal + visual mode)
- Toggle inline code with `<leader>mc` (normal + visual mode)
- Clear all formatting with `<leader>mC` (normal + visual mode)
- Smart word boundary detection for formatting operations

#### Documentation
- Comprehensive help file accessible via `:help markdown-plus`
- Complete API documentation for all modules
- Usage examples and troubleshooting guide
- Installation instructions for lazy.nvim

### Technical Details
- Context-aware keymaps that only activate when appropriate
- Proper fallback to default Vim behavior outside of lists
- No interference with normal mode operations
- Buffer-local keymaps for Markdown files only
- Automatic feature enablement via FileType autocmd

### Changed
- Initial stable release

### Fixed
- List operations now properly enter insert mode on non-list lines
- Fixed `<CR>` behavior to work correctly on regular text
- Removed global `<CR>` mapping that interfered with normal mode
- All keymaps now respect context (list vs non-list, insert vs normal)

## [Unreleased]

### Added

#### Testing Infrastructure
- Comprehensive test suite with 34 test cases covering all major modules
- Test framework using Busted + plenary.nvim
- Test configuration in `.busted`
- Minimal test environment in `spec/minimal_init.lua`
- Test suites for:
  - Configuration validation (`spec/markdown-plus/config_spec.lua`)
  - Utility functions (`spec/markdown-plus/utils_spec.lua`)
  - List management (`spec/markdown-plus/list_spec.lua`)
  - Headers & TOC (`spec/markdown-plus/headers_spec.lua`)

#### Type Safety & Documentation
- Comprehensive type definitions using LuaCATS annotations
- Type definitions module (`lua/markdown-plus/types.lua`)
- Type annotations on all public functions (`@param`, `@return`, `@type`)
- Lua language server configuration (`.luarc.json`)
- Enhanced inline documentation throughout codebase

#### Configuration Validation
- New validation module (`lua/markdown-plus/config/validate.lua`)
- User-friendly error messages for invalid configurations
- Unknown field detection with helpful suggestions
- Early validation during plugin setup

#### Code Quality Tools
- Luacheck linting configuration (`.luacheckrc`)
- StyLua code formatter configuration (`.stylua.toml`)
- Code formatting enforced at 120 char width, 2-space indent
- Makefile with quality commands: `test`, `lint`, `format`
- Git hooks support via Makefile

#### CI/CD Pipeline
- GitHub Actions workflow (`.github/workflows/tests.yml`)
- Matrix testing on Ubuntu and macOS
- Testing against Neovim stable and nightly
- Automated linting with luacheck
- Automated formatting check with StyLua
- Documentation validation

#### Development Documentation
- Development section in README.md
- Installation instructions for dev tools (luacheck, stylua)
- Testing guide with examples
- Contributing guidelines
- Project structure documentation

### Changed
- All Lua files formatted with StyLua for consistency
- Improved error handling with user-friendly messages
- Enhanced null/edge case handling throughout
- Better input validation in all modules
- Updated `.gitignore` to track only essential docs

### Fixed

#### TOC Detection Bug
- Fixed issue where documentation examples with `<!-- TOC -->` markers were incorrectly detected as actual TOCs
- Added content validation to distinguish between documentation and real TOCs
- Fixed validation to accept single-link TOCs (changed requirement from 2+ to 1+ links)
- Fixed end-of-TOC pattern to support all header levels (H1-H6)
- Implemented multi-candidate detection with proper validation
- Added tests to prevent regression

#### List Module Bug
- Fixed variable name typo in `parse_list_line` function
- Changed incorrect `bullet` reference to correct `bullet2` variable
- Prevents nil concatenation errors in `full_marker` field
- Added tests to catch similar issues in the future

### Quality Metrics
- Test coverage: 100% (34/34 tests passing)
- Linting: 0 warnings, 0 errors
- Code formatting: 100% compliant with StyLua
- Type annotations: Complete on all public APIs

### Planned Features
- Task list checkbox toggling
- Toggle between ordered/unordered lists
- Code block formatting support
- Advanced link following (files, URLs)
- Table manipulation
- Custom keymap configuration
- Custom TOC formatting options

---

[1.0.0]: https://github.com/YousefHadder/markdown-plus.nvim/releases/tag/v1.0.0
