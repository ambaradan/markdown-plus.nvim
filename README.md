# markdown-plus.nvim

A comprehensive Neovim plugin that provides modern markdown editing capabilities, implementing features found in popular editors like Typora, Mark Text, and Obsidian.

## Features

### 🚀 Currently Available (Phase 1)

#### List Management
- ✅ **Auto-create next list item**: Press Enter to automatically continue lists
- ✅ **Normal mode list creation**: Use `o`/`O` in normal mode to create new list items
- ✅ **Smart list indentation**: Use Tab/Shift+Tab to indent/outdent list items
- ✅ **Auto-renumber ordered lists**: Automatically renumber when items are added/deleted
- ✅ **Smart backspace**: Remove list markers when backspacing on empty items
- ✅ **List breaking**: Press Enter twice on empty list items to break out of lists
- ✅ **Checkbox support**: Works with both `- [ ]` and `1. [ ]` checkbox lists
- ✅ **Mixed list types**: Supports unordered (`-`, `*`, `+`) and ordered (`1.`) lists
- ✅ **Nested lists**: Full support for nested lists with proper renumbering

### 🔄 Coming Soon
- Text formatting (bold, italic, strikethrough)
- Link management
- Table editing
- Code block utilities
- Headers and TOC generation
- And much more! See [PLAN.md](./PLAN.md) for the complete roadmap.

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "yousefhadder/markdown-plus.nvim",
  ft = "markdown",
  config = function()
    require("markdown-plus").setup({
      -- Configuration options (all optional)
      enabled = true,
      features = {
        list_management = true,  -- Enable list management features
        -- More features will be added in future phases
      },
      keymaps = {
        enabled = true,  -- Enable default keymaps
      },
    })
  end,
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "yousefhadder/markdown-plus.nvim",
  ft = "markdown",
  config = function()
    require("markdown-plus").setup()
  end,
}
```

### Manual Installation

1. Clone this repository to your Neovim configuration directory:
```bash
cd ~/.config/nvim
git clone https://github.com/yousefhadder/markdown-plus.nvim
```

2. Add to your `init.lua`:
```lua
require("markdown-plus").setup()
```

## Usage

The plugin automatically activates when you open a markdown file (`.md` extension). All features work seamlessly with Neovim's built-in functionality.

### List Management

#### Auto-continue Lists
```markdown
- Type your first item and press Enter
- The next item is automatically created ⬅️ (cursor here)
```

#### Checkbox Lists
```markdown
- [ ] Press Enter after this unchecked item
- [ ] Next checkbox item is created ⬅️ (cursor here)

1. [x] Works with ordered lists too
2. [ ] Next numbered checkbox ⬅️ (cursor here)
```

#### Smart Indentation
```markdown
- Top level item
  - Press Tab to indent ⬅️ (cursor here)
    - Press Tab again for deeper nesting
  - Press Shift+Tab to outdent ⬅️ (cursor here)
```

#### List Breaking
```markdown
- Type your item
-
  ⬆️ Press Enter on empty item, then Enter again to break out:

Regular paragraph text continues here.
```

#### Smart Backspace
```markdown
- Type some text, then delete it all
- ⬅️ Press Backspace here to remove the bullet entirely
```

#### Normal Mode List Creation
```markdown
- Position cursor on this list item
- Press 'o' to create next item ⬅️ (new item appears below)
- Press 'O' to create previous item ⬅️ (new item appears above)

1. Works with ordered lists too
2. Press 'o' to create item 3 below ⬅️
3. Press 'O' to create item between 2 and 3 ⬅️
```

## Configuration

```lua
require("markdown-plus").setup({
  -- Global enable/disable
  enabled = true,

  -- Feature toggles
  features = {
    list_management = true,    -- Phase 1 features
    text_formatting = false,   -- Phase 2 features (coming soon)
    links = false,            -- Phase 4 features (coming soon)
    tables = false,           -- Phase 5 features (coming soon)
    code_blocks = false,      -- Phase 6 features (coming soon)
    headers_toc = false,      -- Phase 7 features (coming soon)
    structure = false,        -- Phase 8 features (coming soon)
    live_features = false,    -- Phase 9 features (coming soon)
  },

  -- Keymap configuration
  keymaps = {
    enabled = true,  -- Set to false to disable all default keymaps
  },
})
```

## Development Status

This plugin is under active development. See [PLAN.md](./PLAN.md) for the complete development roadmap and current progress.

**Current Phase**: Phase 1 - Core List Management (✅ Completed)
**Next Phase**: Phase 2 - Text Formatting & Styling

## Testing

To test the current features:

1. Open the included test files: `nvim test_list.md` or `nvim test_renumber.md`
2. Try the various list operations described in the files
3. For manual testing of renumbering: Use `<leader>mr` in normal mode
4. The plugin should automatically activate for `.md` files

### Testing Auto-Renumbering
The auto-renumbering feature now properly separates list groups:
- Lists separated by headers, paragraphs, or other content start numbering from 1
- Nested lists at different indentation levels are renumbered independently
- Empty lines between list items don't break the list continuity

## Contributing

This project follows a phase-based development approach. Each feature is implemented, tested, and refined individually.

- 🐛 **Bug Reports**: Please include steps to reproduce and your Neovim version
- 💡 **Feature Requests**: Check [PLAN.md](./PLAN.md) first - your feature might already be planned!
- 🔧 **Pull Requests**: Focus on single features and include tests

## Requirements

- Neovim 0.11+ (uses modern Lua APIs)
- No external dependencies

## License

MIT License - see [LICENSE](./LICENSE) file for details.

## Roadmap

See [PLAN.md](./PLAN.md) for the complete feature roadmap and implementation timeline.

---

**Status**: 🚧 Active Development | **Phase**: 1 of 10 | **Progress**: List Management ✅