return {
  "echasnovski/mini.files",
  opts = {
    windows = {
      preview = true,
    },
    mappings = {
      go_in = "L",
      go_in_plus = "",
      go_out = "H",
      go_out_plus = "",
    },
  },
  keys = {
    {
      "<c-e>",
      function()
        require("mini.files").open(vim.loop.cwd(), true)
      end,
      desc = "Curr File (mini.files)",
    },
    {
      "<c-f>",
      function()
        local mini = require("mini.files")
        local uv = vim.uv or vim.loop
        -- Start from current buffer's file so mini-files opens its parent dir.
        local path = vim.api.nvim_buf_get_name(0)
        -- Buffer may be unnamed or its file may have been deleted;
        -- fall back to last browsed path, then cwd.
        if path == "" or uv.fs_stat(path) == nil then
          local latest_path = mini.get_latest_path()
          if latest_path ~= nil and uv.fs_stat(latest_path) ~= nil then
            path = latest_path
          else
            path = uv.cwd()
          end
        end
        mini.open(path, true)
      end,
      desc = "Files (mini.files)",
    },
  },
  config = function(_, opts)
    local mini_files = require("mini.files")
    local paths = require("core.utils.paths")
    mini_files.setup(opts)

    -- Dotfile toggle
    local show_dotfiles = true
    local filter_show = function()
      return true
    end
    local filter_hide = function(fs_entry)
      return not vim.startswith(fs_entry.name, ".")
    end
    local toggle_dotfiles = function()
      show_dotfiles = not show_dotfiles
      mini_files.refresh({ content = { filter = show_dotfiles and filter_show or filter_hide } })
    end

    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesBufferCreate",
      callback = function(args)
        local buf_id = args.data.buf_id
        vim.keymap.set("n", "g.", toggle_dotfiles, { buffer = buf_id })
        vim.keymap.set("n", "<CR>", function()
          mini_files.go_in({ close_on_file = true })
        end, { buffer = buf_id, desc = "Open entry and close on file" })

        -- mini.files dir buffers are scratch buffers (buftype=nofile), which Vim
        -- refuses to write -> :w errors E382 *before* any BufWriteCmd can fire.
        -- Switch to "acwrite" so :w is routed through our
        -- BufWriteCmd below. bufhidden stays "hide", so column navigation and :q
        -- never trigger an unsaved-changes (E37) prompt.
        vim.bo[buf_id].buftype = "acwrite"

        -- Editor-style :w -> synchronize pending fs edits (native confirm shows only
        -- if pending). Buffer is named minifiles://..., so BufWriteCmd is the
        -- disk-safe way to intercept :w.
        vim.api.nvim_create_autocmd("BufWriteCmd", {
          buffer = buf_id,
          desc = "mini.files: synchronize on :w",
          callback = function()
            mini_files.synchronize()
            -- Cosmetic: mini.files diffs against the fs (not &modified), but clear
            -- the flag so the buffer doesn't look unsaved after a :w.
            pcall(function()
              vim.bo[buf_id].modified = false
            end)
          end,
        })

        -- Detect whether the quit command carried a bang (:q!). `vim.v.cmdbang`
        -- is NOT populated during QuitPre (only for file read/write autocmds),
        -- so capture it from the command line as it is submitted. The last
        -- command line typed in this buffer before QuitPre is the quit itself.
        vim.api.nvim_create_autocmd("CmdlineLeave", {
          buffer = buf_id,
          desc = "mini.files: remember :q vs :q! for QuitPre",
          callback = function()
            if vim.fn.getcmdtype() ~= ":" then
              return
            end
            vim.b[buf_id].minifiles_quit_bang = vim.fn.getcmdline():match("!%s*$") ~= nil
          end,
        })

        -- Editor-style quit:
        --   :q  -> resolve pending changes (native save/discard/cancel prompt),
        --          then close the whole explorer at once.
        --   :q! -> skip the save prompt and fall through to mini.files' own
        --          close() (the "Close without synchronization?" prompt, i.e.
        --          the same behaviour as the default `q` mapping).
        -- The immediate close() avoids waiting for mini.files' ~1s focus-lost
        -- timer (a bare :q otherwise only closes the focused column).
        vim.api.nvim_create_autocmd("QuitPre", {
          buffer = buf_id,
          desc = "mini.files: save prompt + close on :q",
          callback = function()
            local bang = vim.b[buf_id].minifiles_quit_bang
            vim.b[buf_id].minifiles_quit_bang = nil
            if not bang then
              -- synchronize() returns false ONLY on Cancel -> keep editing.
              if mini_files.synchronize() == false then
                return
              end
            end
            -- :q -> pending already resolved (close() is silent).
            -- :q! -> close() shows its own "Close without synchronization?" prompt.
            vim.schedule(function()
              pcall(mini_files.close)
            end)
          end,
        })
      end,
    })

    -- Clean up buffers whose files were deleted via mini-files.
    -- MiniFilesActionDelete fires AFTER the file is removed from disk,
    -- so the buffer is already stale and would trigger E211 on the next
    -- checktime cycle.
    vim.api.nvim_create_autocmd("User", {
      pattern = "MiniFilesActionDelete",
      callback = function(args)
        -- Normalize the deleted path to an absolute canonical form for matching.
        local deleted_path = paths.canonical((args.data or {}).from)
        if not deleted_path then
          return
        end

        -- Collect buffers whose file matches the deleted path exactly,
        -- or lives under it (covers directory deletes wiping children).
        local bufs_to_close = {}
        for _, buf_id in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_valid(buf_id) then
            local buf_name = paths.canonical(vim.api.nvim_buf_get_name(buf_id))
            if buf_name and (buf_name == deleted_path or vim.startswith(buf_name, deleted_path .. "/")) then
              table.insert(bufs_to_close, buf_id)
            end
          end
        end

        if #bufs_to_close == 0 then
          return
        end

        -- Guard must be set synchronously: after this callback returns,
        -- mini-files may close its window which fires BufEnter, triggering
        -- auto_checktime. The guard prevents checktime from running (and
        -- emitting E211) before our scheduled cleanup executes.
        vim.g._mini_files_delete_cleanup = (tonumber(vim.g._mini_files_delete_cleanup) or 0) + 1

        -- Defer actual buffer removal: we're inside mini-files' sync loop,
        -- so modifying buffers/windows synchronously could interfere with its state.
        vim.schedule(function()
          local ok, err = xpcall(function()
            local bufremove = require("mini.bufremove")
            for _, buf_id in ipairs(bufs_to_close) do
              if vim.api.nvim_buf_is_valid(buf_id) then
                -- bufremove.delete unshows the buffer from all windows
                -- (replacing with alternate/previous/scratch), then runs :bdelete.
                -- force=true skips the unsaved-changes prompt (file is gone anyway).
                -- pcall returns (ok, result): ok=false on throw, removed=false/nil
                -- when bufremove can't act (validation failure or plugin disabled).
                local ok_remove, removed = pcall(bufremove.delete, buf_id, true)
                -- Fallback: bwipeout completely purges the buffer from memory.
                if (not ok_remove or not removed) and vim.api.nvim_buf_is_valid(buf_id) then
                  pcall(vim.cmd, ("noautocmd bwipeout! %d"):format(buf_id))
                end
              end
            end
          end, debug.traceback)

          -- Always decrement guard, even on error, to unblock checktime.
          local cleanup_guard = (tonumber(vim.g._mini_files_delete_cleanup) or 1) - 1
          vim.g._mini_files_delete_cleanup = cleanup_guard > 0 and cleanup_guard or 0

          if not ok then
            vim.notify(("mini-files: delete cleanup error: %s"):format(err), vim.log.levels.ERROR)
          end
        end)
      end,
    })
  end,
}
