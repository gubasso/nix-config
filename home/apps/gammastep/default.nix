# gammastep color temperature config for dwm sessions.
{ lib, hostSettings, ... }:

{
  config = lib.mkIf ((hostSettings.desktop or "none") == "dwm") {
    xdg.configFile."gammastep/config.ini".source = ./config.ini;
  };
}
