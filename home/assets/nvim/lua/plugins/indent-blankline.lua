return {
  "lukas-reineke/indent-blankline.nvim",
  config = function()
    local config = require("ibl.config").default_config
    config.indent.tab_char = config.indent.char
    config.scope.enabled = false
    config.indent.char = "|"
    require("ibl").setup(config)
  end,
}
