return {
  "akinsho/git-conflict.nvim",
  version = "*",
  keys = {
    { "<leader>co", "<cmd>GitConflictChooseOurs<CR>", desc = "Choose Ours" },
    { "<leader>ct", "<cmd>GitConflictChooseTheirs<CR>", desc = "Choose Theirs" },
    { "<leader>cb", "<cmd>GitConflictChooseBoth<CR>", desc = "Choose Both" },
    { "<leader>c0", "<cmd>GitConflictChooseNone<CR>", desc = "Choose None" },
    { "]x", "<cmd>GitConflictNextConflict<CR>", desc = "Next Conflict" },
    { "[x", "<cmd>GitConflictPrevConflict<CR>", desc = "Previous Conflict" },
    { "<leader>cl", "<cmd>GitConflictListQf<CR>", desc = "List Conflicts in Quickfix" },
  },
  config = function()
    require("git-conflict").setup({
      default_mappings = false,
    })
  end,
}
