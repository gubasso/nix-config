return {
  "WhoIsSethDaniel/toggle-lsp-diagnostics.nvim",
  keys = {
    { "<leader>ul", "<Plug>(toggle-lsp-diag)", desc = "Toggle All Lsp Diag" },
    { "<leader>uL", "<Plug>(toggle-lsp-diag-default)", desc = "Set All Lsp to default" },
    { "<leader>ut", "<Plug>(toggle-lsp-diag-vtext)", desc = "Lsp Vtext Toggle" },
    {
      "<leader>ud",
      function()
        vim.diagnostic.enable()
        require("notify")("Vim Diag Enabled")
      end,
      desc = "On vim diagnostics",
    },
    {
      "<leader>uD",
      function()
        vim.diagnostic.disable()
        require("notify")("Vim Diag Disabled")
      end,
      desc = "Off vim diagnostics",
    },
    {
      "<leader>ui",
      function()
        vim.lsp.inlay_hint(0, nil)
      end,
      desc = "Toggle Inlay Hints",
    },
  },
  config = function()
    require("toggle_lsp_diagnostics").init()
  end,
}
