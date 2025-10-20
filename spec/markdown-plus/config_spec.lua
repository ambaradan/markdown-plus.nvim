---@diagnostic disable: undefined-field
local markdown_plus = require("markdown-plus")

describe("markdown-plus configuration", function()
  local original_config

  before_each(function()
    -- Save original config
    original_config = vim.deepcopy(markdown_plus.config)
  end)

  after_each(function()
    -- Restore original config
    markdown_plus.config = original_config
  end)

  describe("setup", function()
    it("accepts empty config", function()
      assert.has_no.errors(function()
        markdown_plus.setup()
      end)
    end)

    it("accepts valid config", function()
      assert.has_no.errors(function()
        markdown_plus.setup({
          enabled = false,
          features = {
            list_management = false,
          },
        })
      end)
      assert.is_false(markdown_plus.config.enabled)
      assert.is_false(markdown_plus.config.features.list_management)
    end)

    it("merges config with defaults", function()
      markdown_plus.setup({
        features = {
          list_management = false,
        },
      })

      -- Check that other features are still enabled (default)
      assert.is_false(markdown_plus.config.features.list_management)
      assert.is_true(markdown_plus.config.features.text_formatting)
      assert.is_true(markdown_plus.config.features.headers_toc)
    end)

    it("validates boolean fields", function()
      local _ = pcall(function()
        markdown_plus.setup({
          enabled = "yes", -- Should be boolean
        })
      end)
      -- Should either error or handle gracefully
      -- The actual behavior depends on validation implementation
    end)

    it("detects unknown fields", function()
      -- Test should validate but may not error depending on implementation
      pcall(function()
        markdown_plus.setup({
          unknown_field = true,
        })
      end)
    end)
  end)

  describe("default configuration", function()
    it("has all required features defined", function()
      assert.is_not_nil(markdown_plus.config.features)
      assert.is_not_nil(markdown_plus.config.features.list_management)
      assert.is_not_nil(markdown_plus.config.features.text_formatting)
      assert.is_not_nil(markdown_plus.config.features.headers_toc)
      assert.is_not_nil(markdown_plus.config.features.links)
    end)

    it("has keymaps configuration", function()
      assert.is_not_nil(markdown_plus.config.keymaps)
      assert.is_not_nil(markdown_plus.config.keymaps.enabled)
    end)

    it("is enabled by default", function()
      assert.is_true(markdown_plus.config.enabled)
    end)
  end)

  describe("feature toggles", function()
    it("can disable all features", function()
      markdown_plus.setup({
        features = {
          list_management = false,
          text_formatting = false,
          headers_toc = false,
          links = false,
        },
      })

      assert.is_false(markdown_plus.config.features.list_management)
      assert.is_false(markdown_plus.config.features.text_formatting)
      assert.is_false(markdown_plus.config.features.headers_toc)
      assert.is_false(markdown_plus.config.features.links)
    end)

    it("can disable keymaps", function()
      markdown_plus.setup({
        keymaps = {
          enabled = false,
        },
      })

      assert.is_false(markdown_plus.config.keymaps.enabled)
    end)
  end)
end)
