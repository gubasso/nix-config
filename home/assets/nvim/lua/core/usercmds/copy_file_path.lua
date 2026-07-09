-- CopyFilePath: Copy current buffer's file path to the system clipboard (+ register).
-- Supports three forms: absolute, relative to cwd, relative to project root.
local M = {}

-- Copy `path` to the + register, or warn when the buffer has no name.
local function copy(path, label)
  if not path or path == "" then
    vim.notify("No file path for current buffer", vim.log.levels.WARN)
    return
  end
  vim.fn.setreg("+", path)
  vim.notify("Copied " .. label .. ": " .. path)
end

-- Absolute path of the current buffer ("" when unnamed).
local function abs_path()
  local name = vim.api.nvim_buf_get_name(0)
  if name == "" then
    return ""
  end
  return vim.fn.fnamemodify(name, ":p")
end

function M.absolute()
  copy(abs_path(), "absolute path")
end

function M.dir()
  local name = vim.api.nvim_buf_get_name(0)
  if name == "" then
    copy("", "")
    return
  end
  copy(vim.fn.fnamemodify(name, ":p:h"), "absolute directory path")
end

function M.cwd()
  local name = vim.api.nvim_buf_get_name(0)
  if name == "" then
    copy("", "")
    return
  end
  copy(vim.fn.fnamemodify(name, ":."), "cwd-relative path")
end

function M.root()
  local name = vim.api.nvim_buf_get_name(0)
  if name == "" then
    copy("", "")
    return
  end

  local root = require("core.utils.paths").get_project_root(vim.fn.expand("%:p:h"))
  local cwd_rel = vim.fn.fnamemodify(name, ":.")
  local root_name = (root and root ~= "") and vim.fn.fnamemodify(root, ":t") or ""

  local path = root_name ~= "" and (root_name .. "/" .. cwd_rel) or cwd_rel
  copy(path, "root-prefixed cwd-relative path")
end

local dispatch = {
  abs = M.absolute,
  dir = M.dir,
  cwd = M.cwd,
  root = M.root,
}

vim.api.nvim_create_user_command("CopyFilePath", function(opts)
  local fn = dispatch[opts.args ~= "" and opts.args or "abs"]
  if not fn then
    vim.notify("CopyFilePath: expected one of abs|dir|cwd|root", vim.log.levels.ERROR)
    return
  end
  fn()
end, {
  nargs = "?",
  complete = function()
    return { "abs", "dir", "cwd", "root" }
  end,
})

return M
