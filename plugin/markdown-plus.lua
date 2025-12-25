-- Plugin loader for markdown-plus.nvim
if vim.g.loaded_markdown_plus then
  return
end
vim.g.loaded_markdown_plus = 1

---Get user configuration from vim.g.markdown_plus (if set before plugin load)
---Supports both table and function forms (function is called to get config)
---@return table
local function get_user_config()
  local vim_g = vim.g.markdown_plus
  if vim_g == nil then
    return {}
  end

  if type(vim_g) == "table" then
    return vim_g
  end

  if type(vim_g) == "function" then
    local ok, result = pcall(vim_g)
    if not ok then
      vim.notify_once(
        "[markdown-plus.nvim] vim.g.markdown_plus function failed: " .. tostring(result),
        vim.log.levels.WARN
      )
      return {}
    end
    if type(result) == "table" then
      return result
    end
    vim.notify_once(
      "[markdown-plus.nvim] vim.g.markdown_plus function must return a table, got " .. type(result),
      vim.log.levels.WARN
    )
    return {}
  end

  vim.notify_once(
    "[markdown-plus.nvim] vim.g.markdown_plus must be a table or function, got " .. type(vim_g),
    vim.log.levels.WARN
  )
  return {}
end

---Get validated filetypes for the FileType autocmd
---@param config table
---@return string|string[]
local function get_filetypes(config)
  local ft = config.filetypes
  if ft == nil then
    return { "markdown" }
  end
  if type(ft) == "string" or type(ft) == "table" then
    return ft
  end
  vim.notify_once(
    "[markdown-plus.nvim] filetypes must be a string or table, got " .. type(ft) .. ". Using default.",
    vim.log.levels.WARN
  )
  return { "markdown" }
end

local filetypes = get_filetypes(get_user_config())

-- Auto-setup with FileType autocmd (deprecated, will be removed in v2.0)
-- This ensures truly lazy loading - plugin only initializes when a relevant file is opened
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("MarkdownPlusAutoSetup", { clear = true }),
  pattern = filetypes,
  once = true,
  callback = function()
    -- Only auto-setup if user hasn't explicitly called setup()
    if not vim.g.markdown_plus_setup_called then
      vim.notify_once(
        "[markdown-plus.nvim] Auto-setup is deprecated and will be removed in v2.0.\n"
          .. "Please add `opts = {}` or `config = true` to your plugin spec.\n"
          .. "See: https://github.com/YousefHadder/markdown-plus.nvim#quick-start",
        vim.log.levels.WARN
      )
      vim.g.markdown_plus_setup_called = true
      -- Get config at runtime to pick up any changes made after plugin load
      require("markdown-plus").setup(get_user_config())
    end
  end,
})
