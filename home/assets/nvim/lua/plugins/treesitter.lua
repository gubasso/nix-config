-- nvim-treesitter `main` branch (Nvim 0.12+).
-- Upstream archived the repo on 2026-04-03; `master` is frozen for
-- Nvim 0.11 back-compat and crashes on 0.12 inside query_predicates
-- when parsing markdown injections (mini.files preview on .md files).
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  -- `:TSUpdate` re-compiles parsers and re-creates query symlinks whenever
  -- lazy.nvim updates the plugin (the symlink targets change on re-clone).
  -- On the main branch `:TSUpdate` only touches installed parsers, not every
  -- registered grammar, so stale metadata (e.g. `rasi`) is not a concern.
  build = ":TSUpdate",
  lazy = false,
  dependencies = {
    {
      "nvim-treesitter/nvim-treesitter-textobjects",
      branch = "main",
    },
  },
  config = function()
    -- `nvim-treesitter.config` exists only on the `main` branch. If it's
    -- missing, the checkout is still the legacy `master` (lazy-lock not yet
    -- synced): bail gracefully so startup survives and `:Lazy sync` is usable.
    local cfg_ok, cfg = pcall(require, "nvim-treesitter.config")
    if not cfg_ok then
      vim.schedule(function()
        vim.notify("nvim-treesitter is still on `master` — run `:Lazy sync` and restart Neovim.", vim.log.levels.WARN)
      end)
      return
    end

    -- Explicit install_dir is required: lazy.nvim's rtp reset strips the
    -- default site directory, and setup() only re-prepends it to rtp when
    -- install_dir is explicitly provided.
    require("nvim-treesitter").setup({
      install_dir = vim.fn.stdpath("data") .. "/site",
    })

    -- Queries live in <plugin>/runtime/queries/ but lazy.nvim only adds
    -- <plugin>/ to rtp.  install() symlinks them into install_dir, but the
    -- symlinks break on re-clone or master→main migration.  Appending the
    -- plugin's runtime/ dir makes bundled queries a reliable fallback
    -- (install_dir is prepended above, so proper symlinks still win).
    local ts_init = vim.api.nvim_get_runtime_file("lua/nvim-treesitter/init.lua", false)[1]
    if ts_init then
      local runtime_dir = vim.fs.joinpath(vim.fn.fnamemodify(ts_init, ":h:h:h"), "runtime")
      if vim.uv.fs_stat(runtime_dir) then
        vim.opt.rtp:append(runtime_dir)
      end
    end

    local ensure_installed = {
      "astro",
      "bash",
      "c",
      "css",
      "desktop",
      "diff",
      "dockerfile",
      -- Install the matched parser+query pair so highlighting works and
      -- overrides the system runtime's skewed query (its highlights.scm
      -- references a `(property)` node the grammar no longer defines, which
      -- crashes the fzf-lua builtin previewer on `.editorconfig`).
      "editorconfig",
      "git_config",
      "git_rebase",
      "gitattributes",
      "gitcommit",
      "gitignore",
      "glimmer",
      "graphql",
      "html",
      "ini",
      "javascript",
      "jsdoc",
      "json",
      "lua",
      "luadoc",
      "luap",
      "markdown",
      "markdown_inline",
      "python",
      "query",
      "readline",
      "regex",
      "ron",
      "rust",
      "scss",
      "sql",
      "ssh_config",
      "svelte",
      "toml",
      "typescript",
      "vim",
      "vimdoc",
      "xml",
      "yaml",
      "zig",
    }

    local installed = cfg.get_installed()
    local to_install = vim
      .iter(ensure_installed)
      :filter(function(p)
        return not vim.tbl_contains(installed, p)
      end)
      :totable()
    if #to_install > 0 then
      require("nvim-treesitter").install(to_install)
    end

    -- main branch does not auto-enable highlight/indent; we opt-in per buffer.
    local function enable_treesitter(buf)
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      if pcall(vim.treesitter.start, buf) then
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
      end
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("user_treesitter_enable", { clear = true }),
      callback = function(args)
        enable_treesitter(args.buf)
      end,
    })

    vim.api.nvim_create_autocmd("User", {
      pattern = "TSUpdate",
      group = vim.api.nvim_create_augroup("user_treesitter_reattach", { clear = true }),
      callback = function()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buftype == "" then
            enable_treesitter(buf)
          end
        end
      end,
    })

    -- Incremental selection was part of the legacy `nvim-treesitter.configs`
    -- module and is not available on the `main` branch; the previous
    -- <C-Space>/<BS> mappings are intentionally dropped here (C-Space is
    -- already bound to nvim-cmp completion).
    --
    -- textobjects (main branch): select + move only. Swap/LSP-peek omitted.
    local ok_to, textobjects = pcall(require, "nvim-treesitter-textobjects")
    if ok_to then
      textobjects.setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      local select = require("nvim-treesitter-textobjects.select").select_textobject
      local move = require("nvim-treesitter-textobjects.move")
      local map = vim.keymap.set

      local selects = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
        ["aa"] = "@parameter.outer",
        ["ia"] = "@parameter.inner",
      }
      for lhs, query in pairs(selects) do
        map({ "x", "o" }, lhs, function()
          select(query, "textobjects")
        end, { desc = "Textobject " .. query })
      end

      map({ "n", "x", "o" }, "]m", function()
        move.goto_next_start("@function.outer", "textobjects")
      end, { desc = "Next function start" })
      map({ "n", "x", "o" }, "]]", function()
        move.goto_next_start("@class.outer", "textobjects")
      end, { desc = "Next class start" })
      map({ "n", "x", "o" }, "]M", function()
        move.goto_next_end("@function.outer", "textobjects")
      end, { desc = "Next function end" })
      map({ "n", "x", "o" }, "][", function()
        move.goto_next_end("@class.outer", "textobjects")
      end, { desc = "Next class end" })
      map({ "n", "x", "o" }, "[m", function()
        move.goto_previous_start("@function.outer", "textobjects")
      end, { desc = "Prev function start" })
      map({ "n", "x", "o" }, "[[", function()
        move.goto_previous_start("@class.outer", "textobjects")
      end, { desc = "Prev class start" })
      map({ "n", "x", "o" }, "[M", function()
        move.goto_previous_end("@function.outer", "textobjects")
      end, { desc = "Prev function end" })
      map({ "n", "x", "o" }, "[]", function()
        move.goto_previous_end("@class.outer", "textobjects")
      end, { desc = "Prev class end" })
    end
  end,
}
