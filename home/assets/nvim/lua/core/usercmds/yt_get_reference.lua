-- YTGetReference: Generate markdown reference from YouTube URL via yt-dlp
-- Works in any filetype (useful for code comments, docstrings, etc.)
local strings = require("core.utils.strings")

local function get_visual_selection()
  local _, start_row, start_col, _ = unpack(vim.fn.getpos("'<"))
  local _, end_row, end_col, _ = unpack(vim.fn.getpos("'>"))
  if start_row ~= end_row then
    return nil -- multi-line selection not supported
  end
  local line = vim.api.nvim_buf_get_lines(0, start_row - 1, start_row, false)[1]
  if not line then
    return nil
  end
  return line:sub(start_col, end_col)
end

local function extract_url(text)
  if not text then
    return nil
  end
  return text:match("https?://[%w%.%-_/?=&#]+")
end

local function get_url(is_visual)
  -- Priority 1: Visual selection
  if is_visual then
    local selection = get_visual_selection()
    local url = extract_url(selection)
    if url then
      return url, "visual"
    end
  end

  -- Priority 2: Under cursor (current line)
  local line = vim.api.nvim_get_current_line()
  local url = extract_url(line)
  if url then
    return url, "line"
  end

  -- Priority 3: Clipboard
  local clipboard = vim.fn.getreg("+")
  url = extract_url(clipboard)
  if url then
    return url, "clipboard"
  end

  return nil, nil
end

local function check_ytdlp()
  return vim.fn.executable("yt-dlp") == 1
end
local function check_bun()
  return vim.fn.executable("bun") == 1
end

local function fetch_metadata(url)
  local output = vim.fn.system({ "yt-dlp", "--no-warnings", "--skip-download", "-j", url })
  local exit_code = vim.v.shell_error
  if exit_code ~= 0 then
    return nil, nil, vim.trim(output)
  end
  local ok, json = pcall(vim.json.decode, output)
  if not ok then
    return nil, nil, "Failed to parse yt-dlp output"
  end
  if json.extractor == "generic" then
    return nil, nil, "Unsupported URL (no specific extractor available)"
  end
  local title = json.title or json.fulltitle
  local channel = json.channel or json.uploader
  return title, channel, nil
end

local function truncate_slug(slug, max_len)
  if #slug <= max_len then
    return slug
  end
  -- Truncate on word boundary (hyphen)
  local truncated = slug:sub(1, max_len)
  local last_hyphen = truncated:match(".*()-")
  if last_hyphen and last_hyphen > max_len / 2 then
    truncated = truncated:sub(1, last_hyphen - 1)
  end
  -- Remove trailing hyphen
  return truncated:gsub("%-+$", "")
end

local function make_reference_id(title)
  local slug = strings.slugify(title)
  return truncate_slug(slug, 30)
end

local function format_reference(id, url, title)
  return string.format('[%s]: %s "%s"', id, url, title)
end

vim.api.nvim_create_user_command("YTGetReference", function(opts)
  if not check_ytdlp() then
    vim.notify("yt-dlp is not installed or not in PATH", vim.log.levels.ERROR)
    return
  end
  if not check_bun() then
    vim.notify("bun is not installed or not in PATH (required)", vim.log.levels.ERROR)
    return
  end

  local is_visual = opts.range > 0
  local url, source = get_url(is_visual)

  if not url then
    vim.notify("No YouTube URL found in selection, line, or clipboard", vim.log.levels.ERROR)
    return
  end

  vim.notify("Fetching title from YouTube...", vim.log.levels.INFO)

  local title, channel, err = fetch_metadata(url)
  if not title then
    vim.notify(err or "yt-dlp failed with unknown error", vim.log.levels.ERROR)
    return
  end

  local ref_id = make_reference_id(title)
  local full_title = channel and (title .. " - " .. channel) or title
  local reference = format_reference(ref_id, url, full_title)

  if source == "line" or source == "visual" then
    local line = vim.api.nvim_get_current_line()
    local new_line = line:gsub(vim.pesc(url), reference)
    vim.api.nvim_set_current_line(new_line)
  else
    -- URL was from clipboard, insert at cursor position
    vim.api.nvim_put({ reference }, "c", true, true)
  end

  vim.notify("Reference created: [" .. ref_id .. "]", vim.log.levels.INFO)
end, {
  range = true,
  desc = "Generate markdown reference from YouTube URL",
})
