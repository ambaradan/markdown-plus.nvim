local M = {}

---Validate user configuration
---@param opts markdown-plus.Config User configuration
---@return boolean is_valid True if config is valid
---@return string|nil error_message Error message if config is invalid
function M.validate(opts)
  ---Helper to validate with path context
  ---@param path string Path context for error messages
  ---@param tbl table Validation table
  ---@return boolean is_valid
  ---@return string|nil error_message
  local function validate_path(path, tbl)
    local ok, err = pcall(vim.validate, tbl)
    if not ok then
      return false, path .. ": " .. tostring(err)
    end
    return true
  end

  -- Validate top-level config
  local ok, err = validate_path("config", {
    enabled = { opts.enabled, "boolean", true },
    features = { opts.features, "table", true },
    keymaps = { opts.keymaps, "table", true },
    filetypes = { opts.filetypes, "table", true },
  })
  if not ok then
    return false, err
  end

  -- Validate filetypes array
  if opts.filetypes then
    if not vim.islist(opts.filetypes) then
      return false, "config.filetypes: must be an array (list)"
    end
    for i, ft in ipairs(opts.filetypes) do
      if type(ft) ~= "string" then
        return false, string.format("config.filetypes[%d]: must be a string, got %s", i, type(ft))
      end
    end
  end

  -- Validate features
  if opts.features then
    ok, err = validate_path("config.features", {
      list_management = { opts.features.list_management, "boolean", true },
      text_formatting = { opts.features.text_formatting, "boolean", true },
      headers_toc = { opts.features.headers_toc, "boolean", true },
      links = { opts.features.links, "boolean", true },
    })
    if not ok then
      return false, err
    end
  end

  -- Validate keymaps
  if opts.keymaps then
    ok, err = validate_path("config.keymaps", {
      enabled = { opts.keymaps.enabled, "boolean", true },
    })
    if not ok then
      return false, err
    end
  end

  -- Check for unknown top-level fields
  local known_fields = { enabled = true, features = true, keymaps = true, filetypes = true }
  for key in pairs(opts) do
    if not known_fields[key] then
      return false,
        string.format(
          "config: unknown field '%s'. Valid fields are: %s",
          key,
          table.concat(vim.tbl_keys(known_fields), ", ")
        )
    end
  end

  -- Check for unknown feature fields
  if opts.features then
    local known_feature_fields = {
      list_management = true,
      text_formatting = true,
      headers_toc = true,
      links = true,
    }
    for key in pairs(opts.features) do
      if not known_feature_fields[key] then
        return false,
          string.format(
            "config.features: unknown field '%s'. Valid fields are: %s",
            key,
            table.concat(vim.tbl_keys(known_feature_fields), ", ")
          )
      end
    end
  end

  -- Check for unknown keymap fields
  if opts.keymaps then
    local known_keymap_fields = { enabled = true }
    for key in pairs(opts.keymaps) do
      if not known_keymap_fields[key] then
        return false,
          string.format(
            "config.keymaps: unknown field '%s'. Valid fields are: %s",
            key,
            table.concat(vim.tbl_keys(known_keymap_fields), ", ")
          )
      end
    end
  end

  return true
end

return M
