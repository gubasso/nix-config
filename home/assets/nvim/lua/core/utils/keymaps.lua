-- Helper functions for keymaps and plugin configurations
local M = {}

-- Highlight the visual selection upon pressing <CR> in Visual mode
function M.highlight_selection()
  vim.cmd.normal({ '"*y', bang = true })
  local text = vim.fn.getreg("*")
  text = vim.fn.escape(text, "\\/")
  text = vim.fn.substitute(text, "\n", "\\n", "g")
  local searchTerm = "\\V" .. text
  vim.fn.setreg("/", searchTerm)
  print("/" .. searchTerm)
  vim.fn.histadd("search", searchTerm)
  vim.opt.hlsearch = true
end

-- Highlight the word under cursor on <leader><CR> in Normal mode
function M.highlight_cword()
  local cword = vim.fn.expand("<cword>")
  local searchTerm = "\\v<" .. cword .. ">"
  vim.fn.setreg("/", searchTerm)
  print("/" .. searchTerm)
  vim.fn.histadd("search", searchTerm)
  vim.opt.hlsearch = true
end

--- Open the file/URL under the cursor with the system opener.
---
--- Behavior:
--- - If the token under cursor looks like a URL (has a scheme, e.g. https:// or file://),
---   it is passed directly to `xdg-open`.
--- - Otherwise it is treated as a filesystem path. Relative paths are resolved
---   against the *current buffer's directory*, then normalized to an absolute path
---   (removing any `.`/`..`). If the file exists, it is opened via `xdg-open`.
--- - Shows friendly notifications when nothing is under the cursor or a file
---   can't be found after normalization.
---
--- Examples it handles:
---   - ../media/img.png        (relative to current file)
---   - ./notes/today.md
---   - /abs/path/to/file.pdf
---   - https://example.com
---   - file:///home/user/pic.jpg
function M.system_open_under_cursor()
  local cfile = vim.fn.expand("<cfile>")
  if cfile == "" then
    vim.notify("No file/URL under the cursor", vim.log.levels.WARN)
    return
  end

  -- URL? (simple "has a scheme" check like 'http:', 'https:', 'file:', 'mailto:', etc.)
  if cfile:match("^[%a][%w+.-]*:") then
    vim.fn.jobstart({ "xdg-open", cfile }, { detach = true })
    return
  end

  -- Resolve relative path against the *buffer's* directory, not just CWD.
  local bufdir = vim.fn.expand("%:p:h")
  local candidate = bufdir ~= "" and (bufdir .. "/" .. cfile) or cfile

  -- Normalize to absolute path (collapses '.' and '..', expands '~')
  local abs = vim.fn.fnamemodify(candidate, ":p")

  -- Try to canonicalize (resolve symlinks) if possible; fall back to abs.
  abs = vim.loop.fs_realpath(abs) or abs

  if not vim.loop.fs_stat(abs) then
    vim.notify("Not found: " .. abs, vim.log.levels.ERROR)
    return
  end

  vim.fn.jobstart({ "xdg-open", abs }, { detach = true })
end

-- Diagnostic navigation helper
function M.diagnostic_goto(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end

return M
