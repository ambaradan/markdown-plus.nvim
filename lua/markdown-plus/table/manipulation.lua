---@module 'markdown-plus.table.manipulation'
---@brief [[
--- Table manipulation for markdown tables
---
--- Provides operations to modify table structure:
--- - Insert/delete rows
--- - Insert/delete columns
--- - Duplicate rows/columns
--- - Automatic reformatting after operations
---@brief ]]

local M = {}

---Insert a row in the table
---@param above boolean If true, insert above current row; otherwise below
---@return boolean success True if row was inserted
function M.insert_row(above)
  local parser = require("markdown-plus.table.parser")
  local formatter = require("markdown-plus.table.format")

  local table_info = parser.get_table_at_cursor()
  if not table_info then
    vim.notify("Not in a table", vim.log.levels.WARN)
    return false
  end

  local pos = parser.get_cursor_position_in_table()
  if not pos then
    return false
  end

  -- Create empty row
  local empty_cells = {}
  for i = 1, table_info.cols do
    table.insert(empty_cells, "")
  end

  -- Determine insertion position
  local insert_index
  if pos.row == 0 then
    -- In header - always insert after (becomes first data row)
    insert_index = 2
  elseif pos.row == 1 then
    -- In separator - insert first data row
    insert_index = 2
  else
    -- In data row
    if above then
      insert_index = pos.row
    else
      insert_index = pos.row + 1
    end
  end

  -- Insert the row into cells array
  table.insert(table_info.cells, insert_index, empty_cells)

  -- Reformat and update buffer
  formatter.format_table(table_info)

  -- Re-parse to get updated table info with correct line numbers
  table_info = parser.get_table_at_cursor()
  if not table_info then
    return false
  end

  -- Move cursor to new row (first cell)
  local navigation = require("markdown-plus.table.navigation")
  navigation.move_to_cell(table_info, insert_index, 0)

  return true
end

---Delete the current row
---@return boolean success True if row was deleted
function M.delete_row()
  local parser = require("markdown-plus.table.parser")
  local formatter = require("markdown-plus.table.format")
  local navigation = require("markdown-plus.table.navigation")

  local table_info = parser.get_table_at_cursor()
  if not table_info then
    vim.notify("Not in a table", vim.log.levels.WARN)
    return false
  end

  local pos = parser.get_cursor_position_in_table()
  if not pos then
    return false
  end

  -- Cannot delete header or separator
  if pos.row <= 1 then
    vim.notify("Cannot delete header or separator row", vim.log.levels.WARN)
    return false
  end

  -- Must have at least one data row (cells[1]=header, cells[2]=first data row)
  if #table_info.cells < 2 then
    vim.notify("Cannot delete the only data row", vim.log.levels.WARN)
    return false
  end

  -- pos.row uses 0-based indexing: 0=header, 1=separator, 2+=data rows
  -- cells array is 1-indexed (Lua): cells[1]=header, cells[2+]=data rows
  -- For data row at pos.row=N (where N>=2), delete cells[N]
  local cells_index = pos.row
  table.remove(table_info.cells, cells_index)

  -- Reformat and update buffer
  formatter.format_table(table_info)

  -- Re-parse to get updated table info with correct line numbers
  table_info = parser.get_table_at_cursor()
  if not table_info then
    return false
  end

  -- Position cursor on the row that moved up (or previous row if last)
  local new_row = pos.row
  if new_row >= #table_info.cells then
    new_row = #table_info.cells - 1
  end
  navigation.move_to_cell(table_info, new_row, pos.col)

  return true
end

---Duplicate the current row
---@return boolean success True if row was duplicated
function M.duplicate_row()
  local parser = require("markdown-plus.table.parser")
  local formatter = require("markdown-plus.table.format")
  local navigation = require("markdown-plus.table.navigation")

  local table_info = parser.get_table_at_cursor()
  if not table_info then
    vim.notify("Not in a table", vim.log.levels.WARN)
    return false
  end

  local pos = parser.get_cursor_position_in_table()
  if not pos then
    return false
  end

  -- Cannot duplicate separator row
  if pos.row == 1 then
    vim.notify("Cannot duplicate separator row", vim.log.levels.WARN)
    return false
  end

  -- pos.row is 0-indexed: 0=header, 1=separator(virtual), 2+=data rows
  -- cells array: 1=header, 2+=data rows
  local cells_index = pos.row
  local current_cells = table_info.cells[cells_index]
  if not current_cells then
    return false
  end

  -- Duplicate the cells
  local duplicate_cells = {}
  for _, cell in ipairs(current_cells) do
    table.insert(duplicate_cells, cell)
  end

  -- Insert below current row
  table.insert(table_info.cells, cells_index + 1, duplicate_cells)

  -- Reformat and update buffer
  formatter.format_table(table_info)

  -- Re-parse to get updated table info with correct line numbers
  table_info = parser.get_table_at_cursor()
  if not table_info then
    return false
  end

  -- Move cursor to duplicated row (first cell)
  navigation.move_to_cell(table_info, pos.row + 1, 0)

  return true
end

---Insert a column in the table
---@param left boolean If true, insert left of current column; otherwise right
---@return boolean success True if column was inserted
function M.insert_column(left)
  local parser = require("markdown-plus.table.parser")
  local formatter = require("markdown-plus.table.format")

  local table_info = parser.get_table_at_cursor()
  if not table_info then
    vim.notify("Not in a table", vim.log.levels.WARN)
    return false
  end

  local pos = parser.get_cursor_position_in_table()
  if not pos then
    return false
  end

  -- Determine insertion position
  local insert_col = left and pos.col or pos.col + 1

  -- Insert empty cell in each row
  for _, row in ipairs(table_info.cells) do
    table.insert(row, insert_col + 1, "")
  end

  -- Update column count and add default alignment
  table_info.cols = table_info.cols + 1
  table.insert(table_info.alignments, insert_col + 1, "left")

  -- Reformat and update buffer
  formatter.format_table(table_info)

  -- Re-parse to get updated table info with correct line numbers
  table_info = parser.get_table_at_cursor()
  if not table_info then
    return false
  end

  -- Move cursor to new column (first row of that column)
  local navigation = require("markdown-plus.table.navigation")
  navigation.move_to_cell(table_info, pos.row, insert_col)

  return true
end

---Delete the current column
---@return boolean success True if column was deleted
function M.delete_column()
  local parser = require("markdown-plus.table.parser")
  local formatter = require("markdown-plus.table.format")

  local table_info = parser.get_table_at_cursor()
  if not table_info then
    vim.notify("Not in a table", vim.log.levels.WARN)
    return false
  end

  local pos = parser.get_cursor_position_in_table()
  if not pos then
    return false
  end

  -- Must have at least 2 columns
  if table_info.cols <= 1 then
    vim.notify("Cannot delete the only column", vim.log.levels.WARN)
    return false
  end

  -- Remove column from each row
  for _, row in ipairs(table_info.cells) do
    table.remove(row, pos.col + 1)
  end

  -- Update column count and remove alignment
  table_info.cols = table_info.cols - 1
  table.remove(table_info.alignments, pos.col + 1)

  -- Reformat and update buffer
  formatter.format_table(table_info)

  -- Re-parse to get updated table info with correct line numbers
  table_info = parser.get_table_at_cursor()
  if not table_info then
    return false
  end

  -- Position cursor on the column to the left (or same position if first column deleted)
  local navigation = require("markdown-plus.table.navigation")
  local new_col = pos.col
  if new_col >= table_info.cols then
    new_col = table_info.cols - 1
  end
  navigation.move_to_cell(table_info, pos.row, new_col)

  return true
end

---Duplicate the current column
---@return boolean success True if column was duplicated
function M.duplicate_column()
  local parser = require("markdown-plus.table.parser")
  local formatter = require("markdown-plus.table.format")

  local table_info = parser.get_table_at_cursor()
  if not table_info then
    vim.notify("Not in a table", vim.log.levels.WARN)
    return false
  end

  local pos = parser.get_cursor_position_in_table()
  if not pos then
    return false
  end

  -- Duplicate column in each row
  for _, row in ipairs(table_info.cells) do
    local cell_content = row[pos.col + 1] or ""
    table.insert(row, pos.col + 2, cell_content)
  end

  -- Update column count and duplicate alignment
  table_info.cols = table_info.cols + 1
  local alignment = table_info.alignments[pos.col + 1] or "left"
  table.insert(table_info.alignments, pos.col + 2, alignment)

  -- Reformat and update buffer
  formatter.format_table(table_info)

  -- Re-parse to get updated table info with correct line numbers
  table_info = parser.get_table_at_cursor()
  if not table_info then
    return false
  end

  -- Move cursor to duplicated column (first cell)
  local navigation = require("markdown-plus.table.navigation")
  navigation.move_to_cell(table_info, pos.row, pos.col + 1)

  return true
end

return M
