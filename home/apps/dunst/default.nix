# dunst notification daemon config for dwm sessions.
{ lib, hostSettings, ... }:

{
  config = lib.mkIf ((hostSettings.desktop or "none") == "dwm") {
    xdg.configFile."dunst/dunstrc".source = ./dunstrc;
  };
}
