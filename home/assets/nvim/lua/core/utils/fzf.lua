-- Shared fzf-lua helpers.
--
-- SoT for rendering arbitrary shell-command output inside fzf-lua's *builtin*
-- previewer, so custom pickers (e.g. the fugitive commit / git-review pickers)
-- get the same native-buffer preview UX as the standard file/grep pickers:
-- Treesitter/`filetype` highlighting, focusable via <M-p>, scrollable via
-- <M-d>/<M-u>, plus the modal-nav keymaps from `winopts.on_create`. Passing a
-- string `preview` instead would force fzf's terminal previewer and lose all of
-- that (see lua/plugins/fzf-lua.lua for the shared winopts).

local M = {}

--- Build an `opts.previewer` spec (fzf-lua's `_ctor` contract) that renders a
--- shell command's output into the builtin previewer — a real Neovim buffer.
--- `build_cmd(entry)` returns the full shell command for the selected entry;
--- `filetype` sets buffer highlighting (e.g. "git" or "diff").
---
--- Do NOT emit `--color` in `build_cmd`: a native buffer shows raw ANSI escapes
--- as garbage — highlighting comes from `filetype`, not ANSI. `build_cmd` owns
--- quoting the entry (fzf used to quote the `{1}` field for us).
---
--- fzf-lua instantiates via `preview_opts._ctor()(preview_opts, opts)`
--- (previewer/init.lua), so `_ctor` returns the previewer *class*. We subclass
--- the builtin `base` and override only `populate_preview_buf`; `new`,
--- `get_tmp_buffer`, `set_preview_buf` (wires `i`=back-to-query) and
--- `gen_winopts` (honors the shared `winopts.preview.wrap`) are inherited.
function M.cmd_previewer(build_cmd, filetype)
  return {
    _ctor = function()
      local P = require("fzf-lua.previewer.builtin").base:extend()
      function P:populate_preview_buf(entry_str)
        if not self.win or not self.win:validate_preview() then
          return
        end
        local buf = self:get_tmp_buffer()
        local entry = vim.trim(entry_str)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.fn.systemlist(build_cmd(entry)))
        vim.bo[buf].filetype = filetype
        self:set_preview_buf(buf)
        self.win:update_preview_scrollbar()
      end
      return P
    end,
  }
end

return M
