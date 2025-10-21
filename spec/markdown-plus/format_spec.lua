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
