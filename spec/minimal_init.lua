-- Minimal init for testing
-- This file sets up the minimal Neovim environment needed for tests

-- Add plugin to runtime path
vim.opt.rtp:prepend(".")

-- Add plenary.nvim if available (for plenary.busted)
local plenary_dir = os.getenv("PLENARY_DIR") or vim.fn.expand("~/.local/share/nvim/lazy/plenary.nvim")
if vim.fn.isdirectory(plenary_dir) == 1 then
  vim.opt.rtp:append(plenary_dir)
end

-- Set up basic vim options for testing
vim.opt.swapfile = false
vim.opt.hidden = true

-- Ensure markdown filetype is recognized
vim.cmd([[
  augroup test_markdown
    autocmd!
    autocmd BufRead,BufNewFile *.md setfiletype markdown
  augroup END
]])

-- Load the plugin
require("markdown-plus")

print("Test environment initialized")
