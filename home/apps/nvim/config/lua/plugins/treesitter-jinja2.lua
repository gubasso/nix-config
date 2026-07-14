return {
  "geigerzaehler/tree-sitter-jinja2",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  build = ":TSUpdate",
  config = function()
    -- Legacy parser-registration API (get_parser_configs) exists only on
    -- nvim-treesitter `master`. On `main` it is gone; jinja2 highlighting
    -- requires a different install path. Guard so startup does not crash.
    local ok, parsers = pcall(require, "nvim-treesitter.parsers")
    if ok and type(parsers.get_parser_configs) == "function" then
      local parser_config = parsers.get_parser_configs()
      parser_config.jinja2 = {
        install_info = {
          url = "https://github.com/geigerzaehler/tree-sitter-jinja2",
          branch = "main",
          files = { "src/parser.c" },
        },
        filetype = "jinja2",
      }
    end
    -- Filetype detection for .py.j2 -> python.jinja2
    vim.filetype.add({
      pattern = {
        [".*%.py%.j2"] = "python.jinja2",
      },
    })
  end,
}
