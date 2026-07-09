-- MdNew: Create/open a Markdown file from a title
local uv = vim.uv or vim.loop
local paths = require("core.utils.paths")
local strings = require("core.utils.strings")

local M = {}

function M.prompt()
  local keys = vim.api.nvim_replace_termcodes(':MdNew ""<Left>', true, false, true)
  vim.api.nvim_feedkeys(keys, "n", false)
end

function M.setup()
  vim.api.nvim_create_user_command("MdNew", function(opts)
    local title = strings.strip_outer_quotes(opts.args)
    if title == "" then
      vim.notify('MdNew: title is required (e.g. :MdNew "My Title")', vim.log.levels.ERROR)
      return
    end

    local dir = paths.target_dir_for_current_buffer()
    local target_name = strings.slugify(title) .. ".md"
    local target_path = vim.fs.joinpath(dir, target_name)

    local existed = (uv.fs_stat(target_path) ~= nil)

    vim.api.nvim_cmd({ cmd = "edit", args = { target_path } }, {})

    local buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local is_empty = (#lines == 0) or (#lines == 1 and lines[1] == "")

    if (not existed) or is_empty then
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "# " .. title,
        "",
        "",
      })
      vim.api.nvim_win_set_cursor(0, { vim.api.nvim_buf_line_count(buf), 0 })
      if not existed then
        vim.api.nvim_buf_call(buf, function()
          vim.api.nvim_cmd({ cmd = "write", mods = { silent = true } }, {})
        end)
      end
    end
  end, {
    nargs = "+",
    desc = "Create/open a Markdown file from a title; fallback to project root if buffer has no file",
  })
end

return M
