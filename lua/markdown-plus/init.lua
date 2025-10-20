-- Main entry point for markdown-plus.nvim
local M = {}

-- Default configuration
M.config = {
  enabled = true,
  features = {
    list_management = true,
    text_formatting = true,
    links = true,
    headers_toc = true,
  },
  keymaps = {
    enabled = true,
  },
  filetypes = { 'markdown' },
}

-- Module references
M.list = nil
M.format = nil
M.links = nil
M.headers = nil

-- Setup function
function M.setup(opts)
  -- Merge user config with defaults
  M.config = vim.tbl_deep_extend("force", M.config, opts or {})

  -- Only load if enabled
  if not M.config.enabled then
    return
  end

  -- Load modules based on enabled features
  if M.config.features.list_management then
    M.list = require("markdown-plus.list")
    M.list.setup(M.config)
  end

  if M.config.features.text_formatting then
    M.format = require("markdown-plus.format")
    M.format.setup(M.config)
  end

  if M.config.features.headers_toc then
    M.headers = require("markdown-plus.headers")
    M.headers.setup(M.config)
  end

  if M.config.features.links then
    M.links = require("markdown-plus.links")
    M.links.setup(M.config)
  end

  -- Set up autocommands for markdown files
  M.setup_autocmds()
end

-- Set up autocommands
function M.setup_autocmds()
  local group = vim.api.nvim_create_augroup("MarkdownPlus", { clear = true })

  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = M.config.filetypes or "markdown",
    callback = function()
      -- Enable features for markdown files
      if M.list then
        M.list.enable()
      end
      if M.format then
        M.format.enable()
      end
      if M.headers then
        M.headers.enable()
      end
      if M.links then
        M.links.enable()
      end
    end,
  })
end

return M
