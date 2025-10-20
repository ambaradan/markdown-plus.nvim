# markdown-plus.nvim

A comprehensive Neovim plugin that provides modern markdown editing capabilities, implementing features found in popular editors like Typora, Mark Text, and Obsidian.

**Note:** While originally designed for Markdown, this plugin can be configured to work with any filetype (see [Configuration](#configuration)).

## Table of Contents

- [Features](#features)
  - [List Management](#list-management)
  - [Text Formatting](#text-formatting)
  - [Headers & Table of Contents](#headers--table-of-contents)
- [Installation](#installation)
- [Usage](#usage)
  - [Auto-continue Lists](#auto-continue-lists)
  - [Checkbox Lists](#checkbox-lists)
  - [Smart Indentation](#smart-indentation)
  - [List Breaking](#list-breaking)
  - [Smart Backspace](#smart-backspace)
  - [Normal Mode List Creation](#normal-mode-list-creation)
  - [Toggle Bold](#toggle-bold)
  - [Toggle Italic](#toggle-italic)
  - [Toggle Strikethrough](#toggle-strikethrough)
  - [Toggle Inline Code](#toggle-inline-code)
  - [Clear All Formatting](#clear-all-formatting)
  - [Smart Word Detection](#smart-word-detection)
  - [Visual Mode Selection](#visual-mode-selection)
  - [Header Navigation](#header-navigation)
  - [Promote/Demote Headers](#promotedemote-headers)
  - [Convert to Header](#convert-to-header)
  - [Generate Table of Contents](#generate-table-of-contents)
  - [Update TOC](#update-toc)
  - [Follow TOC Links](#follow-toc-links)
  - [TOC with Symbols (GitHub-Compatible)](#toc-with-symbols-github-compatible)
  - [Code Blocks Ignored](#code-blocks-ignored)
- [Keymaps Reference](#keymaps-reference)
  - [List Management (Insert Mode)](#list-management-insert-mode)
  - [List Management (Normal Mode)](#list-management-normal-mode)
  - [Text Formatting (Normal & Visual Mode)](#text-formatting-normal--visual-mode)
  - [Headers & TOC (Normal Mode)](#headers--toc-normal-mode)
- [Configuration](#configuration)
- [Tips & Best Practices](#tips--best-practices)
  - [Text Formatting Behavior](#text-formatting-behavior)
  - [List Management Tips](#list-management-tips)
  - [Workflow Examples](#workflow-examples)
- [Contributing](#contributing)
- [Requirements](#requirements)
- [License](#license)


## Features

<details>
<summary><b>List Management</b></summary>

- **Auto-create next list item**: Press Enter to automatically continue lists
- **Normal mode list creation**: Use `o`/`O` in normal mode to create new list items
- **Smart list indentation**: Use Tab/Shift+Tab to indent/outdent list items
- **Auto-renumber ordered lists**: Automatically renumber when items are added/deleted
- **Smart backspace**: Remove list markers when backspacing on empty items
- **List breaking**: Press Enter twice on empty list items to break out of lists
- **Checkbox support**: Works with both `- [ ]` and `1. [ ]` checkbox lists
- **Mixed list types**: Supports unordered (`-`, `*`, `+`) and ordered (`1.`) lists
- **Nested lists**: Full support for nested lists with proper renumbering

</details>

<details>
<summary><b>Text Formatting</b></summary>

- **Toggle bold**: `<leader>mb` to toggle `**bold**` formatting on selection or word
- **Toggle italic**: `<leader>mi` to toggle `*italic*` formatting on selection or word
- **Toggle strikethrough**: `<leader>ms` to toggle `~~strikethrough~~` formatting on selection or word
- **Toggle inline code**: `<leader>mc` to toggle `` `code` `` formatting on selection or word
- **Clear all formatting**: `<leader>mC` to remove all markdown formatting from selection or word
- **Smart word detection**: Works with words containing hyphens (`test-word`), dots (`file.name`), and underscores (`snake_case`)
- **Visual and normal mode**: All formatting commands work in both visual selection and normal mode (on current word)

</details>

<details>
<summary><b>Headers & Table of Contents</b></summary>

- **Header navigation**: Jump between headers with `]]` (next) and `[[` (previous)
- **Promote/demote headers**: Increase/decrease header importance with `<leader>h+` and `<leader>h-`
- **Set header level**: Quickly set header level 1-6 with `<leader>h1` through `<leader>h6`
- **Generate TOC**: Auto-generate table of contents with `<leader>ht` (uses HTML markers to prevent duplicates)
- **Update TOC**: Refresh existing TOC with `<leader>hu` after modifying headers
- **Follow TOC links**: Press `gd` on a TOC link to jump to that header
- **Smart TOC placement**: TOC appears right before first section (after introduction text)
- **Code block aware**: Headers inside code blocks are correctly ignored
- **GitHub-compatible slugs**: Anchor links work correctly on GitHub (handles `Q&A`, `C++`, etc.)

</details>

<details>
<summary><b>Links & References</b></summary>

- **Insert link**: `<leader>ml` to insert a new markdown link with text and URL
- **Convert selection to link**: Select text and `<leader>ml` to convert it to a link
- **Edit link**: `<leader>me` on a link to edit its text and URL
- **Open links**: Use `gx` (native Neovim) to open links in your browser
- **Auto-convert URL**: `<leader>ma` on a URL to convert it to a markdown link
- **Reference-style links**: Convert between inline `[text](url)` and reference `[text][ref]` styles
- **Convert to reference**: `<leader>mR` to convert inline link to reference-style
- **Convert to inline**: `<leader>mI` to convert reference link to inline
- **Smart URL detection**: Works with bare URLs and properly formatted links

</details>

## Installation

<details>
<summary>Using lazy.nvim</summary>

```lua
{
  "yousefhadder/markdown-plus.nvim",
  ft = "markdown",  -- Load on markdown files by default
  config = function()
    require("markdown-plus").setup({
      -- Configuration options (all optional)
      enabled = true,
      features = {
        list_management = true,  -- Enable list management features
        text_formatting = true,  -- Enable text formatting features
        headers_toc = true,      -- Enable headers and TOC features
        links = true,            -- Enable link management features
      },
      keymaps = {
        enabled = true,  -- Enable default keymaps
      },
      filetypes = { "markdown" },  -- Filetypes to enable the plugin for
    })
  end,
}
```

**Using with multiple filetypes:**

```lua
{
  "yousefhadder/markdown-plus.nvim",
  ft = { "markdown", "text", "txt" },  -- Load on multiple filetypes
  config = function()
    require("markdown-plus").setup({
      filetypes = { "markdown", "text", "txt" },  -- Enable for these filetypes
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

1. Add to your `init.lua`:
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

<details>
<summary>Text Formatting Examples</summary>

### Toggle Bold
```markdown
Position cursor on word and press <leader>mb:
text → **text**
**text** → text (toggle off)

Or select text in visual mode and press <leader>mb:
Select "this text" → **this text**
```

### Toggle Italic
```markdown
Position cursor on word and press <leader>mi:
text → *text*
*text* → text (toggle off)
```

### Toggle Strikethrough
```markdown
Position cursor on word and press <leader>ms:
text → ~~text~~
~~text~~ → text (toggle off)
```

### Toggle Inline Code
```markdown
Position cursor on word and press <leader>mc:
text → `text`
`text` → text (toggle off)
```

### Clear All Formatting
```markdown
Position cursor on formatted word and press <leader>mC:
**bold** *italic* `code` → bold italic code

Or select complex formatted text and press <leader>mC:
This **bold** and *italic* text → This bold and italic text
```

### Smart Word Detection
```markdown
Works with special characters in words:
test-with-hyphens → **test-with-hyphens** (entire word formatted)
file.name.here → *file.name.here* (entire word formatted)
snake_case_word → `snake_case_word` (entire word formatted)
```

### Visual Mode Selection
```markdown
Select any text in visual mode and format it:
1. Enter visual mode with 'v'
2. Select the text you want to format
3. Press <leader>mb (or mi, ms, mc, mC)
4. The entire selection will be formatted

Example: Select "multiple words here" → **multiple words here**
```
</details>

<details>
<summary>Headers & TOC Examples</summary>

### Header Navigation
```markdown
Use ]] and [[ to jump between headers quickly:
# Main Title       ← Press ]] to jump here
Content
## Section 1       ← Press ]] to jump here
Content
### Subsection    ← Press ]] to jump here
Content
Press [[ to jump backwards
```

### Promote/Demote Headers
```markdown
Position cursor on any header and adjust its level:
### Subsection    ← Press <leader>h+ → ## Subsection (promoted)
## Section        ← Press <leader>h- → ### Section (demoted)
```

### Convert to Header
```markdown
Position cursor on any line:
Regular text      ← Press <leader>h2 → ## Regular text
Already header    ← Press <leader>h4 → #### Already header
```

### Generate Table of Contents
```markdown
# My Document

Press <leader>ht to generate TOC:

<!-- TOC -->

## Table of Contents

- [Section 1](#section-1)
  - [Subsection 1.1](#subsection-1-1)
- [Section 2](#section-2)

<!-- /TOC -->

## Section 1
...
```

**Note:** The TOC is wrapped in HTML comment markers `<!-- TOC -->` and `<!-- /TOC -->`. This prevents duplicate TOCs from being created if you press `<leader>ht` again. To update an existing TOC, use `<leader>hu` instead.

### Update TOC
```markdown
After adding/removing/renaming headers:
1. Press <leader>hu to update the TOC
2. All links are regenerated automatically
3. The content between <!-- TOC --> and <!-- /TOC --> is replaced
```

### Follow TOC Links
```markdown
## Table of Contents

- [Getting Started](#getting-started)  ← Position cursor here
- [API & SDK](#api--sdk)
- [Q&A](#qa)

Press gd to jump directly to that header!

## Getting Started    ← You jump here instantly!
```

### TOC with Symbols (GitHub-Compatible)
```markdown
# API Documentation

## Q&A              → TOC link: [Q&A](#qa)
## API & SDK        → TOC link: [API & SDK](#api--sdk)
## C++ Examples     → TOC link: [C++ Examples](#c-examples)
## What's New?      → TOC link: [What's New?](#whats-new)

All links work correctly on GitHub! ✓
```

### Code Blocks Ignored
```markdown
# Document

## Real Section

\`\`\`bash
# This is NOT in the TOC
## Neither is this
\`\`\`

Press <leader>ht → Only "Real Section" appears in TOC ✓
```

</details>

<details>
<summary>Links & References Examples</summary>

### Insert New Link
```markdown
In normal mode, press <leader>ml:
1. You'll be prompted: "Link text: "
2. Enter the text (e.g., "GitHub")
3. You'll be prompted: "URL: "
4. Enter the URL (e.g., "https://github.com")
5. Result: [GitHub](https://github.com)
```

### Convert Selection to Link
```markdown
Select text in visual mode:
Visit my website  ← Select "my website" with visual mode

Press <leader>ml:
1. You'll be prompted: "URL: "
2. Enter URL (e.g., "https://example.com")
3. Result: Visit [my website](https://example.com)
```

### Edit Existing Link
```markdown
Position cursor anywhere on a link and press <leader>me:

[Old Text](https://old-url.com)  ← cursor here

Press <leader>me:
1. Link text: Old Text (edit or press Enter)
2. URL: https://old-url.com (edit or press Enter)

Result: [New Text](https://new-url.com)
```

### Open Link in Browser
```markdown
Use native Neovim functionality:
[Google](https://google.com)  ← Position cursor here
Press gx to open in browser

https://example.com  ← Works on bare URLs too
Press gx to open
```

### Convert URL to Link
```markdown
Position cursor on a URL and press <leader>ma:

Check out https://github.com/yousefhadder/markdown-plus.nvim

Press <leader>ma:
1. Link text (empty for URL): GitHub Plugin
2. Result: Check out [GitHub Plugin](https://github.com/yousefhadder/markdown-plus.nvim)

Or leave text empty to use URL as text:
Result: [https://github.com/yousefhadder/markdown-plus.nvim](https://github.com/yousefhadder/markdown-plus.nvim)
```

### Reference-Style Links
```markdown
Convert inline link to reference-style with <leader>mR:

[Documentation](https://docs.example.com)  ← cursor here

Press <leader>mR:
Result:
[Documentation][documentation]

... (at end of document)
[documentation]: https://docs.example.com

---

Convert reference link to inline with <leader>mI:

[My Link][myref]  ← cursor here

... (elsewhere in document)
[myref]: https://myref.com

Press <leader>mI:
Result: [My Link](https://myref.com)
```

### Reuse Existing References
```markdown
When converting links with the same text and URL to reference-style, 
the reference is reused:

Check out [GitHub](https://github.com) for code.
Visit [GitHub](https://github.com) to see projects.

Press <leader>mR on both:
Result:
Check out [GitHub][github] for code.
Visit [GitHub][github] to see projects.

[github]: https://github.com  ← Only one definition

---

Links with different text create separate references even with same URL:

[dotfiles](https://github.com/yousefhadder/dotfiles)
[My Dotfiles](https://github.com/yousefhadder/dotfiles)

Press <leader>mR on both:
Result:
[dotfiles][dotfiles]
[My Dotfiles][my-dotfiles]

[dotfiles]: https://github.com/yousefhadder/dotfiles
[my-dotfiles]: https://github.com/yousefhadder/dotfiles
```

</details>

## Keymaps Reference

<details>
<summary>Default Keymaps</summary>

### List Management (Insert Mode)
| Keymap | Mode | Description |
|--------|------|-------------|
| `<CR>` | Insert | Auto-continue lists or break out of lists |
| `<Tab>` | Insert | Indent list item |
| `<S-Tab>` | Insert | Outdent list item |
| `<BS>` | Insert | Smart backspace (removes empty list markers) |

### List Management (Normal Mode)
| Keymap | Mode | Description |
|--------|------|-------------|
| `o` | Normal | Create next list item |
| `O` | Normal | Create previous list item |
| `<leader>mr` | Normal | Manual renumber ordered lists |
| `<leader>md` | Normal | Debug list groups (development) |

### Text Formatting (Normal & Visual Mode)
| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>mb` | Normal/Visual | Toggle **bold** formatting |
| `<leader>mi` | Normal/Visual | Toggle *italic* formatting |
| `<leader>ms` | Normal/Visual | Toggle ~~strikethrough~~ formatting |
| `<leader>mc` | Normal/Visual | Toggle `` `code` `` formatting |
| `<leader>mC` | Normal/Visual | Clear all formatting |

### Headers & TOC (Normal Mode)
| Keymap | Mode | Description |
|--------|------|-------------|
| `]]` | Normal | Jump to next header |
| `[[` | Normal | Jump to previous header |
| `<leader>h+` | Normal | Promote header (increase importance) |
| `<leader>h-` | Normal | Demote header (decrease importance) |
| `<leader>h1` | Normal | Set/convert to H1 |
| `<leader>h2` | Normal | Set/convert to H2 |
| `<leader>h3` | Normal | Set/convert to H3 |
| `<leader>h4` | Normal | Set/convert to H4 |
| `<leader>h5` | Normal | Set/convert to H5 |
| `<leader>h6` | Normal | Set/convert to H6 |
| `<leader>ht` | Normal | Generate table of contents |
| `<leader>hu` | Normal | Update existing table of contents |
| `gd` | Normal | Follow TOC link (jump to header) |

### Links & References (Normal & Visual Mode)
| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>ml` | Normal | Insert new markdown link |
| `<leader>ml` | Visual | Convert selection to link |
| `<leader>me` | Normal | Edit link under cursor |
| `<leader>ma` | Normal | Convert URL to markdown link |
| `<leader>mR` | Normal | Convert to reference-style link |
| `<leader>mI` | Normal | Convert to inline link |
| `gx` | Normal | Open link in browser (native Neovim) |

**Note**: In normal mode, these commands operate on the word under cursor. In visual mode, they operate on the selected text.

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
    text_formatting = true,    -- Text formatting features
    headers_toc = true,        -- Headers and TOC features
    links = true,              -- Link management and references
  },

  -- Keymap configuration
  keymaps = {
    enabled = true,  -- Set to false to disable all default keymaps
  },

  -- Filetypes configuration
  -- Specifies which filetypes will enable the plugin features
  -- Default: { "markdown" }
  filetypes = { "markdown" },
})
```

### Using with Multiple Filetypes

The plugin can be enabled for any filetype, not just markdown. This is useful for:
- Plain text files (`.txt`, `.text`)
- Note-taking formats (`.note`, `.org`)
- Documentation files
- Any text-based format where you want markdown-style formatting

**Example: Enable for markdown and plain text files**
```lua
require("markdown-plus").setup({
  filetypes = { "markdown", "text", "txt" },
})
```

**Example: Enable for custom note-taking setup**
```lua
require("markdown-plus").setup({
  filetypes = { "markdown", "note", "org", "wiki" },
})
```

**Important:** Make sure your plugin manager also loads the plugin for these filetypes:
```lua
-- For lazy.nvim
{
  "yousefhadder/markdown-plus.nvim",
  ft = { "markdown", "text", "txt" },  -- Match your filetypes config
  config = function()
    require("markdown-plus").setup({
      filetypes = { "markdown", "text", "txt" },
    })
  end,
}
```

```
</details>

## Tips & Best Practices

<details>
<summary>Helpful Tips</summary>

### Text Formatting Behavior
- **Toggle functionality**: Pressing the same keymap twice will add then remove formatting
- **Word detection**: In normal mode, the cursor can be anywhere in the word - the entire word will be formatted
- **Multi-word support**: Use visual mode to format phrases or multiple words
- **Special characters**: Words with hyphens, dots, and underscores are treated as single words
- **Clear formatting**: `<leader>mC` removes ALL formatting types in one go (bold, italic, code, strikethrough)

### List Management Tips
- **Auto-continuation**: Press Enter on a list item to automatically create the next one
- **Breaking out**: Press Enter twice on an empty list item to exit the list
- **Smart indentation**: Tab/Shift+Tab works on list items without breaking formatting
- **Auto-renumbering**: Ordered lists automatically renumber when you add/remove items
- **Mixed lists**: You can have nested ordered lists inside unordered lists and vice versa

### Workflow Examples
```markdown
# Quick formatting workflow
1. Type your text normally
2. Use hjkl to position cursor on any word
3. Press <leader>mb to make it bold (or other formatting keys)
4. Continue writing

# Visual mode workflow
1. Write a sentence or paragraph
2. Select text with v, V, or Ctrl+v
3. Press formatting key to apply to entire selection

# List workflow
1. Type - and space to start a list
2. Press Enter to continue adding items
3. Press Tab to nest items
4. Press Enter twice on empty item to finish
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

