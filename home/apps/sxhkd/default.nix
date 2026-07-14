# sxhkd hotkey config for dwm sessions.
{ lib, hostSettings, ... }:

{
  config = lib.mkIf ((hostSettings.desktop or "none") == "dwm") {
    xdg.configFile."sxhkd/sxhkdrc".source = ./sxhkdrc;
  };
}
