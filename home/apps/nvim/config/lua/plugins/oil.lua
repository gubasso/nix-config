return {
  "stevearc/oil.nvim",
  lazy = false,
  opts = {},
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local oil = require("oil")
    require("which-key").add({ { "-", oil.open, desc = "Open parent directory" } })
    local always_hidden = {
      [".git"] = true,
      ["node_modules"] = true,
    }

    -- Preview is on by default (see OilEnter autocmd below), so a plain
    -- actions.select { vertical/horizontal } would open the entry in a NEW
    -- split *on top of* the still-open preview -> two windows on the same file.
    -- Close the preview window first, then open the split, so the entry lands
    -- in a single window on the right/below (as if "moving into" the preview).
    local function close_preview_win()
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if vim.api.nvim_win_is_valid(win) then
          local ok, is_preview = pcall(function()
            return vim.wo[win].previewwindow
          end)
          if ok and is_preview then
            pcall(vim.api.nvim_win_close, win, true)
          end
        end
      end
    end
    local function open_split(select_opts)
      return function()
        close_preview_win()
        oil.select(select_opts)
      end
    end

    oil.setup({
      keymaps = {
        -- Free Ctrl-h/l for smart-splits window navigation
        ["<C-h>"] = false, -- was: open in horizontal split (now on J)
        ["<C-l>"] = false, -- was: refresh (now on R)
        -- Free Ctrl-p for fzf-lua Find Files
        ["<C-p>"] = false, -- was: preview (now on gp)
        -- Free gs for fugitive Git Status
        ["gs"] = false, -- was: change sort (now on go)

        -- Directional open (mini-files-style), plus splits/tab.
        -- L/J close the preview first (see open_split) so they don't duplicate
        -- the file the preview is already showing; <CR> stays the full-window open.
        ["H"] = { "actions.parent", desc = "Oil: parent dir" },
        ["L"] = { callback = open_split({ vertical = true }), desc = "Oil: open (vsplit)" },
        ["J"] = { callback = open_split({ horizontal = true }), desc = "Oil: open (hsplit)" },
        ["K"] = { "actions.select", opts = { tab = true }, desc = "Oil: open (tab)" },

        -- Relocated defaults (off conflicting keys)
        ["gp"] = { "actions.preview", desc = "Oil: toggle preview" },
        ["R"] = { "actions.refresh", desc = "Oil: refresh" },
        ["go"] = { "actions.change_sort", desc = "Oil: change sort" },
      },
      view_options = {
        show_hidden = true,
        is_always_hidden = function(name)
          return always_hidden[name] or false
        end,
      },
    })

    -- Preview on by default: open the preview pane whenever an oil buffer is
    -- entered. Oil keeps it in sync with the cursor from then on. Scheduled so
    -- the buffer is fully loaded and the cursor entry is resolvable.
    vim.api.nvim_create_autocmd("User", {
      pattern = "OilEnter",
      callback = vim.schedule_wrap(function(args)
        if vim.api.nvim_get_current_buf() == args.data.buf and oil.get_cursor_entry() then
          oil.open_preview()
        end
      end),
    })

    -- On `nvim .`, oil opens the cwd as the startup buffer. Drop the cursor on
    -- README.md (if any) so the default-on preview above shows it.
    --
    -- Oil rewrites a directory argument to an `oil://` URL before we can read it,
    -- so "launched on a directory" is detected via that scheme (a plain `.` never
    -- survives). This one-shot is scoped to opening the cwd specifically, so
    -- later oil navigation, bare `nvim`, `nvim <file>`, opening some other dir,
    -- and kitty-scrollback (argc 0) are all untouched. The README row is located
    -- via oil's entry API rather than a text search, since oil renders each line
    -- with concealed id/icon columns that would defeat an anchored pattern.
    local launched_on_dir = vim.fn.argc() == 1 and vim.startswith(vim.fn.argv(0), "oil://")
    vim.api.nvim_create_autocmd("User", {
      pattern = "OilEnter",
      once = true,
      callback = vim.schedule_wrap(function(args)
        if not launched_on_dir then
          return
        end
        local bufnr = args.data.buf
        if vim.api.nvim_get_current_buf() ~= bufnr then
          return
        end
        local dir = oil.get_current_dir(bufnr)
        if not dir or vim.fs.normalize(dir) ~= vim.fs.normalize(vim.fn.getcwd()) then
          return
        end
        for lnum = 1, vim.api.nvim_buf_line_count(bufnr) do
          local entry = oil.get_entry_on_line(bufnr, lnum)
          if entry and entry.name and entry.name:lower() == "readme.md" then
            vim.api.nvim_win_set_cursor(0, { lnum, 0 })
            return
          end
        end
      end),
    })
  end,
}
