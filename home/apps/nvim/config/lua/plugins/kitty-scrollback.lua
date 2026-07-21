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

    -- after_ready: clear the quit-on-yank autocmd, then position the cursor.
    --
    -- WHY (yank no longer exits the buffer):
    -- The auto-exit is a hardcoded `TextYankPost` autocmd in the augroup
    -- `KittyScrollBackNvimTextYankPost`. Whenever a yank lands in the `+`
    -- (system clipboard) register and a clipboard tool exists, it defers a
    -- `ksb_util.quitall()` (200ms for xclip, else 0ms). It is registered
    -- UNCONDITIONALLY by `load_autocmds()` and is NOT gated by any opt
    -- (`keymaps_enabled` does not affect it). There is no built-in option to
    -- disable it. The default `<leader>y` keymaps just do `"+y`, so the quit
    -- comes purely from this autocmd. We remove it here. `load_autocmds()`
    -- (launch.lua:360) runs before this `vim.schedule`'d callback
    -- (launch.lua:416-417), so the clear reliably lands before any yank.
    -- `pcall` guards the no-clipboard case where the autocmd was never set.
    local function on_ready(_kitty_data, _opts)
      pcall(vim.api.nvim_clear_autocmds, { group = "KittyScrollBackNvimTextYankPost" })
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
