# Neovim package, aliases, config tree, and desktop launcher.
{ lib, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withRuby = false;
    withPython3 = false;
  };

  # Node runtime from nixpkgs, scoped to nvim (the only consumer in this config):
  # mason installs several node-based tools (bash/vim-language-server, doctoc,
  # prettier). npm ships stock defaults -- no custom ~/.npmrc, no user-global
  # prefix; the default prefix is the read-only store, so global CLIs come as nix
  # derivations, never `npm i -g`.
  #
  # tree-sitter CLI + a C compiler are required by nvim-treesitter's `main` branch
  # to compile parsers at install/update. Upstream is explicit: install the CLI
  # via a package manager, NOT npm -- so it comes from nix here, not mason.
  home.packages = [
    pkgs.nodejs
    pkgs.tree-sitter
    pkgs.gcc
  ];

  programs.bash.shellAliases.n = "nvim .";
  # Public base config tree. A private consumer overlays only the files that
  # carry private data (host profile, host-keyed colorscheme, personal spell
  # words) via mkRealConfigDir, so no config file is duplicated across repos
  # (Atomic Artifact Principle — see ADR-0015). mkDefault yields to that overlay.
  xdg.configFile."nvim".source = lib.mkDefault (pkgs.mkRealConfigDir "nvim" ./config null);
  home.file.".local/share/applications/nvim-kitty.desktop".source = ./nvim-kitty.desktop;
}
