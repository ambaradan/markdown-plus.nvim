-- Text formatting module for markdown-plus.nvim
local utils = require("markdown-plus.utils")
local M = {}

---@type markdown-plus.InternalConfig
M.config = {}

---Formatting pattern definition
---@class markdown-plus.format.Pattern
---@field start string Start pattern (Lua pattern)
---@field end_pat string End pattern (Lua pattern)
---@field wrap string Wrapper string

---Formatting patterns for different styles
---@type table<string, markdown-plus.format.Pattern>
M.patterns = {
  bold = { start = "%*%*", end_pat = "%*%*", wrap = "**" },
  italic = { start = "%*", end_pat = "%*", wrap = "*" },
  strikethrough = { start = "~~", end_pat = "~~", wrap = "~~" },
  code = { start = "`", end_pat = "`", wrap = "`" },
}

---Setup text formatting module
---@param config markdown-plus.InternalConfig Plugin configuration
---@return nil
function M.setup(config)
  M.config = config or {}
end

---Enable formatting features for current buffer
---@return nil
function M.enable()
  if not utils.is_markdown_buffer() then
    return
  end

  -- Set up keymaps
  M.setup_keymaps()
end

---Set up keymaps for text formatting
---@return nil
function M.setup_keymaps()
  if not M.config.keymaps or not M.config.keymaps.enabled then
    return
  end

  -- Create <Plug> mappings first
  -- Visual mode <Plug> mappings
  -- NOTE: We use simple functions that will be called while still in visual mode
  -- This allows get_visual_selection() to detect we're in visual mode and use vim.fn.getpos('v')
  vim.keymap.set("x", "<Plug>(MarkdownPlusBold)", function()
    M.toggle_format("bold")
  end, {
    silent = true,
    desc = "Toggle bold formatting",
  })
  vim.keymap.set("x", "<Plug>(MarkdownPlusItalic)", function()
    M.toggle_format("italic")
  end, {
    silent = true,
    desc = "Toggle italic formatting",
  })
  vim.keymap.set("x", "<Plug>(MarkdownPlusStrikethrough)", function()
    M.toggle_format("strikethrough")
  end, {
    silent = true,
    desc = "Toggle strikethrough formatting",
  })
  vim.keymap.set("x", "<Plug>(MarkdownPlusCode)", function()
    M.toggle_format("code")
  end, {
    silent = true,
    desc = "Toggle inline code formatting",
  })
  vim.keymap.set("x", "<Plug>(MarkdownPlusClearFormatting)", function()
    M.clear_formatting()
  end, {
    silent = true,
    desc = "Clear all formatting",
  })

  -- Normal mode <Plug> mappings
  vim.keymap.set("n", "<Plug>(MarkdownPlusBold)", function()
    M.toggle_format_word("bold")
  end, {
    silent = true,
    desc = "Toggle bold on word",
  })
  vim.keymap.set("n", "<Plug>(MarkdownPlusItalic)", function()
    M.toggle_format_word("italic")
  end, {
    silent = true,
    desc = "Toggle italic on word",
  })
  vim.keymap.set("n", "<Plug>(MarkdownPlusStrikethrough)", function()
    M.toggle_format_word("strikethrough")
  end, {
    silent = true,
    desc = "Toggle strikethrough on word",
  })
  vim.keymap.set("n", "<Plug>(MarkdownPlusCode)", function()
    M.toggle_format_word("code")
  end, {
    silent = true,
    desc = "Toggle inline code on word",
  })
  vim.keymap.set("n", "<Plug>(MarkdownPlusClearFormatting)", M.clear_formatting_word, {
    silent = true,
    desc = "Clear formatting on word",
  })

  -- Set up default keymaps only if not already mapped
  -- Note: vim.fn.hasmapto() returns 0 or 1, and in Lua 0 is truthy, so we must compare with == 0
  if vim.fn.hasmapto("<Plug>(MarkdownPlusBold)", "x") == 0 then
    vim.keymap.set("x", "<leader>mb", "<Plug>(MarkdownPlusBold)", { buffer = true, desc = "Toggle bold" })
  end
  if vim.fn.hasmapto("<Plug>(MarkdownPlusItalic)", "x") == 0 then
    vim.keymap.set("x", "<leader>mi", "<Plug>(MarkdownPlusItalic)", { buffer = true, desc = "Toggle italic" })
  end
  if vim.fn.hasmapto("<Plug>(MarkdownPlusStrikethrough)", "x") == 0 then
    vim.keymap.set(
      "x",
      "<leader>ms",
      "<Plug>(MarkdownPlusStrikethrough)",
      { buffer = true, desc = "Toggle strikethrough" }
    )
  end
  if vim.fn.hasmapto("<Plug>(MarkdownPlusCode)", "x") == 0 then
    vim.keymap.set("x", "<leader>mc", "<Plug>(MarkdownPlusCode)", { buffer = true, desc = "Toggle inline code" })
  end
  if vim.fn.hasmapto("<Plug>(MarkdownPlusClearFormatting)", "x") == 0 then
    vim.keymap.set(
      "x",
      "<leader>mC",
      "<Plug>(MarkdownPlusClearFormatting)",
      { buffer = true, desc = "Clear formatting" }
    )
  end

  if vim.fn.hasmapto("<Plug>(MarkdownPlusBold)", "n") == 0 then
    vim.keymap.set("n", "<leader>mb", "<Plug>(MarkdownPlusBold)", { buffer = true, desc = "Toggle bold on word" })
  end
  if vim.fn.hasmapto("<Plug>(MarkdownPlusItalic)", "n") == 0 then
    vim.keymap.set("n", "<leader>mi", "<Plug>(MarkdownPlusItalic)", { buffer = true, desc = "Toggle italic on word" })
  end
  if vim.fn.hasmapto("<Plug>(MarkdownPlusStrikethrough)", "n") == 0 then
    vim.keymap.set(
      "n",
      "<leader>ms",
      "<Plug>(MarkdownPlusStrikethrough)",
      { buffer = true, desc = "Toggle strikethrough on word" }
    )
  end
  if vim.fn.hasmapto("<Plug>(MarkdownPlusCode)", "n") == 0 then
    vim.keymap.set(
      "n",
      "<leader>mc",
      "<Plug>(MarkdownPlusCode)",
      { buffer = true, desc = "Toggle inline code on word" }
    )
  end
  if vim.fn.hasmapto("<Plug>(MarkdownPlusClearFormatting)", "n") == 0 then
    vim.keymap.set(
      "n",
      "<leader>mC",
      "<Plug>(MarkdownPlusClearFormatting)",
      { buffer = true, desc = "Clear formatting on word" }
    )
  end
end

-- Get visual selection range
function M.get_visual_selection()
  -- WORKAROUND: The '< and '> marks are not updated until AFTER exiting visual mode
  -- So we need to get the current visual selection using vim.fn.mode() and cursor positions
  local mode = vim.fn.mode()

  -- If we're in visual mode, use the visual start position and current cursor
  if mode:match("[vV\22]") then -- v, V, or CTRL-V (block mode)
    -- Get visual mode start position
    local start_pos = vim.fn.getpos("v")
    -- Get current cursor position (end of selection)
    local end_pos = vim.fn.getpos(".")

    local start_row = start_pos[2]
    local start_col = start_pos[3]
    local end_row = end_pos[2]
    local end_col = end_pos[3]

    -- Ensure start comes before end (handle backwards selection)
    if start_row > end_row or (start_row == end_row and start_col > end_col) then
      start_row, end_row = end_row, start_row
      start_col, end_col = end_col, start_col
    end

    return {
      start_row = start_row,
      start_col = start_col,
      end_row = end_row,
      end_col = end_col,
    }
  else
    -- If not in visual mode, fall back to '< and '> marks (for when called after visual mode)
    local start_pos = vim.fn.getpos("'<")
    local end_pos = vim.fn.getpos("'>")

    local start_row = start_pos[2]
    local start_col = start_pos[3]
    local end_row = end_pos[2]
    local end_col = end_pos[3]

    -- Ensure start comes before end (handle backwards selection)
    if start_row > end_row or (start_row == end_row and start_col > end_col) then
      start_row, end_row = end_row, start_row
      start_col, end_col = end_col, start_col
    end

    return {
      start_row = start_row,
      start_col = start_col,
      end_row = end_row,
      end_col = end_col,
    }
  end
end

-- Get text in range
function M.get_text_in_range(start_row, start_col, end_row, end_col)
  local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)

  if #lines == 0 then
    return ""
  end

  if #lines == 1 then
    -- Single line selection
    return lines[1]:sub(start_col, end_col)
  else
    -- Multi-line selection
    local text = {}
    -- First line
    table.insert(text, lines[1]:sub(start_col))
    -- Middle lines
    for i = 2, #lines - 1 do
      table.insert(text, lines[i])
    end
    -- Last line
    table.insert(text, lines[#lines]:sub(1, end_col))
    return table.concat(text, "\n")
  end
end

-- Set text in range
function M.set_text_in_range(start_row, start_col, end_row, end_col, new_text)
  -- Validate that start comes before end
  if start_row > end_row or (start_row == end_row and start_col > end_col) then
    vim.notify("MarkdownPlus: Invalid range - start position is after end position", vim.log.levels.ERROR)
    return
  end

  local lines = vim.split(new_text, "\n")

  if start_row == end_row then
    -- Single line replacement
    local line = utils.get_line(start_row)
    local before = line:sub(1, start_col - 1)
    local after = line:sub(end_col + 1)
    local new_line = before .. new_text .. after
    utils.set_line(start_row, new_line)
  else
    -- Multi-line replacement
    local first_line = utils.get_line(start_row)
    local last_line = utils.get_line(end_row)

    local before = first_line:sub(1, start_col - 1)
    local after = last_line:sub(end_col + 1)

    lines[1] = before .. lines[1]
    lines[#lines] = lines[#lines] .. after

    vim.api.nvim_buf_set_lines(0, start_row - 1, end_row, false, lines)
  end
end

-- Check if text has formatting
function M.has_formatting(text, format_type)
  local pattern = M.patterns[format_type]
  if not pattern then
    return false
  end

  local start_pattern = "^" .. pattern.start
  local end_pattern = pattern.end_pat .. "$"

  return text:match(start_pattern) ~= nil and text:match(end_pattern) ~= nil
end

-- Add formatting to text
function M.add_formatting(text, format_type)
  local pattern = M.patterns[format_type]
  if not pattern then
    return text
  end

  return pattern.wrap .. text .. pattern.wrap
end

-- Remove formatting from text
function M.remove_formatting(text, format_type)
  local pattern = M.patterns[format_type]
  if not pattern then
    return text
  end

  local start_pattern = "^" .. pattern.start
  local end_pattern = pattern.end_pat .. "$"

  text = text:gsub(start_pattern, "")
  text = text:gsub(end_pattern, "")

  return text
end

-- Toggle formatting on visual selection
function M.toggle_format(format_type)
  -- Get the current visual selection (works even on first selection due to vim.fn.getpos('v'))
  local selection = M.get_visual_selection()
  local text = M.get_text_in_range(selection.start_row, selection.start_col, selection.end_row, selection.end_col)

  local new_text
  if M.has_formatting(text, format_type) then
    new_text = M.remove_formatting(text, format_type)
  else
    new_text = M.add_formatting(text, format_type)
  end

  M.set_text_in_range(selection.start_row, selection.start_col, selection.end_row, selection.end_col, new_text)

  -- Exit visual mode after the operation
  vim.cmd("normal! gv")
end

-- Get current word boundaries
function M.get_word_boundaries()
  local cursor = utils.get_cursor()
  local row = cursor[1]
  local col = cursor[2]
  local line = utils.get_current_line()

  -- Define what characters are considered word boundaries (stop points)
  -- We want to stop at spaces and most punctuation, but NOT:
  -- - hyphens (-) - for words like "test-with-hyphens"
  -- - dots (.) - for words like "test.with.dots"
  -- - underscores (_) - for words like "test_with_underscores"
  -- - formatting markers (*, `, ~) - we need to include them in selection
  local function is_word_boundary(char)
    -- Empty or space is always a boundary
    if char == "" or char:match("%s") then
      return true
    end
    -- Punctuation except our allowed characters
    if char:match("%p") then
      -- Allow these characters as part of words
      if char == "-" or char == "." or char == "_" or char == "*" or char == "`" or char == "~" then
        return false
      end
      return true
    end
    return false
  end

  -- Find word start
  local word_start = col
  while word_start > 0 do
    local char = line:sub(word_start, word_start)
    if is_word_boundary(char) then
      word_start = word_start + 1
      break
    end
    word_start = word_start - 1
  end
  if word_start == 0 then
    word_start = 1
  end

  -- Find word end
  local word_end = col + 1
  while word_end <= #line do
    local char = line:sub(word_end, word_end)
    if is_word_boundary(char) then
      word_end = word_end - 1
      break
    end
    word_end = word_end + 1
  end
  if word_end > #line then
    word_end = #line
  end

  return {
    row = row,
    start_col = word_start,
    end_col = word_end,
  }
end

-- Toggle formatting on current word
function M.toggle_format_word(format_type)
  local boundaries = M.get_word_boundaries()
  local text = M.get_text_in_range(boundaries.row, boundaries.start_col, boundaries.row, boundaries.end_col)

  if text == "" then
    return
  end

  local new_text
  if M.has_formatting(text, format_type) then
    new_text = M.remove_formatting(text, format_type)
  else
    new_text = M.add_formatting(text, format_type)
  end

  M.set_text_in_range(boundaries.row, boundaries.start_col, boundaries.row, boundaries.end_col, new_text)

  -- Adjust cursor position
  local cursor = utils.get_cursor()
  utils.set_cursor(cursor[1], cursor[2])
end

-- Remove all formatting from visual selection
function M.clear_formatting()
  -- Get the current visual selection (works even on first selection due to vim.fn.getpos('v'))
  local selection = M.get_visual_selection()
  local text = M.get_text_in_range(selection.start_row, selection.start_col, selection.end_row, selection.end_col)

  -- Remove all formatting - must process in order from longest to shortest
  -- to avoid issues like ** becoming * after first pass
  local new_text = text

  -- Remove bold (must come before italic since ** contains *)
  new_text = new_text:gsub("%*%*(.-)%*%*", "%1") -- **text**
  new_text = new_text:gsub("__(.-)__", "%1") -- __text__

  -- Remove strikethrough
  new_text = new_text:gsub("~~(.-)~~", "%1") -- ~~text~~

  -- Remove italic (after bold to avoid breaking **)
  new_text = new_text:gsub("%*(.-)%*", "%1") -- *text*
  new_text = new_text:gsub("_(.-)_", "%1") -- _text_

  -- Remove code
  new_text = new_text:gsub("`(.-)`", "%1") -- `text`

  M.set_text_in_range(selection.start_row, selection.start_col, selection.end_row, selection.end_col, new_text)

  -- Exit visual mode after the operation
  vim.cmd("normal! gv")
end

-- Remove all formatting from current word
function M.clear_formatting_word()
  local boundaries = M.get_word_boundaries()
  local text = M.get_text_in_range(boundaries.row, boundaries.start_col, boundaries.row, boundaries.end_col)

  if text == "" then
    return
  end

  -- Remove all formatting - must process in order from longest to shortest
  local new_text = text

  -- Remove bold (must come before italic)
  new_text = new_text:gsub("%*%*(.-)%*%*", "%1")
  new_text = new_text:gsub("__(.-)__", "%1")

  -- Remove strikethrough
  new_text = new_text:gsub("~~(.-)~~", "%1")

  -- Remove italic (after bold)
  new_text = new_text:gsub("%*(.-)%*", "%1")
  new_text = new_text:gsub("_(.-)_", "%1")

  -- Remove code
  new_text = new_text:gsub("`(.-)`", "%1")

  M.set_text_in_range(boundaries.row, boundaries.start_col, boundaries.row, boundaries.end_col, new_text)
end

return M
