# Font library — install the whole typography catalogue on opt-in hosts.
#
# The catalogue is the central registry in themes/_shared/typography.nix
# (`families`) + lib/theme/fonts.nix (`fontPackagesFor`, applied by the overlay
# as `pkgs.fontPackages`). App modules already install only the single font they
# resolve via `themeLib.fontOf`; this module instead makes the ENTIRE registry
# available so any app can pick any registered family WITHOUT per-app config.
#
# The install list is DERIVED from the registry (`lib.attrValues
# pkgs.fontPackages`) — add a family there and it is installed here automatically,
# no second list to keep in sync. Opt-in per host via `hostSettings.fontLibrary`
# (free-form host attrset, same channel as `hostSettings.theme`/`appFonts`);
# default off, so NixOS hosts (orion/lyra) are untouched until they ask for it.
{
  lib,
  pkgs,
  hostSettings ? { },
  ...
}:

lib.mkIf (hostSettings.fontLibrary or false) {
  home.packages = [
    (pkgs.buildEnv {
      name = "font-library";
      paths = lib.attrValues pkgs.fontPackages;
      # Several bitmap fonts (spleen, dina, tamzen, …) each ship a fixed X11
      # `share/fonts/misc/fonts.dir` index; merged into one profile they collide
      # on that filename. fontconfig apps read the font FILES directly (not the
      # legacy X11 core-font index), so collapsing to a single index is harmless
      # — ignore the collision rather than drop any font.
      ignoreCollisions = true;
    })
  ];
  # Make home-installed fonts discoverable by fontconfig apps.
  fonts.fontconfig.enable = true;
}
