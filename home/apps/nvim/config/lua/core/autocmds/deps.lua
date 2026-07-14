-- Dependency check on startup (if not already verified)
local api = vim.api

local function augroup(name)
  return api.nvim_create_augroup(name, { clear = true })
end

api.nvim_create_autocmd("VimEnter", {
  group = augroup("deps_check"),
  callback = function()
    vim.schedule(function()
      require("core.deps").startup_check()
    end)
  end,
  desc = "Check system dependencies on startup",
})
