return {
  "echasnovski/mini.bufremove",
  config = function()
    local bufremove = require("mini.bufremove")
    require("which-key").add({
      {
        "<leader>k",
        function()
          bufremove.delete(0, false)
        end,
        desc = "Kill Buffer",
      },
      {
        "<leader>K",
        function()
          local current = vim.api.nvim_get_current_buf()
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
