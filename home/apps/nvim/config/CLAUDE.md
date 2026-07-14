# CLAUDE.md

Guidance for Claude Code when working in this Neovim configuration.

## Validation

No automated tests. Validate changes by launching Neovim and exercising affected features.

## Key Conventions

- One file per plugin in `lua/plugins/`; lazy.nvim auto-imports the directory
- Keymaps registered through which-key.nvim using `wk.add()`
- Host branching decided in `init.lua` via `core.host`; minimal path returns early before lazy.nvim
- Sensitive files have swap/backup/undo disabled via autocmd in `core/autocmds/security.lua`

## Adding a New Plugin

```lua
-- lua/plugins/<plugin-name>.lua
return {
  "author/plugin-name",
  opts = {},
}
```

## Adding a New Primary Host

1. Add hostname to `primary_hosts` in `lua/core/host.lua`
2. Add theme entry to `host_theme` in `lua/plugins/colorschemes.lua`
