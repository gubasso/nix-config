-- Core checking logic for dependencies
local uv = vim.uv or vim.loop
local registry = require("core.deps.registry")

local M = {}

-- Check if executable exists in PATH (synchronous, fast)
local function executable_exists(name)
  return vim.fn.executable(name) == 1
end

-- Run a shell command asynchronously and return result via callback
local function async_cmd(cmd, callback)
  local stdout = uv.new_pipe(false)
  local stderr = uv.new_pipe(false)

  local handle
  handle = uv.spawn("sh", {
    args = { "-c", cmd },
    stdio = { nil, stdout, stderr },
  }, function(code)
    stdout:close()
    stderr:close()
    handle:close()
    vim.schedule(function()
      callback(code == 0)
    end)
  end)

  if not handle then
    vim.schedule(function()
      callback(false)
    end)
  end
end

-- Check all executables (sync, very fast - just checks PATH)
function M.check_executables()
  local results = {}
  for _, dep in ipairs(registry.executables) do
    results[dep.name] = {
      found = executable_exists(dep.name),
      required = dep.required,
      hint = dep.hint,
      pacman = dep.pacman,
    }
  end
  return results
end

-- Check provider hosts asynchronously
-- Calls callback(results) when all checks complete
function M.check_providers(callback)
  local results = {}
  local pending = #registry.provider_hosts

  if pending == 0 then
    callback(results)
    return
  end

  for _, provider in ipairs(registry.provider_hosts) do
    async_cmd(provider.check_cmd, function(success)
      results[provider.name] = {
        found = success,
        required = false,
        hint = provider.hint,
        install_cmd = provider.install_cmd,
        pacman = provider.pacman,
      }
      pending = pending - 1
      if pending == 0 then
        callback(results)
      end
    end)
  end
end

-- Full check: executables (sync) + providers (async)
-- Calls callback(all_required_passed, exec_results, provider_results)
function M.check_all(callback)
  local exec_results = M.check_executables()

  M.check_providers(function(provider_results)
    local all_required_passed = true

    for _, result in pairs(exec_results) do
      if result.required and not result.found then
        all_required_passed = false
        break
      end
    end

    callback(all_required_passed, exec_results, provider_results)
  end)
end

-- Get lists of missing dependencies
function M.get_missing(exec_results, provider_results)
  local missing_required = {}
  local missing_optional = {}

  for name, result in pairs(exec_results) do
    if not result.found then
      if result.required then
        table.insert(missing_required, { name = name, hint = result.hint, pacman = result.pacman })
      else
        table.insert(missing_optional, { name = name, hint = result.hint, pacman = result.pacman })
      end
    end
  end

  for name, result in pairs(provider_results) do
    if not result.found then
      table.insert(missing_optional, {
        name = name,
        hint = result.hint,
        install_cmd = result.install_cmd,
        pacman = result.pacman,
      })
    end
  end

  table.sort(missing_required, function(a, b)
    return a.name < b.name
  end)
  table.sort(missing_optional, function(a, b)
    return a.name < b.name
  end)

  return missing_required, missing_optional
end

return M
