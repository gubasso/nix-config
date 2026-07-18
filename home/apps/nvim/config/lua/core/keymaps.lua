local map = vim.keymap.set
local keymaps = require("core.utils.keymaps")

-- Highlighting
map("v", "<CR>", keymaps.highlight_selection, { desc = "Highlighting visual selection" })
map("n", "<leader><CR>", keymaps.highlight_cword, { desc = "Highlighting word under cursor" })

-- System opener
map("n", "gx", keymaps.system_open_under_cursor, { desc = "Open under-cursor (system opener)" })

-- Markdown usercmds
map("n", "<leader>mnn", function()
  require("core.usercmds.md_new").prompt()
end, { desc = "MdNew: New Markdown note" })
map("n", "<leader>mnd", function()
  require("core.usercmds.md_dir_new").prompt()
end, { desc = "MdDirNew: New Dir with README.md" })
map("n", "<leader>mw", function()
  vim.cmd([[keeppatterns %s/\s\+$//e]])
  vim.cmd([[keeppatterns %s/\v^  //e]])
end, { desc = "Whitespace: trim trailing + dedent 2" })

-- Save / Quit
map("n", "<leader>w", ":wa<CR>", { desc = "Save all" })
map("n", "<leader>q", "<cmd>wa<CR><cmd>q<CR>", { desc = "Save all and Quit" })
map("n", "<leader>Q", "<cmd>q!<CR>", { desc = "Quit without saving" })

-- Buffer navigation
map("n", "<leader><tab>", "<cmd>b#<CR>", { desc = "Switch to alternate buffer" })

-- Tab pages (gt/gT next/prev are native)
map("n", "<leader>Tn", "<cmd>tabnew<CR>", { desc = "Tab: new" })
map("n", "<leader>Tc", "<cmd>tabclose<CR>", { desc = "Tab: close" })
map("n", "<leader>To", "<cmd>tabonly<CR>", { desc = "Tab: close others" })
-- Toggle to the last-used tab (browser-style Ctrl+Tab); native g<Tab> equivalent
map("n", "gl", function()
  local last = vim.fn.tabpagenr("#")
  if last ~= 0 then
    vim.cmd(last .. "tabnext")
  end
end, { desc = "Tab: last-used (toggle)" })

-- Search
map("n", "<c-c>", ":set hlsearch!<cr>", { desc = "Toggle hlsearch" })

-- Window resize
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Window zoom (toggle current split fullscreen, kitty-style)
map("n", "gz", keymaps.toggle_window_zoom, { desc = "Zoom: toggle window fullscreen" })

-- Move lines (normal)
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })

-- Move lines (visual)
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selected lines up" })

-- Stay in visual after indent
map("v", "<", "<gv", { desc = "Indent left and reselect" })
map("v", ">", ">gv", { desc = "Indent right and reselect" })

-- Move lines (insert)
map("i", "<A-j>", "<Esc>:m .+1<CR>==gi", { desc = "Move line down in Insert mode" })
map("i", "<A-k>", "<Esc>:m .-2<CR>==gi", { desc = "Move line up in Insert mode" })

-- Clipboard operations (normal)
map("n", "<leader>yy", '"+yy', { desc = "clipboard yy" })
map("n", "<leader>yw", '"+yiw', { desc = "clipboard yiw" })
map("n", "<leader>yl", '"+yiW', { desc = "clipboard yiW" })
map("n", "<leader>Y", '"+yg_', { desc = "clipboard Y" })
map("n", "<leader>D", '"+D', { desc = "clipboard D" })
map("n", "<leader>dd", '"+dd', { desc = "clipboard dd" })
map("n", "<leader>p", '"+p', { desc = "clipboard p" })
map("n", "<leader>P", '"+P', { desc = "clipboard P" })

-- Clipboard operations (normal + visual)
map({ "n", "v" }, "<leader>y", '"+y', { desc = "clipboard y" })
map({ "n", "v" }, "<leader>d", '"+d', { desc = "clipboard d" })

-- Clipboard file path (CopyFilePath usercmd)
local copy_path = require("core.usercmds.copy_file_path")
map("n", "<leader>ip", copy_path.absolute, { desc = "yank path: absolute (/home/u/proj/foo.lua)" })
map("n", "<leader>id", copy_path.dir, { desc = "yank path: absolute dir (/home/u/proj)" })
map("n", "<leader>ir", copy_path.cwd, { desc = "yank path: cwd-relative (foo.lua)" })
map("n", "<leader>iR", copy_path.root, { desc = "yank path: root-prefixed cwd-relative (proj/foo.lua)" })

-- Sudo save
map("c", "w!!", "w !sudo tee > /dev/null %", { desc = "Save of files as sudo" })
