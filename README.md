# markdown-plus.nvim

A comprehensive Neovim plugin that provides modern markdown editing capabilities, implementing features found in popular editors like Typora, Mark Text, and Obsidian.

## Features

## Features

### List Management
- **Auto-create next list item**: Press Enter to automatically continue lists
- **Normal mode list creation**: Use `o`/`O` in normal mode to create new list items
- **Smart list indentation**: Use Tab/Shift+Tab to indent/outdent list items
- **Auto-renumber ordered lists**: Automatically renumber when items are added/deleted
- **Smart backspace**: Remove list markers when backspacing on empty items
- **List breaking**: Press Enter twice on empty list items to break out of lists
- **Checkbox support**: Works with both `- [ ]` and `1. [ ]` checkbox lists
- **Mixed list types**: Supports unordered (`-`, `*`, `+`) and ordered (`1.`) lists
- **Nested lists**: Full support for nested lists with proper renumbering

## Installation

<details>
<summary>Using lazy.nvim</summary>

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
      },
      keymaps = {
        enabled = true,  -- Enable default keymaps
      },
    })
  end,
}
```
</details>

<details>
<summary>Using packer.nvim</summary>

```lua
use {
  "yousefhadder/markdown-plus.nvim",
  ft = "markdown",
  config = function()
    require("markdown-plus").setup()
  end,
}
```
</details>

<details>
<summary>Manual Installation</summary>

1. Clone this repository to your Neovim configuration directory:
```bash
cd ~/.config/nvim
git clone https://github.com/yousefhadder/markdown-plus.nvim
```

2. Add to your `init.lua`:
```lua
require("markdown-plus").setup()
```
</details>

## Usage

The plugin automatically activates when you open a markdown file (`.md` extension). All features work seamlessly with Neovim's built-in functionality.

<details>
<summary>List Management Examples</summary>

### Auto-continue Lists
```markdown
- Type your first item and press Enter
- The next item is automatically created ⬅️ (cursor here)
```

### Checkbox Lists
```markdown
- [ ] Press Enter after this unchecked item
- [ ] Next checkbox item is created ⬅️ (cursor here)

1. [x]
2. [ ]
```

### Smart Indentation
```markdown
- Top level item
  - Press Tab to indent ⬅️ (cursor here)
    - Press Tab again for deeper nesting
  - Press Shift+Tab to outdent ⬅️ (cursor here)
```

### List Breaking
```markdown
- Type your item
-
  ⬆️ Press Enter on empty item, then Enter again to break out:

Regular paragraph text continues here.
```

### Smart Backspace
```markdown
- Type some text, then delete it all
- ⬅️ Press Backspace here to remove the bullet entirely
```

### Normal Mode List Creation
```markdown
- Position cursor on this list item
- Press 'o' to create next item ⬅️ (new item appears below)
- Press 'O' to create previous item ⬅️ (new item appears above)

1. Works with ordered lists too
2. Press 'o' to create item 3 below ⬅️
3. Press 'O' to create item between 2 and 3 ⬅️
```
</details>

## Configuration

<details>
<summary>Configuration Options</summary>

```lua
require("markdown-plus").setup({
  -- Global enable/disable
  enabled = true,

  -- Feature toggles
  features = {
    list_management = true,    -- List management features
  },

  -- Keymap configuration
  keymaps = {
    enabled = true,  -- Set to false to disable all default keymaps
  },
})
```
</details>


## Contributing

Contributions are welcome! Each feature is implemented, tested, and refined individually.

- 🐛 **Bug Reports**: Please include steps to reproduce and your Neovim version
- 💡 **Feature Requests**: Feel free to suggest improvements or new features
- 🔧 **Pull Requests**: Focus on single features and include appropriate documentation

## Requirements

- Neovim 0.11+ (uses modern Lua APIs)
- No external dependencies

## License

MIT License - see [LICENSE](./LICENSE) file for details.

