# xsecurelock environment for dwm sessions.
{
  lib,
  pkgs,
  hostSettings,
  ...
}:

let
  theme = pkgs.themeLib.resolve (hostSettings.theme or "everforest");
  # Static env body + theme-driven color lines appended at the end.
  envConf = pkgs.writeText "xsecurelock-env.conf" ''
    ${builtins.readFile ./env.conf}
    ${pkgs.themeLib.mkXsecurelockEnv theme}
  '';
in
{
  config = lib.mkIf ((hostSettings.desktop or "none") == "dwm") {
    xdg.configFile."xsecurelock/env.conf".source = envConf;
  };
}
