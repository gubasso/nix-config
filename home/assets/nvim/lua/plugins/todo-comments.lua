return {
  "folke/todo-comments.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = { "BufReadPost", "BufNewFile" },
  config = function()
    local td = require("todo-comments")
    td.setup()
    require("which-key").add({
      { "]t", td.jump_next, desc = "Next todo comment" },
      { "[t", td.jump_prev, desc = "Previous todo comment" },
    })
  end,
}
