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

  describe("line operations", function()
    it("get_line retrieves specific line", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "first line",
        "second line",
        "third line",
      })
      vim.api.nvim_set_current_buf(buf)

      local line = utils.get_line(2)

      assert.are.equal("second line", line)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)

    it("set_line modifies specific line", function()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "first line",
        "second line",
        "third line",
      })
      vim.api.nvim_set_current_buf(buf)

      utils.set_line(2, "modified line")
      local line = utils.get_line(2)

      assert.are.equal("modified line", line)

      vim.api.nvim_buf_delete(buf, { force = true })
    end)
  end)
end)
