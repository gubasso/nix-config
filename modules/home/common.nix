# Shared Home-Manager base, imported by each host's hosts/<name>/home.nix.
# `username` is threaded in via home-manager.extraSpecialArgs (see lib/mk-host.nix)
# so this base is host- and user-agnostic.
#
# The graphical session is selected per host by `hostSettings.desktop`
# ("dwm" | "kde" | "none", default "none"): the cross-desktop apps and generic-Linux
# enablement always load, and exactly one desktop-environment module is added on
# top. An unset host gets no desktop chrome — a visible no-op, never the wrong WM's
# session assets. Add a new WM with one module + one `lib.optional` line.
{
  username,
  ...
}:

{
  imports = [
    ./env-shell.nix
    ./nix.nix
    ./keyring.nix
    ./generic-linux.nix
    ./fonts.nix
    ../../home/apps
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "25.11"; # pinned, never auto-bumped; matches system.stateVersion
  };
  programs.home-manager.enable = true;
}
