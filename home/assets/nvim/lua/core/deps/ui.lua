-- UI/display helpers for dependency check results
local checker = require("core.deps.checker")

local M = {}

-- Format results for display
function M.format_results(exec_results, provider_results, show_all)
  local lines = {}
  local missing_required, missing_optional = checker.get_missing(exec_results, provider_results)
  local found = {}

  -- Collect found deps
  for name, result in pairs(exec_results) do
    if result.found then
      table.insert(found, name)
    end
  end
  for name, result in pairs(provider_results) do
    if result.found then
      table.insert(found, name)
    end
  end
  table.sort(found)

  -- Build output
  if #missing_required > 0 then
    table.insert(lines, "MISSING REQUIRED:")
    for _, dep in ipairs(missing_required) do
      table.insert(lines, string.format("  [X] %s", dep.name))
      table.insert(lines, string.format("      %s", dep.hint))
    end
    table.insert(lines, "")
  end

  if #missing_optional > 0 then
    table.insert(lines, "MISSING OPTIONAL:")
    for _, dep in ipairs(missing_optional) do
      table.insert(lines, string.format("  [ ] %s", dep.name))
      table.insert(lines, string.format("      %s", dep.hint))
    end
    table.insert(lines, "")
  end

  if show_all and #found > 0 then
    table.insert(lines, "FOUND:")
    table.insert(lines, "  " .. table.concat(found, ", "))
    table.insert(lines, "")
  end

  return lines, #missing_required, #missing_optional
end

-- Display results in a floating window or via notify
function M.show_results(exec_results, provider_results, opts)
  opts = opts or {}
  local show_all = opts.show_all or false

  local lines, missing_req, missing_opt = M.format_results(exec_results, provider_results, show_all)

  if #lines == 0 then
    vim.notify("All dependencies verified!", vim.log.levels.INFO)
    return
  end

  -- Determine severity
  local level = vim.log.levels.INFO
  if missing_req > 0 then
    level = vim.log.levels.ERROR
  elseif missing_opt > 0 then
    level = vim.log.levels.WARN
  end

  if opts.use_split then
    -- Open in a scratch buffer
    vim.cmd("new")
    local buf = vim.api.nvim_get_current_buf()
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "wipe"
    vim.bo[buf].swapfile = false
    vim.bo[buf].filetype = "deps-check"
    vim.api.nvim_buf_set_name(buf, "[Dependency Check]")
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false

    -- Add q to close
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
  else
    -- Compact notification
    local title = "Dependency Check"
    if missing_req > 0 then
      title = title .. string.format(" (%d required missing)", missing_req)
    elseif missing_opt > 0 then
      title = title .. string.format(" (%d optional missing)", missing_opt)
    end
    vim.notify(table.concat(lines, "\n"), level, { title = title })
  end
end

return M
