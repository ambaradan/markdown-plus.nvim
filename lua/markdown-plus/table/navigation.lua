---@module 'markdown-plus.table.navigation'
---@brief [[
--- Table navigation for markdown tables
---
--- Provides smart navigation between table cells including:
--- - Next/previous cell (horizontal)
--- - Next/previous row (vertical)
--- - Automatic table formatting after navigation
--- - Cell boundary detection
---@brief ]]

local M = {}

---Find the start column of a cell in a row
---@param line string Table row
---@param cell_index integer Cell index (0-based)
---@return integer? col Column position (1-indexed) or nil
local function find_cell_start_col(line, cell_index)
  local col = 1

  -- Skip leading pipe
  if vim.trim(line):match("^|") then
    col = col + 1
    while col <= #line and line:sub(col, col):match("%s") do
      col = col + 1
    end
  end

  if cell_index == 0 then
    return col
  end

  -- Find the target cell
  local current_cell = 0
  while col <= #line do
    local char = line:sub(col, col)
    if char == "|" then
      local prev = col > 1 and line:sub(col - 1, col - 1) or ""
      if prev ~= "\\" then
        current_cell = current_cell + 1
        if current_cell == cell_index then
          -- Skip pipe and whitespace
          col = col + 1
          while col <= #line and line:sub(col, col):match("%s") do
            col = col + 1
          end
          return col
        end
      end
    end
    col = col + 1
  end

  return nil
end

---Move cursor to a specific cell in the table
---@param table_info TableInfo Parsed table information
---@param row integer Row index (0 = header, 1 = separator, 2+ = data)
---@param col integer Column index (0-based)
---@return boolean success True if cursor was moved
function M.move_to_cell(table_info, row, col)
  -- Validate bounds
  if row < 0 or row >= #table_info.cells then
    return false
  end
  if col < 0 or col >= table_info.cols then
    return false
  end

  -- Calculate line number (skip separator row)
  local line_num = table_info.start_row + row
  if row >= 1 then
    line_num = line_num + 1 -- Account for separator
  end

  -- Get the line
  local line = vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1]
  if not line then
    return false
  end

  -- Find cell start column
  local cell_col = find_cell_start_col(line, col)
  if not cell_col then
    return false
  end

  -- Move cursor
  vim.fn.cursor(line_num, cell_col)
  return true
end

---Check if cursor is currently in a table
---@return boolean
function M.is_in_table()
  local parser = require("markdown-plus.table.parser")
  return parser.get_table_at_cursor() ~= nil
end

---Move to next cell (right)
---@return boolean success True if navigation succeeded
function M.move_to_next_cell()
  local parser = require("markdown-plus.table.parser")
  local table_info = parser.get_table_at_cursor()
  if not table_info then
    return false
  end

  local pos = parser.get_cursor_position_in_table()
  if not pos then
    return false
  end

  -- Skip separator row
  local row = pos.row
  if row == 1 then
    row = 2
  end

  -- Try to move right
  if pos.col + 1 < table_info.cols then
    return M.move_to_cell(table_info, row, pos.col + 1)
  end

  -- Wrap to next row, first column
  if row + 1 < #table_info.cells then
    return M.move_to_cell(table_info, row + 1, 0)
  end

  return false
end

---Move to previous cell (left)
---@return boolean success True if navigation succeeded
function M.move_to_prev_cell()
  local parser = require("markdown-plus.table.parser")
  local table_info = parser.get_table_at_cursor()
  if not table_info then
    return false
  end

  local pos = parser.get_cursor_position_in_table()
  if not pos then
    return false
  end

  -- Skip separator row
  local row = pos.row
  if row == 1 then
    row = 0
  end

  -- Try to move left
  if pos.col > 0 then
    return M.move_to_cell(table_info, row, pos.col - 1)
  end

  -- Wrap to previous row, last column
  if row > 0 then
    return M.move_to_cell(table_info, row - 1, table_info.cols - 1)
  end

  return false
end

---Move to cell below (same column)
---@return boolean success True if navigation succeeded
function M.move_to_next_row()
  local parser = require("markdown-plus.table.parser")
  local table_info = parser.get_table_at_cursor()
  if not table_info then
    return false
  end

  local pos = parser.get_cursor_position_in_table()
  if not pos then
    return false
  end

  -- Skip separator row
  local row = pos.row
  if row == 0 then
    -- From header to first data row
    row = 2
  elseif row == 1 then
    -- From separator to first data row
    row = 2
  else
    -- Move to next data row
    row = row + 1
  end

  if row < #table_info.cells then
    return M.move_to_cell(table_info, row, pos.col)
  end

  return false
end

---Move to cell above (same column)
---@return boolean success True if navigation succeeded
function M.move_to_prev_row()
  local parser = require("markdown-plus.table.parser")
  local table_info = parser.get_table_at_cursor()
  if not table_info then
    return false
  end

  local pos = parser.get_cursor_position_in_table()
  if not pos then
    return false
  end

  -- Skip separator row
  local row = pos.row
  if row == 2 then
    -- From first data row to header
    row = 0
  elseif row == 1 then
    -- From separator to header
    row = 0
  else
    -- Move to previous data row
    row = row - 1
  end

  if row >= 0 then
    return M.move_to_cell(table_info, row, pos.col)
  end

  return false
end

return M
