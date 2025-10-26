-- Code block module for markdown-plus.nvim
local utils = require("markdown-plus.utils")
local M = {}

---@type markdown-plus.InternalConfig
M.config = {}

---Setup code block module with user configuration.
---@param config markdown-plus.InternalConfig Plugin configuration
---@return nil
function M.setup(config)
  M.config = config or {}
end

---Enable code block features for the current buffer.
---@return nil
function M.enable()
  if not utils.is_markdown_buffer() then
    return
  end
  M.setup_keymaps()
end

---Set up keymaps for code block formatting.
---@return nil
function M.setup_keymaps()
  if not M.config.keymaps or not M.config.keymaps.enabled then
    return
  end

  -- Visual mode <Plug> mapping
  vim.keymap.set("x", "<Plug>(MarkdownPlusCodeBlock)", function()
    M.convert_to_code_block()
  end, { silent = true, desc = "Convert selection to code block" })

  -- Set default keymap if not already mapped
  if vim.fn.hasmapto("<Plug>(MarkdownPlusCodeBlock)", "x") == 0 then
    vim.keymap.set("x", "<leader>mw", "<Plug>(MarkdownPlusCodeBlock)", {
      buffer = true,
      desc = "Convert selection to code block",
    })
  end
end

---Get the current visual selection range.
---@return table Selection range with start and end positions
function M.get_visual_selection()
  -- v, V, or CTRL-V (block mode)
  local start_pos = vim.fn.getpos("v")
  local end_pos = vim.fn.getpos(".")

  local start_row, start_col = start_pos[2], start_pos[3]
  local end_row, end_col = end_pos[2], end_pos[3]

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

---Get text within a specified range.
---@param start_row number Start row
---@param end_row number End row
---@return string[] Lines in the specified range
function M.get_lines_in_range(start_row, end_row)
  return vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
end

---Convert visual selection to a code block.
---@return nil
function M.convert_to_code_block()
  local selection = M.get_visual_selection()
  local start_row, end_row = selection.start_row, selection.end_row

  -- Prompt for the language of the code block
  local lang = vim.fn.input("Language for code block: ")
  if lang == "" then
    vim.notify("MarkdownPlus: No language specified for code block.", vim.log.levels.WARN)
    return
  end

  -- Define code block markers
  local code_block_start = string.format("```%s", lang)
  local code_block_end = "```"

  -- Insert code block markers at the start and end of the selection
  vim.api.nvim_buf_set_lines(0, start_row - 1, start_row - 1, false, { code_block_start })
  vim.api.nvim_buf_set_lines(0, end_row + 1, end_row + 1, false, { code_block_end })

  -- Exit visual mode and clear the selection
  vim.cmd("normal! \033")
end

return M
