# rofi config: static launcher config + shared layout, with the active theme's
# colors derived from the host's `hostSettings.theme` (lib/theme emitter). The
# generated active-theme.rasi = the theme color block + @import of layout.rasi.
{ pkgs, hostSettings, ... }:

let
  theme = pkgs.themeLib.resolve (hostSettings.theme or "everforest");
  activeTheme = pkgs.writeText "rofi-active-theme.rasi" ''
    ${pkgs.themeLib.mkRofiColors theme}
    @import "~/.config/rofi/layout.rasi"
  '';
in
{
  home.file.".local/state/rofi/active-theme.rasi".source = activeTheme;
  xdg.configFile = {
    "rofi/config.rasi".source = ./config.rasi;
    "rofi/rofimoji.rc".source = ./rofimoji.rc;
    "rofi/layout.rasi".source = ./layout.rasi;
  };
}
