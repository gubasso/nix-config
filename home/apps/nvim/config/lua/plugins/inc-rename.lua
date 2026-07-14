return {
  "smjonas/inc-rename.nvim",
  config = function()
    local ic = require("inc_rename")
    local wk = require("which-key")
    wk.add({
      { "<leader>cR", ":IncRename ", desc = "Rename <new_name>`" },
      {
        "<leader>cr",
        function()
          return ":IncRename " .. vim.fn.expand("<cword>")
        end,
        desc = "Rename `curr_name`+<increment>",
        expr = true,
      },
    })
    ic.setup({ input_buffer_type = "dressing" })
  end,
}
