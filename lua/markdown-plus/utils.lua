-- Common utilities for markdown-plus.nvim
local M = {}

-- Get current cursor position
function M.get_cursor()
  return vim.api.nvim_win_get_cursor(0)
end

-- Set cursor position
function M.set_cursor(row, col)
  vim.api.nvim_win_set_cursor(0, { row, col })
end

-- Get current line content
function M.get_current_line()
  local row = M.get_cursor()[1]
  return vim.api.nvim_buf_get_lines(0, row - 1, row, false)[1] or ""
end

-- Get line content by line number (1-indexed)
function M.get_line(line_num)
  return vim.api.nvim_buf_get_lines(0, line_num - 1, line_num, false)[1] or ""
end

-- Set line content by line number (1-indexed)
function M.set_line(line_num, content)
  vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, false, { content })
end

-- Insert line at position (1-indexed)
function M.insert_line(line_num, content)
  vim.api.nvim_buf_set_lines(0, line_num - 1, line_num - 1, false, { content })
end

-- Delete line at position (1-indexed)
function M.delete_line(line_num)
  vim.api.nvim_buf_set_lines(0, line_num - 1, line_num, false, {})
end

-- Get indentation level of a line
function M.get_indent_level(line)
  local indent = line:match("^(%s*)")
  return #indent
end

-- Get indentation string (spaces or tabs)
function M.get_indent_string(level)
  if vim.bo.expandtab then
    return string.rep(" ", level * vim.bo.shiftwidth)
  else
    return string.rep("\t", math.floor(level / vim.bo.tabstop))
  end
end

-- Check if current buffer is markdown (deprecated, kept for compatibility)
-- Note: This check is now redundant as the autocmd pattern already filters by filetype
function M.is_markdown_buffer()
  return true
end

-- Safe string matching with nil check
function M.safe_match(str, pattern)
  if not str then
    return nil
  end
  return str:match(pattern)
end

-- Escape special regex characters
function M.escape_pattern(str)
  return str:gsub("([^%w])", "%%%1")
end

-- Debug print (only when debug mode is enabled)
function M.debug_print(...)
  if vim.g.markdown_plus_debug then
    print("[MarkdownPlus]", ...)
  end
end

return M