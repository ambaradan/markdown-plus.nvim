-- Tests for markdown-plus links module
describe("markdown-plus links", function()
  local links = require("markdown-plus.links")

  before_each(function()
    -- Create a test buffer
    vim.cmd("enew")
    vim.bo.filetype = "markdown"
    links.setup({ enabled = true })
  end)

  after_each(function()
    -- Clean up test buffer
    vim.cmd("bdelete!")
  end)

  describe("pattern matching", function()
    it("matches inline links", function()
      local text = "[link text](https://example.com)"
      local link_text, url = text:match(links.patterns.inline_link)
      assert.equals("link text", link_text)
      assert.equals("https://example.com", url)
    end)

    it("matches reference links", function()
      local text = "[link text][ref]"
      local link_text, ref = text:match(links.patterns.reference_link)
      assert.equals("link text", link_text)
      assert.equals("ref", ref)
    end)

    it("matches reference definitions", function()
      local text = "[ref]: https://example.com"
      local ref, url = text:match(links.patterns.reference_def)
      assert.equals("ref", ref)
      assert.equals("https://example.com", url)
    end)

    it("matches URLs", function()
      local text = "Visit https://example.com for more info"
      local url = text:match(links.patterns.url)
      assert.equals("https://example.com", url)
    end)
  end)

  describe("get_link_at_cursor", function()
    it("finds inline link when cursor is on it", function()
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "This is [a link](https://example.com) here." })
      vim.api.nvim_win_set_cursor(0, { 1, 10 }) -- cursor on "a link"

      local link = links.get_link_at_cursor()
      if link then
        assert.equals("inline", link.type)
        assert.equals("a link", link.text)
        assert.equals("https://example.com", link.url)
      end
    end)

    it("returns nil when cursor is not on a link", function()
      vim.api.nvim_buf_set_lines(0, 0, -1, false, { "This is plain text." })
      vim.api.nvim_win_set_cursor(0, { 1, 5 })

      local link = links.get_link_at_cursor()
      assert.is_nil(link)
    end)

    it("finds reference link when cursor is on it", function()
      vim.api.nvim_buf_set_lines(0, 0, -1, false, {
        "This is [a link][ref] here.",
        "",
        "[ref]: https://example.com",
      })
      vim.api.nvim_win_set_cursor(0, { 1, 10 })

      local link = links.get_link_at_cursor()
      if link then
        assert.equals("reference", link.type)
        assert.equals("a link", link.text)
      end
    end)
  end)

  describe("patterns", function()
    it("has inline_link pattern", function()
      assert.is_not_nil(links.patterns.inline_link)
    end)

    it("has reference_link pattern", function()
      assert.is_not_nil(links.patterns.reference_link)
    end)

    it("has reference_def pattern", function()
      assert.is_not_nil(links.patterns.reference_def)
    end)

    it("has url pattern", function()
      assert.is_not_nil(links.patterns.url)
    end)
  end)

  describe("find_reference_url", function()
    it("finds URL for given reference", function()
      vim.api.nvim_buf_set_lines(0, 0, -1, false, {
        "Text with [link][myref]",
        "",
        "[myref]: https://example.com",
        "[other]: https://other.com",
      })

      local url = links.find_reference_url("myref")
      assert.equals("https://example.com", url)
    end)

    it("returns nil for non-existent reference", function()
      vim.api.nvim_buf_set_lines(0, 0, -1, false, {
        "[ref]: https://example.com",
      })

      local url = links.find_reference_url("nonexistent")
      assert.is_nil(url)
    end)
  end)
end)
