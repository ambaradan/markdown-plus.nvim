---@diagnostic disable: undefined-field
local utils = require("markdown-plus.utils")

describe("markdown-plus utils", function()
  describe("is_markdown_buffer", function()
    it("returns true for markdown buffers", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
      vim.api.nvim_set_current_buf(buf)
      
      assert.is_true(utils.is_markdown_buffer())
      
      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("returns false for non-markdown buffers", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_option(buf, "filetype", "lua")
      vim.api.nvim_set_current_buf(buf)
      
      assert.is_false(utils.is_markdown_buffer())
      
      vim.api.nvim_buf_delete(buf, { force = true })
    end)
  end)

  describe("get_visual_selection", function()
    it("returns nil when not in visual mode", function()
      local result = utils.get_visual_selection()
      assert.is_nil(result)
    end)

    -- Note: Testing visual mode selection requires more complex setup
    -- and would be better suited for integration tests
  end)

  describe("trim", function()
    it("removes leading and trailing whitespace", function()
      assert.are.equal("hello", utils.trim("  hello  "))
      assert.are.equal("world", utils.trim("\t\nworld\n\t"))
      assert.are.equal("test", utils.trim("test"))
    end)

    it("handles empty strings", function()
      assert.are.equal("", utils.trim(""))
      assert.are.equal("", utils.trim("   "))
    end)

    it("preserves internal whitespace", function()
      assert.are.equal("hello world", utils.trim("  hello world  "))
    end)
  end)

  describe("starts_with", function()
    it("returns true when string starts with prefix", function()
      assert.is_true(utils.starts_with("hello world", "hello"))
      assert.is_true(utils.starts_with("test", "test"))
    end)

    it("returns false when string does not start with prefix", function()
      assert.is_false(utils.starts_with("hello world", "world"))
      assert.is_false(utils.starts_with("test", "testing"))
    end)

    it("handles empty strings", function()
      assert.is_true(utils.starts_with("hello", ""))
      assert.is_false(utils.starts_with("", "hello"))
    end)
  end)

  describe("set_cursor", function()
    it("sets cursor to specified position", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "line 1",
        "line 2",
        "line 3",
      })
      vim.api.nvim_set_current_buf(buf)
      
      utils.set_cursor(2, 3)
      
      local pos = vim.api.nvim_win_get_cursor(0)
      assert.are.equal(2, pos[1]) -- row (1-indexed)
      assert.are.equal(3, pos[2]) -- col (0-indexed)
      
      vim.api.nvim_buf_delete(buf, { force = true })
    end)
  end)

  describe("get_current_line", function()
    it("returns current line content", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "first line",
        "second line",
        "third line",
      })
      vim.api.nvim_set_current_buf(buf)
      
      utils.set_cursor(2, 0)
      local line = utils.get_current_line()
      
      assert.are.equal("second line", line)
      
      vim.api.nvim_buf_delete(buf, { force = true })
    end)
  end)

  describe("replace_current_line", function()
    it("replaces current line with new text", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "original line",
      })
      vim.api.nvim_set_current_buf(buf)
      
      utils.replace_current_line("new line")
      
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      assert.are.equal("new line", lines[1])
      
      vim.api.nvim_buf_delete(buf, { force = true })
    end)
  end)
end)
