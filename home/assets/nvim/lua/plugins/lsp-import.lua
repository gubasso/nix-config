return {
  "stevanmilic/nvim-lspimport",
  keys = {
    {
      "<leader>a",
      function()
        require("lspimport").import()
      end,
      noremap = true,
      desc = "LSP import",
    },
  },
}
