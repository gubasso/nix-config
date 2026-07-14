# picom compositor config for dwm sessions.
{ lib, hostSettings, ... }:

{
  config = lib.mkIf ((hostSettings.desktop or "none") == "dwm") {
    xdg.configFile."picom/picom.conf".source = ./picom.conf;
  };
}
