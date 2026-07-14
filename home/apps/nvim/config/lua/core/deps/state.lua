-- Persistent state management for dependency verification
local uv = vim.uv or vim.loop

local M = {}

local function state_file()
  return vim.fn.stdpath("state") .. "/deps-verified.json"
end

function M.read()
  local path = state_file()
  local fd = uv.fs_open(path, "r", 438)
  if not fd then
    return nil
  end
  local stat = uv.fs_fstat(fd)
  local data = uv.fs_read(fd, stat.size, 0)
  uv.fs_close(fd)

  local ok, decoded = pcall(vim.json.decode, data)
  if ok then
    return decoded
  end
  return nil
end

function M.write(state)
  local path = state_file()
  vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")

  local data = vim.json.encode(state)
  local fd = uv.fs_open(path, "w", 438)
  if fd then
    uv.fs_write(fd, data)
    uv.fs_close(fd)
    return true
  end
  return false
end

function M.is_verified()
  local state = M.read()
  return state and state.verified == true
end

function M.mark_verified()
  return M.write({
    verified = true,
    timestamp = os.time(),
    nvim_version = vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch,
  })
end

function M.reset()
  local path = state_file()
  uv.fs_unlink(path)
end

return M
