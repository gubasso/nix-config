-- Linting: Run nvim-lint on save
local api = vim.api

local function augroup(name)
  return api.nvim_create_augroup(name, { clear = true })
end

api.nvim_create_autocmd({ "BufWritePost" }, {
  group = augroup("lint_on_save"),
  callback = function()
    require("lint").try_lint()
  end,
})
