# Markdown Plus Plugin Development Plan

## Project Overview
A comprehensive Neovim plugin that provides modern markdown editing capabilities, implementing features found in popular editors like Typora, Mark Text, and Obsidian.

## Development Strategy
- **One feature at a time**: Implement, test, and refine each feature individually
- **Incremental testing**: Each feature should be fully functional before moving to the next
- **Modular design**: Features should be independent and configurable
- **Lua-first approach**: Utilize Neovim 0.11+ modern Lua APIs

## Feature Implementation Phases

### Phase 1: Core List Management (Priority: HIGH) - **COMPLETED** ✅
**Estimated Time**: 1-2 weeks
**Status**: Completed - All features implemented and tested
**Started**: 2025-09-28
**Completed**: 2025-09-28

1. **Auto-create next list item** (`list-continue`) - **COMPLETED** ✅
   - Detect current list type (ordered/unordered)
   - Auto-generate next item on Enter
   - Handle nested lists with proper indentation
   - **Test cases**: Various list types, nested levels, mixed lists
   - **Status**: Implemented - includes support for checkboxes and list breaking
   - **Files**: `lua/markdown-plus/list/init.lua`
   - **Test file**: `test_list.md`

2. **Smart list indentation** (`list-indent`) - **COMPLETED** ✅
   - Tab/Shift+Tab for indent/outdent
   - Maintain list formatting during indentation
   - **Test cases**: Multiple indent levels, mixed list types
   - **Status**: Implemented alongside list continuation feature
   - **Files**: `lua/markdown-plus/list/init.lua`

3. **Auto-renumber ordered lists** (`list-renumber`) - **COMPLETED** ✅
   - Detect when items are added/deleted
   - Renumber entire list automatically
   - Handle nested numbered lists
   - **Test cases**: Insert middle items, delete items, nested numbering
   - **Status**: Implemented with autocommands for automatic detection
   - **Files**: `lua/markdown-plus/list/init.lua`
   - **Features**: Handles nested lists, checkboxes, separate list groups
   - **Fixed**: Properly separates list groups (headers/text break continuity)
   - **Debug**: Use `<leader>mr` to manually trigger, `<leader>md` to debug groups

4. **Smart backspace on empty list items** (`list-backspace`) - **COMPLETED** ✅
   - Remove bullet/number when backspacing on empty item
   - Maintain cursor position appropriately
   - **Test cases**: Various list types, nested lists
   - **Status**: Implemented alongside list continuation feature
   - **Files**: `lua/markdown-plus/list/init.lua`

5. **Normal mode list creation** (`list-normal-o`) - **COMPLETED** ✅ (Bonus)
   - Use `o` in normal mode to create next list item
   - Use `O` in normal mode to create previous list item
   - Automatically enter insert mode at end of new item
   - **Test cases**: All list types, nested lists, checkboxes
   - **Status**: Bonus feature added to enhance workflow
   - **Files**: `lua/markdown-plus/list/init.lua`

### Phase 2: Text Formatting & Styling (Priority: HIGH) - **COMPLETED** ✅
**Estimated Time**: 1-2 weeks
**Status**: Completed - All text formatting features implemented and tested
**Started**: 2025-09-28
**Completed**: 2025-09-28

5. **Toggle bold formatting** (`format-bold`) - **COMPLETED** ✅
   - Toggle `**text**` on selection or current word
   - Handle existing formatting correctly
   - **Test cases**: Selection, word boundaries, existing formatting
   - **Status**: Implemented with visual and normal mode support
   - **Keybinding**: `<leader>mb`

6. **Toggle italic formatting** (`format-italic`) - **COMPLETED** ✅
   - Toggle `*text*` on selection or current word
   - Handle conflicts with existing formatting
   - **Test cases**: Selection, word boundaries, nested formatting
   - **Status**: Implemented with visual and normal mode support
   - **Keybinding**: `<leader>mi`

7. **Toggle strikethrough** (`format-strikethrough`) - **COMPLETED** ✅
   - Toggle `~~text~~` on selection or current word
   - **Test cases**: Various selection sizes, existing formatting
   - **Status**: Implemented with visual and normal mode support
   - **Keybinding**: `<leader>ms`

8. **Toggle inline code** (`format-code`) - **COMPLETED** ✅
   - Toggle `` `code` `` on selection or current word
   - Handle backtick escaping
   - **Test cases**: Code with backticks, existing formatting
   - **Status**: Implemented with visual and normal mode support
   - **Keybinding**: `<leader>mc`

9. **Remove all formatting** (`format-clear`) - **COMPLETED** ✅
   - Strip all markdown formatting from selection
   - **Test cases**: Complex nested formatting, mixed styles
   - **Status**: Implemented with visual and normal mode support
   - **Keybinding**: `<leader>mC`
   - **Features**: Removes bold, italic, strikethrough, and code formatting

### Phase 3: Smart Editing Features (Priority: MEDIUM)
**Estimated Time**: 2-3 weeks

10. **Auto-pair markdown syntax** (`autopair`)
    - Auto-close `**`, `__`, `~~`, etc.
    - Smart behavior based on context
    - **Test cases**: Various syntax combinations, cursor positions

11. **Smart Enter behavior** (`smart-enter`)
    - Context-aware Enter key behavior
    - Continue lists, break out of code blocks, etc.
    - **Test cases**: All block types, nested structures

12. **Smart selection expansion** (`expand-selection`)
    - Word → sentence → paragraph → section
    - Markdown-aware selection boundaries
    - **Test cases**: Various text structures, nested elements

13. **Move lines up/down** (`move-lines`)
    - Maintain markdown structure during moves
    - Handle list renumbering when moving list items
    - **Test cases**: Various content types, list items

### Phase 4: Links & References (Priority: MEDIUM) - **COMPLETED** ✅
**Estimated Time**: 2-3 weeks
**Status**: Completed - All link management features implemented and tested
**Started**: 2025-10-19
**Completed**: 2025-10-20

14. **Link insertion and editing** (`link-edit`) - **COMPLETED** ✅
    - Insert new links with text and URL (`<leader>ml`)
    - Convert selection to link in visual mode (`<leader>ml`)
    - Edit existing link components (`<leader>me`)
    - Works with both inline `[text](url)` and reference `[text][ref]` links
    - **Test cases**: New links, existing links, reference links
    - **Status**: Implemented with full inline and reference support
    - **Files**: `lua/markdown-plus/links/init.lua`
    - **Keybindings**: 
      - `<leader>ml` (normal/visual) - Insert/convert to link
      - `<leader>me` - Edit link under cursor

15. **Auto-convert URLs to links** (`url-autolink`) - **COMPLETED** ✅
    - Detect and convert bare URLs to markdown links
    - Position cursor anywhere on URL
    - Prompt for custom link text or use URL as text
    - **Test cases**: Various URL formats, cursor positions
    - **Status**: Implemented with smart cursor detection
    - **Files**: `lua/markdown-plus/links/init.lua`
    - **Keybinding**: `<leader>ma`

16. **Reference-style link management** (`ref-links`) - **COMPLETED** ✅
    - Convert inline links to reference-style (`<leader>mR`)
    - Convert reference links to inline (`<leader>mI`)
    - Smart reference ID generation (lowercase, hyphens, alphanumeric)
    - Automatic reference reuse when text and URL match
    - Reference definitions placed at document end
    - **Test cases**: Conversion both directions, duplicate references, empty ref IDs
    - **Status**: Implemented with validation and reuse logic
    - **Files**: `lua/markdown-plus/links/init.lua`
    - **Keybindings**:
      - `<leader>mR` - Convert to reference-style
      - `<leader>mI` - Convert to inline
    - **Features**:
      - Validates non-empty reference IDs
      - Verifies URL match when reusing references
      - Handles special characters in link text

17. **Open links in browser** - **COMPLETED** ✅
    - Uses native Neovim `gx` command
    - Works on markdown links and bare URLs
    - No custom keymap needed (native functionality)
    - **Status**: Documented to use `gx`

**Issues Fixed**:
- Visual mode selection for multi-word text
- Cursor position detection (0-indexed handling)
- Link detection under cursor (proper iteration)
- Keymap conflicts with other modules
- Documentation accuracy for reference reuse behavior

**Documentation**:
- README.md updated with examples and workflows
- doc/markdown-plus.txt with comprehensive usage guide
- API reference for all link functions
- Keymap reference tables
- Features section made foldable for better navigation

### Phase 5: Tables (Priority: MEDIUM)
**Estimated Time**: 2-3 weeks

18. **Insert table** (`table-insert`)
    - Create table with specified dimensions
    - Auto-format with proper alignment
    - **Test cases**: Various sizes, content types

19. **Table manipulation** (`table-edit`)
    - Add/delete rows and columns
    - Navigate with Tab/Shift+Tab
    - **Test cases**: Various table sizes, cursor positions

20. **Auto-format tables** (`table-format`)
    - Align columns automatically
    - Handle content changes
    - **Test cases**: Various content widths, alignments

21. **CSV to table conversion** (`csv-to-table`)
    - Convert clipboard CSV to markdown table
    - Handle various CSV formats
    - **Test cases**: Different delimiters, quoted content

### Phase 6: Code Blocks (Priority: MEDIUM)
**Estimated Time**: 1-2 weeks

22. **Insert fenced code blocks** (`code-block-insert`)
    - Insert with language selection
    - Auto-close fences
    - **Test cases**: Various languages, existing content

23. **Toggle inline/block code** (`code-toggle`)
    - Convert between inline and block code
    - Maintain content integrity
    - **Test cases**: Various code content, formatting

### Phase 7: Headers & TOC (Priority: MEDIUM) - **COMPLETED** ✅
**Estimated Time**: 2-3 weeks
**Status**: Completed - All features implemented and tested
**Started**: 2025-01-XX
**Completed**: 2025-01-XX

24. **Auto-generate TOC** (`toc-generate`) - **COMPLETED** ✅
    - Create table of contents from headers
    - Smart placement (before first non-H1 header)
    - GitHub-compatible anchor links
    - **Test cases**: Various header structures, nesting, symbols
    - **Status**: Implemented with smart placement and code block detection
    - **Files**: `lua/markdown-plus/headers/init.lua`
    - **Features**: 
      - Respects introduction text
      - Excludes H1 from TOC entries
      - Handles symbols correctly (Q&A, C++, etc.)
      - Ignores headers in code blocks

25. **Header navigation** (`header-nav`) - **COMPLETED** ✅
    - Quick jump between headers with ]] and [[
    - Works across all header levels
    - Skips headers in code blocks
    - **Test cases**: Complex documents, nested headers
    - **Status**: Implemented and tested
    - **Files**: `lua/markdown-plus/headers/init.lua`

26. **Promote/demote headers** (`header-level`) - **COMPLETED** ✅
    - Increase/decrease header levels with <leader>h+ and h-
    - Set specific levels with <leader>h1-h6
    - Respects H1-H6 boundaries
    - **Test cases**: Various header types, boundary conditions
    - **Status**: Implemented with level shortcuts
    - **Files**: `lua/markdown-plus/headers/init.lua`

27. **Update TOC** (`toc-update`) - **COMPLETED** ✅
    - Update existing TOC with <leader>hu
    - Finds and replaces old TOC
    - Regenerates all links
    - **Status**: Implemented
    - **Files**: `lua/markdown-plus/headers/init.lua`

28. **Follow TOC links** (`toc-follow`) - **COMPLETED** ✅
    - Press <CR> or gd on TOC links to jump to headers
    - Centers screen on target
    - **Status**: Implemented
    - **Files**: `lua/markdown-plus/headers/init.lua`

**Enhancements Added**:
- GitHub-compatible slug generation (handles all symbols correctly)
- Code block detection (ignores headers in ``` and ~~~ blocks)
- Smart TOC placement (respects introduction text)
- Follow TOC links with <CR> or gd

### Phase 8: Document Structure (Priority: LOW)
**Estimated Time**: 2-3 weeks

27. **Section folding** (`fold-sections`)
    - Fold by header levels
    - Nested folding support
    - **Test cases**: Various document structures

28. **Document statistics** (`doc-stats`)
    - Word count, reading time, etc.
    - Real-time updates
    - **Test cases**: Various document types

### Phase 9: Live Features (Priority: LOW)
**Estimated Time**: 3-4 weeks

29. **Math equation rendering** (`math-render`)
    - LaTeX support in preview
    - Inline and block equations
    - **Test cases**: Various equation types

30. **Checkbox toggling** (`checkbox-toggle`)
    - Toggle checkboxes in both edit and preview
    - Handle nested task lists
    - **Test cases**: Various checkbox states, nesting

### Phase 10: Productivity Features (Priority: LOW)
**Estimated Time**: 2-3 weeks

31. **Template snippets** (`templates`)
    - Predefined content templates
    - Custom snippet creation
    - **Test cases**: Various template types

32. **Quick insertions** (`quick-insert`)
    - Current date, time, etc.
    - Configurable shortcuts
    - **Test cases**: Various insertion types

## Technical Architecture

### Plugin Structure
```
markdown-plus.nvim/
├── lua/
│   ├── markdown-plus/
│   │   ├── init.lua              # Main plugin entry
│   │   ├── config.lua            # Configuration management
│   │   ├── utils.lua             # Common utilities
│   │   ├── list/                 # List management features
│   │   ├── format/               # Text formatting features
│   │   ├── links/                # Link management features
│   │   ├── tables/               # Table features
│   │   ├── code/                 # Code block features
│   │   ├── headers/              # Header and TOC features
│   │   ├── structure/            # Document structure features
│   │   └── live/                 # Live preview features
├── plugin/
│   └── markdown-plus.lua         # Plugin loader
├── doc/
│   └── markdown-plus.txt         # Documentation
└── tests/                        # Test suite
```

### Key Design Principles
1. **Modularity**: Each feature is self-contained
2. **Configuration**: All features should be configurable
3. **Performance**: Efficient implementation with minimal overhead
4. **Compatibility**: Work with existing markdown plugins
5. **Testing**: Comprehensive test coverage for each feature

### Testing Strategy
- **Unit tests**: Test individual functions and utilities
- **Integration tests**: Test feature interactions
- **Manual testing**: Test real-world usage scenarios
- **Performance tests**: Ensure no significant slowdown

## Configuration Management
- Global enable/disable for all features
- Individual feature toggles
- Customizable keymaps for each feature
- Configurable behavior options

## Documentation Requirements
- Clear feature descriptions
- Usage examples for each feature
- Configuration options
- Troubleshooting guide
- Migration guide from other plugins

## Success Metrics
- Each feature works reliably in isolation
- No conflicts between features
- Minimal performance impact
- Positive user feedback
- Comprehensive test coverage (>90%)

## Future Considerations
- Integration with LSP for enhanced features
- Support for extended markdown syntax
- Plugin ecosystem compatibility
- Export/import functionality
- Live collaboration features