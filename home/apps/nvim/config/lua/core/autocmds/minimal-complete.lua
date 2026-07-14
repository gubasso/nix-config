-- Minimal autocomplete using built-in keyword completion (<C-n>).
-- Debounced trigger avoids fighting with user keystrokes.
local api = vim.api
local fn = vim.fn

local function augroup(name)
  return api.nvim_create_augroup(name, { clear = true })
end

vim.opt.completeopt = { "menu", "menuone", "noinsert", "noselect" }

local timer = vim.uv.new_timer()
local C_n = api.nvim_replace_termcodes("<C-n>", true, false, true)
local C_e = api.nvim_replace_termcodes("<C-e>", true, false, true)

-- Debounced completion trigger: resets on every keystroke, fires after 100ms pause.
api.nvim_create_autocmd("TextChangedI", {
  group = augroup("minimal_complete_trigger"),
  callback = function()
    timer:stop()
    timer:start(
      100,
      0,
      vim.schedule_wrap(function()
        if api.nvim_get_mode().mode ~= "i" then
          return
        end
        if fn.pumvisible() == 1 then
          return
        end
        local col = fn.col(".") - 1
        if col < 2 then
          return
        end
        local line = api.nvim_get_current_line()
        local prefix = line:sub(1, col):match("[%w_]+$")
        if prefix and #prefix >= 2 then
          api.nvim_feedkeys(C_n, "n", false)
        end
      end)
    )
  end,
})

-- Dismiss popup and stop timer when leaving insert mode.
api.nvim_create_autocmd("InsertLeave", {
  group = augroup("minimal_complete_dismiss"),
  callback = function()
    timer:stop()
    if fn.pumvisible() == 1 then
      api.nvim_feedkeys(C_e, "n", false)
    end
  end,
})
