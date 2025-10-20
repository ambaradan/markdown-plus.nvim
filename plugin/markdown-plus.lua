-- Plugin loader for markdown-plus.nvim
if vim.g.loaded_markdown_plus then
  return
end
vim.g.loaded_markdown_plus = 1

-- Create command to setup the plugin
vim.api.nvim_create_user_command("MarkdownPlusSetup", function(opts)
  local config = {}
  if opts.args and opts.args ~= "" then
    config = vim.fn.json_decode(opts.args)
  end
  require("markdown-plus").setup(config)
end, {
  nargs = "?",
  desc = "Setup markdown-plus.nvim plugin",
})

-- Auto-setup with default config if no manual setup is called
vim.defer_fn(function()
  if not vim.g.markdown_plus_setup_called then
    require("markdown-plus").setup()
  end
end, 100)
