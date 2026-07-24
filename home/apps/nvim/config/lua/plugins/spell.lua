-- Automatic spelllang detection for prose buffers.
--
-- vim-DetectSpellLang samples the buffer, runs it through hunspell for each
-- candidate language, and sets &spelllang to the single best match (avoiding the
-- false-negatives of a multi-dictionary "en_us,pt_br" list). hunspell only picks
-- the language; Neovim's own .spl files do the actual spell checking (en ships
-- with Neovim, pt is bundled as spell/pt.utf-8.spl). The hunspell binary + dicts
-- come from Nix (see home/apps/nvim/default.nix). Manual overrides remain: ,e / ,p
-- to force a language, ,s to toggle spell (see core/autocmds/filetypes.lua).
--
-- Globals must be set before the plugin loads, so they live in `init`.
return {
  "Konfekt/vim-DetectSpellLang",
  ft = { "gitcommit", "markdown", "text", "rst", "asciidoc" },
  init = function()
    vim.g.detectspelllang_program = "hunspell"
    vim.g.detectspelllang_langs = { hunspell = { "en_US", "pt_BR" } }
  end,
}
