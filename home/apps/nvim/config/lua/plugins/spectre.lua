return {
  "nvim-pack/nvim-spectre",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    {
      "<leader>cS",
      function()
        require("spectre").toggle()
      end,
      desc = "Spectre Toggle",
    },
    {
      "<leader>cw",
      function()
        require("spectre").open_visual({ select_word = true })
      end,
      desc = "Spectre Search current word",
    },
    {
      "<leader>cw",
      function()
        require("spectre").open_visual({ select_word = true })
      end,
      desc = "Spectre Search current word",
      mode = "v",
    },
    {
      "<leader>c/",
      function()
        require("spectre").open_file_search({ select_word = true })
      end,
      desc = "Spectre Search on current file",
    },
  },
}
