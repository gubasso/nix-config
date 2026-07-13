# dwm / X11 session: the window manager's own X session script, compositor,
# notifier, status bar, screen locker, and their config. Loaded only on hosts
# whose `hostSettings.desktop == "dwm"` (see modules/home/common.nix). dwm-session
# comes from the overlay; other assets from `publicAssetsDir`.
{
  pkgs,
  publicAssetsDir,
  ...
}:

{
  imports = [
    # X11 DPI / xsettingsd scaling. Consumed only by this session's ~/.xinitrc
    # (graphics/profile.sh), so it lives with the dwm session, not the shared base.
    ./graphics.nix
  ];

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
        source = publicAssetsDir + "/dwm/bin/dwm-status-updates";
        executable = true;
      };
      ".Xresources".source = publicAssetsDir + "/dwm/Xresources";
      ".local/share/dwm/autostart_blocking.sh" = {
        source = publicAssetsDir + "/dwm/share/autostart_blocking.sh";
        executable = true;
      };
      ".local/bin/dwm-center-clock" = {
        source = publicAssetsDir + "/dwm/bin/dwm-center-clock";
        executable = true;
      };
      ".local/bin/dwm-status-battery" = {
        source = publicAssetsDir + "/dwm/bin/dwm-status-battery";
        executable = true;
      };
      ".local/bin/dwm-status-right" = {
        source = publicAssetsDir + "/dwm/bin/dwm-status-right";
        executable = true;
      };
      ".local/bin/dwm-status-wifi" = {
        source = publicAssetsDir + "/dwm/bin/dwm-status-wifi";
        executable = true;
      };
      ".local/lib/dwm-status-lib".source = publicAssetsDir + "/dwm/lib/dwm-status-lib";
    };
  };

  xdg.configFile = {
    "dunst/dunstrc".source = publicAssetsDir + "/dunst/dunstrc";
    "picom/picom.conf".source = publicAssetsDir + "/picom/picom.conf";
    "gammastep/config.ini".source = publicAssetsDir + "/gammastep/config.ini";
    "sxhkd/sxhkdrc".source = publicAssetsDir + "/sxhkd/sxhkdrc";
    "dwm/Xresources".source = publicAssetsDir + "/dwm/Xresources";
    # Sourced by ~/.xinitrc before xss-lock. Must exist: if this file is absent,
    # the dash `.`-on-missing-file abort in .xinitrc kills the whole X session.
    "xsecurelock/env.conf".source = publicAssetsDir + "/xsecurelock/env.conf";
  };
}
