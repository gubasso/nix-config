local uv = vim.uv or vim.loop

local M = {}

function M.get_project_root(start_dir)
  start_dir = start_dir or uv.cwd()

  local markers = {
    ".git",
    "lua",
    "package.json",
    "pyproject.toml",
    "go.mod",
    "Cargo.toml",
    "Makefile",
  }

  if vim.fs.root then
    local ok, root = pcall(vim.fs.root, start_dir, markers)
    if ok and root and root ~= "" then
      return root
    end
  end

  local found = vim.fs.find(markers, { upward = true, path = start_dir })[1]
  if found and found ~= "" then
    return vim.fs.dirname(found)
  end

  return uv.cwd()
end

function M.target_dir_for_current_buffer()
  if vim.bo.buftype == "" then
    local name = vim.api.nvim_buf_get_name(0)
    if name ~= "" then
      return vim.fs.dirname(name)
    end
  end

  return M.get_project_root(uv.cwd())
end

function M.normalize(path)
  if type(path) ~= "string" or path == "" then
    return nil
  end
  local normalized = path:gsub("/+$", "")
  if normalized == "" then
    return "/"
  end
  return normalized
end

function M.canonical(path)
  if type(path) ~= "string" or path == "" then
    return nil
  end
  return M.normalize(vim.fn.fnamemodify(path, ":p"))
end

--- Short label for a path: its last two segments (`parent/leaf`), or the single
--- segment / "/" when the path has fewer. Used for compact project identity in
--- the kitty tab bar and the fugitive winbar. Returns nil for nil/empty input.
function M.parent_leaf(path)
  if type(path) ~= "string" or path == "" then
    return nil
  end

  local segments = {}
  for seg in path:gmatch("[^/]+") do
    segments[#segments + 1] = seg
  end

  local n = #segments
  if n >= 2 then
    return segments[n - 1] .. "/" .. segments[n]
  elseif n == 1 then
    return segments[1]
  end
  return "/"
end

return M
