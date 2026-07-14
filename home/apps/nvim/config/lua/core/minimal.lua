-- Minimal core loader for non-primary hosts (containers).
-- Loads sane options + keymaps + subset of autocmds/usercmds.
-- No plugins, no LSP, no treesitter.

vim.g.loaded_perl_provider = 0

require("core.options")
require("core.keymaps")
require("core.autocmds.security")
require("core.autocmds.ux")
require("core.autocmds.minimal-filetypes")
require("core.usercmds.copy_file_path")
require("core.usercmds.md_new").setup()
require("core.usercmds.md_dir_new").setup()
require("core.autocmds.minimal-complete")
