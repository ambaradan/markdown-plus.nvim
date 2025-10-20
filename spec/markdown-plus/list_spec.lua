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

  describe("toggle_task", function()
    it("toggles unchecked task to checked", function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "- [ ] Unchecked task",
      })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })

      list.toggle_task()

      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      assert.are.equal("- [x] Unchecked task", lines[1])
    end)

    it("toggles checked task to unchecked", function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "- [x] Checked task",
      })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })

      list.toggle_task()

      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      assert.are.equal("- [ ] Checked task", lines[1])
    end)

    it("handles tasks with uppercase X", function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "- [X] Checked task",
      })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })

      list.toggle_task()

      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      assert.are.equal("- [ ] Checked task", lines[1])
    end)

    it("handles different bullet styles", function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "* [ ] Star bullet",
      })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })

      list.toggle_task()

      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      assert.are.equal("* [x] Star bullet", lines[1])
    end)
  end)

  describe("cycle_list_marker", function()
    it("cycles through bullet styles: - -> * -> + -> -", function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "- List item",
      })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })

      list.cycle_list_marker()
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      assert.are.equal("* List item", lines[1])

      list.cycle_list_marker()
      lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      assert.are.equal("+ List item", lines[1])

      list.cycle_list_marker()
      lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      assert.are.equal("- List item", lines[1])
    end)

    it("preserves list content and indentation", function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "  - Indented list item with content",
      })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })

      list.cycle_list_marker()

      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      assert.are.equal("  * Indented list item with content", lines[1])
    end)

    it("preserves task checkbox state", function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "- [x] Completed task",
      })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })

      list.cycle_list_marker()

      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      assert.are.equal("* [x] Completed task", lines[1])
    end)
  end)

  describe("increment_numbered_list", function()
    it("increments numbered list items", function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "1. First item",
        "1. Second item",
        "1. Third item",
      })

      list.increment_numbered_list()

      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      assert.are.equal("1. First item", lines[1])
      assert.are.equal("2. Second item", lines[2])
      assert.are.equal("3. Third item", lines[3])
    end)

    it("handles nested lists", function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "1. First item",
        "   1. Nested item",
        "   1. Nested item",
        "1. Second item",
      })

      list.increment_numbered_list()

      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      assert.are.equal("1. First item", lines[1])
      -- Nested items should be renumbered independently
    end)
  end)

  describe("indent/dedent", function()
    it("indents list items", function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "- List item",
      })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })

      list.indent_list_item()

      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      -- Should add indentation (implementation-specific)
      assert.is_true(lines[1]:match("^%s+%-"))
    end)

    it("dedents list items", function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "  - Indented item",
      })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })

      list.dedent_list_item()

      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      -- Should remove indentation
      assert.are.equal("- Indented item", lines[1])
    end)
  end)
end)
