-- Yazi plugin setup. Home Manager (programs.yazi.plugins) symlinks each plugin
-- into ~/.config/yazi/plugins/<name>.yazi; this file runs the setup() calls the
-- plugins that need them. Keymaps live in keymap.toml (programs.yazi.keymap),
-- fetchers/previewers/preloaders in yazi.toml (programs.yazi.settings).

-- git.yazi: show git status as a linemode column. order controls its column slot.
require("git"):setup({ order = 1500 })

-- smart-enter.yazi: <Enter>/l enters a directory or opens a file; open_multi lets
-- a multi-selection open together instead of only the hovered entry.
require("smart-enter"):setup({ open_multi = true })
