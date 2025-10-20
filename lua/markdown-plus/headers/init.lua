-- Headers & TOC module for markdown-plus.nvim
local utils = require("markdown-plus.utils")
local M = {}

---@type markdown-plus.InternalConfig
M.config = {}

---Header pattern (matches # through ######)
M.header_pattern = "^(#+)%s+(.+)$"

---Setup headers module
---@param config markdown-plus.InternalConfig Plugin configuration
---@return nil
function M.setup(config)
  M.config = config or {}
end

---Enable headers features for current buffer
---@return nil
function M.enable()
  if not utils.is_markdown_buffer() then
    return
  end

  -- Set up keymaps
  M.setup_keymaps()
end

---Set up keymaps for headers
---@return nil
function M.setup_keymaps()
  -- Header navigation
  vim.keymap.set("n", "]]", M.next_header, {
    buffer = true,
    silent = true,
    desc = "Jump to next header",
  })
  vim.keymap.set("n", "[[", M.prev_header, {
    buffer = true,
    silent = true,
    desc = "Jump to previous header",
  })

  -- Promote/demote headers
  vim.keymap.set("n", "<leader>h+", M.promote_header, {
    buffer = true,
    silent = true,
    desc = "Promote header (increase level)",
  })
  vim.keymap.set("n", "<leader>h-", M.demote_header, {
    buffer = true,
    silent = true,
    desc = "Demote header (decrease level)",
  })

  -- TOC generation
  vim.keymap.set("n", "<leader>ht", M.generate_toc, {
    buffer = true,
    silent = true,
    desc = "Generate table of contents",
  })
  vim.keymap.set("n", "<leader>hu", M.update_toc, {
    buffer = true,
    silent = true,
    desc = "Update table of contents",
  })

  -- Follow TOC link (jump to header from TOC) - use gd only, not CR
  -- We don't map <CR> to avoid interfering with normal mode behavior
  vim.keymap.set("n", "gd", function()
    M.follow_link()
    -- If follow_link returns false, it means we're not on a TOC link
    -- In that case, we let the default gd behavior work (handled by other plugins/LSP)
  end, {
    buffer = true,
    silent = true,
    desc = "Follow TOC link to header",
  })

  -- Header level shortcuts
  vim.keymap.set("n", "<leader>h1", function()
    M.set_header_level(1)
  end, {
    buffer = true,
    silent = true,
    desc = "Set/convert to H1",
  })
  vim.keymap.set("n", "<leader>h2", function()
    M.set_header_level(2)
  end, {
    buffer = true,
    silent = true,
    desc = "Set/convert to H2",
  })
  vim.keymap.set("n", "<leader>h3", function()
    M.set_header_level(3)
  end, {
    buffer = true,
    silent = true,
    desc = "Set/convert to H3",
  })
  vim.keymap.set("n", "<leader>h4", function()
    M.set_header_level(4)
  end, {
    buffer = true,
    silent = true,
    desc = "Set/convert to H4",
  })
  vim.keymap.set("n", "<leader>h5", function()
    M.set_header_level(5)
  end, {
    buffer = true,
    silent = true,
    desc = "Set/convert to H5",
  })
  vim.keymap.set("n", "<leader>h6", function()
    M.set_header_level(6)
  end, {
    buffer = true,
    silent = true,
    desc = "Set/convert to H6",
  })
end

-- Parse a line to check if it's a header
function M.parse_header(line)
  if not line then
    return nil
  end

  local hashes, text = line:match(M.header_pattern)
  if hashes and text then
    return {
      level = #hashes,
      text = text,
      hashes = hashes,
    }
  end

  return nil
end

-- Get all headers in the buffer
function M.get_all_headers()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local headers = {}
  local in_code_block = false

  for i, line in ipairs(lines) do
    -- Check for code fence (``` or ~~~)
    if line:match("^```") or line:match("^~~~") then
      in_code_block = not in_code_block
    end

    -- Only parse headers if we're not inside a code block
    if not in_code_block then
      local header = M.parse_header(line)
      if header then
        header.line_num = i
        header.full_line = line
        table.insert(headers, header)
      end
    end
  end

  return headers
end

-- Navigate to next header
function M.next_header()
  local cursor = utils.get_cursor()
  local current_line = cursor[1]
  local headers = M.get_all_headers()

  -- Find next header after current line
  for _, header in ipairs(headers) do
    if header.line_num > current_line then
      utils.set_cursor(header.line_num, 0)
      return
    end
  end

  -- No next header, stay at current position
  print("No next header")
end

-- Navigate to previous header
function M.prev_header()
  local cursor = utils.get_cursor()
  local current_line = cursor[1]
  local headers = M.get_all_headers()

  -- Find previous header before current line (search backwards)
  for i = #headers, 1, -1 do
    local header = headers[i]
    if header.line_num < current_line then
      utils.set_cursor(header.line_num, 0)
      return
    end
  end

  -- No previous header, stay at current position
  print("No previous header")
end

-- Follow link in TOC (jump to header from markdown link)
function M.follow_link()
  local line = utils.get_current_line()

  -- Try to extract anchor from markdown link: [text](#anchor)
  local anchor = line:match("%[.-%]%(#(.-)%)")

  if not anchor then
    -- Not on a TOC link, don't do anything (let other mappings or default behavior handle it)
    return false
  end

  -- Convert anchor back to header text (reverse of slug generation)
  -- Anchors are lowercase with hyphens, need to find matching header
  local headers = M.get_all_headers()

  for _, header in ipairs(headers) do
    local slug = M.generate_slug(header.text)
    if slug == anchor then
      -- Found the matching header, jump to it
      utils.set_cursor(header.line_num, 0)
      -- Center the screen on the header
      vim.cmd("normal! zz")
      return true
    end
  end

  -- No matching header found
  print("Header not found: " .. anchor)
  return false
end

-- Promote header (decrease level number, increase importance)
function M.promote_header()
  local cursor = utils.get_cursor()
  local line_num = cursor[1]
  local line = utils.get_line(line_num)
  local header = M.parse_header(line)

  if not header then
    print("Not on a header line")
    return
  end

  if header.level <= 1 then
    print("Already at highest level (H1)")
    return
  end

  -- Decrease level (remove one #)
  local new_level = header.level - 1
  local new_line = string.rep("#", new_level) .. " " .. header.text
  utils.set_line(line_num, new_line)

  print("Promoted to H" .. new_level)
end

-- Demote header (increase level number, decrease importance)
function M.demote_header()
  local cursor = utils.get_cursor()
  local line_num = cursor[1]
  local line = utils.get_line(line_num)
  local header = M.parse_header(line)

  if not header then
    print("Not on a header line")
    return
  end

  if header.level >= 6 then
    print("Already at lowest level (H6)")
    return
  end

  -- Increase level (add one #)
  local new_level = header.level + 1
  local new_line = string.rep("#", new_level) .. " " .. header.text
  utils.set_line(line_num, new_line)

  print("Demoted to H" .. new_level)
end

-- Set specific header level
function M.set_header_level(level)
  if level < 1 or level > 6 then
    print("Invalid header level: " .. level)
    return
  end

  local cursor = utils.get_cursor()
  local line_num = cursor[1]
  local line = utils.get_line(line_num)
  local header = M.parse_header(line)

  if header then
    -- Already a header, change its level
    local new_line = string.rep("#", level) .. " " .. header.text
    utils.set_line(line_num, new_line)
    print("Changed to H" .. level)
  else
    -- Not a header, convert current line to header
    local text = line:match("^%s*(.-)%s*$") -- trim whitespace
    if text == "" then
      print("Cannot create header from empty line")
      return
    end
    local new_line = string.rep("#", level) .. " " .. text
    utils.set_line(line_num, new_line)
    print("Created H" .. level)
  end
end

-- Generate a slug from header text (for TOC links)
function M.generate_slug(text)
  local slug = text

  -- Step 1: Remove markdown formatting (must be done before lowercase)
  slug = slug:gsub("%*%*(.-)%*%*", "%1") -- **bold**
  slug = slug:gsub("%*(.-)%*", "%1") -- *italic*
  slug = slug:gsub("`(.-)`", "%1") -- `code`
  slug = slug:gsub("~~(.-)~~", "%1") -- ~~strikethrough~~

  -- Step 2: Convert to lowercase
  slug = slug:lower()

  -- Step 3: Replace spaces with hyphens (before removing punctuation!)
  slug = slug:gsub("%s+", "-")

  -- Step 4: Remove punctuation (GitHub-compatible)
  -- Keep: alphanumeric, hyphens (-), underscores (_)
  -- Remove: & ! @ # $ % ^ * ( ) = + [ ] { } \ | ; : ' " < > ? / . ,
  slug = slug:gsub("[&!@#$%%^*()=+%[%]{}\\|;:'\",<>?/.]", "")

  -- Step 5: Remove leading/trailing hyphens
  slug = slug:gsub("^%-+", "")
  slug = slug:gsub("%-+$", "")

  return slug
end

-- Generate table of contents
function M.generate_toc()
  local headers = M.get_all_headers()

  if #headers == 0 then
    print("No headers found in document")
    return
  end

  -- Check if TOC already exists
  local existing_toc = M.find_toc()
  if existing_toc then
    print("TOC already exists. Use <leader>hu to update it.")
    return
  end

  -- Find where to insert TOC (right before first non-H1 header)
  local toc_insert_line = 1

  -- Find first header that is not H1
  for _, header in ipairs(headers) do
    if header.level > 1 then
      -- Insert right before this header (but at least at line 1)
      toc_insert_line = math.max(1, header.line_num - 1)
      break
    end
  end

  -- If all headers are H1 (unusual), default to after first H1
  if toc_insert_line == 1 and headers[1] and headers[1].level == 1 then
    toc_insert_line = headers[1].line_num + 1
  end

  -- Build TOC lines with HTML comment markers
  local toc_lines = {
    "",
    "<!-- TOC -->",
    "",
    "## Table of Contents",
    "",
  }

  for _, header in ipairs(headers) do
    -- Skip H1 (usually the document title)
    if header.level > 1 then
      local indent = string.rep("  ", header.level - 2)
      local slug = M.generate_slug(header.text)
      local toc_line = indent .. "- [" .. header.text .. "](#" .. slug .. ")"
      table.insert(toc_lines, toc_line)
    end
  end

  table.insert(toc_lines, "")
  table.insert(toc_lines, "<!-- /TOC -->")
  table.insert(toc_lines, "")

  -- Insert TOC into buffer
  vim.api.nvim_buf_set_lines(0, toc_insert_line - 1, toc_insert_line - 1, false, toc_lines)

  print("TOC generated with " .. (#headers - 1) .. " entries")
end

---Check if content between markers looks like a valid TOC
---@param lines string[] All lines in buffer
---@param start_line number Start line (1-indexed)
---@param end_line number End line (1-indexed)
---@return boolean is_valid True if content looks like a TOC
---@param lines string[]
---@param start_line number
---@param end_line number
---@return boolean
local function is_valid_toc_content(lines, start_line, end_line)
  local has_toc_header = false
  local has_links = false
  local link_count = 0

  for i = start_line, end_line do
    local line = lines[i]
    if not line then
      break
    end

    -- Check for TOC header
    if line:match("^##%s+[Tt]able%s+[Oo]f%s+[Cc]ontents") then
      has_toc_header = true
    end

    -- Check for markdown links (TOC entries)
    -- Match patterns like: - [Text](#link) or   - [Text](#link)
    if line:match("^%s*%-%s+%[.-%]%(#.-%)") then
      has_links = true
      link_count = link_count + 1
    end
  end

  -- Valid TOC should have either:
  -- 1. A TOC header + at least one link, OR
  -- 2. At least 1 link (for TOCs without header)
  return (has_toc_header and has_links) or (link_count >= 1)
end

---Find existing TOC in document
---@return {start_line: number, end_line: number}|nil TOC location
function M.find_toc()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

  -- Look for <!-- TOC --> marker pairs
  local toc_candidates = {}

  for i, line in ipairs(lines) do
    if line:match("^%s*<!%-%-%s*TOC%s*%-%->%s*$") then
      -- Found opening marker, look for closing marker
      for j = i + 1, #lines do
        if lines[j]:match("^%s*<!%-%-%s*/TOC%s*%-%->%s*$") then
          -- Found a complete pair, validate it's actually a TOC
          if is_valid_toc_content(lines, i, j) then
            table.insert(toc_candidates, {
              start_line = i,
              end_line = j,
            })
          end
          break
        end
      end
    end
  end

  -- Return the first valid TOC found
  if #toc_candidates > 0 then
    return toc_candidates[1]
  end

  -- Fallback: look for old-style TOC without markers (for backwards compatibility)
  for i, line in ipairs(lines) do
    -- Look for "## Table of Contents" or similar
    if line:match("^##%s+[Tt]able%s+[Oo]f%s+[Cc]ontents") then
      -- Check if the next few lines contain TOC links
      local has_links = false
      local check_lines = math.min(i + 10, #lines) -- Check next 10 lines

      for j = i + 1, check_lines do
        if lines[j]:match("^%s*%-%s+%[.-%]%(#.-%)") then
          has_links = true
          break
        end
      end

      -- Only treat as TOC if it has actual links
      if has_links then
        -- Find the end of TOC (next header at same or higher level)
        local toc_end_line = i
        for j = i + 1, #lines do
          local next_line = lines[j]
          -- TOC ends at next header (any level: #, ##, ###, etc.)
          -- Pattern matches lines starting with # followed by space
          if next_line:match("^#+%s") then
            toc_end_line = j - 1
            break
          end
          -- Also end at blank line followed by non-list content
          if next_line == "" and lines[j + 1] and not lines[j + 1]:match("^%s*%-") then
            toc_end_line = j - 1
            break
          end
          toc_end_line = j
        end

        return {
          start_line = i,
          end_line = toc_end_line,
        }
      end
    end
  end

  return nil
end

-- Update existing TOC
function M.update_toc()
  local toc_location = M.find_toc()

  if not toc_location then
    print("No TOC found. Use <leader>ht to generate one.")
    return
  end

  local headers = M.get_all_headers()

  -- Build new TOC content with markers
  local toc_lines = {
    "<!-- TOC -->",
    "",
    "## Table of Contents",
    "",
  }

  for _, header in ipairs(headers) do
    -- Skip H1 and skip if header is within TOC range
    if header.level > 1 and (header.line_num < toc_location.start_line or header.line_num > toc_location.end_line) then
      local indent = string.rep("  ", header.level - 2)
      local slug = M.generate_slug(header.text)
      local toc_line = indent .. "- [" .. header.text .. "](#" .. slug .. ")"
      table.insert(toc_lines, toc_line)
    end
  end

  table.insert(toc_lines, "")
  table.insert(toc_lines, "<!-- /TOC -->")

  -- Replace old TOC with new one
  vim.api.nvim_buf_set_lines(0, toc_location.start_line - 1, toc_location.end_line, false, toc_lines)

  print("TOC updated")
end

return M
