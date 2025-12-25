-- Plugin loader for markdown-plus.nvim
if vim.g.loaded_markdown_plus then
  return
end
vim.g.loaded_markdown_plus = 1

-- Read user config from vim.g.markdown_plus (if set before plugin load)
-- This allows users to configure filetypes without calling setup() first
-- Supports both table and function forms (function is called to get config)
local function get_user_config()
  local vim_g = vim.g.markdown_plus
  if vim_g == nil then
    return {}
  elseif type(vim_g) == "table" then
    return vim_g
  elseif type(vim_g) == "function" then
    local ok, result = pcall(vim_g)
    if ok and type(result) == "table" then
      return result
    end
  end
  return {}
end

local user_config = get_user_config()
local filetypes = user_config.filetypes or { "markdown" }

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
      require("markdown-plus").setup(user_config)
    end
  end,
})
