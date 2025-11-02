---@module 'markdown-plus.table.keymaps'
---@brief [[
--- Keymap setup for table features
---
--- Provides <Plug> mappings and default keybindings for all table operations
---@brief ]]

local M = {}

local plug_mappings_registered = false

---Register global <Plug> mappings (should be called once)
local function register_plug_mappings()
  if plug_mappings_registered then
    return
  end
  plug_mappings_registered = true
  -- Define <Plug> mappings
  local plug_mappings = {
    -- Table creation & formatting
    {
      "n",
      "<Plug>(markdown-plus-table-create)",
      function()
        require("markdown-plus.table.creator").create_table_interactive()
      end,
      "Create new table",
    },
    {
      "n",
      "<Plug>(markdown-plus-table-format)",
      function()
        require("markdown-plus.table").format_table()
      end,
      "Format table",
    },
    {
      "n",
      "<Plug>(markdown-plus-table-normalize)",
      function()
        require("markdown-plus.table").normalize_table()
      end,
      "Normalize table",
    },

    -- Row operations
    {
      "n",
      "<Plug>(markdown-plus-table-insert-row-below)",
      function()
        require("markdown-plus.table").insert_row_below()
      end,
      "Insert row below",
    },
    {
      "n",
      "<Plug>(markdown-plus-table-insert-row-above)",
      function()
        require("markdown-plus.table").insert_row_above()
      end,
      "Insert row above",
    },
    {
      "n",
      "<Plug>(markdown-plus-table-delete-row)",
      function()
        require("markdown-plus.table").delete_row()
      end,
      "Delete row",
    },
    {
      "n",
      "<Plug>(markdown-plus-table-duplicate-row)",
      function()
        require("markdown-plus.table.manipulation").duplicate_row()
      end,
      "Duplicate row",
    },

    -- Column operations
    {
      "n",
      "<Plug>(markdown-plus-table-insert-column-right)",
      function()
        require("markdown-plus.table").insert_column_right()
      end,
      "Insert column right",
    },
    {
      "n",
      "<Plug>(markdown-plus-table-insert-column-left)",
      function()
        require("markdown-plus.table").insert_column_left()
      end,
      "Insert column left",
    },
    {
      "n",
      "<Plug>(markdown-plus-table-delete-column)",
      function()
        require("markdown-plus.table").delete_column()
      end,
      "Delete column",
    },
    {
      "n",
      "<Plug>(markdown-plus-table-duplicate-column)",
      function()
        require("markdown-plus.table.manipulation").duplicate_column()
      end,
      "Duplicate column",
    },
  }

  -- Register all <Plug> mappings
  for _, mapping in ipairs(plug_mappings) do
    local mode, lhs, rhs, desc = mapping[1], mapping[2], mapping[3], mapping[4]
    vim.keymap.set(mode, lhs, rhs, {
      silent = true,
      desc = desc,
    })
  end
end

---Setup buffer-local default keymaps
---@param config TableConfig Table configuration
local function setup_buffer_keymaps(config)
  local prefix = config.keymaps.prefix or "<leader>t"

  -- Set up default keybindings if enabled
  if config.keymaps.enabled then
    local default_mappings = {
      -- Table creation & formatting (normal mode)
      { "n", prefix .. "c", "<Plug>(markdown-plus-table-create)" },
      { "n", prefix .. "f", "<Plug>(markdown-plus-table-format)" },
      { "n", prefix .. "n", "<Plug>(markdown-plus-table-normalize)" },

      -- Row operations (normal mode)
      { "n", prefix .. "ir", "<Plug>(markdown-plus-table-insert-row-below)" },
      { "n", prefix .. "iR", "<Plug>(markdown-plus-table-insert-row-above)" },
      { "n", prefix .. "dr", "<Plug>(markdown-plus-table-delete-row)" },
      { "n", prefix .. "yr", "<Plug>(markdown-plus-table-duplicate-row)" },

      -- Column operations (normal mode)
      { "n", prefix .. "ic", "<Plug>(markdown-plus-table-insert-column-right)" },
      { "n", prefix .. "iC", "<Plug>(markdown-plus-table-insert-column-left)" },
      { "n", prefix .. "dc", "<Plug>(markdown-plus-table-delete-column)" },
      { "n", prefix .. "yc", "<Plug>(markdown-plus-table-duplicate-column)" },
    }

    for _, mapping in ipairs(default_mappings) do
      local mode, lhs, rhs = mapping[1], mapping[2], mapping[3]
      if vim.fn.hasmapto(rhs, mode) == 0 then
        vim.keymap.set(mode, lhs, rhs, {
          buffer = true,
          silent = true,
        })
      end
    end
  end

  -- Set up insert mode navigation if enabled (default: true)
  local insert_nav_enabled = config.keymaps.insert_mode_navigation
  if insert_nav_enabled == nil then
    insert_nav_enabled = true -- Default to enabled
  end

  if insert_nav_enabled then
    local navigation = require("markdown-plus.table.navigation")

    -- Helper to create insert mode navigation with fallback
    local function make_nav_mapping(nav_func, fallback_key)
      return function()
        local success = nav_func()
        if not success then
          -- Not in table or at boundary, use default behavior
          local key = vim.api.nvim_replace_termcodes(fallback_key, true, false, true)
          vim.api.nvim_feedkeys(key, "n", false)
        end
      end
    end

    -- Insert mode navigation mappings
    local insert_mappings = {
      { "<A-h>", navigation.move_left, "<Left>" },
      { "<A-l>", navigation.move_right, "<Right>" },
      { "<A-j>", navigation.move_down, "<Down>" },
      { "<A-k>", navigation.move_up, "<Up>" },
    }

    for _, mapping in ipairs(insert_mappings) do
      local lhs, nav_func, fallback = mapping[1], mapping[2], mapping[3]
      vim.keymap.set("i", lhs, make_nav_mapping(nav_func, fallback), {
        buffer = true,
        silent = true,
        desc = "Navigate table cell or fallback to " .. fallback,
      })
    end
  end
end

---Register global <Plug> mappings (call once during module setup)
function M.register_plug_mappings()
  register_plug_mappings()
end

---Setup buffer-local keymaps for current buffer
---@param config TableConfig Table configuration
function M.setup_buffer_keymaps(config)
  setup_buffer_keymaps(config)
end

---Setup table keymaps (registers <Plug> mappings once, then sets up buffer-local defaults)
---For backward compatibility - prefer calling register_plug_mappings() once and setup_buffer_keymaps() per buffer
---@param config TableConfig Table configuration
function M.setup(config)
  register_plug_mappings()
  setup_buffer_keymaps(config)
end

return M
