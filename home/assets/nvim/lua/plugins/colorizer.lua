return {
  "brenoprata10/nvim-highlight-colors",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("nvim-highlight-colors").setup({
      render = "background",
      enable_named_colors = true,
      enable_tailwind = true,
      enable_var_usage = true,
      enable_hex = true,
      enable_short_hex = true,
      enable_rgb = true,
      enable_hsl = true,
    })
  end,
}
