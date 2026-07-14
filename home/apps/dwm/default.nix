# dwm / X11 session assets and status helpers.
{
  lib,
  pkgs,
  hostSettings,
  ...
}:

{
  config = lib.mkIf ((hostSettings.desktop or "none") == "dwm") {
    home = {
      packages = with pkgs; [
        dunst
        picom
      ];
      file = {
        ".xinitrc".source = "${pkgs.dwm-session}/share/dwm-session/xinitrc";
        ".local/share/dwm/autostart.sh" = {
          source = "${pkgs.dwm-session}/share/dwm/autostart.sh";
          executable = true;
        };
        ".local/bin/dwm-status-updates" = {
          source = ./bin/dwm-status-updates;
          executable = true;
        };
        ".Xresources".source = ./Xresources;
        ".local/share/dwm/autostart_blocking.sh" = {
          source = ./share/autostart_blocking.sh;
          executable = true;
        };
        ".local/bin/dwm-center-clock" = {
          source = ./bin/dwm-center-clock;
          executable = true;
        };
        ".local/bin/dwm-status-battery" = {
          source = ./bin/dwm-status-battery;
          executable = true;
        };
        ".local/bin/dwm-status-right" = {
          source = ./bin/dwm-status-right;
          executable = true;
        };
        ".local/bin/dwm-status-wifi" = {
          source = ./bin/dwm-status-wifi;
          executable = true;
        };
        ".local/lib/dwm-status-lib".source = ./lib/dwm-status-lib;
      };
    };
    xdg.configFile."dwm/Xresources".source = ./Xresources;
  };
}
