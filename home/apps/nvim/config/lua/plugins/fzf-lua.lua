return {
  "ibhagwan/fzf-lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  cmd = "FzfLua",
  config = function()
    local fzf = require("fzf-lua")

    -- DRY opt builders. Each picker shares a base token list (joined verbatim
    -- onto the fd/rg invocation); per-call sites only declare their additions.
    --   * fd_base / rg_base: always-on flags incl. the .git exclusion.
    --   * `with(base, { ... })`: returns base + extras as one space-joined
    --     string, without mutating base.
    local fd_base = { "--color=never", "--type f", "--exclude .git" }
    local rg_base = {
      "--column",
      "--line-number",
      "--no-heading",
      "--color=always",
      "--smart-case",
      [[--glob "!.git/"]],
    }
    local function with(base, extra)
      local parts = {}
      for _, v in ipairs(base) do
        parts[#parts + 1] = v
      end
      for _, v in ipairs(extra or {}) do
        parts[#parts + 1] = v
      end
      return table.concat(parts, " ")
    end

    fzf.setup({
      "telescope", -- Use telescope profile for familiar look/feel
      previewers = {
        builtin = {
          treesitter = {
            enabled = true,
            -- Belt-and-suspenders with the editorconfig parser installed in
            -- treesitter.lua: if a host still has a skewed parser/query pair
            -- (system runtime's highlights.scm references a `(property)` node
            -- the grammar dropped), fall back to plain-text preview instead of
            -- crashing the builtin previewer on `.editorconfig`.
            disabled = { "editorconfig" },
          },
        },
      },
      winopts = {
        -- Builtin previewer: renders into a real Neovim buffer (Treesitter
        -- highlighting / line numbers), so it's focusable for native motions
        -- (see <M-p>/focus-preview below). `wrap` still applies.
        -- `horizontal = "right:60%"`: preview takes 60% of the width on the
        -- right (overrides the telescope profile's right:50%). Applies when the
        -- flex layout picks horizontal (fzf width > flip_columns).
        preview = { default = "builtin", wrap = true, horizontal = "right:60%" },
        -- Open as a real Neovim split (normal window/buffer) instead of a
        -- float, so <C-w> moves/splits treat it like any other window.
        -- Accept-actions (<CR>/<C-s>/<C-v>) still close the picker; use
        -- <M-Esc> (hide, below) to stash a LIVE picker and <leader>fR
        -- (:FzfLua resume) to return to it with query + results intact.
        split = "belowright new",
        -- ------------------------------------------------------------------
        -- Telescope-style modal navigation (research notes)
        -- ------------------------------------------------------------------
        -- Goal: pressing <Esc> in the fzf picker enters a "normal mode"
        -- where j/k/g/G/<C-d>/<C-u>/etc. navigate the list (like
        -- telescope.nvim), without aborting fzf.
        --
        -- What did NOT work (verified against fzf-lua HEAD + fzf 0.72):
        --
        --   1. Binding keymap.fzf["esc"] = "disable-search+rebind(...)".
        --      fzf-lua lowercases all keymap.fzf keys (config.lua,
        --      map_tolower; only `alt-<letter>` is excluded), so uppercase
        --      letter binds collapse onto their lowercase. The terminal-
        --      mode <Esc>→<Esc> passthrough at win.lua:313-317 is only
        --      installed in the `dummy_abort` case — customizing esc opts
        --      out of it.
        --
        --   2. keymap.fzf["esc"] = "transform:case $FZF_PROMPT in ..." to
        --      toggle modes by inspecting the prompt. Even though
        --      core.lua:573-624 emits `transform:` binds as their own
        --      --bind arg (so embedded parens/commas are safe), the chain
        --      did not actually toggle from inside the fzf-lua/Neovim
        --      terminal — Esc still closed the picker.
        --
        -- What works: don't fight fzf-lua's bind layer; emulate modal mode
        -- Neovim-side. Mechanism lifted from
        -- drop-stones/fzf-lua-normal-mode (bindings/util.lua):
        --
        --   * <Esc> in terminal-job mode (t) is remapped to <C-\><C-n>.
        --     This exits to terminal-normal mode (nt) — Neovim's normal
        --     mode inside the fzf buffer. fzf process keeps running.
        --   * Buffer-local n-mode keymaps feed actions to fzf by briefly
        --     re-entering t mode, sending the action key, then exiting
        --     back to nt: feedkeys("i" .. key .. "<C-\\><C-n>", "n", false).
        --   * i/a// (Neovim defaults in nt) re-enter t mode to type the
        --     query again. `q` feeds <C-c> so fzf aborts.
        --
        -- on_create runs AFTER fzf-lua's setup_keybinds (win.lua:1109 vs
        -- 1120), so our buffer-local <Esc> tmap overrides fzf-lua's own.
        --
        -- Refs:
        --   https://github.com/drop-stones/fzf-lua-normal-mode
        --   (esp. lua/fzf-lua-normal-mode/bindings/util.lua)
        -- ------------------------------------------------------------------
        on_create = function(e)
          local map_opts = { buffer = e.bufnr, silent = true, nowait = true }
          -- Keep <C-j>/<C-k> inside fzf-lua instead of global smart-splits terminal maps.
          vim.keymap.set("t", "<C-j>", "<Down>", map_opts)
          vim.keymap.set("t", "<C-k>", "<Up>", map_opts)
          vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], map_opts)
          -- <M-Esc>: stash the LIVE picker (keeps the fzf process running via
          -- FzfWin:hide) so <leader>fR / :FzfLua resume returns to the exact
          -- same state — as opposed to an accept/abort, which ends the process
          -- and makes resume a fresh re-run of the last query. Bound in both
          -- terminal (typing) and terminal-normal (modal-nav) modes; fzf-lua's
          -- keymap.builtin default only covers terminal mode.
          local function hide()
            require("fzf-lua").hide()
          end
          vim.keymap.set("t", "<M-Esc>", hide, map_opts)
          vim.keymap.set("n", "<M-Esc>", hide, map_opts)

          local function feed(keys)
            local seq = vim.api.nvim_replace_termcodes("i" .. keys .. [[<C-\><C-n>]], true, false, true)
            return function()
              vim.api.nvim_feedkeys(seq, "n", false)
            end
          end

          vim.keymap.set("n", "j", feed("<Down>"), map_opts)
          vim.keymap.set("n", "k", feed("<Up>"), map_opts)
          -- Empirically, in this Neovim → terminal → fzf path, <A-g> and
          -- <A-G> end up swapped relative to fzf-lua's documented defaults
          -- (alt-g=first, alt-G=last). Crossed here to restore Vim
          -- convention: g=top, G=bottom.
          vim.keymap.set("n", "g", feed("<A-G>"), map_opts)
          vim.keymap.set("n", "G", feed("<A-g>"), map_opts)
          vim.keymap.set("n", "<C-d>", feed("<C-d>"), map_opts) -- half-page-down
          vim.keymap.set("n", "<C-u>", feed("<C-u>"), map_opts)
          vim.keymap.set("n", "<C-f>", feed("<C-f>"), map_opts) -- page-down
          vim.keymap.set("n", "<C-b>", feed("<C-b>"), map_opts)
          vim.keymap.set("n", "<A-d>", feed("<A-d>"), map_opts) -- preview-half-page-down
          vim.keymap.set("n", "<A-u>", feed("<A-u>"), map_opts)
          vim.keymap.set("n", "<CR>", feed("<CR>"), map_opts)
          vim.keymap.set("n", "q", feed("<C-c>"), map_opts)

          -- Forward every non-vim-navigation key fzf-lua binds (multi-select,
          -- toggles, splits, preview controls, send-to-qf, etc.) so the picker
          -- behaves identically in NORMAL and INSERT modes. <C-h>/<C-l>/<C-w>
          -- are intentionally NOT forwarded — they remain Vim window commands.
          local forward = {
            "<Tab>",
            "<S-Tab>", -- multi-select toggle (fzf default)
            "<A-a>", -- toggle-all
            "<A-i>",
            "<A-h>",
            "<A-f>", -- toggle ignore/hidden/follow
            "<A-q>",
            "<A-Q>", -- send selection to qf/ll
            "<C-s>",
            "<C-v>",
            "<C-t>",
            "<C-x>", -- splits / tab / trouble
            "<C-i>",
            "<C-g>",
            "<C-q>", -- grep_lgrep toggle, accept, select-all+accept
            "<C-a>",
            "<C-e>", -- BOL/EOL inside fzf's query field
            "<F1>",
            "<F2>",
            "<F3>",
            "<F4>",
            "<F5>",
            "<F6>",
            "<F7>",
            "<F8>",
            "<F9>",
            "<S-Down>",
            "<S-Up>", -- preview page nav (fzf-lua default)
            "<A-S-Down>",
            "<A-S-Up>", -- preview line nav (fzf-lua default)
            "<A-p>", -- focus-preview: enter the preview window for native motions
          }
          for _, key in ipairs(forward) do
            vim.keymap.set("n", key, feed(key), map_opts)
          end
        end,
      },
      files = {
        hidden = true,
        follow = true,
        -- `--exclude /tests`: the leading slash anchors the glob to the project
        -- root, so only the root-level tests/ is skipped (nested src/tests/ is
        -- still shown). Plain `--exclude tests` would drop `tests` at ANY depth.
        --
        -- Per-project extra excludes: drop a `.ignore` file in the repo root.
        -- fd reads `.gitignore`/`.ignore`/`.fdignore` natively (and rg reads the
        -- same `.ignore`), so one root `.ignore` covers BOTH pickers with zero
        -- Lua. Anchor each entry with a leading slash, e.g.:
        --   /build/
        --   /target/   (rust)
        --   /.venv/    (python)
        -- Use `.fdignore` (fd-only) / `.rgignore` (rg-only) for tool-specific
        -- rules. The <leader>fF/<leader>fG maps below bypass all of this.
        fd_opts = with(fd_base, { "--exclude /tests" }),
      },
      grep = {
        hidden = true,
        follow = true,
        -- `!/tests/**`: leading slash anchors the glob to the project root, so
        -- only root tests/ is skipped (nested src/tests/ stays). `!tests/` would
        -- match any depth. Per-project extras live in a root `.ignore` (or
        -- `.rgignore`) read by ripgrep automatically — same `.ignore` fd reads.
        rg_opts = with(rg_base, { [[--glob "!/tests/**"]] }),
        -- Abbreviate each parent-path component to 1 char (/h/u/p/s/file.lua)
        -- so the path occupies a small, fixed chunk of the width. fzf always
        -- truncates the RIGHT of a line; capping the (left) path here keeps the
        -- matched text — the important part — visible instead of cut off. Bump
        -- to 2+ for more path context, or swap for `formatter =
        -- "path.filename_first"` to move the filename ahead of the path.
        path_shorten = 1,
        fzf_opts = {
          ["--delimiter"] = ":",
          ["--nth"] = "4..", -- match only line text
          ["--scheme"] = "default", -- avoid path-prioritizing scoring
          ["--tiebreak"] = "begin,index", -- remove length bias
        },
        actions = {
          ["ctrl-g"] = false,
          ["ctrl-i"] = { fn = require("fzf-lua").actions.grep_lgrep, reload = true },
        },
      },
      keymap = {
        builtin = {
          true, -- inherit builtin defaults (<S-Down>/<S-Up> preview page,
          -- <M-S-Down>/<M-S-Up> preview line, <F3> wrap, <F4> toggle, <M-Esc> hide, ...)
          -- Jump INTO the preview as a real Neovim buffer for native motions
          -- (j/k/gg/G, / search). Return with `i` (back to query) or <C-w>w.
          ["<M-p>"] = "focus-preview",
          -- Half-page preview scroll without leaving the picker. Ports the old
          -- keymap.fzf alt-d/alt-u, which only worked with fzf-native previewers.
          ["<M-d>"] = "preview-half-page-down",
          ["<M-u>"] = "preview-half-page-up",
        },
        fzf = {
          true, -- inherit fzf-lua defaults
          ["ctrl-q"] = "select-all+accept", -- Send all to quickfix
          -- List navigation (fzf result list; always active, consumed by feed() too).
          ["ctrl-d"] = "half-page-down",
          ["ctrl-u"] = "half-page-up",
          ["ctrl-f"] = "page-down",
          ["ctrl-b"] = "page-up",
          -- (alt-d/alt-u preview binds removed: the preview is now a Neovim
          --  buffer, scrolled via keymap.builtin above, not fzf preview actions.)
        },
      },
      actions = {
        files = {
          ["ctrl-t"] = require("trouble.sources.fzf").actions.open, -- Open in Trouble
        },
      },
    })

    -- Shrink the preview to 35% (vs the global right:60%) so the result
    -- list — the point of a fuzzy line grep — gets the remaining 65%.
    -- Shared by <leader>fg and <C-/> below (same action, two entry points).
    local function grep_project_fuzzy()
      fzf.grep_project({ winopts = { preview = { horizontal = "right:35%" } } })
    end

    -- Register keymaps via which-key
    require("which-key").add({
      -- Direct shortcuts (muscle memory / conventions)
      { "<C-p>", fzf.files, desc = "Find Files" },
      { "<C-/>", grep_project_fuzzy, desc = "Grep project (fuzzy lines)" },
      { "<leader>/", fzf.blines, desc = "Buffer lines (fuzzy)" },
      { "<leader>:", fzf.command_history, desc = "Command History" },
      { "<leader>r", fzf.resume, desc = "Resume last picker" },

      -- <leader>f — everyday pickers (lowercase = frequent)
      { "<leader>fb", fzf.buffers, desc = "Buffers" },
      { "<leader>fg", grep_project_fuzzy, desc = "Grep project (fuzzy lines)" },
      {
        "<leader>fr",
        function()
          fzf.live_grep({ exec_empty_query = true })
        end,
        desc = "Grep (regex)",
      },
      { "<leader>fw", fzf.grep_cword, desc = "Grep word under cursor" },
      {
        "<leader>f/",
        function()
          fzf.fzf_exec("fd --type d --hidden --exclude .git", {
            prompt = "Directory> ",
            actions = {
              ["default"] = {
                fn = function(selected)
                  fzf.live_grep({ search_paths = { selected[1] } })
                end,
                noclose = true,
              },
            },
          })
        end,
        desc = "Grep in subdirectory",
      },
      {
        "<leader>f.",
        function()
          local name = vim.api.nvim_buf_get_name(0)
          if name == "" then
            vim.notify("Buffer has no file path", vim.log.levels.WARN)
            return
          end
          local buf_dir = vim.fn.fnamemodify(name, ":h")
          fzf.grep_project({ search_paths = { buf_dir } })
        end,
        desc = "Grep in buffer dir",
      },
      { "<leader>fh", fzf.help_tags, desc = "Help Tags" },
      { "<leader>ft", "<cmd>TodoFzfLua<CR>", desc = "Todo: All comments" },
      { "<leader>fm", fzf.keymaps, desc = "Keymaps" },

      -- <leader>f — specialized pickers (uppercase = less frequent)
      { "<leader>fA", fzf.builtin, desc = "All fzf-lua" },
      { "<leader>fC", fzf.commands, desc = "Available Commands" },
      { "<leader>fR", fzf.resume, desc = "Resume last picker" },

      -- Escape hatches: include EVERYTHING (root tests/ + .ignore-d paths).
      -- `--no-ignore` bypasses .gitignore/.ignore/.fdignore/.rgignore, and
      -- omitting the tests glob re-includes tests/. .git stays excluded; drop
      -- the .git filter too if you really want it.
      {
        "<leader>fF",
        function()
          fzf.files({ hidden = true, follow = true, fd_opts = with(fd_base, { "--no-ignore" }) })
        end,
        desc = "Find Files (all, no excludes)",
      },
      {
        "<leader>fG",
        function()
          fzf.grep_project({ hidden = true, follow = true, rg_opts = with(rg_base, { "--no-ignore" }) })
        end,
        desc = "Grep (all, no excludes)",
      },
      {
        "<leader>fT",
        function()
          require("todo-comments.fzf").todo({ keywords = { "TODO", "FIX", "FIXME" } })
        end,
        desc = "Todo: Fix/Fixme",
      },

      -- LSP pickers
      {
        "gd",
        function()
          fzf.lsp_definitions({ jump1 = true })
        end,
        desc = "Goto Definition",
      },
      { "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
      {
        "gr",
        function()
          fzf.lsp_references({ ignore_current_line = true })
        end,
        desc = "References",
      },
      {
        "gI",
        function()
          fzf.lsp_implementations({ jump1 = true })
        end,
        desc = "Goto Implementation",
      },
      {
        "gy",
        function()
          fzf.lsp_typedefs({ jump1 = true })
        end,
        desc = "Goto Type Definition",
      },
    })
  end,
}
