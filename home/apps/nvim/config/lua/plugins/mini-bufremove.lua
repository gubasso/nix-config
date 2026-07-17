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
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if buf ~= current and vim.bo[buf].buflisted then
              bufremove.delete(buf, false)
            end
          end
        end,
        desc = "Kill Other Buffers",
      },
    })
  end,
}
