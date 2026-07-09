-- Extended checkbox states (SlRvb's ITS Theme conventions)
-- Grouping matters: :Checkbox change moves within a group (X) or between (Y).
-- e.g. on [/], change 1 0 -> [X], change 0 1 -> [<]
--
-- Basic task:     [ ] Unchecked  [/] In progress  [X] Completed
-- Scheduling:     [<] Scheduled  [>] Rescheduled
-- Status:         [?] Question   [!] Important    [*] Star
-- Content:        ["] Quote
-- Markers (lc):   [l] Location   [b] Bookmark     [i] Idea/Info   (*lowercase)
-- Markers (uc):   [S] Savings    [I] Information                  (*uppercase)
-- Arguments:      [p] Pro        [c] Con
-- Task outcomes:  [f] Fire/Urgent  [k] Key point  [w] Win/Success
-- Priority:       [u] Up         [d] Down
return {
  "OXY2DEV/markview.nvim",
  lazy = false,
  keys = {
    { "<leader>mv", "<cmd>Markview toggle<cr>", desc = "Toggle Markview (buffer)" },
    { "<leader>mV", "<cmd>Markview Toggle<cr>", desc = "Toggle Markview (global)" },
    { "<leader>me", "<cmd>Markview enable<cr>", desc = "Enable Markview (buffer)" },
    { "<leader>md", "<cmd>Markview disable<cr>", desc = "Disable Markview (buffer)" },
    { "<leader>mE", "<cmd>Markview Enable<cr>", desc = "Enable Markview (global)" },
    { "<leader>mD", "<cmd>Markview Disable<cr>", desc = "Disable Markview (global)" },
    { "<leader>ms", "<cmd>Markview splitToggle<cr>", desc = "Toggle Markview split" },
    {
      "<leader>mt",
      function()
        vim.b.noborder = not vim.b.noborder
        require("markview").commands.Render()
      end,
      desc = "Toggle table borders",
    },
    { "<leader>mc", "<cmd>Checkbox toggle<cr>", desc = "Toggle checkbox", mode = { "n", "v" } },
    { "<leader>mi", "<cmd>Checkbox interactive<cr>", desc = "Interactive checkbox picker" },
  },
  config = function(_, opts)
    require("markview").setup(opts)
    require("markview.extras.checkboxes").setup()
  end,
  opts = function()
    local presets = require("markview.presets")
    local default_tables = require("markview.config.markdown").tables
    local no_border = presets.tables.none

    return {
      preview = {
        enable = false,
      },
      markdown = {
        headings = presets.headings.numbered,
        list_items = {
          shift_width = function(buffer)
            return vim.bo[buffer].shiftwidth
          end,
        },
        tables = function(buffer)
          if buffer and vim.b[buffer].noborder == true then
            return vim.tbl_deep_extend("force", default_tables, no_border)
          end
          return default_tables
        end,
      },
    }
  end,
}
