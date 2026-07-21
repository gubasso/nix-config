{
  lib,
  pkgs,
  # Provided as a specialArg by lib/mk-host.nix for real hosts; default to {}
  # so the module also evaluates standalone (e.g. the nixosModules flake check).
  hostSettings ? { },
  ...
}:
let
  isDwm = (hostSettings.desktop or "none") == "dwm";
in
{
  # Bare WM (dwm/X11) has no desktop-environment portal backend, so
  # Electron/Flatpak/browser file-chooser dialogs have nothing to talk to.
  # Force the GTK backend to give them a working native picker. Mirrors the
  # legacy nova portals.conf ([preferred] default=gtk + FileChooser=gtk).
  # KDE hosts ship their own portal and must not get this.
  config = lib.mkIf isDwm {
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
      config.common = {
        default = "gtk";
        "org.freedesktop.impl.portal.FileChooser" = "gtk";
      };
    };
  };
}
