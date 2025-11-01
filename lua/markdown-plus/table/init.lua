---@module 'markdown-plus.table'
---@brief [[
--- Table editing module for markdown-plus.nvim
---
--- This module provides comprehensive table editing capabilities including:
--- - Automatic table formatting and alignment
--- - Smart cell navigation
--- - Row and column operations (insert, delete, move)
--- - Table creation and normalization
--- - Advanced features (sorting, CSV conversion, transpose)
---@brief ]]

local M = {}

---@class TableConfig
---@field enabled boolean Enable table features
---@field auto_format boolean Automatically format tables on edit
---@field default_alignment string Default column alignment ('left', 'center', 'right')
---@field keymaps TableKeymaps Keymap configuration

---@class TableKeymaps
---@field enabled boolean Enable default keymaps
---@field prefix string Keymap prefix (default: '<leader>t')

---Default configuration for table module
---@type TableConfig
M.defaults = {
  enabled = true,
  auto_format = true,
  default_alignment = "left",
  keymaps = {
    enabled = true,
    prefix = "<leader>t",
  },
}

---Current table configuration
---@type TableConfig
M.config = vim.deepcopy(M.defaults)

---Setup table module with user configuration
---@param opts? TableConfig User configuration
function M.setup(opts)
  M.config = vim.tbl_deep_extend("force", M.defaults, opts or {})

  if not M.config.enabled then
    return
  end

  -- Register global <Plug> mappings once
  local keymaps = require("markdown-plus.table.keymaps")
  keymaps.register_plug_mappings()
end

---Check if cursor is inside a table
---@return boolean
function M.is_in_table()
  local parser = require("markdown-plus.table.parser")
  return parser.get_table_at_cursor() ~= nil
end

---Format the table at cursor position
---@return boolean success True if table was formatted
function M.format_table()
  local parser = require("markdown-plus.table.parser")
  local formatter = require("markdown-plus.table.format")

  local table_info = parser.get_table_at_cursor()
  if not table_info then
    vim.notify("Not in a table", vim.log.levels.WARN)
    return false
  end

  formatter.format_table(table_info)
  return true
end

---Normalize a malformed table at cursor position
---This is an alias for format_table() that emphasizes fixing malformed tables
---@return boolean success True if table was normalized
function M.normalize_table()
  return M.format_table()
end

---Create a new table with specified dimensions
---@param rows integer Number of rows (excluding header)
---@param cols integer Number of columns
function M.create_table(rows, cols)
  local creator = require("markdown-plus.table.creator")
  creator.create_table(rows, cols, M.config.default_alignment)
end

---Insert row below current row
---@return boolean success True if row was inserted
function M.insert_row_below()
  local manip = require("markdown-plus.table.manipulation")
  return manip.insert_row(false)
end

---Insert row above current row
---@return boolean success True if row was inserted
function M.insert_row_above()
  local manip = require("markdown-plus.table.manipulation")
  return manip.insert_row(true)
end

---Delete current row
---@return boolean success True if row was deleted
function M.delete_row()
  local manip = require("markdown-plus.table.manipulation")
  return manip.delete_row()
end

---Insert column to the right
---@return boolean success True if column was inserted
function M.insert_column_right()
  local manip = require("markdown-plus.table.manipulation")
  return manip.insert_column(false)
end

---Insert column to the left
---@return boolean success True if column was inserted
function M.insert_column_left()
  local manip = require("markdown-plus.table.manipulation")
  return manip.insert_column(true)
end

---Delete current column
---@return boolean success True if column was deleted
function M.delete_column()
  local manip = require("markdown-plus.table.manipulation")
  return manip.delete_column()
end

return M
