-- MdDirNew: Create a directory with README.md from a title
local uv = vim.uv or vim.loop
local paths = require("core.utils.paths")
local strings = require("core.utils.strings")

local M = {}

function M.prompt()
  local keys = vim.api.nvim_replace_termcodes(':MdDirNew ""<Left>', true, false, true)
  vim.api.nvim_feedkeys(keys, "n", false)
end

function M.setup()
  vim.api.nvim_create_user_command("MdDirNew", function(opts)
    local title = strings.strip_outer_quotes(opts.args)
    if title == "" then
      vim.notify('MdDirNew: title is required (e.g. :MdDirNew "My Title")', vim.log.levels.ERROR)
      return
    end

    local base_dir = paths.target_dir_for_current_buffer()
    local dir_name = strings.slugify(title)
    local dir_path = vim.fs.joinpath(base_dir, dir_name)
    local readme_path = vim.fs.joinpath(dir_path, "README.md")

    -- Create directory if it doesn't exist
    if not uv.fs_stat(dir_path) then
      vim.fn.mkdir(dir_path, "p")
    end

    local existed = (uv.fs_stat(readme_path) ~= nil)

    vim.api.nvim_cmd({ cmd = "edit", args = { readme_path } }, {})

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
    desc = "Create a directory with README.md from a title",
  })
end

return M
