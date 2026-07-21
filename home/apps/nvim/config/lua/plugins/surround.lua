return {
  "kylechui/nvim-surround",
  version = "*",
  event = "VeryLazy",
  config = function()
    require("nvim-surround").setup({
      surrounds = {
        -- Markdown link: `ysiw l` on `word` -> `[word]()`
        ["l"] = {
          add = { "[", "]()" },
          find = "%b[]%b()",
          delete = "^(%[)().-(%]%b())()$",
        },
      },
    })
  end,
}
