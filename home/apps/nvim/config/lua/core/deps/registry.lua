-- Dependency definitions for Neovim setup
local M = {}

-- System executables to check
-- pacman: package name for Arch Linux auto-install
M.executables = {
  -- Core tools
  { name = "git", required = true, hint = "pacman -S git", pacman = "git" },
  { name = "hg", required = false, hint = "pacman -S mercurial", pacman = "mercurial" },

  -- Node ecosystem (required by mason's node-based tools)
  { name = "node", required = true, hint = "pacman -S nodejs", pacman = "nodejs" },
  { name = "npm", required = false, hint = "pacman -S npm", pacman = "npm" },

  -- Go
  { name = "go", required = false, hint = "pacman -S go", pacman = "go" },

  -- Ruby
  { name = "ruby", required = false, hint = "pacman -S ruby", pacman = "ruby" },
  { name = "gem", required = false, hint = "Comes with ruby", pacman = nil },

  -- PHP
  { name = "php", required = false, hint = "pacman -S php", pacman = "php" },
  { name = "composer", required = false, hint = "pacman -S composer", pacman = "composer" },

  -- Java
  { name = "java", required = false, hint = "pacman -S jdk-openjdk", pacman = "jdk-openjdk" },
  { name = "javac", required = false, hint = "pacman -S jdk-openjdk", pacman = nil },

  -- Other languages
  { name = "perl", required = false, hint = "pacman -S perl", pacman = "perl" },
  { name = "lua", required = false, hint = "pacman -S lua", pacman = "lua" },
  { name = "luarocks", required = false, hint = "pacman -S luarocks", pacman = "luarocks" },

  -- Python
  { name = "python", required = true, hint = "pacman -S python", pacman = "python" },
  { name = "pip", required = true, hint = "pacman -S python-pip", pacman = "python-pip" },

  -- Tree-sitter
  { name = "tree-sitter", required = false, hint = "pacman -S tree-sitter-cli", pacman = "tree-sitter-cli" },

  -- Build tools
  { name = "make", required = false, hint = "pacman -S base-devel", pacman = "base-devel" },
  { name = "gcc", required = false, hint = "pacman -S base-devel", pacman = nil },
}

-- Neovim provider hosts
M.provider_hosts = {
  {
    name = "neovim-node-host",
    check_cmd = "command -v neovim-node-host >/dev/null 2>&1",
    hint = "npm install -g neovim",
    install_cmd = "npm install -g neovim",
  },
  {
    name = "neovim-ruby-host",
    check_cmd = "gem list neovim 2>/dev/null | grep -q neovim",
    hint = "gem install neovim",
    install_cmd = "gem install neovim",
  },
  {
    name = "pynvim",
    check_cmd = "command -v pynvim-python >/dev/null 2>&1 || python -c 'import pynvim' 2>/dev/null",
    hint = "pipx install pynvim (or pacman -S python-pynvim)",
    install_cmd = "pipx install pynvim",
    pacman = "python-pynvim",
  },
  {
    name = "Neovim::Ext (perl)",
    check_cmd = "perl -MNeovim::Ext -e 1 2>/dev/null",
    hint = "cpanm Neovim::Ext",
    install_cmd = "cpanm -n Neovim::Ext",
  },
}

-- Get unique pacman packages for missing executables
function M.get_pacman_packages(missing_executables)
  local packages = {}
  local seen = {}
  for _, name in ipairs(missing_executables) do
    for _, dep in ipairs(M.executables) do
      if dep.name == name and dep.pacman and not seen[dep.pacman] then
        table.insert(packages, dep.pacman)
        seen[dep.pacman] = true
      end
    end
  end
  return packages
end

return M
