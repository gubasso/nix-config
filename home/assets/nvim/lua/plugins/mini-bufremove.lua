return {
  "echasnovski/mini.bufremove",
  config = function()
    require("which-key").add({
      {
        "<leader>bd",
        function()
          require("mini.bufremove").delete(0, false)
        end,
        desc = "Buffer Delete",
      },
    })
  end,
}
