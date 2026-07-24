# Cross-desktop browser packages, launchers, webapp desktop files, and config.
{ pkgs, config, ... }:

{
  home.packages =
    map (p: config.lib.nixGL.wrap p) (
      with pkgs;
      [
        brave
        librewolf
      ]
    )
    ++ (with pkgs; [
      feh
      fontconfig
      liberation_ttf
    ]);

  home.file = {
    ".local/bin/browser-launcher" = {
      source = ./bin/browser-launcher;
      executable = true;
    };
    ".local/bin/brave-launcher" = {
      source = ./bin/brave-launcher;
      executable = true;
    };
    ".local/share/applications/brave-browser.desktop".source = ./applications/brave-browser.desktop;
    ".local/share/applications/webapp-ai.desktop".source = ./applications/webapp-ai.desktop;
    ".local/share/applications/webapp-google.desktop".source = ./applications/webapp-google.desktop;
    ".local/share/applications/webapp-social.desktop".source = ./applications/webapp-social.desktop;
    ".local/share/icons/hicolor/scalable/apps/brave-browser.svg".source = ./icons/brave-browser.svg;
    ".local/share/icons/hicolor/scalable/apps/webapp-ai.svg".source = ./icons/webapp-ai.svg;
    ".local/share/icons/hicolor/scalable/apps/webapp-google.svg".source = ./icons/webapp-google.svg;
    ".local/share/icons/hicolor/scalable/apps/webapp-social.svg".source = ./icons/webapp-social.svg;
  };

  xdg.configFile = {
    "browser/env.sh".source = ./env.sh;
    "browser/flags.d/defaults.conf".source = ./flags.d/defaults.conf;
    "browser/vulkan/disabled-icd.d/disabled.json".source = ./vulkan/disabled-icd.d/disabled.json;
    "browser/vulkan/disabled-icd.d/README.md".source = ./vulkan/disabled-icd.d/README.md;
  };
}
