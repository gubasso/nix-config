local keymaps = require("core.utils.keymaps")

return {
  "williamboman/mason-lspconfig.nvim",
  dependencies = {
    "williamboman/mason.nvim",
    "neovim/nvim-lspconfig",
    "hrsh7th/cmp-nvim-lsp",
    "ibhagwan/fzf-lua",
  },
  config = function()
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    require("mason").setup()

    -- Shared defaults for all LSP configs.
    vim.lsp.config("*", { capabilities = capabilities })

    -- Server-specific settings.
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
        },
      },
    })

    vim.lsp.config("rust_analyzer", {
      settings = {
        ["rust-analyzer"] = {
          checkOnSave = { allFeatures = true, command = "clippy", extraArgs = { "--no-deps" } },
        },
      },
    })

    vim.lsp.config("pyright", {
      settings = {
        pyright = { disableOrganizeImports = true },
        python = { analysis = { ignore = { "*" } } },
      },
    })

    local ensure_installed = {
      "bashls",
      "lua_ls",
      "vimls",
      "rust_analyzer",
      "svelte",
      "html",
      "emmet_language_server",
      "ts_ls",
      "cssls",
      "eslint",
      "pyright",
      "ruff",
      "marksman",
      "yamlls",
      "texlab",
    }

    require("mason-lspconfig").setup({
      ensure_installed = ensure_installed,
    })

    -- Zig: project-managed zls (not Mason-installed, to match project Zig version).
    if vim.fn.executable("zls") == 1 then
      vim.lsp.enable("zls")
    end
  end,
  keys = {
    { "<leader>cd", vim.diagnostic.open_float, desc = "Line Diagnostics" },
    { "<leader>cl", "<cmd>LspInfo<cr>", desc = "Lsp Info" },
    { "K", vim.lsp.buf.hover, desc = "Hover" },
    { "gK", vim.lsp.buf.signature_help, desc = "Signature Help" },
    { "]d", keymaps.diagnostic_goto(true), desc = "Next Diagnostic" },
    { "[d", keymaps.diagnostic_goto(false), desc = "Prev Diagnostic" },
    { "]e", keymaps.diagnostic_goto(true, "ERROR"), desc = "Next Error" },
    { "[e", keymaps.diagnostic_goto(false, "ERROR"), desc = "Prev Error" },
    { "]w", keymaps.diagnostic_goto(true, "WARN"), desc = "Next Warning" },
    { "[w", keymaps.diagnostic_goto(false, "WARN"), desc = "Prev Warning" },
    { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "v" } },
    {
      "<leader>cA",
      function()
        vim.lsp.buf.code_action({
          context = {
            only = {
              "source",
            },
            diagnostics = {},
          },
        })
      end,
      desc = "Source Action",
    },
  },
}
