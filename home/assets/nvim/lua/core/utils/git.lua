-- Generic git helpers (no plugin dependencies).
-- Used by fugitive.lua review commands and available for reuse elsewhere.

local M = {}

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
