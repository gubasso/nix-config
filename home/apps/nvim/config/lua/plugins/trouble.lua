return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons", "folke/todo-comments.nvim" },
  opts = {
    modes = {
      -- Flat, no-auto-open list used by the fugitive commit-file picker (ctrl-x).
      -- One line per file; nothing opens/previews on cursor move — only on <CR>.
      git_commit_files = {
        source = "qf.qflist", -- read the quickfix list we just populated
        groups = {}, -- flat: no file-header tree grouping
        format = "{file_icon} {text}", -- one line per file (text = the rel path we set)
        auto_preview = false, -- do not open/preview the item on cursor move
        auto_jump = false,
        follow = false,
        focus = true, -- land the cursor in the list to navigate it
      },
    },
  },
  cmd = "Trouble",
  keys = {
    { "<leader>xw", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
    {
      "<leader>xd",
      "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
      desc = "Buffer Diagnostics (Trouble)",
    },
    { "<leader>xcs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
    {
      "<leader>xcl",
      "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
      desc = "LSP Definitions / references / ... (Trouble)",
    },
    { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
    { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
  },
}
