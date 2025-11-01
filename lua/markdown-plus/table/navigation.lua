---@module 'markdown-plus.table.navigation'
---@brief [[
--- Table navigation utilities for markdown tables
---
--- Provides cursor positioning within table cells for manipulation operations
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
  -- Validate bounds (row=1 is separator, not in cells array)
  if row < 0 or (row > 1 and row - 1 >= #table_info.cells) then
    return false
  end
  if col < 0 or col >= table_info.cols then
    return false
  end

  -- Calculate actual line number (account for separator between header and data rows)
  -- row: 0=header, 1=separator (not in cells), 2+=data rows
  local line_num
  if row == 1 then
    line_num = table_info.start_row + 1
  elseif row > 1 then
    line_num = table_info.start_row + row + 1
  else
    line_num = table_info.start_row
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

return M
