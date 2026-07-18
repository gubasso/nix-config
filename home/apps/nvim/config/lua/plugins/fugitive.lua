-- vim-fugitive config with custom git-review commands.
--
-- Adds a "review mode" workflow on top of fugitive: pick a base branch,
-- then diff/browse/quickfix all changes between that base and HEAD.
-- Gitsigns gutters are repointed to the same base so inline indicators
-- match the review scope.
--
-- Lazy-loaded via `cmd` (fugitive + GitReview* stubs) and `keys`.
-- On first trigger lazy.nvim loads the plugin, runs config(), which
-- replaces the stubs with real user commands.
--
-- Keymaps (global):
--   <leader>gg  :Git prompt        <leader>gs  status (split)
--   gs          status (full win)  <leader>gp  push    <leader>gP  pull
--   gs/<leader>gs reuse the existing persistent status buffer (cursor preserved,
--   like :b#) when one exists, falling back to a fresh :0Git/:Git otherwise.
--   <leader>gl  log                <leader>gL  log --oneline
--   <leader>gc  file commits (full win)     <leader>gC  file commits (split)
--               (oneline by default; :GitFileLog[!] full for verbose messages)
--   <leader>gv  diff file (staged+unstaged)
--   <leader>gV  diff file (staged) <leader>gu  diff file (unstaged)
--
-- Keymaps (fugitive/git buffers):
--   <CR>  open entry / fzf commit picker    o  open in split
--   In the commit picker: <CR> opens the working file(s) (current state, no diff),
--     ctrl-y the diff at the commit, ctrl-x sends the selection to a Trouble list
--     (multi-select with <Tab>, select-all with <A-a>).
--   q     close window                      f  commit file list (name+status)
--   (  )  previous/next item (fugitive-native; replaced the deprecated <C-P>/<C-N>,
--         whose nag maps we drop so <C-p> stays "Find Files" here too)
--   The status buffer is normalized to a persistent listed buffer (bufhidden=hide),
--   so leaving via <CR> and returning with <leader><tab> (:b#) keeps it around.
--   On re-entry it auto-refreshes (FugitiveDidChange) and fugitive repositions the
--   cursor near the same entry — fresh content with the cursor where you left it,
--   like a normal buffer that updated while inactive.
--   File history (<leader>gc/gC) buffers are normal listed buffers, so <leader><tab>
--   (:b#), :bnext, and buffer pickers navigate them. In a file-log buffer: <CR>
--   diffs the file at the commit (full window), o in a split; the diff header matches
--   the log format (oneline, or full message when opened with `full`). In that diff:
--   <CR> opens the working file (full window), o in a split; <leader><tab> returns
--   to the diff.
--
-- Review commands (base auto-detected: @{upstream} → origin/HEAD → fallbacks):
--   <leader>gB  :GitReviewBase [ref]  set/detect review base
--   <leader>gr  :GitReviewDiff        full diff base...HEAD
--   <leader>gF  :GitReviewFiles       fzf picker of changed files
--   <leader>gQ  :GitReviewQf          gitsigns hunks → quickfix
--   <leader>gX  :GitReviewReset       clear base, restore gitsigns

-- Helpers ─────────────────────────────────────────────────────────────────────

local git = require("core.utils.git")
local nvfzf = require("core.utils.fzf")
local paths = require("core.utils.paths")

--- Trigger Fugitive's native <CR> action (stage/unstage, open file, etc.).
--- Uses synchronous execute/normal instead of feedkeys — see keymap comment.
local function fugitive_open_entry()
  vim.cmd([[execute "normal \<Plug>fugitive:\<CR>"]])
end

--- Find the loaded fugitive status (index) buffer for the current repo, if any.
--- FugitiveGitDir() identifies the repo; matching it keeps multi-repo sessions
--- correct. Returns the bufnr or nil.
local function find_status_buffer()
  local git_dir = vim.fn.FugitiveGitDir()
  if git_dir == "" then
    return nil
  end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if
      vim.api.nvim_buf_is_loaded(buf)
      and vim.b[buf].fugitive_type == "index"
      and vim.fn.FugitiveGitDir(buf) == git_dir
    then
      return buf
    end
  end
  return nil
end

--- Show the repo's status buffer, reusing the existing persistent index buffer
--- when one exists. :buffer switches without re-rendering, so the cursor/view
--- are preserved exactly like :b# (the BufEnter→FugitiveDidChange autocmd then
--- refreshes content and repositions near the same entry). Falls back to
--- fugitive's :Git/:0Git when no status buffer exists yet. `split` opens in a
--- horizontal split; otherwise it replaces the current window.
---
--- Rationale: :0Git/:Git :edit the fugitive:// buffer and re-render from scratch,
--- so StageSeek resets the cursor to the top. :buffer avoids that re-render.
local function open_status(split)
  local buf = find_status_buffer()
  if buf then
    vim.cmd(split and ("split | buffer " .. buf) or ("buffer " .. buf))
  else
    vim.cmd(split and "Git" or "0Git")
  end
end

--- Resolve a commit-picker entry (repo-relative path) to an absolute working-tree
--- path. Returns nil if it can't resolve or the file is not readable now
--- (deleted/renamed since the commit) — "current state" only applies to files
--- that still exist in the working tree.
local function resolve_worktree_file(rel)
  local root = vim.fn.FugitiveWorkTree()
  if root == "" then
    root = git.first_line("git rev-parse --show-toplevel")
  end
  if not root or root == "" then
    return nil
  end
  local abs = root .. "/" .. rel
  if vim.fn.filereadable(abs) == 0 then
    return nil
  end
  return abs
end

--- Open a list of repo-relative files (current working state) in a Trouble panel
--- via the quickfix list. Skips files missing from the working tree.
local function open_files_in_trouble(rel_files)
  local items = {}
  for _, rel in ipairs(rel_files) do
    local abs = resolve_worktree_file(rel)
    if abs then
      items[#items + 1] = { filename = abs, lnum = 1, col = 1, text = rel }
    end
  end
  if #items == 0 then
    vim.notify("No selected files exist in the working tree", vim.log.levels.WARN)
    return
  end
  vim.fn.setqflist(items, "r")
  local ok = pcall(function()
    require("trouble").open({ mode = "git_commit_files" })
  end)
  if not ok then
    vim.cmd("Trouble git_commit_files") -- fallback to the command form
  end
end

--- Open an fzf-lua picker listing all files touched by a commit. Multi-select is
--- enabled (<Tab> toggles, <A-a> toggles all). Actions:
---   <CR>    open the working file(s), current state, no diff
---   ctrl-y  diff the highlighted file at the commit (:0Git show, full window)
---   ctrl-x  open the selected files (current state) in a Trouble list
local function open_commit_picker(sha)
  require("fzf-lua").fzf_exec("git diff-tree --no-commit-id -r --name-only " .. sha, {
    prompt = sha:sub(1, 7) .. " files> ",
    fzf_opts = { ["--multi"] = true },
    previewer = nvfzf.cmd_previewer(function(file)
      return "git show " .. sha .. " -- " .. vim.fn.shellescape(file)
    end, "git"),
    actions = {
      -- <CR>: open the working file(s), current state, no diff. The first opens
      -- in the current window (edit); the rest load as listed buffers (badd) so
      -- they're browsable (<leader><tab>, pickers) without stealing the window.
      ["default"] = function(selected)
        if not selected or #selected == 0 then
          return
        end
        local opened = 0
        for _, rel in ipairs(selected) do
          local abs = resolve_worktree_file(rel)
          if abs then
            vim.cmd((opened == 0 and "edit " or "badd ") .. vim.fn.fnameescape(abs))
            opened = opened + 1
          end
        end
        if opened == 0 then
          vim.notify("Selected file(s) not in working tree", vim.log.levels.WARN)
        end
      end,
      -- ctrl-y: diff of the highlighted file at this commit (previous default).
      -- NOT ctrl-d: the global keymap.fzf binds ctrl-d=half-page-down, which fzf-lua
      -- emits as an fzf `--bind`; that scroll bind wins over a same-key action, so a
      -- ctrl-d action never fires here. ctrl-y is unbound globally, so it's clean.
      ["ctrl-y"] = function(selected)
        if not selected or not selected[1] then
          return
        end
        vim.cmd("0Git show " .. sha .. " -- " .. vim.fn.fnameescape(selected[1]))
      end,
      -- ctrl-x: open selected files (current state) in a Trouble list.
      ["ctrl-x"] = function(selected)
        if not selected or #selected == 0 then
          return
        end
        open_files_in_trouble(selected)
      end,
    },
  })
end

--- In the fugitive status buffer, return the abbreviated SHA on the current
--- line if the cursor is on an unpushed-commit entry, otherwise nil.
local function extract_commit_under_cursor()
  if vim.b.fugitive_type ~= "index" then
    return nil
  end
  local line = vim.api.nvim_get_current_line()
  local sha = line:match("^%s*([0-9a-fA-F]+)")
  if not sha or #sha < 7 or #sha > 40 then
    return nil
  end
  return sha
end

--- Extract a commit SHA from a git-log output line.
--- Handles both verbose ("commit <sha>") and oneline/graph formats.
local function extract_git_log_sha(line)
  -- verbose format: "commit <sha>" (possibly with graph chars)
  local sha = line:match("[*| ]*commit%s+([0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]%x*)")
  if not sha then
    -- oneline / decorated format: SHA at start of line (possibly indented)
    sha = line:match("^%s*([0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]%x*)%s")
  end
  return sha
end

-- File history ──────────────────────────────────────────────────────────────
-- A "file log" is a `:Git log --follow -- <file>` pager buffer (filetype=git)
-- scoped to one file. The <CR>/o overrides below detect that scope and diff THAT
-- file at the commit under the cursor, instead of opening the whole commit object
-- (fugitive's native behavior). The scoped file is tagged on the buffer via
-- vim.b.git_file_log_path; a file-diff buffer is tagged with vim.b.git_review_diff
-- and vim.b.git_review_file (the working file to open from it).
--
-- These buffers are normalized (see below) into ordinary listed, persistent
-- buffers, so <leader><tab> (:b#), :bnext, and buffer pickers all work naturally.

--- Make a fugitive review pager buffer a normal, persistent, listed buffer so
--- ordinary navigation (<leader><tab>=:b#, :bnext, buffer pickers) works. Fugitive
--- defaults these to bufhidden=delete + unlisted (ephemeral) — we don't want that.
local function normalize_review_buffer()
  vim.bo.bufhidden = "hide"
  vim.bo.buflisted = true
end

--- Thin accessor for the current buffer's file-log scope; returns (path, oneline)
--- or nil. Buffers persist (bufhidden=hide), so the buffer vars are reliable.
local function get_file_log_scope()
  return vim.b.git_file_log_path, vim.b.git_file_log_oneline
end

--- Open the current file's commit history in a fugitive pager buffer.
--- `full` opens in the current window (`0Git`, per open_commit_picker above);
--- otherwise the default split. `oneline` shows one line per commit (default);
--- pass false for the verbose medium format (full commit messages).
local function open_file_log(full, oneline)
  local file = vim.fn.expand("%:p")
  if file == "" then
    vim.notify("No file for log", vim.log.levels.WARN)
    return
  end
  local cmd = full and "0Git log" or "Git log"
  if oneline then
    cmd = cmd .. " --oneline"
  end
  vim.cmd(cmd .. " --follow -- " .. vim.fn.fnameescape(file))
  -- Tag the resulting log buffer so <CR>/o diff THIS file, not the whole commit,
  -- and remember the format so the diff matches (oneline header vs full message).
  vim.b.git_file_log_path = file
  vim.b.git_file_log_oneline = oneline
  normalize_review_buffer()
end

--- In a file-log buffer, diff the scoped file at the commit under the cursor.
--- `split` opens a split; otherwise the current window (`0Git`). The diff header
--- mirrors the log format: oneline (`--oneline`, no full message) or verbose.
local function show_file_at_commit(split)
  local file, oneline = get_file_log_scope()
  if not file then
    return
  end
  local sha = extract_git_log_sha(vim.api.nvim_get_current_line())
  if not sha then
    fugitive_open_entry() -- non-commit line: fall back to native behavior
    return
  end
  local cmd = split and "Git show" or "0Git show"
  if oneline then
    cmd = cmd .. " --oneline"
  end
  vim.cmd(cmd .. " " .. sha .. " -- " .. vim.fn.fnameescape(file))
  normalize_review_buffer()
  -- Tag the diff so its <CR>/o open the real working file (not fugitive's blob).
  vim.b.git_review_file = file
  vim.b.git_review_diff = true
end

--- From a review diff buffer, open the scoped WORKING file (editable) rather than
--- fugitive's read-only index blob. The diff stays the window's alternate, so
--- <leader><tab> (:b#) toggles back to it naturally.
local function open_review_working_file(split)
  local file = vim.b.git_review_file
  if not file or file == "" then
    fugitive_open_entry() -- fallback to native behavior
    return
  end
  vim.cmd((split and "split " or "edit ") .. vim.fn.fnameescape(file))
end

-- Review state ────────────────────────────────────────────────────────────────
-- The review base is stored in vim.g.git_review_base (session-global).
-- It persists until explicitly reset or until Neovim exits.

--- Return the current review base, auto-resolving on first call.
local function get_review_base()
  local base = vim.g.git_review_base
  if base and base ~= "" then
    return base
  end
  base = git.resolve_base_branch()
  if base then
    vim.g.git_review_base = base
  end
  return base
end

--- Point gitsigns gutters at the merge-base of `base` and HEAD so that
--- inline +/- indicators reflect the review scope, not just uncommitted edits.
local function sync_gitsigns_base(base)
  local ok, gs = pcall(require, "gitsigns")
  if not ok then
    return false
  end

  local quoted_base = vim.fn.shellescape(base)
  local merge_base = git.first_line("git merge-base " .. quoted_base .. " HEAD 2>/dev/null")
  if not merge_base then
    vim.notify("Unable to compute merge-base for " .. base, vim.log.levels.WARN)
    return false
  end

  local changed = pcall(gs.change_base, merge_base, true)
  if not changed then
    vim.notify("Unable to set gitsigns review base", vim.log.levels.WARN)
    return false
  end

  return true
end

--- Reset gitsigns back to its default base (HEAD).
local function reset_gitsigns_base()
  local ok, gs = pcall(require, "gitsigns")
  if not ok then
    return false
  end
  local reset = pcall(gs.change_base, nil, true)
  if not reset then
    vim.notify("Unable to reset gitsigns base", vim.log.levels.WARN)
    return false
  end
  return true
end

--- Build a three-dot revspec suitable for `git diff` / `git log`.
local function review_revspec(base)
  return base .. "...HEAD"
end

--- Validate and store a new review base; sync gitsigns to match.
local function set_review_base(base)
  if not git.ref_exists(base) then
    vim.notify("Invalid review base: " .. base, vim.log.levels.WARN)
    return false
  end
  vim.g.git_review_base = base
  sync_gitsigns_base(base)
  vim.notify("Git review base: " .. base, vim.log.levels.INFO)
  return true
end

--- Return the review base after verifying it still exists.
--- Auto-resolves on first call; notifies and returns nil on failure.
local function ensure_review_base()
  local base = get_review_base()
  if not base then
    vim.notify("Unable to resolve review base branch", vim.log.levels.WARN)
    return nil
  end
  if not git.ref_exists(base) then
    vim.notify("Saved review base no longer exists: " .. base, vim.log.levels.WARN)
    return nil
  end
  sync_gitsigns_base(base)
  return base
end

-- Review UI ───────────────────────────────────────────────────────────────────

--- fzf-lua picker of files changed between base and HEAD.
--- Selecting a file opens it (if it exists on disk) or shows the diff.
local function open_review_file_picker(base)
  local revspec = review_revspec(base)
  local revspec_quoted = vim.fn.shellescape(revspec)
  require("fzf-lua").fzf_exec("git diff --name-only " .. revspec_quoted, {
    prompt = base .. "...HEAD files> ",
    previewer = nvfzf.cmd_previewer(function(file)
      return "git diff " .. revspec_quoted .. " -- " .. vim.fn.shellescape(file)
    end, "diff"),
    actions = {
      ["default"] = function(selected)
        if not selected or not selected[1] then
          return
        end
        local path = selected[1]
        if vim.fn.filereadable(path) == 1 then
          vim.cmd("edit " .. vim.fn.fnameescape(path))
        else
          vim.cmd("Git diff " .. revspec_quoted .. " -- " .. vim.fn.shellescape(path))
        end
      end,
    },
  })
end

--- Open a full stat+patch diff of base...HEAD in a fugitive buffer.
local function open_review_diff()
  local base = ensure_review_base()
  if not base then
    return
  end
  local escaped_base = vim.fn.fnameescape(review_revspec(base))
  vim.cmd("Git diff --stat --patch " .. escaped_base)
end

--- Populate the quickfix list with all gitsigns hunks (review-scoped).
local function open_review_qf()
  local base = ensure_review_base()
  if not base then
    return
  end

  local ok, gs = pcall(require, "gitsigns")
  if not ok then
    vim.notify("gitsigns is unavailable", vim.log.levels.WARN)
    return
  end

  local listed = pcall(gs.setqflist, "all")
  if not listed then
    vim.notify("Unable to populate quickfix from gitsigns", vim.log.levels.WARN)
  end
end

-- User commands ───────────────────────────────────────────────────────────────
-- Registered in config() to replace lazy.nvim cmd-stubs on first load.
-- pcall(del) + create avoids "command already exists" errors when re-sourcing.

local function create_review_commands()
  local function create(name, opts, fn)
    pcall(vim.api.nvim_del_user_command, name)
    vim.api.nvim_create_user_command(name, fn, opts)
  end

  -- :GitReviewBase [ref]  — set (or auto-detect) the review base branch
  create("GitReviewBase", { nargs = "?" }, function(opts)
    local base = opts.args
    if base == "" then
      vim.g.git_review_base = nil
      base = git.resolve_base_branch()
      if not base then
        vim.notify("Unable to resolve review base branch", vim.log.levels.WARN)
        return
      end
    end
    set_review_base(base)
  end)

  -- :GitReviewDiff  — open full diff (stat + patch) against base
  create("GitReviewDiff", {}, function()
    open_review_diff()
  end)

  -- :GitReviewFiles  — fzf picker of changed files
  create("GitReviewFiles", {}, function()
    local base = ensure_review_base()
    if not base then
      return
    end
    open_review_file_picker(base)
  end)

  -- :GitReviewQf  — gitsigns hunks → quickfix list
  create("GitReviewQf", {}, function()
    open_review_qf()
  end)

  -- :GitReviewReset  — clear review base and restore default gitsigns
  create("GitReviewReset", {}, function()
    vim.g.git_review_base = nil
    reset_gitsigns_base()
    vim.notify("Git review base reset", vim.log.levels.INFO)
  end)

  -- :GitFileLog[!] [full]  — current file's commit history.
  -- bang = split (else full window); arg "full" = verbose messages (else oneline).
  create("GitFileLog", {
    bang = true,
    nargs = "?",
    complete = function()
      return { "full" }
    end,
  }, function(opts)
    open_file_log(not opts.bang, opts.args ~= "full")
  end)
end

-- Status-buffer auto-refresh + cursor persistence ───────────────────────────────
-- Fugitive's status buffer defaults to bufhidden=delete (ephemeral, unlisted);
-- combined with the <CR> mapping closing the status window, it gets wiped on
-- switch and the cursor resets to the top on return. We normalize it to a
-- persistent listed buffer (bufhidden=hide, like normalize_review_buffer does
-- for pager buffers) so :b#/<leader><tab> return to the same buffer.
--
-- We deliberately do NOT winsaveview()/winrestview() the cursor. Fugitive already
-- does something better on its own: when the index buffer is persistent, its
-- internal `s:ReloadStatusBuffer` saves the entry under the cursor (section +
-- filename + hunk offset via s:StageInfo), regenerates the buffer, then re-finds
-- that entry (s:StageSeek) — content-aware repositioning that follows the file
-- even if lines moved. Raw winrestview() restores a stale line/col and clobbers
-- that, so we leave cursor placement to fugitive.

--- Make the fugitive status (index) buffer persistent + listed so it survives a
--- window close / buffer switch (and fugitive's own reload can reposition the
--- cursor across refreshes).
local function normalize_status_buffer()
  if vim.b.fugitive_type ~= "index" then
    return
  end
  vim.bo.bufhidden = "hide"
  vim.bo.buflisted = true
end

--- Normalize the status buffer and force a refresh whenever we re-enter it, so
--- it behaves like a normal buffer that updated while inactive: fresh content +
--- cursor near where we left it.
local function setup_status_cursor_restore()
  local group = vim.api.nvim_create_augroup("fugitive_status_view", { clear = true })

  -- Fugitive fires `User FugitiveIndex` for the status/index buffer on (re)render.
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "FugitiveIndex",
    callback = normalize_status_buffer,
  })

  -- On returning to the status buffer, force a refresh via fugitive's public
  -- FugitiveDidChange() (→ s:ReloadStatusBuffer → s:StageSeek), which re-renders
  -- the index and repositions the cursor near the same logical entry. Deferred so
  -- the buffer has finished entering; current-buf guard avoids refreshing a
  -- buffer we've already left.
  --
  -- ALTERNATIVE (lighter): drop this BufEnter autocmd entirely. Fugitive has its
  -- own `BufEnter index,index.lock,fugitive://*//` → s:ReloadWinStatus autocmd
  -- that reloads only when the repo changed since the last render (reltime-gated)
  -- and repositions the cursor the same way. That avoids an unconditional
  -- `git status` per entry, but only refreshes after a FugitiveDidChange event
  -- fired (fugitive staging, file writes, FocusGained) — external `git` in a
  -- terminal without refocusing Neovim can leave it stale. We force-refresh here
  -- for normal-buffer-like reliability; swap to the native path if the extra
  -- `git status` per entry is noticeable.
  vim.api.nvim_create_autocmd("BufEnter", {
    group = group,
    pattern = "fugitive://*",
    callback = function(args)
      if vim.b[args.buf].fugitive_type ~= "index" then
        return
      end
      vim.schedule(function()
        if vim.api.nvim_get_current_buf() == args.buf then
          pcall(vim.fn.FugitiveDidChange) -- forces reload + content-aware reposition
        end
      end)
    end,
  })
end

--- Fugitive binds its own buffer-local <C-P>/<C-N> in the status buffer (see
--- autoload/fugitive.vim `s:Map` for '<C-P>'/'<C-N>') to move to the previous/next
--- item, but their only job now is to echo the nag
--- `CTRL-P is deprecated in favor of (` / `CTRL-N is deprecated in favor of )` —
--- tpope replaced item navigation with `(` and `)`. Those buffer-local maps also
--- shadow our global <C-p> -> fzf Find Files inside the status buffer (a
--- buffer-local map wins over a global one), so ctrl-p behaves inconsistently
--- there. Drop them so <C-p> falls through to Find Files uniformly; `(` / `)`
--- still navigate items.
---
--- Hooked to `User FugitiveIndex` (not a one-shot FileType) because fugitive
--- re-installs these maps on every status re-render (they live inside
--- `fugitive#BufReadStatus`), so a single deletion would return after the first
--- FugitiveDidChange refresh. Deletion is scheduled so it always runs after
--- fugitive has (re)installed the maps for the current render.
local function setup_drop_deprecated_nav_maps()
  local group = vim.api.nvim_create_augroup("fugitive_drop_ctrl_nav", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "FugitiveIndex",
    callback = function()
      if vim.b.fugitive_type ~= "index" then
        return
      end
      local buf = vim.api.nvim_get_current_buf()
      vim.schedule(function()
        if not vim.api.nvim_buf_is_valid(buf) then
          return
        end
        pcall(vim.keymap.del, "n", "<C-p>", { buffer = buf })
        pcall(vim.keymap.del, "n", "<C-n>", { buffer = buf })
      end)
    end,
  })
end

--- Fugitive object buffers (blobs, commits, and the transient buffers native
--- <CR> routes through after `=` inline-diff expansion) default to
--- bufhidden=delete, so :b# can land on a wiped buffer and render blank
--- (neovim/neovim#27286). Forcing bufhidden=hide keeps them loaded. Mirrors the
--- upstream recommendation in tpope/vim-fugitive#1880.
--- https://github.com/tpope/vim-fugitive/discussions/1880
local function setup_fugitive_object_persistence()
  local group = vim.api.nvim_create_augroup("fugitive_object_persist", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "FugitiveObject",
    callback = function()
      vim.bo.bufhidden = "hide"
    end,
  })
end

-- Status-buffer winbar header ───────────────────────────────────────────────────
-- Fugitive's status buffer opens with the branch (Head:/Push:/Pull:) at the top,
-- but never shows WHICH project you're in. This adds a lean, theme-following winbar
-- as a one-look overview, prioritised: project (parent/leaf) > git status summary
-- (starship vocabulary, shared with the kitty tab bar) > branch (muted, redundant,
-- dropped first when narrow).

--- Truncate to `max` display cells (char-safe, not byte-based), appending "…".
local function winbar_truncate(s, max)
  if vim.fn.strchars(s) <= max then
    return s
  end
  return vim.fn.strcharpart(s, 0, max - 1) .. "…"
end

--- Wrap `text` in a winbar highlight group (statusline-format), resetting after.
local function winbar_seg(hl, text)
  return "%#" .. hl .. "#" .. text .. "%*"
end

--- Winbar highlights, linked to semantic groups so they follow the active
--- colorscheme. Re-run on ColorScheme (see setup_status_winbar) to stay fresh.
local function setup_winbar_highlights()
  local set = vim.api.nvim_set_hl
  set(0, "FugitiveWinbarProject", { link = "Directory" })
  set(0, "FugitiveWinbarDirty", { link = "WarningMsg" })
  set(0, "FugitiveWinbarAhead", { link = "diffAdded" })
  set(0, "FugitiveWinbarBehind", { link = "DiagnosticInfo" })
  set(0, "FugitiveWinbarStash", { link = "Comment" })
  set(0, "FugitiveWinbarBranch", { link = "Comment" })
  set(0, "FugitiveWinbarDelim", { link = "NonText" })
end

--- Global render function for the winbar `%{%v:lua.FugitiveWinbar()%}` expression.
--- Must be global: v:lua cannot call `require(...).fn()`. Re-evaluated on every
--- redraw, so it stays responsive to window resize (which FugitiveIndex does not
--- fire on). Reads the stable identity vars set on FugitiveIndex off the *drawn*
--- window's buffer (via g:statusline_winid, not 0), plus the live cached git
--- summary for the volatile counts.
function _G.FugitiveWinbar()
  local winid = vim.g.statusline_winid
  local valid = winid and winid ~= 0 and vim.api.nvim_win_is_valid(winid)
  local buf = valid and vim.api.nvim_win_get_buf(winid) or vim.api.nvim_get_current_buf()

  local project = vim.b[buf].winbar_project
  if not project or project == "" then
    return ""
  end
  local root = vim.b[buf].winbar_root or ""
  local branch = vim.b[buf].winbar_branch or ""
  local width = valid and vim.api.nvim_win_get_width(winid) or vim.o.columns

  local summary = git.status_summary(root)

  -- Status cluster: tight starship-style concatenation, each part coloured.
  local status = {}
  if summary.dirty then
    status[#status + 1] = winbar_seg("FugitiveWinbarDirty", "*")
  end
  if summary.ahead > 0 then
    status[#status + 1] = winbar_seg("FugitiveWinbarAhead", "⇡" .. summary.ahead)
  end
  if summary.behind > 0 then
    status[#status + 1] = winbar_seg("FugitiveWinbarBehind", "⇣" .. summary.behind)
  end
  if summary.stashed > 0 then
    status[#status + 1] = winbar_seg("FugitiveWinbarStash", "≡")
  end
  local status_str = table.concat(status, "")

  -- Groups joined by wider gaps: project (protected) > status > branch (first to
  -- drop). project ≥ (any width) · status ≥ 50 · branch ≥ 80.
  local groups = { winbar_seg("FugitiveWinbarProject", width < 50 and winbar_truncate(project, 24) or project) }
  if width >= 50 and status_str ~= "" then
    groups[#groups + 1] = status_str
  end
  if width >= 80 and branch ~= "" then
    groups[#groups + 1] = winbar_seg("FugitiveWinbarBranch", winbar_truncate(branch, 30))
  end

  -- Curly-brace frame (muted), centred across the window via the statusline `%=`
  -- split trick (`%=…%=` distributes free space equally on both sides).
  local content = winbar_seg("FugitiveWinbarDelim", "{ ")
    .. table.concat(groups, "   ")
    .. winbar_seg("FugitiveWinbarDelim", " }")
  return "%=" .. content .. "%="
end

--- Attach the winbar to fugitive index buffers. On FugitiveIndex (guarded to the
--- index buffer, like normalize_status_buffer) we cache identity vars and set the
--- window's winbar; a BufWinEnter/BufEnter guard clears our winbar from any window
--- that later shows a non-index buffer (winbar is window-local and would otherwise
--- leave a blank reserved row). Highlights are (re)linked on ColorScheme.
local function setup_status_winbar()
  setup_winbar_highlights()
  local hl_group = vim.api.nvim_create_augroup("fugitive_winbar_hl", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = hl_group,
    callback = setup_winbar_highlights,
  })

  local group = vim.api.nvim_create_augroup("fugitive_winbar", { clear = true })

  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "FugitiveIndex",
    callback = function()
      if vim.b.fugitive_type ~= "index" then
        return
      end
      local wt = vim.fn.FugitiveWorkTree()
      local project = (wt ~= "" and paths.parent_leaf(wt)) or nil
      vim.b.winbar_root = wt
      vim.b.winbar_project = project
      vim.b.winbar_branch = vim.fn.FugitiveHead()
      vim.wo.winbar = project and "%{%v:lua.FugitiveWinbar()%}" or ""
    end,
  })

  -- Drop a leaked winbar when a non-index buffer enters a window that had ours.
  vim.api.nvim_create_autocmd({ "BufWinEnter", "BufEnter" }, {
    group = group,
    callback = function(args)
      if vim.b[args.buf].fugitive_type == "index" then
        return -- the FugitiveIndex handler owns setting it
      end
      local wb = vim.wo.winbar
      if type(wb) == "string" and wb:find("FugitiveWinbar", 1, true) then
        vim.wo.winbar = ""
      end
    end,
  })
end

-- Plugin spec ─────────────────────────────────────────────────────────────────

return {
  "tpope/vim-fugitive",
  cmd = {
    "Git",
    "G",
    "GitReviewBase",
    "GitReviewDiff",
    "GitReviewFiles",
    "GitReviewQf",
    "GitReviewReset",
    "GitFileLog",
  },
  -- Auto-open the :Git status buffer as the entrypoint when nvim is launched
  -- bare (no args) inside a git repo. In `init` (not `config`) so it registers
  -- at startup even though the plugin is lazy; vim.cmd.Git() then triggers the
  -- `cmd` lazy-load above.
  init = function()
    local group = vim.api.nvim_create_augroup("fugitive_startup", { clear = true })

    -- StdinReadPre fires only when data is piped in (`cmd | nvim`, `nvim -`);
    -- mark it so the VimEnter handler bails. kitty-scrollback does NOT use stdin.
    vim.api.nvim_create_autocmd("StdinReadPre", {
      group = group,
      callback = function()
        vim.g.started_with_stdin = true
      end,
    })

    vim.api.nvim_create_autocmd("VimEnter", {
      group = group,
      desc = "Open fugitive :Git status on bare launch in a git repo",
      callback = function()
        -- 1. Exclude kitty-scrollback (launches nvim bare, argc 0). Decisive
        --    guard; argc/stdin do NOT catch it (env set by the kitten).
        if vim.env.KITTY_SCROLLBACK_NVIM then
          return
        end
        -- 2. Any file/dir arg (`nvim <file>`, `nvim .`, git's COMMIT_EDITMSG,
        --    rebase-todo) -> leave alone. `nvim .` is handled by yazi.
        if vim.fn.argc() > 0 then
          return
        end
        -- 3. Piped stdin (`cmd | nvim`).
        if vim.g.started_with_stdin then
          return
        end
        -- 4. Must be inside a git repo. vim.fs.find matches BOTH a `.git` dir and
        --    a `.git` file (worktrees/submodules), unlike finddir(); no subprocess.
        if vim.tbl_isempty(vim.fs.find(".git", { upward = true, path = vim.fn.getcwd() })) then
          return
        end
        -- Defer so startup settles and fugitive lazy-loads cleanly. Use
        -- `Git ++curwin` (NOT `0Git`): fugitive opens the summary full-window
        -- only when curwin is true (autoload/fugitive.vim: s:StatusCommand ->
        -- :edit vs keepalt split). The `0` count sets curwin only when fugitive
        -- is already loaded; here it lazy-loads via lazy.nvim's `cmd` stub, which
        -- re-executes the command WITHOUT the count, so `0Git` degrades to a
        -- split. `++curwin` is an argument (survives the lazy re-exec) and forces
        -- curwin=true -> full current window. The helper isn't reused here: at
        -- VimEnter fugitive isn't loaded, so its FugitiveGitDir() lookup would
        -- error, and no status buffer exists yet.
        vim.schedule(function()
          vim.cmd("Git ++curwin")
        end)
      end,
    })
  end,
  config = function()
    create_review_commands()
    setup_status_cursor_restore()
    setup_drop_deprecated_nav_maps()
    setup_fugitive_object_persistence()
    setup_status_winbar()
  end,
  -- Lazy-load: plugin is loaded only when one of these keymaps is pressed.
  keys = {
    -- Global (trigger lazy-loading)
    { "<leader>gg", ":Git ", desc = "Git Command" },
    -- Reuse the existing persistent status buffer (cursor preserved, like :b#)
    -- when one exists; fall back to a fresh :Git/:0Git on first open.
    {
      "<leader>gs",
      function()
        open_status(true)
      end,
      desc = "Git Status (split window)",
    },
    {
      "gs",
      function()
        open_status(false)
      end,
      desc = "Git Status (current window)",
    },
    { "<leader>gp", "<cmd>Git push<CR>", desc = "Git Push" },
    { "<leader>gP", "<cmd>Git pull<CR>", desc = "Git Pull" },
    { "<leader>gL", "<cmd>Git log<CR>", desc = "Git Log" },
    { "<leader>gl", "<cmd>Git log --oneline<CR>", desc = "Git Log (oneline)" },
    -- Per-file commit history (filetype=git pager). <CR>/o diff the file at a commit.
    { "<leader>gc", "<cmd>GitFileLog<CR>", desc = "Git File Commits (full window)" },
    { "<leader>gC", "<cmd>GitFileLog!<CR>", desc = "Git File Commits (split)" },
    -- Three diff variants for the current file (%).
    -- HEAD includes both staged and unstaged changes; --cached is staged only;
    -- bare `diff` is unstaged only. Each pipes to :only for full-screen view.
    { "<leader>gv", ":Git diff HEAD -- % | only<CR>", desc = "Git Diff (current file, staged + unstaged)" },
    { "<leader>gV", ":Git diff --cached -- % | only<CR>", desc = "Git Diff (current file, staged only)" },
    { "<leader>gu", ":Git diff -- % | only<CR>", desc = "Git Diff (current file, unstaged only)" },
    { "<leader>gr", "<cmd>GitReviewDiff<CR>", desc = "Git Review Diff" },
    { "<leader>gF", "<cmd>GitReviewFiles<CR>", desc = "Git Review Files" },
    { "<leader>gQ", "<cmd>GitReviewQf<CR>", desc = "Git Review QF" },
    { "<leader>gB", "<cmd>GitReviewBase<CR>", desc = "Git Review Base" },
    { "<leader>gX", "<cmd>GitReviewReset<CR>", desc = "Git Review Reset" },

    -- Buffer-local (ft-scoped, managed by lazy.nvim)

    -- <CR>: Use native Fugitive navigation (opens file at correct line from
    -- inline diff hunk lines, file entries, etc.). On unpushed commit lines,
    -- intercept abbreviated SHAs that Fugitive cannot resolve and open the
    -- fzf-lua file picker for the commit instead.
    -- Use synchronous execute/normal rather than feedkeys: feedkeys is
    -- asynchronous and something in the Neovim->Vimscript handoff causes
    -- s:StageInfo() to see the wrong cursor state, producing the
    -- fugitive root buffer (fugitive:///.../.git//) instead of the file.
    --
    -- For git log / output buffers: Fugitive's built-in <CR> (s:cfile)
    -- requires the cursor to be on a full 40-char SHA -- abbreviated SHAs
    -- from modern `git log` are not recognized by the positive-match branch
    -- (fugitive.vim:8211). The cword fallback at :8287 also fails when the
    -- cursor is not on the SHA token. This override extracts the SHA from
    -- anywhere on the line and opens the fzf-lua file picker for the commit.
    -- Falls back to Fugitive's native <Plug>fugitive:<CR> for non-commit lines.
    {
      "<CR>",
      function()
        if get_file_log_scope() then
          show_file_at_commit(false) -- <CR>: file diff at commit in a full window
          return
        end
        if vim.b.git_review_diff then
          open_review_working_file(false) -- <CR>: working file, full window
          return
        end
        if vim.bo.filetype == "fugitive" then
          local sha = extract_commit_under_cursor()
          if sha then
            open_commit_picker(sha)
            return
          end
          local status_buf = vim.api.nvim_get_current_buf()
          local win = vim.api.nvim_get_current_win()
          fugitive_open_entry()
          vim.schedule(function()
            -- After `=` inline-diff expansion, fugitive's native <CR> can route
            -- through a transient fugitive object buffer that becomes the
            -- window's alternate (#); :b# then reloads that wiped/unlisted
            -- buffer and renders blank (https://github.com/neovim/neovim/issues/27286).
            -- Re-point the alternate at the status buffer so <leader><tab> (:b#)
            -- reliably returns to it.
            if vim.api.nvim_get_current_buf() ~= status_buf then
              local name = vim.api.nvim_buf_get_name(status_buf)
              if name ~= "" then
                pcall(vim.cmd, "balt " .. vim.fn.fnameescape(name))
              end
            end
            -- Fugitive may open a split to keep status visible; close the old
            -- status window so <CR> always lands in a full-window file view.
            if vim.api.nvim_get_current_win() ~= win and vim.api.nvim_win_is_valid(win) then
              pcall(vim.api.nvim_win_close, win, false)
            end
          end)
        else -- git log / output buffer
          local sha = extract_git_log_sha(vim.api.nvim_get_current_line())
          if sha then
            open_commit_picker(sha)
          else
            fugitive_open_entry()
          end
        end
      end,
      ft = { "fugitive", "git" },
      desc = "Open fugitive entry or commit diff",
    },

    -- o: Open entry in a split while keeping fugitive visible.
    -- In a file-log buffer (filetype=git, tagged), diff the file at the commit
    -- in a split instead of opening the whole commit object.
    {
      "o",
      function()
        if get_file_log_scope() then
          show_file_at_commit(true) -- o: file diff at commit in a split
          return
        end
        if vim.b.git_review_diff then
          open_review_working_file(true) -- o: working file in a split
          return
        end
        local sha = extract_commit_under_cursor()
        if sha then
          open_commit_picker(sha)
          return
        end
        vim.cmd.split()
        fugitive_open_entry()
      end,
      ft = { "fugitive", "git" },
      desc = "Open fugitive entry (split)",
    },

    {
      "q",
      function()
        if #vim.api.nvim_tabpage_list_wins(0) > 1 then
          vim.api.nvim_win_close(0, false)
        else
          vim.cmd.bdelete()
        end
      end,
      ft = "fugitive",
      desc = "Close fugitive window",
    },

    {
      "f",
      function()
        local sha = extract_commit_under_cursor()
        if not sha then
          vim.notify("No commit hash under cursor", vim.log.levels.INFO)
          return
        end
        vim.cmd("Git show --name-status --format= " .. sha)
      end,
      ft = "fugitive",
      desc = "Commit files list (name+status)",
    },
  },
}
