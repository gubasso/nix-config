# dunst notification daemon config for dwm sessions.
{
  lib,
  pkgs,
  hostSettings,
  ...
}:

let
  # dunst owns its theme emitter (ADR-0018), built from lib/theme primitives.
  emit = import ./theme.nix { inherit (pkgs) themeLib; };
  theme = pkgs.themeLib.resolve (hostSettings.theme or "everforest");
in
{
  config = lib.mkIf ((hostSettings.desktop or "none") == "dwm") {
    xdg.configFile = {
      # Structural config stays static; colors come from the theme-driven
      # drop-in (dunst merges dunstrc.d/*.conf over the base dunstrc).
      "dunst/dunstrc".source = ./dunstrc;
      "dunst/dunstrc.d/zzz-theme.conf".text = emit.mkDunstColors theme;
    };
  };
}
