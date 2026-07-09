-- User commands module loader
-- Loads all user command sub-modules

require("core.usercmds.yt_get_reference")
require("core.usercmds.copy_file_path")
require("core.usercmds.md_new").setup()
require("core.usercmds.md_dir_new").setup()
require("core.usercmds.deps")
require("core.usercmds.todos").setup()
