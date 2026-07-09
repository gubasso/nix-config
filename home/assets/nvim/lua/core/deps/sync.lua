-- Auto-install dependencies for Arch Linux
local uv = vim.uv or vim.loop
local registry = require("core.deps.registry")
local checker = require("core.deps.checker")

local M = {}

-- Detect Linux distribution
function M.get_distro()
  local handle = io.open("/etc/os-release", "r")
  if not handle then
    return nil
  end
  local content = handle:read("*a")
  handle:close()

  local id = content:match("^ID=(%w+)") or content:match("\nID=(%w+)")
  return id
end

-- Check if we're on Arch Linux
function M.is_arch()
  local distro = M.get_distro()
  return distro == "arch" or distro == "archlinux"
end

-- Check if a command exists
local function has_cmd(cmd)
  return vim.fn.executable(cmd) == 1
end

-- Get the package manager to use (prefer paru over pacman)
function M.get_package_manager()
  if has_cmd("paru") then
    return "paru"
  elseif has_cmd("pacman") then
    return "pacman"
  end
  return nil
end

-- Build install command for pacman packages
function M.build_pacman_cmd(packages, pkg_manager)
  if #packages == 0 then
    return nil
  end

  local cmd
  if pkg_manager == "paru" then
    cmd = "paru -S --needed --noconfirm " .. table.concat(packages, " ")
  else
    cmd = "sudo pacman -S --needed --noconfirm " .. table.concat(packages, " ")
  end
  return cmd
end

-- Build install commands for provider hosts
function M.build_provider_cmds(missing_providers)
  local cmds = {}
  for _, provider in ipairs(missing_providers) do
    if provider.install_cmd then
      table.insert(cmds, provider.install_cmd)
    end
  end
  return cmds
end

-- Run sync: check deps and install missing ones
function M.sync(opts)
  opts = opts or {}

  if not M.is_arch() then
    vim.notify("DepsSync only supports Arch Linux", vim.log.levels.ERROR)
    return
  end

  local pkg_manager = M.get_package_manager()
  if not pkg_manager then
    vim.notify("Neither pacman nor paru found", vim.log.levels.ERROR)
    return
  end

  checker.check_all(function(_, exec_results, provider_results)
    local missing_required, missing_optional = checker.get_missing(exec_results, provider_results)
    local all_missing = vim.list_extend(vim.list_extend({}, missing_required), missing_optional)

    -- Collect pacman packages
    local pacman_packages = {}
    local provider_cmds = {}
    local seen = {}

    for _, dep in ipairs(all_missing) do
      if dep.pacman and not seen[dep.pacman] then
        table.insert(pacman_packages, dep.pacman)
        seen[dep.pacman] = true
      elseif dep.install_cmd then
        table.insert(provider_cmds, dep.install_cmd)
      end
    end

    if #pacman_packages == 0 and #provider_cmds == 0 then
      vim.notify("All dependencies already installed!", vim.log.levels.INFO)
      return
    end

    -- Build command list
    local commands = {}
    local pacman_cmd = M.build_pacman_cmd(pacman_packages, pkg_manager)
    if pacman_cmd then
      table.insert(commands, pacman_cmd)
    end
    for _, cmd in ipairs(provider_cmds) do
      table.insert(commands, cmd)
    end

    -- Show what will be installed
    local lines = { "The following will be installed:", "" }
    if #pacman_packages > 0 then
      table.insert(lines, "Pacman packages (" .. pkg_manager .. "):")
      table.insert(lines, "  " .. table.concat(pacman_packages, " "))
      table.insert(lines, "")
    end
    if #provider_cmds > 0 then
      table.insert(lines, "Provider commands:")
      for _, cmd in ipairs(provider_cmds) do
        table.insert(lines, "  " .. cmd)
      end
      table.insert(lines, "")
    end
    table.insert(lines, "Commands to run:")
    for _, cmd in ipairs(commands) do
      table.insert(lines, "  " .. cmd)
    end

    -- Open in terminal if not dry-run
    if opts.dry_run then
      vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "DepsSync (dry run)" })
    else
      -- Open terminal with the install commands
      local full_cmd = table.concat(commands, " && ")
      vim.cmd("new")
      vim.cmd("terminal " .. full_cmd)
      vim.cmd("startinsert")
    end
  end)
end

return M
