---Test suite for table row_mapper module
---Tests row index mapping, validation, and bounds checking
---@diagnostic disable: undefined-field
local row_mapper = require("markdown-plus.table.row_mapper")

describe("table.row_mapper", function()
  describe("constants", function()
    it("defines correct row position constants", function()
      assert.equals(0, row_mapper.HEADER_ROW)
      assert.equals(1, row_mapper.SEPARATOR_ROW)
      assert.equals(2, row_mapper.FIRST_DATA_ROW)
    end)
  end)

  describe("pos_row_to_cells_index", function()
    it("maps header row correctly", function()
      local cells_index = row_mapper.pos_row_to_cells_index(0)
      assert.equals(1, cells_index)
    end)

    it("returns nil for separator row", function()
      local cells_index = row_mapper.pos_row_to_cells_index(1)
      assert.is_nil(cells_index)
    end)

    it("maps first data row correctly", function()
      local cells_index = row_mapper.pos_row_to_cells_index(2)
      assert.equals(2, cells_index)
    end)

    it("maps subsequent data rows correctly", function()
      assert.equals(3, row_mapper.pos_row_to_cells_index(3))
      assert.equals(4, row_mapper.pos_row_to_cells_index(4))
      assert.equals(10, row_mapper.pos_row_to_cells_index(10))
    end)
  end)

  describe("cells_index_to_pos_row", function()
    it("maps header cell correctly", function()
      local pos_row = row_mapper.cells_index_to_pos_row(1)
      assert.equals(0, pos_row)
    end)

    it("maps first data cell correctly", function()
      local pos_row = row_mapper.cells_index_to_pos_row(2)
      assert.equals(2, pos_row)
    end)

    it("maps subsequent data cells correctly", function()
      assert.equals(3, row_mapper.cells_index_to_pos_row(3))
      assert.equals(4, row_mapper.cells_index_to_pos_row(4))
      assert.equals(10, row_mapper.cells_index_to_pos_row(10))
    end)
  end)

  describe("roundtrip conversion", function()
    it("header roundtrip: pos -> cells -> pos", function()
      local cells_index = row_mapper.pos_row_to_cells_index(0)
      local pos_row = row_mapper.cells_index_to_pos_row(cells_index)
      assert.equals(0, pos_row)
    end)

    it("data row roundtrip: pos -> cells -> pos", function()
      for pos_row = 2, 10 do
        local cells_index = row_mapper.pos_row_to_cells_index(pos_row)
        local recovered_pos = row_mapper.cells_index_to_pos_row(cells_index)
        assert.equals(pos_row, recovered_pos)
      end
    end)

    it("header roundtrip: cells -> pos -> cells", function()
      local pos_row = row_mapper.cells_index_to_pos_row(1)
      local cells_index = row_mapper.pos_row_to_cells_index(pos_row)
      assert.equals(1, cells_index)
    end)

    it("data cell roundtrip: cells -> pos -> cells", function()
      for cells_index = 2, 10 do
        local pos_row = row_mapper.cells_index_to_pos_row(cells_index)
        local recovered_cells = row_mapper.pos_row_to_cells_index(pos_row)
        assert.equals(cells_index, recovered_cells)
      end
    end)
  end)

  describe("is_header_row", function()
    it("returns true for header position", function()
      assert.is_true(row_mapper.is_header_row(0))
    end)

    it("returns false for non-header positions", function()
      assert.is_false(row_mapper.is_header_row(1))
      assert.is_false(row_mapper.is_header_row(2))
      assert.is_false(row_mapper.is_header_row(10))
    end)
  end)

  describe("is_separator_row", function()
    it("returns true for separator position", function()
      assert.is_true(row_mapper.is_separator_row(1))
    end)

    it("returns false for non-separator positions", function()
      assert.is_false(row_mapper.is_separator_row(0))
      assert.is_false(row_mapper.is_separator_row(2))
      assert.is_false(row_mapper.is_separator_row(10))
    end)
  end)

  describe("is_data_row", function()
    it("returns true for data row positions", function()
      assert.is_true(row_mapper.is_data_row(2))
      assert.is_true(row_mapper.is_data_row(3))
      assert.is_true(row_mapper.is_data_row(10))
    end)

    it("returns false for header and separator", function()
      assert.is_false(row_mapper.is_data_row(0))
      assert.is_false(row_mapper.is_data_row(1))
    end)
  end)

  describe("validate_cells_index", function()
    it("accepts valid header index", function()
      local valid, err = row_mapper.validate_cells_index(1, 5)
      assert.is_true(valid)
      assert.is_nil(err)
    end)

    it("accepts valid data indices", function()
      local valid, err = row_mapper.validate_cells_index(2, 5)
      assert.is_true(valid)
      assert.is_nil(err)

      valid, err = row_mapper.validate_cells_index(5, 5)
      assert.is_true(valid)
      assert.is_nil(err)
    end)

    it("rejects index less than 1", function()
      local valid, err = row_mapper.validate_cells_index(0, 5)
      assert.is_false(valid)
      assert.is_not_nil(err)
      assert.matches("less than 1", err)
    end)

    it("rejects negative index", function()
      local valid, err = row_mapper.validate_cells_index(-1, 5)
      assert.is_false(valid)
      assert.is_not_nil(err)
      assert.matches("less than 1", err)
    end)

    it("rejects index exceeding cells count", function()
      local valid, err = row_mapper.validate_cells_index(6, 5)
      assert.is_false(valid)
      assert.is_not_nil(err)
      assert.matches("exceeds cells count", err)
    end)

    it("rejects index far exceeding cells count", function()
      local valid, err = row_mapper.validate_cells_index(100, 5)
      assert.is_false(valid)
      assert.is_not_nil(err)
      assert.matches("exceeds cells count", err)
    end)
  end)

  describe("edge cases", function()
    it("handles table with only header (cells count = 1)", function()
      local cells_count = 1

      -- Header is valid
      local valid, err = row_mapper.validate_cells_index(1, cells_count)
      assert.is_true(valid)
      assert.is_nil(err)

      -- Data row index 2 is invalid (no data rows)
      valid, err = row_mapper.validate_cells_index(2, cells_count)
      assert.is_false(valid)
      assert.is_not_nil(err)
    end)

    it("handles large table (many data rows)", function()
      local cells_count = 100

      -- Header is valid
      local valid = row_mapper.validate_cells_index(1, cells_count)
      assert.is_true(valid)

      -- All data rows are valid
      for i = 2, 100 do
        valid = row_mapper.validate_cells_index(i, cells_count)
        assert.is_true(valid)
      end

      -- Beyond table is invalid
      valid = row_mapper.validate_cells_index(101, cells_count)
      assert.is_false(valid)
    end)

    it("separator conversion always returns nil", function()
      -- Separator row (pos 1) cannot map to cells
      local cells_index = row_mapper.pos_row_to_cells_index(1)
      assert.is_nil(cells_index)
    end)
  end)

  describe("consistency checks", function()
    it("every valid cells index can map to pos_row", function()
      local cells_count = 10
      for cells_index = 1, cells_count do
        local pos_row = row_mapper.cells_index_to_pos_row(cells_index)
        assert.is_not_nil(pos_row)
        assert.is_true(pos_row >= 0)
      end
    end)

    it("every valid pos_row (except separator) can map to cells", function()
      local max_pos_row = 10
      for pos_row = 0, max_pos_row do
        if pos_row ~= row_mapper.SEPARATOR_ROW then
          local cells_index = row_mapper.pos_row_to_cells_index(pos_row)
          assert.is_not_nil(cells_index)
          assert.is_true(cells_index >= 1)
        end
      end
    end)

    it("no cells index maps to separator row", function()
      for cells_index = 1, 20 do
        local pos_row = row_mapper.cells_index_to_pos_row(cells_index)
        assert.is_not.equals(row_mapper.SEPARATOR_ROW, pos_row)
      end
    end)
  end)
end)
