-- Dependency check user commands
local deps = require("core.deps")

-- :DepsCheck - Run dependency check (skip if verified)
-- :DepsCheck! - Force re-check even if verified
vim.api.nvim_create_user_command("DepsCheck", function(opts)
  deps.check({
    force = opts.bang,
    show_all = false,
    use_split = false,
  })
end, {
  bang = true,
  desc = "Check system dependencies (! to force re-check)",
})

-- :DepsStatus - Show full status in split window
vim.api.nvim_create_user_command("DepsStatus", function()
  deps.status({ use_split = true })
end, {
  desc = "Show full dependency status in split",
})

-- :DepsReset - Clear verified state
vim.api.nvim_create_user_command("DepsReset", function()
  deps.reset()
end, {
  desc = "Reset dependency verification state",
})

-- :DepsSync - Auto-install missing dependencies (Arch Linux only)
-- :DepsSync! - Dry run (show what would be installed)
vim.api.nvim_create_user_command("DepsSync", function(opts)
  deps.sync({
    dry_run = opts.bang,
  })
end, {
  bang = true,
  desc = "Auto-install missing dependencies (Arch Linux only, ! for dry run)",
})
