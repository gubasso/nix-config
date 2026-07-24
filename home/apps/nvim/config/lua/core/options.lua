local opt = vim.opt

vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.g.markdown_recommended_style = 0 -- Fix markdown indentation settings

-- Disable built-in netrw; yazi.nvim is the file explorer (open_for_directories)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

opt.autowrite = true -- Enable auto write
opt.completeopt = "menu,menuone,noselect"
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.cursorline = true -- Enable highlighting of the current line
opt.expandtab = true -- Use spaces instead of tabs
opt.exrc = true -- Allow project-local .nvim.lua (used for per-project zls overrides)
opt.formatoptions = "jcroqlnt" -- tcqj
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.ignorecase = true -- ignores case sensitivity by default
opt.smartcase = true --  no case sensitivity, unless if uppercase character is introduced
opt.smartindent = true -- Insert indents automatically
opt.inccommand = "split" -- preview incremental substitute, 'split' -- shows search matches (or substitutions matches) in a split window, in real time... live feedback
opt.list = true -- Show some invisible characters (tabs...
opt.mouse = "a" -- Enable mouse mode
opt.number = true -- Print line number
opt.relativenumber = true -- Relative line numbers
opt.signcolumn = "number"
opt.pumblend = 10 -- Popup blend
opt.pumheight = 10 -- Maximum number of entries in a popup
opt.scrolloff = 4 -- Lines of context
opt.sidescrolloff = 8 -- Columns of context
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize" }
opt.shiftround = true -- Round indent
opt.shiftwidth = 2 -- Size of an indent
opt.shortmess:append({ W = true, I = true, c = true })
-- Spell is scoped to prose filetypes (see core/autocmds/filetypes.lua), not
-- enabled globally, so code buffers are not spell-checked. spelllang is set
-- per-buffer there and auto-detected by vim-DetectSpellLang (plugins/spell.lua).
opt.splitbelow = true -- Put new windows below current
opt.splitright = true -- Put new windows right of current
opt.tabstop = 2 -- Number of spaces tabs count for
opt.softtabstop = 2
opt.termguicolors = true -- True color support
opt.timeout = true
opt.timeoutlen = 300
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200 -- Save swap file and trigger CursorHold
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.winminwidth = 5 -- Minimum window width
opt.splitkeep = "screen"
opt.shortmess:append({ C = true })
opt.fileencoding = "utf-8"
opt.colorcolumn = "80"
opt.backup = false
opt.writebackup = false
opt.swapfile = false
opt.autoread = true
opt.hlsearch = false
opt.incsearch = true
opt.foldlevel = 99 -- Start fully unfolded
opt.foldtext = "" -- Neovim 0.10+ native rendered foldtext
opt.more = false -- disable the "-- More --" pager (auto-runs to the end)

-- Node provider: resolve neovim-node-host from PATH (works with bun or npm)
local node_host = vim.fn.exepath("neovim-node-host")
if node_host ~= "" then
  vim.g.node_host_prog = node_host
end

-- Ruby provider: resolve neovim-ruby-host from PATH
local ruby_host = vim.fn.exepath("neovim-ruby-host")
if ruby_host ~= "" then
  vim.g.ruby_host_prog = ruby_host
end
