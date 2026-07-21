-- kitty-scrollback.nvim - Browse kitty scrollback in Neovim
-- After install: nvim --headless +'KittyScrollbackGenerateKittens' +qa

return {
  "mikesmithgh/kitty-scrollback.nvim",
  lazy = true,
  cmd = { "KittyScrollbackGenerateKittens", "KittyScrollbackCheckHealth" },
  event = { "User KittyScrollbackLaunch" },
  config = function()
    local function goto_last_written_line()
      local last_line = vim.fn.line("$")
      while last_line > 1 and vim.fn.getline(last_line):match("^%s*$") do
        last_line = last_line - 1
      end
      vim.api.nvim_win_set_cursor(0, { last_line, 0 })
    end

    -- Read a buffer's lines and strip trailing blank lines. The scrollback is a
    -- terminal buffer whose grid is padded with empty lines up to the window
    -- height; this returns just the real captured text.
    local function trimmed_lines(bufid)
      local lines = vim.api.nvim_buf_get_lines(bufid, 0, -1, false)
      while #lines > 0 and lines[#lines]:match("^%s*$") do
        table.remove(lines)
      end
      return lines
    end

    -- after_ready: swap the terminal scrollback buffer for a plain editable
    -- scratch buffer holding the same text, so i/a/o are NATIVE insert.
    --
    -- WHY (the terminal buffer is the root problem):
    -- The scrollback content is loaded via jobstart({ term = true }) / termopen
    -- into the pager buffer (kitty_commands.lua:58,144-146), so it is a genuine
    -- `term://` buffer. The one-shot `kitten @ get-text` job exits before this
    -- callback fires, but Neovim keeps `buftype=terminal` for the buffer's life.
    -- On a terminal buffer, i/a/o enter TERMINAL MODE (feed keys to the dead job)
    -- and snap the view to the grid cursor -- which sits below the captured text,
    -- in the blank padding -- so editing appears to "jump to the end then go
    -- blank". No amount of `modifiable`/autocmd-clearing changes this: terminal
    -- mode is intrinsic to terminal buffers. The only robust fix is to leave the
    -- terminal buffer behind. We copy its text into a fresh `nofile` scratch
    -- buffer and show that in the pager window instead.
    --
    -- Trade-off: the scratch buffer is plain text -- the terminal's ANSI colors
    -- (terminal-cell highlights, not text) are lost. That is the cost of native
    -- editing, and fine for the massage-then-yank workflow.
    --
    -- We still clear `KittyScrollBackNvimTextYankPost` so yank does NOT quit the
    -- pager (a deliberate preference); and because the plugin's own `q`/quit
    -- keymaps live on the now-hidden terminal buffer and gate on it, we add a
    -- buffer-local `q` -> quitall! on the scratch buffer (quitting nvim closes
    -- the kitty overlay). `load_autocmds()` (launch.lua:360) runs before this
    -- `vim.schedule`'d callback (launch.lua:416-417), so the clear lands first.
    -- Refs (commit 9342a0e): kitty_commands.lua:58,144-146 (term=true);
    -- launch.lua:350-358 (buffer + window), :416-417 (after_ready).
    local function on_ready(_kitty_data, _opts)
      pcall(vim.api.nvim_clear_autocmds, { group = "KittyScrollBackNvimTextYankPost" })

      local lines = trimmed_lines(vim.api.nvim_get_current_buf())
      local buf = vim.api.nvim_create_buf(false, true) -- unlisted scratch (nofile)
      vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
      vim.api.nvim_set_option_value("swapfile", false, { buf = buf })
      vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      vim.api.nvim_win_set_buf(0, buf) -- current window is the pager window here

      vim.keymap.set("n", "q", "<cmd>quitall!<cr>", { buffer = buf, nowait = true })

      goto_last_written_line()
    end

    -- Keep the tab name while browsing scrollback. The plugin's kitten launches
    -- the pager as an overlay with a hardcoded, launch-LOCKED
    -- `--title kitty-scrollback.nvim`, and kitty derives the tab title from the
    -- active window's title -- so the tab reads "kitty-scrollback.nvim" until the
    -- pager closes. A permanent remote-control set-window-title overrides even a
    -- launch-locked title, so we stamp the originating window's title
    -- (kitty_data.window_title, passed to every callback) onto the overlay. Fired
    -- from after_launch -- the earliest per-launch callback -- to avoid a flash of
    -- the plugin name. Mirrors the shell precmd's `kitten @ set-window-title`
    -- (kitty.conf remote control: allow_remote_control socket-only + listen_on,
    -- inherited by the overlay via the kitten's --copy-env).
    local function restore_tab_title(kitty_data, _opts)
      local title = kitty_data and kitty_data.window_title
      if type(title) == "string" and title ~= "" then
        pcall(vim.system, { "kitten", "@", "set-window-title", title })
      end
    end

    -- IMPORTANT: the config that applies to ALL launches must be at the first
    -- POSITIONAL index `[1]` of the setup table -- NOT under a key named
    -- `default`. launch.lua reads the global config as `configs[1]`:
    --     local global_opts = config_to_opts(config_source.configs[1])
    --     opts = vim.tbl_deep_extend('force', defaults, global_opts, builtin_opts, user_opts)
    -- A `default = {...}` key is silently ignored (it is neither index [1],
    -- nor a `ksb_builtin_*` name, nor the launched config name). `space e n`
    -- launches with no `--config`, which resolves to `ksb_builtin_get_text_all`
    -- (launch.lua:237) -- a `default`/`ksb_builtin_last_cmd_output`-only config
    -- never reaches it, so `after_ready` never fired. Index [1] covers every
    -- launch (full scrollback `n`, last-cmd `ctrl+n`, etc.) at once.
    --
    -- Refs (pinned commit 9342a0e):
    --   autocommands.lua -- augroup + unconditional quit-on-`+`-yank:
    --     https://github.com/mikesmithgh/kitty-scrollback.nvim/blob/9342a0e0e5556ce0b7f9dc41c4bdd39ae9dc85dd/lua/kitty-scrollback/autocommands.lua
    --   launch.lua -- configs[1] global merge, default config name, load order:
    --     https://github.com/mikesmithgh/kitty-scrollback.nvim/blob/9342a0e0e5556ce0b7f9dc41c4bdd39ae9dc85dd/lua/kitty-scrollback/launch.lua
    --   configs/builtin.lua -- ksb_builtin_get_text_all is the no-`--config` default:
    --     https://github.com/mikesmithgh/kitty-scrollback.nvim/blob/9342a0e0e5556ce0b7f9dc41c4bdd39ae9dc85dd/lua/kitty-scrollback/configs/builtin.lua
    require("kitty-scrollback").setup({
      {
        callbacks = {
          after_launch = restore_tab_title,
          after_ready = on_ready,
        },
      },
    })
  end,
}
