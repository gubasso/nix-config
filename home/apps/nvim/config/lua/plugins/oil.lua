return {
  "stevearc/oil.nvim",
  lazy = false,
  opts = {},
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local oil = require("oil")
    local project_root = vim.fn.getcwd()
    require("which-key").add({
      { "<leader>-", oil.open, desc = "Open parent directory" },
      {
        "<leader>_",
        function()
          oil.open(project_root)
        end,
        desc = "Open project root",
      },
    })
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

    -- Capped miller-columns navigation (macOS Finder / mini.files style).
    -- H/L move between columns instead of endlessly spawning splits: L descends
    -- (reusing a single "detail" column once the cap is hit), H ascends (closing
    -- the tagged detail column, or plain parent nav in the leftmost oil buffer).
    -- Generated columns are tagged with `vim.w.oil_miller` so they can be reused
    -- and collapsed. MILLER_MAX is the number of columns to keep: 2 = the
    -- original oil column + one reused detail column.
    local MILLER_MAX = 2

    local function oil_entry_path()
      local entry = oil.get_cursor_entry()
      local dir = oil.get_current_dir()
      if not entry or not dir then
        return nil, nil
      end
      return dir .. entry.name, entry
    end

    local function close_right_miller_windows(anchor)
      close_preview_win()
      local seen_anchor = false
      for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if win == anchor then
          seen_anchor = true
        elseif seen_anchor and vim.api.nvim_win_is_valid(win) and vim.w[win].oil_miller then
          pcall(vim.api.nvim_win_close, win, true)
        end
      end
    end

    local function miller_right()
      local cur = vim.api.nvim_get_current_win()
      local path, entry = oil_entry_path()
      if not path then
        return
      end
      close_right_miller_windows(cur)
      -- CURRENT behavior: the cap counts *all* windows in the tab, not just
      -- miller columns. This is intentional for now. Consequence: pre-existing
      -- unrelated splits (e.g. an `:vsplit` you opened yourself) count toward the
      -- budget, so with another split already open, L may skip creating a fresh
      -- detail column and instead `wincmd l` into that unrelated window and open
      -- there. Fine when oil miller nav is the only thing splitting the tab.
      --
      -- ALTERNATIVE (deferred): count only oil-managed (tagged) columns so
      -- unrelated splits never affect the cap. To switch, replace the condition
      -- below with a helper that counts tagged windows + the anchor, e.g.:
      --   local function miller_count()
      --     local n = 0
      --     for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
      --       if vim.w[w].oil_miller then n = n + 1 end
      --     end
      --     return n + 1 -- + the original/anchor oil window
      --   end
      --   ... if miller_count() < MILLER_MAX then ...
      if #vim.api.nvim_tabpage_list_wins(0) < MILLER_MAX then
        vim.cmd("belowright vertical split")
      else
        vim.cmd("wincmd l")
      end
      vim.w.oil_miller = true
      if entry.type == "directory" then
        oil.open(path)
      else
        vim.cmd.edit(vim.fn.fnameescape(path))
      end
    end

    local function miller_left()
      local cur = vim.api.nvim_get_current_win()
      if vim.w[cur].oil_miller then
        pcall(vim.api.nvim_win_close, cur, true)
        vim.cmd("wincmd h")
      else
        oil.open()
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
        -- H/L are miller navigation; J closes the preview first (see open_split)
        -- so it doesn't duplicate the file the preview is already showing.
        ["H"] = { callback = miller_left, desc = "Oil: miller left / parent" },
        ["L"] = { callback = miller_right, desc = "Oil: miller right / open" },
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
