-- Generic public colorscheme selection. Private consumers can overlay this
-- file with host-specific choices.
local active = "habamax"

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
    end,
  }),

  activate("everforest", {
    "neanias/everforest-nvim",
    config = function()
      require("everforest").setup({
        background = "medium",
      })
    end,
  }),
}
