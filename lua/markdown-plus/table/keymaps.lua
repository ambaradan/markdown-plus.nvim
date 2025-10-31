---@module 'markdown-plus.table.keymaps'
---@brief [[
--- Keymap setup for table features
---
--- Provides <Plug> mappings and default keybindings for all table operations
---@brief ]]

local M = {}

---Setup table keymaps
---@param config TableConfig Table configuration
function M.setup(config)
  local prefix = config.keymaps.prefix or "<leader>t"

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

    -- Navigation (insert mode) - only work in tables
    {
      "i",
      "<Plug>(markdown-plus-table-next-cell)",
      function()
        local nav = require("markdown-plus.table.navigation")
        if nav.is_in_table() then
          require("markdown-plus.table").next_cell()
        else
          -- Fallback to default behavior
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-l>", true, false, true), "n", false)
        end
      end,
      "Next cell",
    },
    {
      "i",
      "<Plug>(markdown-plus-table-prev-cell)",
      function()
        local nav = require("markdown-plus.table.navigation")
        if nav.is_in_table() then
          require("markdown-plus.table").prev_cell()
        else
          -- Fallback to default behavior
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-z>", true, false, true), "n", false)
        end
      end,
      "Previous cell",
    },
    {
      "i",
      "<Plug>(markdown-plus-table-next-row)",
      function()
        local nav = require("markdown-plus.table.navigation")
        if nav.is_in_table() then
          require("markdown-plus.table").next_row()
        else
          -- Fallback to default behavior
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<M-j>", true, false, true), "n", false)
        end
      end,
      "Next row",
    },
    {
      "i",
      "<Plug>(markdown-plus-table-prev-row)",
      function()
        local nav = require("markdown-plus.table.navigation")
        if nav.is_in_table() then
          require("markdown-plus.table").prev_row()
        else
          -- Fallback to default behavior
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<M-k>", true, false, true), "n", false)
        end
      end,
      "Previous row",
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

  -- Set up default keybindings if enabled
  if config.keymaps.enabled then
    local default_mappings = {
      -- Table creation & formatting (normal mode)
      { "n", prefix .. "c", "<Plug>(markdown-plus-table-create)" },
      { "n", prefix .. "f", "<Plug>(markdown-plus-table-format)" },
      { "n", prefix .. "n", "<Plug>(markdown-plus-table-normalize)" },

      -- Navigation (insert mode)
      { "i", "<C-l>", "<Plug>(markdown-plus-table-next-cell)" },
      { "i", "<C-h>", "<Plug>(markdown-plus-table-prev-cell)" },
      { "i", "<M-j>", "<Plug>(markdown-plus-table-next-row)" },
      { "i", "<M-k>", "<Plug>(markdown-plus-table-prev-row)" },

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
end

return M
