-- Quote management module for markdown-plus.nvim
local utils = require("markdown-plus.utils")
local M = {}

---@type markdown-plus.InternalConfig
M.config = {}

--- Setup quote module
---@param config markdown-plus.InternalConfig Plugin configuration
---@return nil
function M.setup(config)
  M.config = config or {}
end

--- Enable quote features for current buffer
---@return nil
function M.enable()
  if not utils.is_markdown_buffer() then
    return
  end
  M.setup_keymaps()
end

--- Set up keymaps for quote management
---@return nil
function M.setup_keymaps()
  if not M.config.keymaps or not M.config.keymaps.enabled then
    return
  end

  -- Visual mode <Plug> mappings
  vim.keymap.set("x", "<Plug>(MarkdownPlusToggleQuote)", function()
    M.toggle_quote()
  end, { silent = true, desc = "Toggle blockquote" })

  -- Normal mode <Plug> mappings
  vim.keymap.set("n", "<Plug>(MarkdownPlusToggleQuote)", function()
    M.toggle_quote_line()
  end, { silent = true, desc = "Toggle blockquote on line" })

  if vim.fn.hasmapto("<Plug>(MarkdownPlusToggleQuote)", "n") == 0 then
    vim.keymap.set(
      "n",
      "<leader>mq",
      "<Plug>(MarkdownPlusToggleQuote)",
      { buffer = true, desc = "Toggle blockquote on line" }
    )
  end
  if vim.fn.hasmapto("<Plug>(MarkdownPlusToggleQuote)", "x") == 0 then
    vim.keymap.set(
      "x",
      "<leader>mq",
      ":lua vim.cmd('normal! gv')<CR>:lua require('markdown-plus.quote').toggle_quote()<CR>",
      { buffer = true, desc = "Toggle blockquote", silent = true }
    )
  end
end

-- Get visual selection range
function M.get_visual_selection()
  -- Get visual mode start position
  local start_pos = vim.fn.getpos("v")
  -- Get current cursor position (end of selection)
  local end_pos = vim.fn.getpos(".")
  local start_row = math.min(start_pos[2], end_pos[2])
  local end_row = math.max(start_pos[2], end_pos[2])
  return {
    start_row = start_row,
    end_row = end_row,
  }
end

function M.toggle_quote()
  local start_row = vim.fn.line("'<")
  local end_row = vim.fn.line("'>")

  if start_row == 0 or end_row == 0 then
    return
  end

  for row = start_row, end_row do
    M.toggle_quote_on_line(row)
  end
end

-- Toggle blockquote on current line
function M.toggle_quote_line()
  local cursor = utils.get_cursor()
  local row = cursor[1]
  M.toggle_quote_on_line(row)
end

-- Toggle blockquote on a specific line
---@param line_num number 1-indexed line number
---@return nil
function M.toggle_quote_on_line(line_num)
  local line = utils.get_line(line_num)
  if line == "" then
    return -- Do nothing for empty lines
  end
  -- Check if the line starts with '>'
  if line:match("^%s*>") then
    -- Remove blockquote and any following space
    line = line:gsub("^%s*>%s?", "", 1)
  else
    -- Add blockquote
    line = "> " .. line
  end
  utils.set_line(line_num, line)
end

return M
