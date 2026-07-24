# arandr: GTK GUI front-end for xrandr (visual multi-monitor layout tool).
{
  lib,
  pkgs,
  hostSettings,
  ...
}:

{
  config = lib.mkIf ((hostSettings.desktop or "none") == "dwm") {
    home.packages = [ pkgs.arandr ];
  };
}
