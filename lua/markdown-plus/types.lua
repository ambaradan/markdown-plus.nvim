---@meta

---User configuration for markdown-plus.nvim
---Can be provided via setup() or vim.g.markdown_plus (table or function)
---@class markdown-plus.Config
---@field enabled? boolean Enable the plugin (default: true)
---@field features? markdown-plus.FeatureConfig Feature toggles
---@field keymaps? markdown-plus.KeymapConfig Keymap configuration
---@field filetypes? string[] Filetypes to enable plugin for (default: {"markdown"})

---Feature configuration
---@class markdown-plus.FeatureConfig
---@field list_management? boolean Enable list management (default: true)
---@field text_formatting? boolean Enable text formatting (default: true)
---@field headers_toc? boolean Enable headers and TOC (default: true)
---@field links? boolean Enable link management (default: true)
---@field quotes? boolean Enable quote management (default: true)

---Keymap configuration
---@class markdown-plus.KeymapConfig
---@field enabled? boolean Enable default keymaps (default: true)

---Internal configuration (with all optional fields resolved)
---@class markdown-plus.InternalConfig
---@field enabled boolean
---@field features markdown-plus.InternalFeatureConfig
---@field keymaps markdown-plus.InternalKeymapConfig

---Internal feature configuration
---@class markdown-plus.InternalFeatureConfig
---@field list_management boolean
---@field text_formatting boolean
---@field headers_toc boolean
---@field links boolean
---@field quotes boolean

---Internal keymap configuration
---@class markdown-plus.InternalKeymapConfig
---@field enabled boolean

return {}
