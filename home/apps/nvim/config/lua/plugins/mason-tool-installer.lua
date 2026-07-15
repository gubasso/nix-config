return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig", "williamboman/mason-lspconfig.nvim" },
  config = function()
    local opts = {
      ensure_installed = {
        "bash-language-server",
        "lua-language-server",
        "vim-language-server",
        "stylua",
        "shellcheck",
        "editorconfig-checker",
        "json-to-struct",
        "misspell",
        "rust-analyzer",
        "doctoc",
        "prettier",
        -- tree-sitter CLI comes from nix (home/apps/nvim/default.nix), per
        -- nvim-treesitter `main` upstream guidance to NOT install it via npm.
        "texlab",
        "flake8",
      },
      auto_update = true,
      run_on_start = #vim.api.nvim_list_uis() > 0,
    }
    require("mason-tool-installer").setup(opts)
  end,
}
