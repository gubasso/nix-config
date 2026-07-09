# Repository Guidelines

## Project Structure & Module Organization

- `init.lua` is the entry point; it bootstraps `lazy.nvim`, loads `lua/core`, and imports plugin
  specs.
- `lua/core/` holds core behavior (`init.lua`, `options.lua`, `autocmds.lua`, `usercmds.lua`).
- `lua/core/commands/` stores modular user command definitions (e.g., `md_new.lua`).
- `lua/core/utils/` contains reusable helpers shared across modules (e.g., `strings.lua`,
  `paths.lua`).
- `lua/plugins/*.lua` defines plugin specs (one file per plugin), auto-imported via lazy.nvim.
- `lua/plugins/colorschemes.lua` handles per-host colorscheme selection via a hostname map.
- `lua/snippets/` contains LuaSnip snippets.
- `spell/` contains custom dictionary files.

## Build, Test, and Development Commands

- `nvim` launches the configuration locally from `~/.config/nvim` (this repo is intended to be
  stowed there).
- `nvim --headless "+Lazy sync" +qa` installs/updates plugins via lazy.nvim.
- `nvim --headless "+checkhealth" +qa` runs Neovim health checks.

## Coding Style & Naming Conventions

- Lua code uses 2-space indentation and spaces over tabs (see `lua/core/options.lua`).
- Prefer explicit, descriptive names (`highlight_selection`, `system_open_under_cursor`).
- Keep plugin specs in separate files inside `lua/plugins/` (one file per plugin for
  maintainability).
- No formatter or linter is configured; match existing style and layout.

## Testing Guidelines

- There is no automated test suite in this repository.
- Validate changes by launching Neovim and exercising affected features (e.g., keymaps, plugins,
  snippets).

## Commit & Pull Request Guidelines

- Git history is not available in this directory, so no commit convention is enforced here.
- Use concise, imperative commit subjects (e.g., "Add telescope keymaps") and include context in the
  body when changes are non-obvious.
- In PRs, describe behavior changes, list relevant plugins or files, and add screenshots/gifs for UI
  changes.

## Configuration & Safety Notes

- Sensitive files (e.g., `.env`, credentials) are treated specially by autocmds to avoid swap/undo
  files.
- Per-host colorscheme is configured in `lua/plugins/colorschemes.lua` via the `host_theme` map.
