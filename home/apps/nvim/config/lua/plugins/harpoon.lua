return {
  "ThePrimeagen/harpoon",
  dependencies = { "nvim-lua/plenary.nvim", "rcarriga/nvim-notify" },
  keys = {
    {
      "<s-h>",
      function()
        require("harpoon.mark").add_file()
        require("notify")("harpoon added")
      end,
      desc = "add file",
    },
    {
      "<M-1>",
      function()
        require("harpoon.ui").nav_file(1)
      end,
      desc = "Harpoon 1",
    },
    {
      "<M-2>",
      function()
        require("harpoon.ui").nav_file(2)
      end,
      desc = "Harpoon 2",
    },
    {
      "<M-3>",
      function()
        require("harpoon.ui").nav_file(3)
      end,
      desc = "Harpoon 3",
    },
    {
      "<M-4>",
      function()
        require("harpoon.ui").nav_file(4)
      end,
      desc = "Harpoon 4",
    },
    {
      "<M-5>",
      function()
        require("harpoon.ui").nav_file(5)
      end,
      desc = "Harpoon 5",
    },
    {
      "<M-6>",
      function()
        require("harpoon.ui").nav_file(6)
      end,
      desc = "Harpoon 6",
    },
    {
      "<M-7>",
      function()
        require("harpoon.ui").nav_file(7)
      end,
      desc = "Harpoon 7",
    },
    {
      "<M-8>",
      function()
        require("harpoon.ui").nav_file(8)
      end,
      desc = "Harpoon 8",
    },
    {
      "<M-9>",
      function()
        require("harpoon.ui").nav_file(9)
      end,
      desc = "Harpoon 9",
    },
    {
      "<leader>ha",
      function()
        require("harpoon.mark").add_file()
      end,
      desc = "add file",
    },
    {
      "<leader>hh",
      function()
        require("harpoon.ui").toggle_quick_menu()
      end,
      desc = "menu",
    },
    {
      "<leader>hp",
      function()
        require("harpoon.ui").nav_prev()
      end,
      desc = "prev mark",
    },
    {
      "<leader>hn",
      function()
        require("harpoon.ui").nav_next()
      end,
      desc = "next mark",
    },
  },
  opts = {
    menu = {
      width = vim.api.nvim_win_get_width(0) - 4,
    },
  },
}
