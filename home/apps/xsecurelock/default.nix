# xsecurelock environment for dwm sessions.
{ lib, hostSettings, ... }:

{
  config = lib.mkIf ((hostSettings.desktop or "none") == "dwm") {
    xdg.configFile."xsecurelock/env.conf".source = ./env.conf;
  };
}
