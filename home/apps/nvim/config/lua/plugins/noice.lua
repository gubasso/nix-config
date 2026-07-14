return {
  "folke/noice.nvim",
  event = "VeryLazy",
  opts = {
    cmdline = { enabled = false },
    popupmenu = { backend = "cmp" },
    messages = { enabled = false },
    lsp = {
      progress = { enabled = false },
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true,
      },
      signature = { auto_open = { enabled = false, trigger = false } },
    },
    presets = {
      bottom_search = true,
      command_palette = true,
      long_message_to_split = true,
      inc_rename = true,
      lsp_doc_border = true,
    },
  },
  config = function(_, opts)
    local no = require("noice")
    require("which-key").add({
      {
        "<leader>nl",
        function()
          no.cmd("last")
        end,
        desc = "Noice Last Message",
      },
      {
        "<leader>nh",
        function()
          no.cmd("history")
        end,
        desc = "Noice History",
      },
      {
        "<leader>na",
        function()
          no.cmd("all")
        end,
        desc = "Noice All",
      },
      {
        "<leader>nd",
        function()
          no.cmd("dismiss")
        end,
        desc = "Dismiss All",
      },
      {
        "<S-Enter>",
        function()
          no.redirect(vim.fn.getcmdline())
        end,
        mode = "c",
        desc = "Redirect Cmdline",
      },
    })
    no.setup(opts)
  end,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
}
