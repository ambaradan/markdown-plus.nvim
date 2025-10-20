---Test suite for markdown-plus.nvim list management
---Tests list parsing, empty list detection, and list continuation
---@diagnostic disable: undefined-field
local list = require("markdown-plus.list")

describe("markdown-plus list management", function()
  local buf

  before_each(function()
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
    vim.api.nvim_set_current_buf(buf)
  end)

  after_each(function()
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_delete(buf, { force = true })
    end
  end)

  describe("parse_list_line", function()
    it("parses unordered list items", function()
      local info = list.parse_list_line("- List item")
      assert.is_not_nil(info)
      assert.are.equal("unordered", info.type)
      assert.are.equal("-", info.marker)
    end)

    it("parses ordered list items", function()
      local info = list.parse_list_line("1. List item")
      assert.is_not_nil(info)
      assert.are.equal("ordered", info.type)
    end)

    it("parses task list items", function()
      local info = list.parse_list_line("- [ ] Unchecked task")
      assert.is_not_nil(info)
      assert.is_not_nil(info.checkbox)
    end)

    it("returns nil for non-list lines", function()
      local info = list.parse_list_line("Not a list")
      assert.is_nil(info)
    end)
  end)

  describe("is_empty_list_item", function()
    it("detects empty list items", function()
      local info = list.parse_list_line("- ")
      local is_empty = list.is_empty_list_item("- ", info)
      assert.is_true(is_empty)
    end)

    it("detects non-empty list items", function()
      local info = list.parse_list_line("- Content")
      local is_empty = list.is_empty_list_item("- Content", info)
      assert.is_false(is_empty)
    end)
  end)
end)
