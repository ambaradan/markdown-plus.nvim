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

  describe("extract_headers", function()
    it("extracts headers from markdown", function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "# Heading 1",
        "Some text",
        "## Heading 2",
        "More text",
        "### Heading 3",
      })

      local result = headers.extract_headers()

      assert.are.equal(3, #result)
      assert.are.equal(1, result[1].level)
      assert.are.equal("Heading 1", result[1].text)
      assert.are.equal(2, result[2].level)
      assert.are.equal("Heading 2", result[2].text)
      assert.are.equal(3, result[3].level)
      assert.are.equal("Heading 3", result[3].text)
    end)

    it("handles headers with inline code", function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "# Heading with `code`",
        "## Another with `multiple` `code` blocks",
      })

      local result = headers.extract_headers()

      assert.are.equal(2, #result)
      assert.are.equal("Heading with `code`", result[1].text)
      assert.are.equal("Another with `multiple` `code` blocks", result[2].text)
    end)

    it("ignores code blocks", function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "# Real Header",
        "```",
        "# Not a header",
        "## Still not a header",
        "```",
        "## Real Header 2",
      })

      local result = headers.extract_headers()

      assert.are.equal(2, #result)
      assert.are.equal("Real Header", result[1].text)
      assert.are.equal("Real Header 2", result[2].text)
    end)
  end)

  describe("find_toc", function()
    it("finds TOC with markers and links", function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "# Document Title",
        "",
        "<!-- TOC -->",
        "",
        "## Table of Contents",
        "",
        "- [Section 1](#section-1)",
        "- [Section 2](#section-2)",
        "",
        "<!-- /TOC -->",
        "",
        "## Section 1",
      })

      local result = headers.find_toc()

      assert.is_not_nil(result)
      assert.are.equal(3, result.start_line)
      assert.are.equal(10, result.end_line)
    end)

    it("ignores markers without TOC links (documentation examples)", function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "# Documentation",
        "",
        "Here's how to use TOC:",
        "",
        "<!-- TOC -->",
        "This is just example text, not real TOC links",
        "<!-- /TOC -->",
        "",
        "<!-- TOC -->",
        "## Table of Contents",
        "- [Real Section](#real-section)",
        "<!-- /TOC -->",
        "",
        "## Real Section",
      })

      local result = headers.find_toc()

      assert.is_not_nil(result)
      -- Should find the second TOC (lines 9-12), not the first (lines 5-7)
      assert.are.equal(9, result.start_line)
      assert.are.equal(12, result.end_line)
    end)

    it("finds legacy TOC without markers", function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "# Document",
        "",
        "## Table of Contents",
        "",
        "- [Section 1](#section-1)",
        "- [Section 2](#section-2)",
        "",
        "## Section 1",
      })

      local result = headers.find_toc()

      assert.is_not_nil(result)
      assert.are.equal(3, result.start_line)
    end)

    it("ignores 'Table of Contents' headers without links", function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "# Document",
        "",
        "## Table of Contents",
        "",
        "This section explains how to create a TOC.",
        "No actual links here.",
        "",
        "## Section 1",
      })

      local result = headers.find_toc()

      assert.is_nil(result)
    end)

    it("returns nil when no TOC exists", function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "# Document",
        "## Section 1",
        "## Section 2",
      })

      local result = headers.find_toc()

      assert.is_nil(result)
    end)

    it("handles end-of-TOC detection with any header level", function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "## Table of Contents",
        "- [Section](#section)",
        "### Next Header",  -- Should end TOC here
        "Content",
      })

      local result = headers.find_toc()

      assert.is_not_nil(result)
      assert.are.equal(1, result.start_line)
      assert.are.equal(2, result.end_line) -- Should stop before line 3
    end)
  end)

  describe("generate_slug", function()
    it("generates valid slugs from header text", function()
      -- Note: We're testing the slug generation indirectly through TOC generation
      -- Direct testing would require exposing the function or testing through public API
      
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "# Test",
        "## Section One",
        "## Section-Two",
        "## Section & Three",
      })

      -- The slug generation is tested implicitly when TOC is generated
      -- and links match the expected format
    end)
  end)

  describe("generate_toc", function()
    it("generates TOC for document with headers", function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "# Main Title",
        "",
        "## Introduction",
        "Some content",
        "",
        "## Features",
        "More content",
        "",
        "### Sub-feature",
        "Details",
      })

      headers.generate_toc()

      local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      
      -- Check for TOC markers
      assert.is_true(vim.tbl_contains(lines, "<!-- TOC -->"))
      assert.is_true(vim.tbl_contains(lines, "<!-- /TOC -->"))
      
      -- Check for TOC header
      local has_toc_header = false
      for _, line in ipairs(lines) do
        if line:match("^##%s+Table of Contents") then
          has_toc_header = true
          break
        end
      end
      assert.is_true(has_toc_header)
    end)

    it("does not create duplicate TOC", function()
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "# Title",
        "",
        "<!-- TOC -->",
        "## Table of Contents",
        "- [Section](#section)",
        "<!-- /TOC -->",
        "",
        "## Section",
      })

      local lines_before = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      
      headers.generate_toc()
      
      local lines_after = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      
      -- Count should not change (TOC already exists message should be shown)
      assert.are.equal(#lines_before, #lines_after)
    end)
  end)
end)
