-- Single source of truth for colorscheme selection.
-- All themes are declared so they stay in the lockfile on every host.
-- The active theme is determined by hostname; unrecognized hosts get habamax.
local host = require("core.host")

local host_theme = {
  nova = "catppuccin",
  tumblesuse = "everforest",
}
local active = host_theme[host.name] or "habamax"

local function activate(name, spec)
  if name == active then
    spec.lazy = false
    spec.priority = 1000
  else
    spec.lazy = true
  end
  return spec
end

return {
  activate("catppuccin", {
    "catppuccin/nvim",
    name = "catppuccin",
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  }),
  activate("everforest", {
    "neanias/everforest-nvim",
    version = false,
    config = function()
      require("everforest").setup({
        background = "hard",
      })
      vim.cmd.colorscheme("everforest")
    end,
  }),
  activate("zenbones", {
    "zenbones-theme/zenbones.nvim",
    dependencies = "rktjmp/lush.nvim",
    config = function()
      vim.g.zenbones_darken_comments = 45
      vim.o.background = "dark"
      vim.g.zenbones_darkness = "warm"
      vim.cmd.colorscheme("zenbones")
    end,
  }),
}
