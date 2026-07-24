-- Minimal filetype settings for container hosts.
-- Provides prose wrap+spell without which-key or treesitter dependencies.
-- No lazy.nvim here, so vim-DetectSpellLang is unavailable: spelllang stays a
-- static en_us (no auto-detection, no manual override maps).
local api = vim.api

api.nvim_create_autocmd("FileType", {
  group = api.nvim_create_augroup("minimal_wrap_spell", { clear = true }),
  pattern = { "gitcommit", "markdown", "text", "rst", "asciidoc" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
    vim.opt_local.colorcolumn = ""
  end,
})
