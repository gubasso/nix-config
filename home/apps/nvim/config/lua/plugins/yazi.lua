-- yazi.nvim: the `yazi` ranger-style TUI embedded in a floating window.
-- Replaces oil.nvim as the primary full-screen file browser and the handler for
-- `nvim <dir>`. mini.files stays as the in-editor miller explorer (<C-e>/<C-f>).
return {
  "mikavilpas/yazi.nvim",
  -- Eager (like the old oil spec) so open_for_directories can hijack `nvim .`
  -- at startup, before a VeryLazy trigger would fire.
  lazy = false,
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    -- Single opener: `:Yazi toggle` opens fresh on first use and resumes the last
    -- session (restoring the hovered file) thereafter -- yazi.nvim's M.toggle
    -- falls back to a normal open when there is no prior state.
    { "<leader>-", mode = { "n", "v" }, "<cmd>Yazi toggle<cr>", desc = "Yazi (resume/open)" },
    { "<leader>_", "<cmd>Yazi cwd<cr>", desc = "Yazi (working dir)" },
  },
  opts = {
    open_for_directories = true, -- replace netrw/oil: `nvim <dir>` opens yazi
  },
}
