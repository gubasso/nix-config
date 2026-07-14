# rofi config, themes, and active-theme state seed.
{ hostSettings, ... }:

let
  rofiTheme = hostSettings.rofiTheme or "everforest";
in
{
  home.file.".local/state/rofi/active-theme.rasi".source = ./themes + "/${rofiTheme}.rasi";
  xdg.configFile = {
    "rofi/config.rasi".source = ./config.rasi;
    "rofi/rofimoji.rc".source = ./rofimoji.rc;
    "rofi/themes/everforest.rasi".source = ./themes/everforest.rasi;
    "rofi/themes/catppuccin-mocha.rasi".source = ./themes/catppuccin-mocha.rasi;
    "rofi/themes/dracula.rasi".source = ./themes/dracula.rasi;
    "rofi/themes/purple-city.rasi".source = ./themes/purple-city.rasi;
    "rofi/themes/tokyonight.rasi".source = ./themes/tokyonight.rasi;
  };
}
