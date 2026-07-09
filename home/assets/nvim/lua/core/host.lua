-- Host profile: single source of truth for hostname-based configuration.
local hostname = (vim.uv or vim.loop).os_gethostname()

local primary_hosts = {
  nova = true,
  tumblesuse = true,
}

local M = {}

M.name = hostname
M.is_primary = primary_hosts[hostname] == true
M.is_minimal = not M.is_primary

return M
