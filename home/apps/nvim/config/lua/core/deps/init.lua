-- Main API for dependency checking
local checker = require("core.deps.checker")
local state = require("core.deps.state")
local ui = require("core.deps.ui")
local sync = require("core.deps.sync")

local M = {}

-- Check if verification has been completed
function M.is_verified()
  return state.is_verified()
end

-- Run full dependency check
-- Options:
--   force: run even if already verified
--   silent: don't show notifications
--   show_all: include found deps in output
--   use_split: show results in split window
function M.check(opts)
  opts = opts or {}

  if not opts.force and state.is_verified() then
    if not opts.silent then
      vim.notify("Dependencies already verified. Use :DepsCheck! to force re-check.", vim.log.levels.INFO)
    end
    return
  end

  checker.check_all(function(all_required_passed, exec_results, provider_results)
    if all_required_passed then
      state.mark_verified()
      if not opts.silent then
        vim.notify("All required dependencies found! State saved.", vim.log.levels.INFO)
      end
    end

    if not opts.silent then
      ui.show_results(exec_results, provider_results, {
        show_all = opts.show_all,
        use_split = opts.use_split,
      })
    end
  end)
end

-- Reset verification state
function M.reset()
  state.reset()
  vim.notify("Dependency verification state reset. Will re-check on next startup.", vim.log.levels.INFO)
end

-- Show current status
function M.status(opts)
  opts = opts or {}

  checker.check_all(function(_, exec_results, provider_results)
    ui.show_results(exec_results, provider_results, {
      show_all = true,
      use_split = opts.use_split ~= false,
    })
  end)
end

-- Run startup check (called from autocmd)
function M.startup_check()
  if state.is_verified() then
    return
  end

  -- Defer to avoid blocking startup
  vim.defer_fn(function()
    M.check({ silent = false, show_all = false })
  end, 100)
end

-- Sync dependencies (Arch Linux only)
function M.sync(opts)
  sync.sync(opts)
end

return M
