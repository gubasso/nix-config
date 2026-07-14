# KDE Plasma seam for future shared home config.
{ lib, hostSettings, ... }:

{
  config = lib.mkIf ((hostSettings.desktop or "none") == "kde") { };
}
