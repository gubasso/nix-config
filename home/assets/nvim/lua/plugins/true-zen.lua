return {
  "Pocco81/true-zen.nvim",
  config = function()
    local tz = require("true-zen")
    require("which-key").add({
      {
        "<leader>zn",
        function()
          local first = 0
          local last = vim.api.nvim_buf_line_count(0)
          tz.narrow(first, last)
        end,
        desc = "TZNarrow N",
      },
      { "<leader>zf", tz.focus, desc = "TZFocus" },
      { "<leader>zm", tz.minimalist, desc = "TZMinimalist" },
      { "<leader>za", tz.ataraxis, desc = "TZAtaraxis" },
      {
        "<leader>zn",
        mode = "v",
        function()
          local first = vim.fn.line("v")
          local last = vim.fn.line(".")
          tz.narrow(first, last)
        end,
        desc = "TZNarrow V",
      },
    })
    tz.setup({})
  end,
}
