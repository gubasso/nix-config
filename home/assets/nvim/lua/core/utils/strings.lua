local M = {}

function M.trim(s)
  return (s or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

function M.strip_outer_quotes(s)
  s = M.trim(s)
  local first, last = s:sub(1, 1), s:sub(-1)
  if (first == '"' and last == '"') or (first == "'" and last == "'") then
    s = s:sub(2, -2)
  end
  return s
end

function M.strip_md_list_marker(line)
  local text = line or ""
  local replaced
  text, replaced = text:gsub("^%s*[-*+]%s*%[[^%]]*%]%s*", "", 1)
  if replaced == 0 then
    text, replaced = text:gsub("^%s*[-*+]%s+", "", 1)
    if replaced == 0 then
      text = text:gsub("^%s*%d+[.)]%s+", "", 1)
    end
  end
  return M.trim(text)
end

function M.slugify(title, max_len)
  local slug = (title or "")
    :gsub("^%s+", "")
    :gsub("%s+$", "")
    :lower()
    :gsub("[_%s]+", "-")
    :gsub("[^%w%-]+", "-")
    :gsub("%-+", "-")
    :gsub("^%-+", "")
    :gsub("%-+$", "")

  if slug == "" then
    slug = "untitled"
  end

  if max_len and #slug > max_len then
    local truncated = slug:sub(1, max_len)
    local boundary = truncated:match("^(.*)%-[^%-]+$")
    if boundary and boundary ~= "" then
      truncated = boundary
    end
    truncated = truncated:gsub("%-+$", "")
    if truncated == "" then
      truncated = slug:sub(1, max_len):gsub("%-+$", "")
    end
    if truncated == "" then
      truncated = "untitled"
    end
    slug = truncated
  end

  return slug
end

return M
