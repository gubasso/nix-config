-- UX improvements: Quality of life autocmds
local api = vim.api
local fn = vim.fn

local function augroup(name)
  return api.nvim_create_augroup(name, { clear = true })
end

-- Close certain filetypes with <q>
api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "PlenaryTestPopup",
    "help",
    "lspinfo",
    "man",
    "notify",
    "qf",
    "spectre_panel",
    "startuptime",
    "tsplayground",
    "neotest-output",
    "checkhealth",
    "neotest-summary",
    "neotest-output-panel",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", function()
      if #api.nvim_tabpage_list_wins(0) > 1 then
        vim.cmd("close")
      else
        vim.cmd("bdelete")
      end
    end, { buffer = event.buf, silent = true })
  end,
})

-- Focus / checktime behavior (File auto-reload mechanism)
api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI", "TermClose", "TermLeave" }, {
  group = augroup("auto_checktime"),
  callback = function()
    -- Guard set synchronously by mini-files delete handler; prevents
    -- checktime from seeing stale buffers before scheduled cleanup runs.
    if (tonumber(vim.g._mini_files_delete_cleanup) or 0) > 0 then
      return
    end
    if fn.getcmdwintype() ~= "" then
      return
    end
    local mode = api.nvim_get_mode().mode
    if mode:match("^[cr!t]") then
      return
    end

    -- Safety net: catch files deleted outside mini-files (shell, git, etc).
    -- Scope: only normal file buffers (buftype=""), with a name on disk,
    -- that are NOT modified and are known to have been on disk at least
    -- once (_file_backed). The _file_backed guard prevents new-file buffers
    -- (`:e newfile`, MdNew, MdDirNew) from being misclassified as stale.
    -- The modified guard prevents discarding unsaved edits on deleted files.
    local buf = api.nvim_get_current_buf()
    if vim.bo[buf].buftype == "" then
      local name = api.nvim_buf_get_name(buf)
      if
        name ~= ""
        and not vim.bo[buf].modified
        and vim.b[buf]._file_backed
        and (vim.uv or vim.loop).fs_stat(name) == nil
      then
        -- Buffer points to a file that no longer exists on disk.
        -- Remove it before checktime can see it and emit E211.
        local ok_mini, mini_br = pcall(require, "mini.bufremove")
        local ok_remove, removed = false, false
        if ok_mini then
          ok_remove, removed = pcall(mini_br.delete, buf, true)
        end
        if not ok_remove or not removed then
          pcall(vim.cmd, ("noautocmd bwipeout! %d"):format(buf))
        end
        -- Skip checktime this cycle; next trigger (BufEnter into the
        -- replacement buffer) will run it normally with the stale buffer gone.
        return
      end
    end

    vim.cmd("checktime")
  end,
})

-- Mark buffers that are known to be backed by files on disk.
local file_backed_group = augroup("file_backed_mark")

api.nvim_create_autocmd("BufReadPost", {
  group = file_backed_group,
  callback = function(event)
    vim.b[event.buf]._file_backed = true
  end,
})

api.nvim_create_autocmd("BufWritePost", {
  group = file_backed_group,
  callback = function(event)
    if vim.bo[event.buf].buftype == "" and api.nvim_buf_get_name(event.buf) ~= "" then
      vim.b[event.buf]._file_backed = true
    end
  end,
})

-- Highlight on yank
api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Resize splits on VimResized
-- Ensures split windows are kept evenly sized when UI size changes
api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- Go to last location when opening a buffer
api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function()
    local exclude = { "gitcommit" }
    local buf = api.nvim_get_current_buf()
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) then
      return
    end
    local mark = api.nvim_buf_get_mark(buf, '"')
    local lcount = api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto create directory when saving a file
api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    local match = event and event.match or ""
    if match:match("^%w%w+://") then
      return
    end
    local file = vim.loop.fs_realpath(match) or match
    fn.mkdir(fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Refresh terminal title when gitsigns updates branch/diff metadata.
api.nvim_create_autocmd("User", {
  group = augroup("kitty_title_refresh"),
  pattern = "GitSignsUpdate",
  callback = function()
    vim.cmd.redraw()
  end,
})

-- Refresh terminal title on mode changes (for kitty right-side mode segment).
api.nvim_create_autocmd("ModeChanged", {
  group = augroup("kitty_title_mode_refresh"),
  callback = function()
    vim.cmd.redraw()
  end,
})

-- Refresh terminal title after writes/focus (git status may have changed).
api.nvim_create_autocmd({ "BufWritePost", "FocusGained" }, {
  group = augroup("kitty_title_git_refresh"),
  callback = function()
    vim.cmd.redraw()
  end,
})
