-- List management module for markdown-plus.nvim
local utils = require("markdown-plus.utils")
local M = {}

---@type markdown-plus.InternalConfig
M.config = {}

---List patterns for detection
---@class markdown-plus.list.Patterns
---@field unordered string Pattern for unordered lists (-, +, *)
---@field ordered string Pattern for ordered lists (1., 2., etc.)
---@field checkbox string Pattern for checkbox lists (- [ ], - [x], etc.)
---@field ordered_checkbox string Pattern for ordered checkbox lists (1. [ ], etc.)

---@type markdown-plus.list.Patterns
M.patterns = {
  unordered = "^(%s*)([%-%+%*])%s+",
  ordered = "^(%s*)(%d+)%.%s+",
  checkbox = "^(%s*)([%-%+%*])%s+%[(.?)%]%s+",
  ordered_checkbox = "^(%s*)(%d+)%.%s+%[(.?)%]%s+",
}

---Setup list management module
---@param config markdown-plus.InternalConfig Plugin configuration
---@return nil
function M.setup(config)
  M.config = config or {}
end

---Enable list management features for current buffer
---@return nil
function M.enable()
  if not utils.is_markdown_buffer() then
    return
  end

  -- Set up keymaps
  M.setup_keymaps()
end

---Set up keymaps for list management
---@return nil
function M.setup_keymaps()
  if not M.config.keymaps or not M.config.keymaps.enabled then
    return
  end

  -- Create <Plug> mappings first
  vim.keymap.set("i", "<Plug>(MarkdownPlusListEnter)", M.handle_enter, {
    silent = true,
    desc = "Auto-continue list or break out",
  })
  vim.keymap.set("i", "<Plug>(MarkdownPlusListIndent)", M.handle_tab, {
    silent = true,
    desc = "Indent list item",
  })
  vim.keymap.set("i", "<Plug>(MarkdownPlusListOutdent)", M.handle_shift_tab, {
    silent = true,
    desc = "Outdent list item",
  })
  vim.keymap.set("i", "<Plug>(MarkdownPlusListBackspace)", M.handle_backspace, {
    silent = true,
    desc = "Smart backspace (remove empty list)",
  })
  vim.keymap.set("n", "<Plug>(MarkdownPlusRenumberLists)", M.renumber_ordered_lists, {
    silent = true,
    desc = "Renumber ordered lists",
  })
  vim.keymap.set("n", "<Plug>(MarkdownPlusDebugLists)", M.debug_list_groups, {
    silent = true,
    desc = "Debug list groups",
  })
  vim.keymap.set("n", "<Plug>(MarkdownPlusNewListItemBelow)", M.handle_normal_o, {
    silent = true,
    desc = "New list item below",
  })
  vim.keymap.set("n", "<Plug>(MarkdownPlusNewListItemAbove)", M.handle_normal_O, {
    silent = true,
    desc = "New list item above",
  })

  -- Set up default keymaps only if not already mapped
  if not vim.fn.hasmapto("<Plug>(MarkdownPlusListEnter)", "i") then
    vim.keymap.set("i", "<CR>", "<Plug>(MarkdownPlusListEnter)", { buffer = true })
  end
  if not vim.fn.hasmapto("<Plug>(MarkdownPlusListIndent)", "i") then
    vim.keymap.set("i", "<Tab>", "<Plug>(MarkdownPlusListIndent)", { buffer = true })
  end
  if not vim.fn.hasmapto("<Plug>(MarkdownPlusListOutdent)", "i") then
    vim.keymap.set("i", "<S-Tab>", "<Plug>(MarkdownPlusListOutdent)", { buffer = true })
  end
  if not vim.fn.hasmapto("<Plug>(MarkdownPlusListBackspace)", "i") then
    vim.keymap.set("i", "<BS>", "<Plug>(MarkdownPlusListBackspace)", { buffer = true })
  end
  if not vim.fn.hasmapto("<Plug>(MarkdownPlusRenumberLists)", "n") then
    vim.keymap.set("n", "<leader>mr", "<Plug>(MarkdownPlusRenumberLists)", { buffer = true })
  end
  if not vim.fn.hasmapto("<Plug>(MarkdownPlusDebugLists)", "n") then
    vim.keymap.set("n", "<leader>md", "<Plug>(MarkdownPlusDebugLists)", { buffer = true })
  end
  if not vim.fn.hasmapto("<Plug>(MarkdownPlusNewListItemBelow)", "n") then
    vim.keymap.set("n", "o", "<Plug>(MarkdownPlusNewListItemBelow)", { buffer = true })
  end
  if not vim.fn.hasmapto("<Plug>(MarkdownPlusNewListItemAbove)", "n") then
    vim.keymap.set("n", "O", "<Plug>(MarkdownPlusNewListItemAbove)", { buffer = true })
  end

  -- Set up autocommands for auto-renumbering
  M.setup_renumber_autocmds()
end

---Set up autocommands for auto-renumbering
---@return nil
function M.setup_renumber_autocmds()
  local group = vim.api.nvim_create_augroup("MarkdownPlusListRenumber", { clear = true })

  -- Renumber on text changes (insertions/deletions)
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
    group = group,
    buffer = 0,
    callback = function()
      M.renumber_ordered_lists()
    end,
  })
end

-- Handle Enter key press
function M.handle_enter()
  local current_line = utils.get_current_line()
  local cursor = utils.get_cursor()
  local row, col = cursor[1], cursor[2]

  -- Check if we're in a list
  local list_info = M.parse_list_line(current_line)

  if not list_info then
    -- Not in a list, simulate default Enter behavior
    -- Split the line at cursor position
    local line_before = current_line:sub(1, col)
    local line_after = current_line:sub(col + 1)

    utils.set_line(row, line_before)
    utils.insert_line(row + 1, line_after)
    utils.set_cursor(row + 1, 0)
    return
  end

  -- Check if current list item is empty
  if M.is_empty_list_item(current_line, list_info) then
    -- Empty list item - break out of list
    M.break_out_of_list(list_info)
    return
  end

  -- Create next list item
  M.create_next_list_item(list_info)
end

-- Parse a line to detect list information
function M.parse_list_line(line)
  if not line then
    return nil
  end

  -- Try ordered list with checkbox
  local indent, number, checkbox = line:match(M.patterns.ordered_checkbox)
  if indent and number and checkbox then
    return {
      type = "ordered",
      indent = indent,
      marker = number .. ".",
      checkbox = checkbox,
      full_marker = number .. ". [" .. checkbox .. "]",
    }
  end

  -- Try unordered list with checkbox
  local indent2, bullet, checkbox2 = line:match(M.patterns.checkbox)
  if indent2 and bullet and checkbox2 then
    return {
      type = "unordered",
      indent = indent2,
      marker = bullet,
      checkbox = checkbox2,
      full_marker = bullet .. " [" .. checkbox2 .. "]",
    }
  end

  -- Try ordered list
  local indent3, number2 = line:match(M.patterns.ordered)
  if indent3 and number2 then
    return {
      type = "ordered",
      indent = indent3,
      marker = number2 .. ".",
      checkbox = nil,
      full_marker = number2 .. ".",
    }
  end

  -- Try unordered list
  local indent4, bullet2 = line:match(M.patterns.unordered)
  if indent4 and bullet2 then
    return {
      type = "unordered",
      indent = indent4,
      marker = bullet2,
      checkbox = nil,
      full_marker = bullet2,
    }
  end

  return nil
end

-- Check if a list item is empty (only contains marker)
function M.is_empty_list_item(line, list_info)
  if not line or not list_info then
    return false
  end

  local content_pattern = "^" .. utils.escape_pattern(list_info.indent .. list_info.full_marker) .. "%s*$"
  return line:match(content_pattern) ~= nil
end

-- Break out of list (remove current empty item)
function M.break_out_of_list(list_info)
  local cursor = utils.get_cursor()
  local row = cursor[1]

  -- Replace current line with just the indentation
  utils.set_line(row, list_info.indent)

  -- Position cursor at end of line
  utils.set_cursor(row, #list_info.indent)
end

-- Create next list item
function M.create_next_list_item(list_info)
  local cursor = utils.get_cursor()
  local row = cursor[1]

  local next_marker
  if list_info.type == "ordered" then
    -- Get next number
    local current_num = tonumber(list_info.marker:match("(%d+)"))
    next_marker = (current_num + 1) .. "."
  else
    -- Keep same bullet
    next_marker = list_info.marker
  end

  -- Build next line
  local next_line = list_info.indent .. next_marker .. " "
  if list_info.checkbox then
    next_line = next_line .. "[ ] "
  end

  -- Insert new line
  utils.insert_line(row + 1, next_line)

  -- Move cursor to new line at end
  utils.set_cursor(row + 1, #next_line)
end

-- Handle Tab key for indentation
function M.handle_tab()
  local current_line = utils.get_current_line()
  local list_info = M.parse_list_line(current_line)

  if not list_info then
    -- Not in a list, insert a tab character or spaces
    local cursor = utils.get_cursor()
    local row, col = cursor[1], cursor[2]
    local indent = string.rep(" ", vim.bo.shiftwidth or 2)
    local new_line = current_line:sub(1, col) .. indent .. current_line:sub(col + 1)
    utils.set_line(row, new_line)
    utils.set_cursor(row, col + #indent)
    return
  end

  -- Increase indentation
  local cursor = utils.get_cursor()
  local row, col = cursor[1], cursor[2]
  local indent_size = vim.bo.shiftwidth

  local new_indent = list_info.indent .. string.rep(" ", indent_size)
  local new_line = new_indent .. list_info.full_marker .. " " .. current_line:match(list_info.full_marker .. "%s*(.*)")

  utils.set_line(row, new_line)

  -- Adjust cursor position
  utils.set_cursor(row, col + indent_size)
end

-- Handle Shift+Tab key for outdentation
function M.handle_shift_tab()
  local current_line = utils.get_current_line()
  local list_info = M.parse_list_line(current_line)

  if not list_info then
    -- Not in a list, remove indentation if any
    local cursor = utils.get_cursor()
    local row, col = cursor[1], cursor[2]
    local indent_size = vim.bo.shiftwidth or 2
    local leading_spaces = current_line:match("^(%s*)")

    if #leading_spaces >= indent_size then
      local new_line = current_line:sub(indent_size + 1)
      utils.set_line(row, new_line)
      utils.set_cursor(row, math.max(0, col - indent_size))
    end
    return
  end

  -- Decrease indentation
  local cursor = utils.get_cursor()
  local row, col = cursor[1], cursor[2]
  local indent_size = vim.bo.shiftwidth

  if #list_info.indent < indent_size then
    -- Can't outdent further
    return
  end

  local new_indent = list_info.indent:sub(1, -indent_size - 1)
  local content = current_line:match(list_info.full_marker .. "%s*(.*)")
  local new_line = new_indent .. list_info.full_marker .. " " .. (content or "")

  utils.set_line(row, new_line)

  -- Adjust cursor position
  local new_col = math.max(0, col - indent_size)
  utils.set_cursor(row, new_col)
end

-- Handle Backspace key for smart list removal
function M.handle_backspace()
  local current_line = utils.get_current_line()
  local cursor = utils.get_cursor()
  local row, col = cursor[1], cursor[2]

  -- Check if cursor is at the beginning of list content
  local list_info = M.parse_list_line(current_line)
  if not list_info then
    -- Not in a list, delete character before cursor
    if col > 0 then
      local new_line = current_line:sub(1, col - 1) .. current_line:sub(col + 1)
      utils.set_line(row, new_line)
      utils.set_cursor(row, col - 1)
    elseif row > 1 then
      -- At beginning of line, join with previous line
      local prev_line = utils.get_line(row - 1)
      local joined = prev_line .. current_line
      vim.api.nvim_buf_set_lines(0, row - 2, row, false, { joined })
      utils.set_cursor(row - 1, #prev_line)
    end
    return
  end

  local marker_end = #list_info.indent + #list_info.full_marker + 1
  if col == marker_end and M.is_empty_list_item(current_line, list_info) then
    -- At the beginning of empty list item, remove the list marker
    utils.set_line(row, list_info.indent)
    utils.set_cursor(row, #list_info.indent)
    return
  end

  -- Default backspace in list item
  if col > 0 then
    local new_line = current_line:sub(1, col - 1) .. current_line:sub(col + 1)
    utils.set_line(row, new_line)
    utils.set_cursor(row, col - 1)
  end
end

-- Handle normal mode 'o' key
function M.handle_normal_o()
  local current_line = utils.get_current_line()
  local cursor = utils.get_cursor()
  local row = cursor[1]

  -- Check if current line is a list item
  local list_info = M.parse_list_line(current_line)

  if not list_info then
    -- Not in a list, use default 'o' behavior
    -- Create blank line below and enter insert mode
    utils.insert_line(row + 1, "")
    utils.set_cursor(row + 1, 0)
    vim.cmd("startinsert")
    return
  end

  -- Create next list item and enter insert mode
  local next_marker
  if list_info.type == "ordered" then
    -- Get next number
    local current_num = tonumber(list_info.marker:match("(%d+)"))
    next_marker = (current_num + 1) .. "."
  else
    -- Keep same bullet
    next_marker = list_info.marker
  end

  -- Build next line
  local next_line = list_info.indent .. next_marker .. " "
  if list_info.checkbox then
    next_line = next_line .. "[ ] "
  end

  -- Insert new line after current
  utils.insert_line(row + 1, next_line)

  -- Move cursor to new line at end and enter insert mode
  utils.set_cursor(row + 1, #next_line)
  vim.cmd("startinsert!")
end

-- Handle normal mode 'O' key
function M.handle_normal_O()
  local current_line = utils.get_current_line()
  local cursor = utils.get_cursor()
  local row = cursor[1]

  -- Check if current line is a list item
  local list_info = M.parse_list_line(current_line)

  if not list_info then
    -- Not in a list, use default 'O' behavior
    -- Create blank line above and enter insert mode
    utils.insert_line(row, "")
    utils.set_cursor(row, 0)
    vim.cmd("startinsert")
    return
  end

  -- For 'O', we need to create a list item before the current one
  -- This means we need to determine what the previous number should be
  local prev_marker
  if list_info.type == "ordered" then
    -- Check if there's a previous line that might be a list item
    if row > 1 then
      local prev_line = utils.get_line(row - 1)
      local prev_list_info = M.parse_list_line(prev_line)

      if prev_list_info and prev_list_info.type == "ordered" and #prev_list_info.indent == #list_info.indent then
        -- There's a previous ordered list item at same indent, use its number + 1
        local prev_num_actual = tonumber(prev_list_info.marker:match("(%d+)"))
        prev_marker = (prev_num_actual + 1) .. "."
      else
        -- No previous list item, this will become item 1, current will be renumbered
        prev_marker = "1."
      end
    else
      -- At top of document
      prev_marker = "1."
    end
  else
    -- Keep same bullet for unordered lists
    prev_marker = list_info.marker
  end

  -- Build previous line
  local prev_line = list_info.indent .. prev_marker .. " "
  if list_info.checkbox then
    prev_line = prev_line .. "[ ] "
  end

  -- Insert new line before current
  utils.insert_line(row, prev_line)

  -- Move cursor to new line at end and enter insert mode
  utils.set_cursor(row, #prev_line)
  vim.cmd("startinsert!")
end

-- Renumber all ordered lists in the buffer
function M.renumber_ordered_lists()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local modified = false
  local changes = {}

  -- Find all distinct list groups
  local list_groups = M.find_list_groups(lines)

  -- Renumber each list group
  for _, group in ipairs(list_groups) do
    local renumbered = M.renumber_list_group(group)
    if renumbered then
      modified = true
      for _, change in ipairs(renumbered) do
        table.insert(changes, change)
      end
    end
  end

  -- Apply changes if any were made
  if modified then
    for _, change in ipairs(changes) do
      utils.set_line(change.line_num, change.new_line)
    end
  end
end

-- Find all distinct list groups in the buffer
function M.find_list_groups(lines)
  local groups = {}
  local current_groups_by_indent = {} -- Track active groups by indentation level

  for i, line in ipairs(lines) do
    local list_info = M.parse_list_line(line)

    if list_info and list_info.type == "ordered" then
      local indent_level = #list_info.indent

      -- Check if we have an active group at this indentation level
      local current_group = current_groups_by_indent[indent_level]

      if not current_group then
        -- Create new group for this indentation level
        current_group = {
          indent = indent_level,
          start_line = i,
          items = {},
        }
        current_groups_by_indent[indent_level] = current_group
        table.insert(groups, current_group)
      end

      -- Add item to current group
      table.insert(current_group.items, {
        line_num = i,
        indent = list_info.indent,
        checkbox = list_info.checkbox,
        content = line:match(list_info.full_marker .. "%s*(.*)") or "",
        original_line = line,
      })
    else
      -- Not an ordered list item
      -- Check if this line breaks the list continuity
      if M.is_list_breaking_line(line) then
        -- Clear all active groups (lists are separated by non-list content)
        current_groups_by_indent = {}
      end
    end
  end

  return groups
end

-- Check if a line breaks list continuity
function M.is_list_breaking_line(line)
  -- Empty lines don't break lists
  if not line or line:match("^%s*$") then
    return false
  end

  -- Any non-list content breaks list continuity
  -- This includes headers, paragraphs, etc.
  return true
end

-- Renumber items in a list group
function M.renumber_list_group(group)
  if #group.items == 0 then
    return nil
  end

  local changes = {}
  local expected_number = 1

  for _, item in ipairs(group.items) do
    local checkbox_part = ""
    if item.checkbox then
      checkbox_part = " [" .. item.checkbox .. "]"
    end

    local expected_line = item.indent .. expected_number .. "." .. checkbox_part .. " " .. item.content

    -- Only create change if line is different
    if expected_line ~= item.original_line then
      table.insert(changes, {
        line_num = item.line_num,
        new_line = expected_line,
      })
    end

    expected_number = expected_number + 1
  end

  return #changes > 0 and changes or nil
end

-- Debug function to show detected list groups
function M.debug_list_groups()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local groups = M.find_list_groups(lines)

  print("=== Detected List Groups ===")
  for i, group in ipairs(groups) do
    print(string.format("Group %d (indent: %d, start: %d):", i, group.indent, group.start_line))
    for _, item in ipairs(group.items) do
      print(string.format("  Line %d: %s", item.line_num, item.original_line))
    end
    print()
  end
end

return M
