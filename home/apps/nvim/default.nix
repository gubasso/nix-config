# Neovim package, aliases, config tree, and desktop launcher.
{ pkgs, ... }:

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
  xdg.configFile."nvim".source = ./config;
  home.file.".local/share/applications/nvim-kitty.desktop".source = ./nvim-kitty.desktop;
}
