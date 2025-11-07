---Health check for markdown-plus.nvim
---Run with :checkhealth markdown-plus

local M = {}

-- Get vim.health or fallback to older health module
local health = vim.health or require("health")

---Check if a module can be loaded
---@param module_name string Module name to check
---@return boolean success True if module can be loaded
local function can_require(module_name)
  local ok = pcall(require, module_name)
  return ok
end

---Check markdown-plus.nvim health
function M.check()
  health.start("markdown-plus.nvim")

  -- Check Neovim version
  local nvim_version = vim.version()
  if nvim_version.major > 0 or (nvim_version.major == 0 and nvim_version.minor >= 11) then
    health.ok(string.format("Neovim version: %d.%d.%d", nvim_version.major, nvim_version.minor, nvim_version.patch))
  else
    health.error(
      string.format(
        "Neovim version %d.%d.%d is too old (requires 0.11+)",
        nvim_version.major,
        nvim_version.minor,
        nvim_version.patch
      )
    )
  end

  -- Check Lua version
  if jit then
    health.ok("Running on LuaJIT " .. jit.version)
  else
    health.warn("Running on Lua " .. _VERSION .. " (LuaJIT recommended for best performance)")
  end

  -- Check plugin initialization
  local plugin_loaded = vim.g.loaded_markdown_plus == 1
  if plugin_loaded then
    health.ok("Plugin is loaded")
  else
    health.warn("Plugin is not loaded (may load on FileType event)")
  end

  -- Check configuration
  local validator = require("markdown-plus.config.validate")
  local config = vim.g.markdown_plus or {}

  -- Handle function config
  if type(config) == "function" then
    local ok, result = pcall(config)
    if ok and type(result) == "table" then
      config = result
    elseif ok then
      health.error(string.format("vim.g.markdown_plus function returned %s instead of table", type(result)))
      config = {}
    else
      health.error("vim.g.markdown_plus function failed: " .. tostring(result))
      config = {}
    end
  end

  local ok, err = validator.validate(config)
  if ok then
    health.ok("Configuration is valid")
  else
    health.error("Configuration error: " .. err)
  end

  -- Check enabled features
  local markdown_plus = require("markdown-plus")
  if markdown_plus.config then
    local features = markdown_plus.config.features or {}
    local enabled_features = {}

    for feature, enabled in pairs(features) do
      if enabled then
        table.insert(enabled_features, feature)
      end
    end

    if #enabled_features > 0 then
      health.ok("Enabled features: " .. table.concat(enabled_features, ", "))
    else
      health.warn("No features are enabled")
    end
  end

  -- Check for plenary.nvim (optional, for tests)
  if can_require("plenary") then
    health.ok("plenary.nvim is installed (required for running tests)")
  else
    health.info("plenary.nvim not found (only needed for tests, not for plugin operation)")
  end

  -- Check for potential conflicts
  if vim.g.loaded_vim_markdown then
    health.warn("vim-markdown plugin detected - may have keymap conflicts", {
      "Consider disabling conflicting keymaps from vim-markdown",
      "Or disable markdown-plus.nvim default keymaps and create custom ones",
    })
  end

  -- Check filetype detection
  local current_ft = vim.bo.filetype
  if current_ft == "markdown" then
    health.ok("Currently in markdown buffer")
  else
    health.info("Not in markdown buffer (current filetype: " .. (current_ft ~= "" and current_ft or "none") .. ")")
  end

  -- Check configured filetypes
  if markdown_plus.config and markdown_plus.config.filetypes then
    local fts = markdown_plus.config.filetypes
    if type(fts) == "table" and #fts > 0 then
      health.ok("Configured for filetypes: " .. table.concat(fts, ", "))
    else
      health.warn("No filetypes configured")
    end
  end

  -- Check keymap configuration
  if markdown_plus.config and markdown_plus.config.keymaps then
    if markdown_plus.config.keymaps.enabled then
      health.ok("Default keymaps are enabled")
    else
      health.info(
        "Default keymaps are disabled (using custom keymaps)",
        { "Make sure you've set up custom <Plug> mappings" }
      )
    end
  end

  -- Additional recommendations
  health.start("Recommendations")

  -- Check for recommended tools
  if vim.fn.executable("stylua") == 1 then
    health.ok("stylua found (useful for development)")
  else
    health.info("stylua not found (only needed for plugin development)")
  end

  if vim.fn.executable("luacheck") == 1 then
    health.ok("luacheck found (useful for development)")
  else
    health.info("luacheck not found (only needed for plugin development)")
  end
end

return M
