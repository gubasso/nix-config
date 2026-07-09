-- Mixed-language injection (Python + Jinja2 in .py.j2 files)
return {
  "cathaysia/nvim-jinja",
  dependencies = { "nvim-treesitter/nvim-treesitter", "geigerzaehler/tree-sitter-jinja2" },
  ft = { "jinja2", "htmljinja", "python.jinja2" },
}
