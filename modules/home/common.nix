# Shared Home-Manager base, imported by each host's hosts/<name>/home.nix.
# `username` is threaded in via home-manager.extraSpecialArgs (see lib/mk-host.nix)
# so this base is host- and user-agnostic.
{ username, ... }:

{
  imports = [
    ./env-shell.nix
    ./core-cli.nix
    ./desktop.nix
    ./graphics.nix
    ./keyring.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "25.11"; # pinned, never auto-bumped; matches system.stateVersion
  };
  programs.home-manager.enable = true;
}
