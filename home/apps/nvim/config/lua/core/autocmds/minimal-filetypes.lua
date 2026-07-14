-- Minimal filetype settings for container hosts.
-- Provides markdown/gitcommit wrap+spell without which-key or treesitter dependencies.
local api = vim.api

api.nvim_create_autocmd("FileType", {
  group = api.nvim_create_augroup("minimal_wrap_spell", { clear = true }),
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
    vim.opt_local.colorcolumn = ""
  end,
})
