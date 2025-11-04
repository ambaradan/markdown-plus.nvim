---@module 'markdown-plus.table.format'
---@brief [[
--- Table formatter for markdown tables
---
--- Handles automatic formatting and alignment of tables including:
--- - Column width calculation
--- - Cell padding and alignment
--- - Separator row generation
--- - Pretty-printing with proper spacing
---@brief ]]

local M = {}

---Calculate maximum width for each column
---@param cells string[][] Cell contents [row][col]
---@param cols integer Number of columns
---@return integer[] widths Maximum width for each column
local function calculate_column_widths(cells, cols)
  local widths = {}
  for col = 1, cols do
    local max_width = 3 -- Minimum width (for "---")
    for _, row in ipairs(cells) do
      if row[col] then
        max_width = math.max(max_width, vim.fn.strwidth(row[col]))
      end
    end
    table.insert(widths, max_width)
  end
  return widths
end

---Pad a cell to specified width with alignment
---@param content string Cell content
---@param width integer Target width
---@param alignment string 'left', 'center', or 'right'
---@return string padded Padded cell content
local function pad_cell(content, width, alignment)
  local content_width = vim.fn.strwidth(content)
  local padding = width - content_width

  if padding <= 0 then
    return content
  end

  if alignment == "center" then
    local left_pad = math.floor(padding / 2)
    local right_pad = padding - left_pad
    return string.rep(" ", left_pad) .. content .. string.rep(" ", right_pad)
  elseif alignment == "right" then
    return string.rep(" ", padding) .. content
  else -- left
    return content .. string.rep(" ", padding)
  end
end

---Generate separator cell with alignment markers
---@param width integer Width of the cell
---@param alignment string 'left', 'center', or 'right'
---@return string separator Separator cell
local function generate_separator_cell(width, alignment)
  -- Ensure minimum width for alignment markers
  if width < 3 then
    width = 3
  end

  if alignment == "center" then
    -- Center: colon + dashes + colon (total = width)
    local inner_dashes = math.max(1, width - 2)
    return ":" .. string.rep("-", inner_dashes) .. ":"
  elseif alignment == "right" then
    -- Right: dashes + colon (total = width)
    local dashes = math.max(2, width - 1)
    return string.rep("-", dashes) .. ":"
  else
    -- Left: just dashes
    return string.rep("-", width)
  end
end

---Format a table row
---@param cells string[] Cell contents
---@param widths integer[] Column widths
---@param alignments string[] Column alignments
---@return string row Formatted row
local function format_row(cells, widths, alignments)
  local formatted = {}
  for col = 1, #widths do
    local content = cells[col] or ""
    local padded = pad_cell(content, widths[col], alignments[col] or "left")
    table.insert(formatted, padded)
  end
  return "| " .. table.concat(formatted, " | ") .. " |"
end

---Format separator row
---@param widths integer[] Column widths
---@param alignments string[] Column alignments
---@return string separator Formatted separator row
local function format_separator(widths, alignments)
  local separators = {}
  for col = 1, #widths do
    local sep = generate_separator_cell(widths[col], alignments[col] or "left")
    table.insert(separators, sep)
  end
  return "| " .. table.concat(separators, " | ") .. " |"
end

---Format and replace table in buffer
---@param table_info TableInfo Parsed table information
function M.format_table(table_info)
  local widths = calculate_column_widths(table_info.cells, table_info.cols)

  -- Format all rows
  local formatted_rows = {}

  -- Header row
  table.insert(formatted_rows, format_row(table_info.cells[1], widths, table_info.alignments))

  -- Separator row
  table.insert(formatted_rows, format_separator(widths, table_info.alignments))

  -- Data rows
  for i = 2, #table_info.cells do
    table.insert(formatted_rows, format_row(table_info.cells[i], widths, table_info.alignments))
  end

  -- Calculate the correct end row based on current table structure
  -- This handles cases where rows were added/removed from table_info.cells
  local new_end_row = table_info.start_row + #formatted_rows - 1

  -- Replace table in buffer
  vim.api.nvim_buf_set_lines(0, table_info.start_row - 1, table_info.end_row, false, formatted_rows)

  -- Update table_info.end_row to reflect the new table size
  table_info.end_row = new_end_row
end

---Format table and preserve cursor position
---@param table_info TableInfo Parsed table information
function M.format_table_preserve_cursor(table_info)
  local parser = require("markdown-plus.table.parser")
  local pos = parser.get_cursor_position_in_table()

  M.format_table(table_info)

  -- Restore cursor position if we had one
  if pos then
    -- Get updated table info
    local new_table_info = parser.get_table_at_cursor()
    if new_table_info then
      local target_row = new_table_info.start_row + pos.row
      -- Try to position cursor in the same cell
      -- For now, just restore to the same row
      vim.fn.cursor(target_row, 1)
    end
  end
end

return M
