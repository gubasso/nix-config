-- Project-wide todo discovery via fzf-lua + rg
local paths = require("core.utils.paths")

local M = {}

local PRIORITY_ORDER = { high = 1, medium = 2, low = 3, none = 4 }

--- Extract priority from a todo line, e.g. @priority(high) -> "high"
---@param text string
---@return string
local function extract_priority(text)
  local val = text:match("@priority%((%w+)%)")
  if val then
    val = val:lower()
    if PRIORITY_ORDER[val] then
      return val
    end
  end
  return "none"
end

--- Extract group from a todo line, e.g. @group(frontend) -> "frontend"
---@param text string
---@return string
local function extract_group(text)
  local val = text:match("@group%(([^)]+)%)")
  if val then
    val = vim.trim(val)
    if val ~= "" then
      return val
    end
  end
  return "none"
end

--- Extract status from a todo line, e.g. @status(doing) -> "doing"
---@param text string
---@return string
local function extract_status(text)
  local val = text:match("@status%(([^)]+)%)")
  if val then
    val = vim.trim(val)
    if val ~= "" then
      return val
    end
  end
  return "none"
end

--- Format a display entry for the picker
---@param priority string
---@param rel_path string
---@param lnum string
---@param text string
---@return string
local function format_entry(priority, rel_path, lnum, text)
  local tag = ("[%s]"):format(priority:upper())
  return ("%-6s %s:%s  %s"):format(tag, rel_path, lnum, text)
end

--- Parse rg output lines into structured entries
---@param lines string[]
---@param root string
---@return table[]
local function parse_entries(lines, root)
  local entries = {}
  for _, line in ipairs(lines) do
    local path, lnum, text = line:match("^(.-):(.-):(.*)$")
    if path and lnum and text then
      local rel = path
      if root and path:sub(1, #root) == root then
        rel = path:sub(#root + 2)
      end
      local priority = extract_priority(text)
      local group = extract_group(text)
      local status = extract_status(text)
      entries[#entries + 1] = {
        path = path,
        rel_path = rel,
        lnum = lnum,
        text = vim.trim(text),
        priority = priority,
        group = group,
        status = status,
      }
    end
  end
  return entries
end

--- Sort entries: primary by priority rank, secondary by path, tertiary by line
---@param entries table[]
local function sort_by_priority(entries)
  table.sort(entries, function(a, b)
    local pa, pb = PRIORITY_ORDER[a.priority], PRIORITY_ORDER[b.priority]
    if pa ~= pb then
      return pa < pb
    end
    if a.rel_path ~= b.rel_path then
      return a.rel_path < b.rel_path
    end
    return tonumber(a.lnum) < tonumber(b.lnum)
  end)
end

--- Sort entries by path then line number
---@param entries table[]
local function sort_by_path(entries)
  table.sort(entries, function(a, b)
    if a.rel_path ~= b.rel_path then
      return a.rel_path < b.rel_path
    end
    return tonumber(a.lnum) < tonumber(b.lnum)
  end)
end

--- Launch fzf-lua picker with the given entries
---@param entries table[]
---@param prompt_str string
local function show_picker(entries, prompt_str)
  local fzf = require("fzf-lua")
  local display = {}
  local lookup = {}
  for i, e in ipairs(entries) do
    local line = format_entry(e.priority, e.rel_path, e.lnum, e.text)
    display[i] = line
    lookup[line] = e
  end

  fzf.fzf_exec(display, {
    prompt = prompt_str,
    actions = {
      ["default"] = function(selected)
        if not selected or #selected == 0 then
          return
        end
        local entry = lookup[selected[1]]
        if entry then
          vim.cmd("edit +" .. entry.lnum .. " " .. vim.fn.fnameescape(entry.path))
        end
      end,
    },
  })
end

--- Collect todos from the project via rg
---@param filter_priority? string  nil for all, or "high"/"medium"/"low"
---@param callback fun(entries: table[])
local function collect_todos(filter_priority, callback)
  local root = paths.get_project_root(paths.target_dir_for_current_buffer())
  local cmd = {
    "rg",
    "--no-heading",
    "--line-number",
    "--color=never",
    "--glob=*.md",
    [[^\s*(?:[-*+]|\d+[.)])\s+\[.\]\s+]],
    root,
  }

  vim.system(cmd, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 and result.code ~= 1 then
        vim.notify("rg error: " .. (result.stderr or "unknown"), vim.log.levels.WARN)
        return
      end

      local stdout = result.stdout or ""
      if stdout == "" then
        vim.notify("No todos found", vim.log.levels.INFO)
        return
      end

      local lines = vim.split(stdout, "\n", { trimempty = true })
      local entries = parse_entries(lines, root)

      if filter_priority then
        local filtered = {}
        for _, e in ipairs(entries) do
          if e.priority == filter_priority then
            filtered[#filtered + 1] = e
          end
        end
        entries = filtered
      end

      if #entries == 0 then
        vim.notify("No todos found", vim.log.levels.INFO)
        return
      end

      callback(entries)
    end)
  end)
end

function M.setup()
  -- Check rg availability once at setup
  if vim.fn.executable("rg") ~= 1 then
    vim.notify("rg not found", vim.log.levels.WARN)
    return
  end

  vim.api.nvim_create_user_command("TodosAll", function()
    collect_todos(nil, function(entries)
      sort_by_priority(entries)
      show_picker(entries, "All Todos> ")
    end)
  end, { desc = "Browse all project todos via fzf-lua" })

  vim.api.nvim_create_user_command("TodosPriority", function()
    vim.ui.select({ "high", "medium", "low" }, { prompt = "Filter by priority:" }, function(choice)
      if not choice then
        return
      end
      collect_todos(choice, function(entries)
        sort_by_path(entries)
        show_picker(entries, choice:upper() .. " Todos> ")
      end)
    end)
  end, { desc = "Browse project todos filtered by priority" })

  vim.api.nvim_create_user_command("TodosGroup", function()
    collect_todos(nil, function(entries)
      local seen = {}
      local groups = {}
      for _, e in ipairs(entries) do
        if e.group ~= "none" and not seen[e.group] then
          seen[e.group] = true
          groups[#groups + 1] = e.group
        end
      end
      table.sort(groups)

      if #groups == 0 then
        vim.notify("No grouped todos found", vim.log.levels.INFO)
        return
      end

      vim.ui.select(groups, { prompt = "Filter by group:" }, function(choice)
        if not choice then
          return
        end
        local filtered = {}
        for _, e in ipairs(entries) do
          if e.group == choice then
            filtered[#filtered + 1] = e
          end
        end
        sort_by_priority(filtered)
        show_picker(filtered, choice .. " Todos> ")
      end)
    end)
  end, { desc = "Browse project todos filtered by group" })

  vim.api.nvim_create_user_command("TodosStatus", function()
    collect_todos(nil, function(entries)
      local seen = {}
      local statuses = {}
      for _, e in ipairs(entries) do
        if e.status ~= "none" and not seen[e.status] then
          seen[e.status] = true
          statuses[#statuses + 1] = e.status
        end
      end
      table.sort(statuses)

      if #statuses == 0 then
        vim.notify("No status-tagged todos found", vim.log.levels.INFO)
        return
      end

      vim.ui.select(statuses, { prompt = "Filter by status:" }, function(choice)
        if not choice then
          return
        end
        local filtered = {}
        for _, e in ipairs(entries) do
          if e.status == choice then
            filtered[#filtered + 1] = e
          end
        end
        sort_by_priority(filtered)
        show_picker(filtered, choice .. " Todos> ")
      end)
    end)
  end, { desc = "Browse project todos filtered by status" })
end

return M
