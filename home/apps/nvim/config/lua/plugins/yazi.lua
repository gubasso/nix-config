-- yazi.nvim: the `yazi` ranger-style TUI embedded in a floating window.
-- Replaces oil.nvim as the primary full-screen file browser and the handler for
-- `nvim <dir>`. mini.files stays as the in-editor miller explorer (<C-e>/<C-f>).
return {
  "mikavilpas/yazi.nvim",
  -- Eager (like the old oil spec) so open_for_directories can hijack `nvim .`
  -- at startup, before a VeryLazy trigger would fire.
  lazy = false,
  -- fzf-lua backs the in-yazi grep (<c-s>); grug-far backs the replace (<c-g>).
  -- yazi.nvim only soft-depends on these (require at keypress) -- declaring them
  -- here makes lazy.nvim install them so the default grep/replace keymaps work.
  dependencies = {
    "nvim-lua/plenary.nvim",
    "ibhagwan/fzf-lua",
    "MagicDuck/grug-far.nvim",
  },
  keys = {
    -- Single opener: `:Yazi toggle` opens fresh on first use and resumes the last
    -- session (restoring the hovered file) thereafter -- yazi.nvim's M.toggle
    -- falls back to a normal open when there is no prior state.
    { "<leader>-", mode = { "n", "v" }, "<cmd>Yazi toggle<cr>", desc = "Yazi (resume/open)" },
    { "<leader>_", "<cmd>Yazi cwd<cr>", desc = "Yazi (working dir)" },
  },
  opts = {
    open_for_directories = true, -- replace netrw/oil: `nvim <dir>` opens yazi
    integrations = {
      -- Point the built-in grep at fzf-lua (this config's picker; no telescope).
      grep_in_directory = "fzf-lua",
      grep_in_selected_files = "fzf-lua",
      -- replace_* left at defaults: they require("grug-far"), now a dependency.
    },
    hooks = {
      -- <c-q> in yazi selects multiple files and hands them here. Instead of the
      -- native quickfix window, populate the quickfix list and open it as a flat
      -- Trouble list (one file per line -- see the `qflist` mode in trouble.lua).
      yazi_opened_multiple_files = function(chosen_files)
        local items = {}
        for _, f in ipairs(chosen_files or {}) do
          items[#items + 1] = { filename = f, lnum = 1, col = 1 }
        end
        if #items == 0 then
          return
        end
        vim.fn.setqflist(items, "r")
        local ok = pcall(function()
          require("trouble").open({ mode = "qflist" })
        end)
        if not ok then
          vim.cmd("Trouble qflist open")
        end
      end,
    },
  },
}
