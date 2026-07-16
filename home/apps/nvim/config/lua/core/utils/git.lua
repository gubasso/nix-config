-- Generic git helpers (no plugin dependencies).
-- Used by fugitive.lua review commands and available for reuse elsewhere.

local M = {}

-- Repo-wide status summary (porcelain v2), cached briefly so repeated callers
-- (kitty tab bar on every event, fugitive winbar on every redraw) share one
-- shell-out per repo rather than one each.
local status_cache = { root = "", ts = 0, summary = nil }

--- Repo-wide git status summary for `root`. Returns a structured table
--- `{ ahead, behind, stashed, dirty }`; all zero/false on an empty root or any
--- git failure. Cached for 2s per root. This is the single source of truth for
--- the compact status shown in the kitty tab bar and the fugitive winbar.
function M.status_summary(root)
  local empty = { ahead = 0, behind = 0, stashed = 0, dirty = false }
  if not root or root == "" then
    return empty
  end

  local uv = vim.uv or vim.loop
  local now = uv.hrtime()
  if status_cache.root == root and status_cache.summary and (now - status_cache.ts) < 2e9 then
    return status_cache.summary
  end

  local out = vim.fn.systemlist({ "git", "-C", root, "status", "--porcelain=2", "--branch" })
  if vim.v.shell_error ~= 0 then
    status_cache = { root = root, ts = now, summary = empty }
    return empty
  end

  local ahead, behind, dirty = 0, 0, false
  for _, line in ipairs(out) do
    if vim.startswith(line, "# branch.ab ") then
      local a, b = line:match("^# branch%.ab %+(%d+) %-(%d+)$")
      ahead = tonumber(a) or 0
      behind = tonumber(b) or 0
    elseif not vim.startswith(line, "#") then
      dirty = true
    end
  end

  -- Stash check (refs/stash missing = no stashes = non-zero exit).
  local stash_out = vim.fn.systemlist({
    "git",
    "-C",
    root,
    "rev-list",
    "--walk-reflogs",
    "--count",
    "refs/stash",
  })
  local stashed = (vim.v.shell_error == 0 and stash_out[1]) and (tonumber(stash_out[1]) or 0) or 0

  local summary = { ahead = ahead, behind = behind, stashed = stashed, dirty = dirty }
  status_cache = { root = root, ts = now, summary = summary }
  return summary
end

--- Render a status summary into the compact string matching starship.toml
--- [git_status]: `*` dirty, `⇡N` ahead, `⇣N` behind, `≡` stash (individual
--- indicators are zero-width otherwise). Pure — no I/O. Empty string when clean.
function M.format_status(summary)
  if not summary then
    return ""
  end
  local parts = {}
  if summary.dirty then
    parts[#parts + 1] = "*"
  end
  if summary.ahead > 0 then
    parts[#parts + 1] = "⇡" .. summary.ahead
  end
  if summary.behind > 0 then
    parts[#parts + 1] = "⇣" .. summary.behind
  end
  if summary.stashed > 0 then
    parts[#parts + 1] = "≡"
  end
  return table.concat(parts, "")
end

--- Run a git shell command and return the first line of stdout, or nil on
--- failure / empty output. Useful for single-value git queries like
--- `git rev-parse HEAD`.
function M.first_line(cmd)
  local output = vim.fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 then
    return nil
  end
  local line = output[1]
  if not line or line == "" then
    return nil
  end
  return line
end

--- Return true if `ref` resolves to an existing commit object.
--- The `^{commit}` peel ensures tags and other indirections are dereferenced.
function M.ref_exists(ref)
  local rev = vim.fn.shellescape(ref .. "^{commit}")
  return M.first_line("git rev-parse --verify --quiet " .. rev .. " 2>/dev/null") ~= nil
end

--- Determine the base branch for a review diff.
--- Resolution order:
---   1. Current branch's @{upstream} (e.g. origin/feature → its tracking branch)
---   2. origin/HEAD (the remote's default branch)
---   3. First existing ref from a common-name fallback list
--- Returns the branch name as a string, or nil if nothing is found.
function M.resolve_base_branch()
  -- 1. Tracking branch (most specific — honours per-branch config)
  local upstream = M.first_line("git rev-parse --abbrev-ref --symbolic-full-name @{upstream} 2>/dev/null")
  if upstream then
    return upstream
  end

  -- 2. Remote default branch (works even on detached HEAD / new branches)
  local origin_head = M.first_line("git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null")
  if origin_head then
    return origin_head:gsub("^refs/remotes/", "")
  end

  -- 3. Common branch names as last resort
  for _, ref in ipairs({ "origin/main", "origin/master", "main", "master", "develop" }) do
    if M.ref_exists(ref) then
      return ref
    end
  end

  return nil
end

return M
