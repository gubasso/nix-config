-- Host profile: generic public default.
local hostname = (vim.uv or vim.loop).os_gethostname()

local M = {}

M.name = hostname
M.is_primary = false
M.is_minimal = true

return M
