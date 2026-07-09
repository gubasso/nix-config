local function toggle_metadata_insert(tag_name)
  local line = vim.api.nvim_get_current_line()
  local has_tag = line:find("@" .. tag_name .. "%(") ~= nil
  require("checkmate").toggle_metadata(tag_name)
  if not has_tag then
    vim.schedule(function()
      vim.schedule(function()
        vim.cmd("startinsert")
      end)
    end)
  end
end

return {
  "bngarren/checkmate.nvim",
  ft = "markdown",
  dependencies = { "nvim-lua/plenary.nvim", "L3MON4D3/LuaSnip" },
  keys = {
    {
      "<leader>tt",
      function()
        require("checkmate").toggle()
      end,
      desc = "Toggle todo item",
      mode = { "n", "v" },
      ft = "markdown",
    },
    {
      "<leader>tc",
      function()
        require("checkmate").check()
      end,
      desc = "Set todo item as checked (done)",
      mode = { "n", "v" },
      ft = "markdown",
    },
    {
      "<leader>tu",
      function()
        require("checkmate").uncheck()
      end,
      desc = "Set todo item as unchecked (not done)",
      mode = { "n", "v" },
      ft = "markdown",
    },
    {
      "<leader>t=",
      function()
        require("checkmate").cycle()
      end,
      desc = "Cycle todo item(s) to the next state",
      mode = { "n", "v" },
      ft = "markdown",
    },
    {
      "<leader>t-",
      function()
        require("checkmate").cycle({ backward = true })
      end,
      desc = "Cycle todo item(s) to the previous state",
      mode = { "n", "v" },
      ft = "markdown",
    },
    {
      "<leader>tn",
      function()
        require("checkmate").create()
      end,
      desc = "Create todo item",
      mode = { "n", "v" },
      ft = "markdown",
    },
    {
      "<C-t>",
      function()
        require("checkmate").create()
      end,
      desc = "Create todo item (insert mode)",
      mode = "i",
      ft = "markdown",
    },
    {
      "<leader>tR",
      function()
        require("checkmate").remove()
      end,
      desc = "Remove todo marker (convert to text)",
      mode = { "n", "v" },
      ft = "markdown",
    },
    {
      "<leader>tr",
      function()
        require("checkmate").remove_all_metadata()
      end,
      desc = "Metadata: Remove all from todo",
      mode = { "n", "v" },
      ft = "markdown",
    },
    {
      "<leader>tg",
      function()
        toggle_metadata_insert("group")
      end,
      desc = "Metadata: Toggle @group",
      ft = "markdown",
    },
    {
      "<leader>tS",
      function()
        toggle_metadata_insert("status")
      end,
      desc = "Metadata: Toggle @status",
      ft = "markdown",
    },
    {
      "<leader>tp",
      function()
        require("checkmate").toggle_metadata("priority")
      end,
      desc = "Metadata: Toggle @priority",
      ft = "markdown",
    },
    {
      "<leader>ts",
      function()
        require("checkmate").toggle_metadata("started")
      end,
      desc = "Metadata: Toggle @started",
      ft = "markdown",
    },
    {
      "<leader>td",
      function()
        require("checkmate").toggle_metadata("done")
      end,
      desc = "Metadata: Toggle @done",
      ft = "markdown",
    },
    {
      "<leader>ta",
      function()
        require("checkmate").archive()
      end,
      desc = "Archive checked/completed todo items",
      ft = "markdown",
    },
    {
      "<leader>tf",
      function()
        require("checkmate").select_todo()
      end,
      desc = "Open a picker to select a todo",
      ft = "markdown",
    },
    {
      "<leader>tv",
      function()
        require("checkmate").select_metadata_value()
      end,
      desc = "Metadata: Select value under cursor",
      ft = "markdown",
    },
    {
      "<leader>t]",
      function()
        require("checkmate").jump_next_metadata()
      end,
      desc = "Metadata: Jump to next tag",
      ft = "markdown",
    },
    {
      "<leader>t[",
      function()
        require("checkmate").jump_previous_metadata()
      end,
      desc = "Metadata: Jump to previous tag",
      ft = "markdown",
    },
  },
  config = function()
    local function collect_metadata_values(tag_name)
      local paths = require("core.utils.paths")
      local root = paths.get_project_root(paths.target_dir_for_current_buffer())
      local result = vim.fn.system({
        "rg",
        "--no-filename",
        "--no-line-number",
        "--only-matching",
        "--color=never",
        "--glob=*.md",
        "@" .. tag_name .. [[\(([^)]+)\)]],
        root,
      })
      local seen = {}
      local values = {}
      for val in result:gmatch("[^\n]+") do
        val = val:match("@" .. tag_name .. "%((.+)%)") or val
        val = vim.trim(val)
        if val ~= "" and not seen[val] then
          seen[val] = true
          values[#values + 1] = val
        end
      end
      table.sort(values)
      return values
    end

    require("checkmate").setup({
      -- Default file patterns: todo.md, TODO.md, *.todo, *.todo.md
      -- Uncomment to activate on ALL markdown files:
      files = { "*.md" },

      default_list_marker = "-",
      show_todo_count = true,

      -- List continuation: auto-create todos on Enter
      list_continuation = {
        enabled = true,
        split_line = true,
      },

      -- Smart toggle: check/uncheck cascades to direct children/parents
      smart_toggle = {
        enabled = true,
        check_down = "direct_children",
        uncheck_down = "none",
        check_up = "direct_children",
        uncheck_up = "direct_children",
      },

      -- Archive completed items under ## Archive heading
      archive = {
        heading = { title = "Archive", level = 2 },
        newest_first = true,
      },

      -- Metadata tags
      metadata = {
        priority = {
          style = function(ctx)
            local v = ctx.value:lower()
            if v == "high" then
              return { fg = "#ff5555", bold = true }
            end
            if v == "medium" then
              return { fg = "#ffb86c" }
            end
            return { fg = "#8be9fd" }
          end,
          choices = { "high", "medium", "low" },
          get_value = function()
            return "medium"
          end,
          sort_order = 10,
          jump_to_on_insert = "value",
          select_on_insert = true,
        },
        started = {
          aliases = { "init" },
          style = { fg = "#9fd6d5" },
          get_value = function()
            return tostring(os.date("!%Y-%m-%dT%H:%M:%SZ"))
          end,
          sort_order = 20,
        },
        group = {
          style = { fg = "#bd93f9", italic = true },
          choices = function()
            return collect_metadata_values("group")
          end,
          get_value = function()
            return ""
          end,
          select_on_insert = false,
          jump_to_on_insert = "value",
          sort_order = 5,
        },
        status = {
          style = { fg = "#bd93f9", italic = true },
          choices = function()
            return collect_metadata_values("status")
          end,
          get_value = function()
            return ""
          end,
          select_on_insert = false,
          jump_to_on_insert = "value",
          sort_order = 6,
        },
        done = {
          aliases = { "completed", "finished" },
          style = { fg = "#96de7a" },
          get_value = function()
            return tostring(os.date("!%Y-%m-%dT%H:%M:%SZ"))
          end,
          on_add = function(todo)
            require("checkmate").set_todo_state(todo, "checked")
          end,
          on_remove = function(todo)
            require("checkmate").set_todo_state(todo, "unchecked")
          end,
          sort_order = 30,
        },
      },

      -- Disable checkmate-managed keymaps (using lazy.nvim keys instead)
      keys = false,
    })

    local ls = require("luasnip")
    local cms = require("checkmate.snippets")
    ls.add_snippets("markdown", {
      cms.todo({
        trigger = ".todo",
        desc = "Insert todo item",
        text = "",
        metadata = {},
      }),
      cms.todo({
        trigger = ".todop",
        desc = "Insert todo item with @priority",
        text = "",
        metadata = { priority = true },
      }),
      cms.todo({
        trigger = ".todog",
        desc = "Insert todo item with @group",
        text = "",
        metadata = { group = true },
      }),
      cms.metadata({
        trigger = ".todosb",
        tag = "status",
        value = "backlog",
        desc = "Set @status(backlog)",
      }),
      cms.metadata({
        trigger = ".todost",
        tag = "status",
        value = "todo",
        desc = "Set @status(todo)",
      }),
      cms.metadata({
        trigger = ".todosd",
        tag = "status",
        value = "doing",
        desc = "Set @status(doing)",
      }),
      cms.metadata({
        trigger = ".todosrt",
        tag = "status",
        value = "review-todo",
        desc = "Set @status(review-todo)",
      }),
      cms.metadata({
        trigger = ".todosrd",
        tag = "status",
        value = "review-doing",
        desc = "Set @status(review-doing)",
      }),
    })
  end,
}
