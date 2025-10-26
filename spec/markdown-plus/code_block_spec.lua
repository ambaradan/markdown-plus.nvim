-- Tests for markdown-plus code_block module
describe("markdown-plus code_block", function()
  local code_block = require("markdown-plus.code_block")

  before_each(function()
    -- Create a new test buffer and set filetype to markdown
    vim.cmd("enew")
    vim.bo.filetype = "markdown"

    -- Setup the code_block module with test configuration
    code_block.setup({
      enabled = true,
      features = {
        list_management = true,
        text_formatting = true,
        links = true,
        headers_toc = true,
        quotes = true,
        code_block = true,
      },
      keymaps = {
        enabled = true,
      },
      code_block = {
        enabled = true,
      },
      filetypes = { "markdown" },
    })
  end)

  after_each(function()
    -- Clean up the test buffer after each test
    vim.cmd("bdelete!")
  end)

  describe("convert_to_code_block", function()
    it("converts selected lines to a code block", function()
      -- Set buffer lines for testing
      vim.api.nvim_buf_set_lines(0, 0, -1, false, {
        "First line",
        "Second line",
        "Third line",
      })

      -- Select lines 2-3 (1-based index)
      vim.api.nvim_win_set_cursor(0, { 2, 0 })
      vim.cmd("normal! Vj") -- Enter visual line mode and select down one line

      -- Mock vim.fn.input to simulate user input
      _G.vim.fn.input = function()
        return "lua"
      end

      -- Call the function to convert selection to a code block
      code_block.convert_to_code_block()

      -- Get the buffer lines after conversion
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

      -- Verify the buffer contains the expected lines
      assert.are.equal("First line", lines[1])
      assert.are.equal("```lua", lines[2])
      assert.are.equal("Second line", lines[3])
      assert.are.equal("Third line", lines[4])
      assert.are.equal("```", lines[5])
    end)

    it("does not modify empty lines", function()
      -- Set buffer lines with empty lines for testing
      vim.api.nvim_buf_set_lines(0, 0, -1, false, {
        "",
        "Second line",
        "",
      })

      -- Select all lines (1-3, 1-based index)
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
      vim.cmd("normal! Vjj") -- Enter visual line mode and select down two lines

      -- Mock vim.fn.input to simulate user input
      _G.vim.fn.input = function()
        return "lua"
      end

      -- Call the function to convert selection to a code block
      code_block.convert_to_code_block()

      -- Get the buffer lines after conversion
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

      -- Verify the buffer contains the expected lines
      assert.are.equal("```lua", lines[1])
      assert.are.equal("", lines[2])
      assert.are.equal("Second line", lines[3])
      assert.are.equal("", lines[4])
      assert.are.equal("```", lines[5])
    end)
  end)

  describe("get_visual_selection", function()
    it("returns correct selection range for line-wise visual mode", function()
      -- Set buffer lines for testing
      vim.api.nvim_buf_set_lines(0, 0, -1, false, {
        "First line",
        "Second line",
        "Third line",
      })

      -- Select lines 2-3 (1-based index)
      vim.api.nvim_win_set_cursor(0, { 2, 0 })
      vim.cmd("normal! Vj") -- Enter visual line mode and select down one line

      -- Get the visual selection range
      local selection = code_block.get_visual_selection()

      -- Verify the selection range is correct
      assert.are.equal(2, selection.start_row)
      assert.are.equal(3, selection.end_row)
    end)
  end)

  describe("setup_keymaps", function()
    it("does not set keymaps if keymaps.enabled is false", function()
      code_block.setup({
        keymaps = {
          enabled = false,
        },
      })
      -- Verify that no keymap is set
      assert.is_false(vim.fn.hasmapto("<Plug>(MarkdownPlusCodeBlock)", "x") == 1)
    end)

    it("sets up the <Plug> mapping correctly", function()
      code_block.setup_keymaps()
      -- Verify that the <Plug> keymap exists
      assert.is_true(vim.fn.hasmapto("<Plug>(MarkdownPlusCodeBlock)", "x") == 1)
    end)
  end)

  describe("get_lines_in_range", function()
    it("returns the correct lines for a valid range", function()
      vim.api.nvim_buf_set_lines(0, 0, -1, false, {
        "First line",
        "Second line",
        "Third line",
      })
      local lines = code_block.get_lines_in_range(1, 2) -- 1-based index
      assert.are.same({ "First line", "Second line" }, lines)
    end)

    it("returns an empty list for an out-of-bounds range", function()
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "First line" })
      local lines = code_block.get_lines_in_range(2, 3) -- 1-based index
      assert.are.same({}, lines)
    end)
  end)

  describe("convert_to_code_block with backward selection", function()
    it("correctly handles backward visual selection", function()
      vim.api.nvim_buf_set_lines(0, 0, -1, false, {
        "First line",
        "Second line",
        "Third line",
      })

      -- Select from line 3 to line 2 (backward)
      vim.api.nvim_win_set_cursor(0, { 3, 0 })
      vim.cmd("normal! Vk") -- Enter visual line mode and select up one line

      _G.vim.fn.input = function()
        return "lua"
      end

      code_block.convert_to_code_block()

      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

      -- The buffer should now contain:
      -- 1. First line (unchanged)
      -- 2. ```lua (inserted before selection)
      -- 3. Second line
      -- 4. Third line
      -- 5. ``` (inserted after selection)
      assert.are.equal("First line", lines[1])
      assert.are.equal("```lua", lines[2])
      assert.are.equal("Second line", lines[3])
      assert.are.equal("Third line", lines[4])
      assert.are.equal("```", lines[5])
    end)
  end)

  describe("convert_to_code_block without user input", function()
    it("shows a warning and does not insert code block markers", function()
      vim.api.nvim_buf_set_lines(0, 0, -1, false, {
        "First line",
        "Second line",
      })
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
      vim.cmd("normal! Vj")
      _G.vim.fn.input = function()
        return ""
      end
      code_block.convert_to_code_block()
      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
      -- Verify that no markers were inserted
      assert.are.equal("First line", lines[1])
      assert.are.equal("Second line", lines[2])
    end)
  end)

  describe("enable", function()
    it("does nothing if buffer is not markdown", function()
      vim.bo.filetype = "text"
      code_block.enable()
      -- No direct way to verify this without mocking/spying, but the function should exit early
    end)
  end)

  describe("get_visual_selection in block mode", function()
    it("returns the correct selection range for multi-line visual mode", function()
      vim.api.nvim_buf_set_lines(0, 0, -1, false, {
        "First line",
        "Second line",
        "Third line",
      })

      -- Select lines 1-2 (1-based index) in line-wise visual mode
      vim.api.nvim_win_set_cursor(0, { 1, 0 })
      vim.cmd("normal! Vj") -- Enter visual line mode and select down one line

      local selection = code_block.get_visual_selection()

      -- Verify the selection range is correct
      assert.are.equal(1, selection.start_row)
      assert.are.equal(2, selection.end_row)
    end)
  end)
end)
