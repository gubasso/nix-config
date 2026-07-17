# xsecurelock environment for dwm sessions.
{
  lib,
  pkgs,
  hostSettings,
  ...
}:

let
  # xsecurelock owns its theme emitter (ADR-0018), built from lib/theme primitives.
  emit = import ./theme.nix { inherit (pkgs) themeLib; };
  theme = pkgs.themeLib.resolve (hostSettings.theme or "everforest");
  # Static env body + theme-driven color lines appended at the end.
  envConf = pkgs.writeText "xsecurelock-env.conf" ''
    ${builtins.readFile ./env.conf}
    ${emit.mkXsecurelockEnv theme}
  '';
in
{
  config = lib.mkIf ((hostSettings.desktop or "none") == "dwm") {
    xdg.configFile."xsecurelock/env.conf".source = envConf;
  };
}
