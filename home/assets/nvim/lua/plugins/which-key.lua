return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    layout = {
      height = { min = 4, max = 25 },
    },
    -- Keep buffer-local mappings first and groups together.
    -- `order` preserves plugin-generated ranking (notably `z=` spelling suggestions).
    -- Regular keymaps usually have no `order`, so they fall through to `desc` (alphabetical by description).
    sort = { "local", "group", "order", "desc" },
  },
  config = function(_, opts)
    local wk = require("which-key")
    wk.setup(opts)

    -- Groups (presentation layer for which-key popup)
    wk.add({
      { "<leader>b", group = "Buffer" },
      { "<leader>c", group = "Code" },
      { "<leader>e", group = "Explorer" },
      { "<leader>f", group = "Find" },
      { "<leader>h", group = "Harpoon" },
      { "<leader>m", group = "Markdown" },
      { "<leader>mn", group = "Md New" },
      { "<leader>n", group = "Noice" },
      { "<leader>u", group = "Toggle" },
      { "<leader>x", group = "Trouble" },
      { "<leader>z", group = "Zen" },
      { "<leader>g", group = "Git" },
      { "<leader>t", group = "Todo" },
    })

    vim.keymap.set("n", "<leader>?", function()
      require("which-key").show({ global = false })
    end, { desc = "Buffer Local Keymaps (which-key)" })
  end,
}
