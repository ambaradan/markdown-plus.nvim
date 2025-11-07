---@module 'markdown-plus.table.row_mapper'
---@brief [[
--- Row index mapping utilities for table operations
---
--- This module provides explicit mapping between position rows and cells array indices.
---
--- Position row system (used by cursor position):
---   pos.row = 0: Header row
---   pos.row = 1: Separator row (VIRTUAL - not in cells array!)
---   pos.row = 2+: Data rows
---
--- Cells array system (1-indexed Lua array):
---   cells[1]: Header row
---   cells[2+]: Data rows
---   Note: Separator row is NOT in cells array
---@brief ]]

local M = {}

-- Constants for special row positions
M.HEADER_ROW = 0
M.SEPARATOR_ROW = 1
M.FIRST_DATA_ROW = 2

---Convert position row to cells array index
---@param pos_row integer Position row (0=header, 1=separator, 2+=data)
---@return integer|nil cells_index Index in cells array (1-indexed), or nil if separator
function M.pos_row_to_cells_index(pos_row)
  if pos_row == M.HEADER_ROW then
    return 1 -- cells[1] = header
  elseif pos_row == M.SEPARATOR_ROW then
    return nil -- Separator is virtual, not in cells array
  else
    -- Data rows: pos.row=2 maps to cells[2], pos.row=3 maps to cells[3], etc.
    return pos_row
  end
end

---Convert cells array index to position row
---@param cells_index integer Index in cells array (1-indexed)
---@return integer pos_row Position row (0=header, 2+=data)
function M.cells_index_to_pos_row(cells_index)
  if cells_index == 1 then
    return M.HEADER_ROW -- cells[1] = header at pos.row=0
  else
    -- Data rows: cells[2] maps to pos.row=2, cells[3] maps to pos.row=3, etc.
    return cells_index
  end
end

---Check if position row is a data row
---@param pos_row integer Position row
---@return boolean
function M.is_data_row(pos_row)
  return pos_row >= M.FIRST_DATA_ROW
end

---Check if position row is the header
---@param pos_row integer Position row
---@return boolean
function M.is_header_row(pos_row)
  return pos_row == M.HEADER_ROW
end

---Check if position row is the separator
---@param pos_row integer Position row
---@return boolean
function M.is_separator_row(pos_row)
  return pos_row == M.SEPARATOR_ROW
end

---Validate cells index is within bounds
---@param cells_index integer Cells array index
---@param cells_count integer Total number of cells
---@return boolean valid True if index is valid
---@return string|nil error_msg Error message if invalid
function M.validate_cells_index(cells_index, cells_count)
  if cells_index < 1 then
    return false, string.format("cells_index %d is less than 1", cells_index)
  end
  if cells_index > cells_count then
    return false, string.format("cells_index %d exceeds cells count %d", cells_index, cells_count)
  end
  return true, nil
end

return M
