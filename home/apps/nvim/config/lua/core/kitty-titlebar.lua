-- Kitty tab bar integration: publish structured nvim state to the custom tab bar
-- (kitty/.config/kitty/tab_bar.py) via kitty user vars, and set the window/OS title
-- to a clean project label so the raw protocol never leaks into the WM bar (DWM).

local opt = vim.opt

local git = require("core.utils.git")
local paths = require("core.utils.paths")

local kitty_mode_map = {
  n = "N",
  no = "N",
  nov = "N",
  noV = "N",
  ["no\22"] = "N",
  niI = "N",
  niR = "N",
  niV = "N",
  nt = "N",
  v = "V",
  vs = "V",
  V = "VL",
  Vs = "VL",
  ["\22"] = "VB",
  ["\22s"] = "VB",
  s = "S",
  S = "SL",
  ["\19"] = "SB",
  i = "I",
  ic = "I",
  ix = "I",
  R = "R",
  Rc = "R",
  Rx = "R",
  Rv = "VR",
  Rvc = "VR",
  Rvx = "VR",
  c = "C",
  cv = "EX",
  r = "P",
  rm = "M",
  ["r?"] = "CF",
  ["!"] = "SH",
  t = "T",
}

local function kitty_mode_label()
  return kitty_mode_map[vim.api.nvim_get_mode().mode] or "?"
end

-- Project label for the tab "name", mirroring rename_tab_from_cwd.py: the last
-- two segments of the cwd (parent/dir), or the single segment / "/" at the root.
-- Uses Neovim's cwd, which is the project root when nvim is launched there.
-- Emitted as the trailing protocol field; empty means "no label" (renderer then
-- falls back to the filename).
local function kitty_cwd_label()
  return paths.parent_leaf(vim.fn.getcwd()) or ""
end

-- Repo-wide status string for the tab bar. Parse + cache live in core.utils.git
-- (shared with the fugitive winbar); this renders the starship-style compact form.
local function kitty_git_status(root)
  return git.format_status(git.status_summary(root))
end

-- ── Data channel: publish status as kitty user vars (OSC 1337) ───────────────
-- Mirrors the shell producer's KITTY_SHELL_* vars (92-kitty-titlebar.bash) so the
-- custom tab bar (tab_bar.py) renders nvim state without the protocol ever riding
-- the window title -- which kitty would forward to the OS/X11 title and leak into
-- the WM bar (e.g. DWM). Values are base64-encoded; an empty value unsets the var.
local KITTY_NVIM_VARS = {
  marker = "KITTY_NVIM",
  mode = "KITTY_NVIM_MODE",
  branch = "KITTY_NVIM_BRANCH",
  diff = "KITTY_NVIM_DIFF",
  status = "KITTY_NVIM_STATUS",
  file = "KITTY_NVIM_FILE",
  modified = "KITTY_NVIM_MODIFIED",
  pct = "KITTY_NVIM_PCT",
}

-- Last value sent per var; change-detection keeps frequent events (cursor moves)
-- cheap -- usually only the scroll% var is re-sent.
local last_emitted = {}

local function kitty_osc_setvar(name, value)
  return ("\027]1337;SetUserVar=%s=%s\007"):format(name, vim.base64.encode(value))
end

local function emit_var(name, value)
  value = value or ""
  if last_emitted[name] == value then
    return
  end
  -- nvim_ui_send routes to the attached UI (kitty) -- the forked-TUI-safe path that
  -- Neovim core itself uses for OSC sequences (see runtime osc52.lua). Cache only on
  -- success so a send issued before the UI attaches is retried on the next event.
  local ok = pcall(vim.api.nvim_ui_send, kitty_osc_setvar(name, value))
  if ok then
    last_emitted[name] = value
  end
end

local function emit_vars()
  local buf = vim.api.nvim_get_current_buf()
  local mode = kitty_mode_label()

  local branch = ""
  local diff = ""
  local gs = vim.b[buf].gitsigns_status_dict
  if gs then
    branch = gs.head or ""
    local parts = {}
    if (gs.added or 0) > 0 then
      parts[#parts + 1] = "+" .. gs.added
    end
    if (gs.changed or 0) > 0 then
      parts[#parts + 1] = "~" .. gs.changed
    end
    if (gs.removed or 0) > 0 then
      parts[#parts + 1] = "-" .. gs.removed
    end
    diff = table.concat(parts, " ")
  end

  -- Repo-wide git status (cached shell-out)
  local root = (gs and gs.root) or ""
  if root == "" then
    local path = vim.api.nvim_buf_get_name(buf)
    if path ~= "" then
      if vim.fs.root then
        root = vim.fs.root(path, ".git") or ""
      else
        local gitdir = vim.fn.finddir(".git", vim.fn.fnamemodify(path, ":p:h") .. ";")
        if gitdir ~= "" then
          root = vim.fn.fnamemodify(gitdir, ":h")
        end
      end
    end
  end
  local git_st = kitty_git_status(root)

  local file = vim.fn.expand("%:t")
  if file == "" then
    file = "[No Name]"
  end

  local modified = vim.bo[buf].modified and "[+]" or ""

  local line = vim.fn.line(".")
  local total = vim.fn.line("$")
  local pct
  if total <= 1 or line == 1 then
    pct = "Top"
  elseif line == total then
    pct = "Bot"
  else
    pct = math.floor(line * 100 / total) .. "%"
  end

  emit_var(KITTY_NVIM_VARS.marker, "1")
  emit_var(KITTY_NVIM_VARS.mode, mode)
  emit_var(KITTY_NVIM_VARS.branch, branch)
  emit_var(KITTY_NVIM_VARS.diff, diff)
  emit_var(KITTY_NVIM_VARS.status, git_st)
  emit_var(KITTY_NVIM_VARS.file, file)
  emit_var(KITTY_NVIM_VARS.modified, modified)
  emit_var(KITTY_NVIM_VARS.pct, pct)
end

local function clear_vars()
  for _, name in pairs(KITTY_NVIM_VARS) do
    emit_var(name, "")
  end
end

-- A newly attached UI holds none of our user vars, and nvim_ui_send() reports
-- success even when it reached no stdout-TTY UI -- so any values "sent" before the
-- UI attached were cached in last_emitted without ever being delivered. Drop the
-- cache on UIEnter so the first post-attach emit_vars() re-sends the full set.
local function emit_vars_on_ui_attach()
  for k in pairs(last_emitted) do
    last_emitted[k] = nil
  end
  emit_vars()
end

-- ── Display channel: window/OS title is just the project label ───────────────
-- External programs that read the X11 window title (e.g. DWM's bar) show this;
-- the rich status travels via user vars only.
function _G._kitty_label()
  local label = kitty_cwd_label()
  if label == "" then
    return "nvim"
  end
  return label
end

-- Disable Neovim's native status UI; the kitty tab bar provides mode, position, etc.
opt.laststatus = 0
opt.showmode = false
opt.ruler = false

opt.title = true
opt.titlelen = 0
opt.titlestring = "%{v:lua._kitty_label()}"

-- Publish status user vars on state-relevant events; clear them on exit so the shell
-- (resuming in the same kitty window) cleanly takes over the tab bar.
local augroup = vim.api.nvim_create_augroup("kitty_titlebar", { clear = true })
vim.api.nvim_create_autocmd("UIEnter", {
  group = augroup,
  callback = emit_vars_on_ui_attach,
})
vim.api.nvim_create_autocmd({
  "VimEnter",
  "ModeChanged",
  "CursorMoved",
  "CursorMovedI",
  "TextChanged",
  "TextChangedI",
  "BufEnter",
  "BufWinEnter",
  "BufWritePost",
  "DirChanged",
  "WinEnter",
  "FocusGained",
}, {
  group = augroup,
  callback = emit_vars,
})
vim.api.nvim_create_autocmd("VimLeavePre", {
  group = augroup,
  callback = clear_vars,
})
