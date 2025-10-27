-- Tests for markdown-plus text formatting module
describe("markdown-plus format", function()
  local format = require("markdown-plus.format")

  before_each(function()
    -- Create a test buffer
    vim.cmd("enew")
    vim.bo.filetype = "markdown"
    format.setup({ enabled = true })
  end)

  after_each(function()
    -- Clean up test buffer
    vim.cmd("bdelete!")
  end)

  describe("has_formatting", function()
    it("detects bold formatting", function()
      assert.is_true(format.has_formatting("**text**", "bold"))
      assert.is_false(format.has_formatting("text", "bold"))
      assert.is_false(format.has_formatting("**text", "bold"))
      assert.is_false(format.has_formatting("text**", "bold"))
    end)

    it("detects italic formatting", function()
      assert.is_true(format.has_formatting("*text*", "italic"))
      assert.is_false(format.has_formatting("text", "italic"))
      assert.is_false(format.has_formatting("*text", "italic"))
    end)

    it("detects strikethrough formatting", function()
      assert.is_true(format.has_formatting("~~text~~", "strikethrough"))
      assert.is_false(format.has_formatting("text", "strikethrough"))
      assert.is_false(format.has_formatting("~~text", "strikethrough"))
    end)

    it("detects inline code formatting", function()
      assert.is_true(format.has_formatting("`text`", "code"))
      assert.is_false(format.has_formatting("text", "code"))
      assert.is_false(format.has_formatting("`text", "code"))
    end)
  end)

  describe("add_formatting", function()
    it("adds bold formatting", function()
      local result = format.add_formatting("text", "bold")
      assert.equals("**text**", result)
    end)

    it("adds italic formatting", function()
      local result = format.add_formatting("text", "italic")
      assert.equals("*text*", result)
    end)

    it("adds strikethrough formatting", function()
      local result = format.add_formatting("text", "strikethrough")
      assert.equals("~~text~~", result)
    end)

    it("adds inline code formatting", function()
      local result = format.add_formatting("text", "code")
      assert.equals("`text`", result)
    end)
  end)

  describe("remove_formatting", function()
    it("removes bold formatting", function()
      local result = format.remove_formatting("**text**", "bold")
      assert.equals("text", result)
    end)

    it("removes italic formatting", function()
      local result = format.remove_formatting("*text*", "italic")
      assert.equals("text", result)
    end)

    it("removes strikethrough formatting", function()
      local result = format.remove_formatting("~~text~~", "strikethrough")
      assert.equals("text", result)
    end)

    it("removes inline code formatting", function()
      local result = format.remove_formatting("`text`", "code")
      assert.equals("text", result)
    end)

    it("returns unchanged text if no formatting present", function()
      local result = format.remove_formatting("text", "bold")
      assert.equals("text", result)
    end)
  end)

  describe("get_text_in_range", function()
    it("gets text from single line", function()
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "hello world" })
      local result = format.get_text_in_range(1, 1, 1, 5)
      assert.equals("hello", result)
    end)

    it("gets text from middle of line", function()
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "hello world" })
      local result = format.get_text_in_range(1, 7, 1, 11)
      assert.equals("world", result)
    end)

    it("gets text from multiple lines", function()
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "line one", "line two", "line three" })
      local result = format.get_text_in_range(1, 6, 2, 4)
      assert.equals("one\nline", result)
    end)
  end)

  describe("set_text_in_range", function()
    it("sets text in single line", function()
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "hello world" })
      format.set_text_in_range(1, 1, 1, 5, "goodbye")
      local line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
      assert.equals("goodbye world", line)
    end)

    it("sets text in middle of line", function()
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "hello world" })
      format.set_text_in_range(1, 7, 1, 11, "universe")
      local line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
      assert.equals("hello universe", line)
    end)

    it("validates range order and shows error for invalid range", function()
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "hello world" })
      -- This should not crash, just show an error
      format.set_text_in_range(1, 10, 1, 5, "test")
      -- Line should remain unchanged
      local line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1]
      assert.equals("hello world", line)
    end)
  end)

  describe("get_visual_selection", function()
    it("handles forward selection using '< and '> marks (after visual mode)", function()
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "hello world" })
      -- Simulate visual selection from position 1,1 to 1,5 (after exiting visual mode)
      vim.fn.setpos("'<", { 0, 1, 1, 0 })
      vim.fn.setpos("'>", { 0, 1, 5, 0 })
      local selection = format.get_visual_selection()
      assert.equals(1, selection.start_row)
      assert.equals(1, selection.start_col)
      assert.equals(1, selection.end_row)
      assert.equals(5, selection.end_col)
    end)

    it("handles backward selection using '< and '> marks (after visual mode)", function()
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "hello world" })
      -- Simulate backward visual selection from position 1,5 to 1,1 (after exiting visual mode)
      vim.fn.setpos("'<", { 0, 1, 5, 0 })
      vim.fn.setpos("'>", { 0, 1, 1, 0 })
      local selection = format.get_visual_selection()
      -- Should be normalized with start before end
      assert.equals(1, selection.start_row)
      assert.equals(1, selection.start_col)
      assert.equals(1, selection.end_row)
      assert.equals(5, selection.end_col)
    end)

    it("handles multi-line backward selection using '< and '> marks (after visual mode)", function()
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "line one", "line two" })
      -- Simulate backward selection from line 2 to line 1 (after exiting visual mode)
      vim.fn.setpos("'<", { 0, 2, 5, 0 })
      vim.fn.setpos("'>", { 0, 1, 3, 0 })
      local selection = format.get_visual_selection()
      -- Should be normalized
      assert.equals(1, selection.start_row)
      assert.equals(3, selection.start_col)
      assert.equals(2, selection.end_row)
      assert.equals(5, selection.end_col)
    end)

    it("handles selection while in visual mode using 'v' mark", function()
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "hello world" })
      -- Simulate being in visual mode
      vim.cmd("normal! gg0vllll")
      local selection = format.get_visual_selection()
      -- Should detect visual mode and use vim.fn.getpos('v') and vim.fn.getpos('.')
      assert.is_not_nil(selection.start_row)
      assert.is_not_nil(selection.start_col)
      assert.is_not_nil(selection.end_row)
      assert.is_not_nil(selection.end_col)
    end)

    it("handles visual line mode (V) by selecting entire lines", function()
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "hello world" })
      -- Simulate being in visual line mode (V)
      vim.cmd("normal! ggV")
      local selection = format.get_visual_selection()
      -- In line mode, should select from column 1 to end of line
      assert.equals(1, selection.start_row)
      assert.equals(1, selection.start_col)
      assert.equals(1, selection.end_row)
      assert.equals(11, selection.end_col) -- "hello world" has 11 characters
    end)

    it("handles visual line mode (V) with multiple lines", function()
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "first line", "second line", "third line" })
      -- Simulate visual line mode selecting lines 1-2
      vim.cmd("normal! ggVj")
      local selection = format.get_visual_selection()
      -- Should select entire lines
      assert.equals(1, selection.start_row)
      assert.equals(1, selection.start_col)
      assert.equals(2, selection.end_row)
      assert.equals(11, selection.end_col) -- "second line" has 11 characters
    end)
  end)

  describe("patterns", function()
    it("has bold pattern", function()
      assert.is_not_nil(format.patterns.bold)
      assert.equals("**", format.patterns.bold.wrap)
    end)

    it("has italic pattern", function()
      assert.is_not_nil(format.patterns.italic)
      assert.equals("*", format.patterns.italic.wrap)
    end)

    it("has strikethrough pattern", function()
      assert.is_not_nil(format.patterns.strikethrough)
      assert.equals("~~", format.patterns.strikethrough.wrap)
    end)

    it("has code pattern", function()
      assert.is_not_nil(format.patterns.code)
      assert.equals("`", format.patterns.code.wrap)
    end)
  end)
end)
