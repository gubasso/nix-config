-- Distraction-free editing. Replaces true-zen.nvim (broken on Neovim 0.10/0.11,
-- pocco81/true-zen.nvim#130) and twilight.nvim with one actively-maintained
-- plugin. zen = centered layout; dim = light-focus dimming; two independent keys.
return {
  "folke/snacks.nvim",
  keys = {
    { "<leader>zl", function() Snacks.zen() end, desc = "Zen layout (centered)" },
    { "<leader>zf", function() Snacks.dim() end, desc = "Focus dim" },
  },
  ---@type snacks.Config
  opts = {
    zen = {
      toggles = { dim = false }, -- keep layout and dim independent (no auto-dim)
      show = { statusline = false, tabline = false },
      win = { width = 120 }, -- tune to taste
    },
    dim = {},
  },
}
