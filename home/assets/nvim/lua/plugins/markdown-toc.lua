return {
  "mzlogin/vim-markdown-toc",
  config = function()
    vim.g.vmt_fence_text = "toc"
    vim.g.vmt_cycle_list_item_markers = 1
    vim.g.vmt_fence_hidden_markdown_style = ""
  end,
}
