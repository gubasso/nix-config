return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons", "folke/todo-comments.nvim" },
  opts = {
    modes = {
      -- Override the built-in quickfix mode to be FLAT: one item per line, no
      -- collapsible file-header tree. This is the shared "quickfix without tree"
      -- surface -- <leader>xQ, and yazi.nvim's <c-q> multi-file send all use it.
      qflist = {
        source = "qf",
        groups = {}, -- flat: no file-header tree grouping
        format = "{file_icon} {text} {pos}",
        focus = true,
      },
      -- Flat, no-auto-open list used by the fugitive commit-file picker
      -- (<cr>/ctrl-q: current working version of the selected files).
      -- One line per file; nothing opens/previews on cursor move — only on <CR>.
      git_commit_files = {
        source = "qf.qflist", -- read the quickfix list we just populated
        groups = {}, -- flat: no file-header tree grouping
        format = "{file_icon} {text}", -- one line per file (text = the rel path we set)
        auto_preview = false, -- do not open/preview the item on cursor move
        auto_jump = false,
        follow = false,
        focus = true, -- land the cursor in the list to navigate it
      },
      -- Same flat list, but for the fugitive picker's ctrl-y ("diff format"):
      -- opening an item shows THAT file's patch at the commit (0Git show <sha> --
      -- <file>) instead of editing the working file. The commit is passed in via
      -- vim.g.git_commit_diff_sha, set right before this mode is opened.
      git_commit_diffs = {
        source = "qf.qflist",
        groups = {},
        format = "{file_icon} {text}",
        auto_preview = false,
        auto_jump = false,
        follow = false,
        focus = true,
        keys = {
          ["<cr>"] = {
            action = function(view, ctx)
              local sha = vim.g.git_commit_diff_sha
              local file = ctx.item and ctx.item.filename
              if not sha or not file then
                return
              end
              view:close()
              vim.cmd("0Git show " .. sha .. " -- " .. vim.fn.fnameescape(file))
            end,
            desc = "Show file diff at commit",
          },
          ["o"] = {
            action = function(_view, ctx)
              local sha = vim.g.git_commit_diff_sha
              local file = ctx.item and ctx.item.filename
              if not sha or not file then
                return
              end
              vim.cmd("Git show " .. sha .. " -- " .. vim.fn.fnameescape(file))
            end,
            desc = "Show file diff at commit (split)",
          },
        },
      },
    },
  },
  cmd = "Trouble",
  keys = {
    { "<leader>xw", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
    {
      "<leader>xd",
      "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
      desc = "Buffer Diagnostics (Trouble)",
    },
    { "<leader>xcs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
    {
      "<leader>xcl",
      "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
      desc = "LSP Definitions / references / ... (Trouble)",
    },
    { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
    { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
  },
}
