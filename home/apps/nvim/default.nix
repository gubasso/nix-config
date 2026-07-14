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

  # JS/Node runtimes from nixpkgs. npm ships stock defaults -- no custom
  # ~/.npmrc, no user-global prefix; the default prefix is the read-only store,
  # so global CLIs come as nix derivations, never `npm i -g` / `bun add -g`.
  # bun is also required by the nvim yt_get_reference usercmd.
  home.packages = [
    pkgs.nodejs
    pkgs.bun
  ];

  programs.bash.shellAliases.n = "nvim";
  # Public base config tree. A private consumer overlays only the files that
  # carry private data (host profile, host-keyed colorscheme, personal spell
  # words) via mkRealConfigDir, so no config file is duplicated across repos
  # (Atomic Artifact Principle — see ADR-0015). mkDefault yields to that overlay.
  xdg.configFile."nvim".source = lib.mkDefault (pkgs.mkRealConfigDir "nvim" ./config null);
  home.file.".local/share/applications/nvim-kitty.desktop".source = ./nvim-kitty.desktop;
}
