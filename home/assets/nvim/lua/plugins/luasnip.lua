return {
  "L3MON4D3/LuaSnip",
  build = "make install_jsregexp",
  event = "InsertEnter",
  dependencies = {
    "rafamadriz/friendly-snippets",
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
      require("luasnip.loaders.from_lua").lazy_load({
        paths = { vim.fn.stdpath("config") .. "/lua/snippets" },
      })
    end,
  },
  init = function()
    local ls = require("luasnip")
    local wk = require("which-key")

    ls.config.set_config({
      update_events = "TextChanged,TextChangedI",
    })

    wk.add({
      { mode = "i", { "<c-K>", ls.expand, desc = "Expand snippet" } },
      {
        mode = { "i", "s" },
        {
          "<c-N>",
          function()
            ls.jump(1)
          end,
          desc = "Jump snippet forward",
        },
        {
          "<c-P>",
          function()
            ls.jump(-1)
          end,
          desc = "Jump snippet backward",
        },
        {
          "<c-E>",
          function()
            if ls.choice_active() then
              ls.change_choice(1)
            end
          end,
          desc = "Change snippet choice",
        },
      },
    })
  end,
}
