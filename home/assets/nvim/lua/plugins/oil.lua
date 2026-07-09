return {
  "stevearc/oil.nvim",
  opts = {},
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local oil = require("oil")
    require("which-key").add({ { "-", oil.open, desc = "Open parent directory" } })
    local always_hidden = {
      [".git"] = true,
      ["node_modules"] = true,
    }

    oil.setup({
      view_options = {
        show_hidden = true,
        is_always_hidden = function(name)
          return always_hidden[name] or false
        end,
      },
    })
  end,
}
