-- Filetype mappings and filetype-specific settings
local api = vim.api

local function augroup(name)
  return api.nvim_create_augroup(name, { clear = true })
end

-- Ghostty "screen.txt" and "history.txt" files: Jump to end-of-file
api.nvim_create_autocmd({ "BufWinEnter", "BufNewFile" }, {
  group = augroup("GhosttyTxtEOF"),
  pattern = { "screen.txt", "history.txt" },
  callback = function(args)
    vim.schedule(function() -- wait until the window is ready
      if api.nvim_get_current_buf() ~= args.buf then
        return
      end
      vim.cmd.normal({ "G", bang = true })
    end)
  end,
})

-- Google Apps Script (.gs) treated as javascript
api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup("filetype_mappings"),
  pattern = { "*.gs" },
  callback = function()
    vim.bo.filetype = "javascript"
  end,
})

-- Markdown treesitter folds
api.nvim_create_autocmd("FileType", {
  group = augroup("markdown_folds"),
  pattern = { "markdown" },
  callback = function()
    vim.opt_local.foldmethod = "expr"
    vim.opt_local.foldexpr = "v:lua.vim.treesitter.foldexpr()"
  end,
})

-- Prose settings: wrap + spell for writing filetypes. spelllang starts at en_us;
-- vim-DetectSpellLang (plugins/spell.lua) overrides it from the buffer content.
-- The ,e / ,p / ,s maps below stay as manual overrides when detection is wrong.
api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "gitcommit", "markdown", "text", "rst", "asciidoc" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
    vim.opt_local.colorcolumn = ""
    -- Buffer-local which-key mappings
    require("which-key").add({
      { "<LocalLeader>l", ":RunYTMDLink<CR>", buffer = 0, desc = "YTMDLink: YouTube -> Markdown Link" },
      {
        "<LocalLeader>s",
        function()
          vim.opt_local.spell = not vim.opt_local.spell
          print("Spell checking: " .. (vim.bo[0].spell and "ON" or "OFF"))
        end,
        buffer = 0,
        desc = "Toggle spell checking",
      },
      {
        "<LocalLeader>p",
        function()
          vim.opt_local.spelllang = { "pt" }
        end,
        buffer = 0,
        desc = "Spelllang pt",
      },
      {
        "<LocalLeader>e",
        function()
          vim.opt_local.spelllang = { "en" }
        end,
        buffer = 0,
        desc = "Spelllang en",
      },
    })
  end,
})
