return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPost", "BufNewFile" },
  keys = {
    {
      "]h",
      function()
        require("gitsigns").nav_hunk("next")
      end,
      desc = "Next Hunk",
    },
    {
      "[h",
      function()
        require("gitsigns").nav_hunk("prev")
      end,
      desc = "Prev Hunk",
    },
    {
      "<leader>gh",
      function()
        require("gitsigns").preview_hunk()
      end,
      desc = "Preview Hunk",
    },
    {
      "<leader>gH",
      function()
        require("gitsigns").preview_hunk_inline()
      end,
      desc = "Preview Hunk Inline",
    },
    {
      "<leader>gd",
      function()
        require("gitsigns").diffthis()
      end,
      desc = "Diff This",
    },
    {
      "<leader>gR",
      function()
        require("gitsigns").reset_hunk()
      end,
      desc = "Reset Hunk",
    },
    {
      "<leader>gS",
      function()
        require("gitsigns").stage_hunk()
      end,
      desc = "Stage Hunk",
    },
    {
      "<leader>gb",
      function()
        require("gitsigns").blame_line()
      end,
      desc = "Blame Line",
    },
  },
  opts = {},
}
