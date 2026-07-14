local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local f = ls.function_node
local fmt = require("luasnip.extras.fmt").fmt

local function make_md_fence(lang)
  return s(
    { trig = lang, dscr = "Insert " .. lang .. " fenced code block" },
    fmt(
      string.format(
        [[
```%s
{}
```]],
        lang
      ),
      { i(1, "code") }
    )
  )
end

-- Pads the current line (from cursor position) with '-' up to 62 columns.
local function dash_to_62()
  return s(
    {
      trig = "-",
      name = "Fill line to 62 with dashes",
      dscr = "Pad with '-' until the line has 62 columns",
      wordTrig = false,
    },
    f(function(_)
      local col = vim.fn.col(".")
      local total = 62
      local n = math.max(total - col + 1, 0)
      return string.rep("-", n)
    end)
  )
end

ls.add_snippets("markdown", {
  make_md_fence("py"),
  make_md_fence("sh"),
  make_md_fence("fish"),
  make_md_fence("bash"),
  make_md_fence("json"),
  dash_to_62(),
})
