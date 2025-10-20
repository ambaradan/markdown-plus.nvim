---Test suite for markdown-plus.nvim headers and TOC functionality
---Tests header parsing, slug generation, TOC detection, and TOC generation
---@diagnostic disable: undefined-field
local headers = require("markdown-plus.headers")

describe("markdown-plus headers", function()
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

  describe("parse_header", function()
    it("parses markdown headers", function()
      local header = headers.parse_header("## Test Header")
      assert.is_not_nil(header)
      assert.are.equal(2, header.level)
      assert.are.equal("Test Header", header.text)
    end)

    it("returns nil for non-header lines", function()
      local header = headers.parse_header("Not a header")
      assert.is_nil(header)
    end)
  end)

  describe("generate_slug", function()
    it("generates valid slugs from header text", function()
      assert.are.equal("test-header", headers.generate_slug("Test Header"))
      assert.are.equal("hello-world", headers.generate_slug("Hello World"))
      assert.are.equal("with-code", headers.generate_slug("With `code`"))
    end)

    it("handles special characters", function()
      assert.are.equal("test--header", headers.generate_slug("Test & Header"))
      assert.are.equal("123-numbers", headers.generate_slug("123 Numbers"))
    end)
  end)

  describe("find_toc", function()
    it("finds TOC with markers and links", function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "# Document",
        "<!-- TOC -->",
        "- [Header](#header)",
        "<!-- /TOC -->",
        "",
        "## Header",
      })

      local toc = headers.find_toc()
      assert.is_not_nil(toc)
      assert.are.equal(2, toc.start_line)
      assert.are.equal(4, toc.end_line)
    end)

    it("ignores markers without TOC links (documentation examples)", function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "# Document",
        "You can add TOC with:",
        "<!-- TOC -->",
        "<!-- /TOC -->",
        "",
        "## Header",
      })

      local toc = headers.find_toc()
      -- Should not find TOC because there are no actual links
      assert.is_nil(toc)
    end)

    it("finds legacy TOC without markers", function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "# Document",
        "## Table of Contents",
        "- [Header](#header)",
        "",
        "## Header",
      })

      local toc = headers.find_toc()
      assert.is_not_nil(toc)
    end)

    it("ignores 'Table of Contents' headers without links", function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "# Document",
        "## Table of Contents",
        "",
        "This section will contain the TOC.",
        "",
        "## Header",
      })

      local toc = headers.find_toc()
      -- Should not find TOC because there are no actual links
      assert.is_nil(toc)
    end)

    it("returns nil when no TOC exists", function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "# Document",
        "## Header",
        "Content",
      })

      local toc = headers.find_toc()
      assert.is_nil(toc)
    end)

    it("handles end-of-TOC detection with any header level", function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "<!-- TOC -->",
        "- [H1](#h1)",
        "- [H2](#h2)",
        "<!-- /TOC -->",
        "",
        "# H1",
      })

      local toc = headers.find_toc()
      assert.is_not_nil(toc)
      assert.are.equal(4, toc.end_line)
    end)
  end)

  describe("generate_toc", function()
    it("generates TOC for document with headers", function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "# Main Title",
        "",
        "## Section 1",
        "Content",
        "",
        "## Section 2",
        "More content",
      })

      headers.generate_toc()

      -- Check that TOC was inserted
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local has_toc_marker = false
      for _, line in ipairs(lines) do
        if line:match("<!%-%- TOC %-%->") then
          has_toc_marker = true
          break
        end
      end
      assert.is_true(has_toc_marker)
    end)

    it("does not create duplicate TOC", function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "# Main Title",
        "<!-- TOC -->",
        "- [Section](#section)",
        "<!-- /TOC -->",
        "",
        "## Section",
      })

      headers.generate_toc()

      -- Should not create a second TOC
      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      local toc_count = 0
      for _, line in ipairs(lines) do
        if line:match("<!%-%- TOC %-%->") then
          toc_count = toc_count + 1
        end
      end
      assert.are.equal(1, toc_count)
    end)
  end)
end)
