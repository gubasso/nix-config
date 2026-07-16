# dunst notification daemon config for dwm sessions.
{
  lib,
  pkgs,
  hostSettings,
  ...
}:

let
  theme = pkgs.themeLib.resolve (hostSettings.theme or "everforest");
in
{
  config = lib.mkIf ((hostSettings.desktop or "none") == "dwm") {
    xdg.configFile = {
      # Structural config stays static; colors come from the theme-driven
      # drop-in (dunst merges dunstrc.d/*.conf over the base dunstrc).
      "dunst/dunstrc".source = ./dunstrc;
      "dunst/dunstrc.d/zzz-theme.conf".text = pkgs.themeLib.mkDunstColors theme;
    };
  };
}
