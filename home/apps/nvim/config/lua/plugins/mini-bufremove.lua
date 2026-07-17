return {
  "echasnovski/mini.bufremove",
  config = function()
    local bufremove = require("mini.bufremove")
    require("which-key").add({
      {
        "<leader>k",
        function()
          local win = vim.api.nvim_get_current_win()
          local buf = vim.api.nvim_get_current_buf()

          -- If this file is visible in more than one window (splits/tabs showing
          -- the same buffer), kill ONLY this split and leave the buffer -- and
          -- every other window showing it -- untouched. (#win_findbuf > 1
          -- guarantees this isn't the last window, so nvim_win_close can't quit
          -- Neovim.)
          if #vim.fn.win_findbuf(buf) > 1 then
            pcall(vim.api.nvim_win_close, win, false)
            return
          end

          -- This is the buffer's only view: delete it (safe -- force=false prompts
          -- on unsaved changes and returns falsy if declined; declined/invalid =>
          -- leave the layout untouched), then close its split. Since no other
          -- window shows this buffer, nothing else is disturbed. nvim_win_close
          -- errors only on the last window of the last tab -- pcall swallows that
          -- so Neovim stays open showing the alternate buffer instead of quitting.
          -- Closing the sole window of a non-last tab closes that tab.
          local ok, removed = pcall(bufremove.delete, buf, false)
          if not (ok and removed) then
            return
          end
          if vim.api.nvim_win_is_valid(win) then
            pcall(vim.api.nvim_win_close, win, false)
          end
        end,
        desc = "Kill Buffer",
      },
      {
        "<leader>K",
        function()
          local current = vim.api.nvim_get_current_buf()
          local cur_win = vim.api.nvim_get_current_win()

          -- Collapse the current tabpage to a single window: close every other
          -- (non-floating) split, keeping the window we're in. Closing a split
          -- only hides its buffer ('hidden' is on by default), so unsaved work is
          -- kept and is still skipped by the buffer sweep below. Floating windows
          -- (mini.files, noice, etc.) are left alone.
          for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
            if win ~= cur_win and vim.api.nvim_win_is_valid(win) then
              if vim.api.nvim_win_get_config(win).relative == "" then
                pcall(vim.api.nvim_win_close, win, false)
              end
            end
          end

          local closed, skipped = 0, 0
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if buf ~= current and vim.bo[buf].buflisted then
              if vim.bo[buf].modified then
                -- Safe path: never discard unsaved changes.
                skipped = skipped + 1
              else
                -- pcall: bufremove.delete can throw or return false on a
                -- validation failure (see mini-files.lua) — don't let one bad
                -- buffer abort the whole sweep.
                local ok_remove, removed = pcall(bufremove.delete, buf, false)
                if ok_remove and removed then
                  closed = closed + 1
                else
                  skipped = skipped + 1
                end
              end
            end
          end
          local msg = ("Killed %d other buffer(s)"):format(closed)
          if skipped > 0 then
            msg = msg .. (", skipped %d (unsaved/blocked)"):format(skipped)
          end
          vim.notify(msg, vim.log.levels.INFO)
        end,
        desc = "Kill Other Buffers",
      },
    })
  end,
}
