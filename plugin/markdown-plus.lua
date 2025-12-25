-- Plugin loader for markdown-plus.nvim
if vim.g.loaded_markdown_plus then
  return
end
vim.g.loaded_markdown_plus = 1

-- Read user config from vim.g.markdown_plus (if set before plugin load)
-- This allows users to configure filetypes without calling setup() first
local user_config = type(vim.g.markdown_plus) == "table" and vim.g.markdown_plus or {}
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
