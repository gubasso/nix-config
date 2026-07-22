-- yazi.nvim: the `yazi` ranger-style TUI embedded in a floating window.
-- Replaces oil.nvim as the primary full-screen file browser and the handler for
-- `nvim <dir>`. mini.files stays as the in-editor miller explorer (<leader>e…).
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
    -- <C-e>: open a fresh yazi at the working dir.
    { "<c-e>", "<cmd>Yazi cwd<cr>", desc = "Yazi (working dir)" },
    -- <C-f>: force a fresh yazi hovering the current file (NOT resume/toggle) --
    -- bare `:Yazi` opens on the current buffer's file, like mini.files does.
    { "<c-f>", "<cmd>Yazi<cr>", desc = "Yazi (current file)" },
    -- <C-y>: toggle/resume the last yazi session (restores the hovered file);
    -- yazi.nvim's M.toggle falls back to a normal open when there is no prior state.
    { "<c-y>", "<cmd>Yazi toggle<cr>", desc = "Yazi (resume)" },
  },
  opts = {
    open_for_directories = true, -- replace netrw/oil: `nvim <dir>` opens yazi
    -- Rebind the file-openers off <c-v>/<c-x>/<c-t> onto Alt combos. yazi.nvim
    -- installs these as terminal-mode maps on its buffer, so the defaults hijack
    -- keys before an embedded $EDITOR (bulk rename `r`) sees them -- <c-v> would
    -- exit to the outer nvim instead of visual-block. Alt combos are free during
    -- rename editing. Mnemonics mirror vim's <c-w>v / <c-w>s / <c-w>t.
    keymaps = {
      open_file_in_vertical_split = "<M-v>",
      open_file_in_horizontal_split = "<M-s>",
      open_file_in_tab = "<M-t>",
    },
    integrations = {
      -- Use grep_project (ripgrep once, then fzf fuzzy-filter) instead of
      -- yazi.nvim's built-in "fzf-lua" backend (which calls live_grep =
      -- per-keystroke rg regex, no fuzzy). This makes <c-s> fuzzy-match like this
      -- config's <leader>/ does (e.g. "chtoo" -> "Check tools..."), inheriting the
      -- global `grep` table (rg_opts, --nth, <c-i> live-toggle). Signatures per
      -- yazi.nvim types.lua:
      --   grep_in_directory(directory: string)
      --   grep_in_selected_files(selected_files: Path[], relative_paths: string[])
      grep_in_directory = function(directory)
        require("fzf-lua").grep_project({ search_paths = { directory } })
      end,
      grep_in_selected_files = function(_selected_files, relative_paths)
        require("fzf-lua").grep_project({ search_paths = relative_paths })
      end,
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
