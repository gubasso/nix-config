--       _ ____   _(_)_ __ ___   | |_   _  __ _
--      | '_ \ \ / / | '_ ` _ \  | | | | |/ _` |
--      | | | \ V /| | | | | | |_| | |_| | (_| |
--      |_| |_|\_/ |_|_| |_| |_(_)_|\__,_|\__,_|

pcall(vim.loader.enable)

local host = require("core.host")

if host.is_minimal then
  -- Minimal path: sane options + built-in colorscheme, no plugins.
  vim.g.dotfiles_minimal = true
  require("core.minimal")
  vim.cmd.colorscheme("habamax")
  return
end

-- Full path: lazy.nvim + all plugins for primary hosts.
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("core") -- needs to come first

require("lazy").setup({
  { import = "plugins" },
}, {
  -- Config is deployed read-only into the Nix store, so the lockfile cannot
  -- live in stdpath("config"). Relocate it to the writable state dir; this is
  -- the only file lazy.nvim writes back into the config tree.
  lockfile = vim.fn.stdpath("state") .. "/lazy/lazy-lock.json",
})
