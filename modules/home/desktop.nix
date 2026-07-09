# Desktop base: browsers, compositor/notifier, the dwm X session, and their
# config assets. Asset files come from the consumer's tree via `assetsDir`
# (threaded by lib/mk-host.nix). dwm-session comes from the overlay.
{ pkgs, assetsDir, ... }:

{
  home.packages = with pkgs; [
    brave
    librewolf
    thunderbird
    dunst
    picom
    kitty
    feh
    autorandr
    fontconfig
    liberation_ttf
    nerd-fonts.hack
  ];

  programs.autorandr.enable = true;
  # No profiles declared: autorandr matches by EDID fingerprint, which is
  # hardware-specific and only knowable on-metal. Capture with
  # `autorandr --fingerprint` per machine and add profiles in the consumer.

  home.file.".xinitrc".source = "${pkgs.dwm-session}/share/dwm-session/xinitrc";
  home.file.".local/share/dwm/autostart.sh" = {
    source = "${pkgs.dwm-session}/share/dwm/autostart.sh";
    executable = true;
  };
  home.file.".local/bin/browser-launcher" = {
    source = assetsDir + "/bin/browser-launcher";
    executable = true;
  };
  home.file.".local/bin/brave-launcher" = {
    source = assetsDir + "/bin/brave-launcher";
    executable = true;
  };
  home.file.".local/bin/kitty-dctl-pair" = {
    source = assetsDir + "/bin/kitty-dctl-pair";
    executable = true;
  };
  home.file.".local/bin/kitty-dctl-suse" = {
    source = assetsDir + "/bin/kitty-dctl-suse";
    executable = true;
  };
  home.file.".local/bin/kitty-mode-help" = {
    source = assetsDir + "/bin/kitty-mode-help";
    executable = true;
  };

  xdg.configFile."rofi/config.rasi".source = assetsDir + "/rofi/config.rasi";
  xdg.configFile."rofi/rofimoji.rc".source = assetsDir + "/rofi/rofimoji.rc";
  # config.rasi includes `@theme "~/.local/state/rofi/active-theme.rasi"`. Vendor
  # the theme and seed the active-theme state file pointing at it, so a fresh
  # activation has a working theme. Re-point active-theme.rasi to another
  # themes/*.rasi to switch.
  xdg.configFile."rofi/themes/everforest.rasi".source = assetsDir + "/rofi/themes/everforest.rasi";
  xdg.configFile."rofi/themes/catppuccin-mocha.rasi".source =
    assetsDir + "/rofi/themes/catppuccin-mocha.rasi";
  xdg.configFile."rofi/themes/dracula.rasi".source = assetsDir + "/rofi/themes/dracula.rasi";
  xdg.configFile."rofi/themes/purple-city.rasi".source = assetsDir + "/rofi/themes/purple-city.rasi";
  xdg.configFile."rofi/themes/tokyonight.rasi".source = assetsDir + "/rofi/themes/tokyonight.rasi";
  home.file.".local/state/rofi/active-theme.rasi".source = assetsDir + "/rofi/themes/everforest.rasi";
  xdg.configFile."kitty".source = assetsDir + "/kitty";
  xdg.configFile."dunst/dunstrc".source = assetsDir + "/dunst/dunstrc";
  xdg.configFile."picom/picom.conf".source = assetsDir + "/picom/picom.conf";
  xdg.configFile."gammastep/config.ini".source = assetsDir + "/gammastep/config.ini";
  # xsettingsd config is generated per-context by modules/home/graphics.nix,
  # not a static asset.
  # Sourced by ~/.xinitrc before xss-lock. Must exist: if this file is absent,
  # the dash `.`-on-missing-file abort in .xinitrc kills the whole X session.
  xdg.configFile."xsecurelock/env.conf".source = assetsDir + "/xsecurelock/env.conf";
  xdg.configFile."browser/env.sh".source = assetsDir + "/browser/env.sh";
  xdg.configFile."browser/flags.d/defaults.conf".source =
    assetsDir + "/browser/flags.d/defaults.conf";
  xdg.configFile."browser/vulkan/disabled-icd.d/disabled.json".source =
    assetsDir + "/browser/vulkan/disabled-icd.d/disabled.json";
  xdg.configFile."browser/vulkan/disabled-icd.d/README.md".source =
    assetsDir + "/browser/vulkan/disabled-icd.d/README.md";
  xdg.configFile."autorandr/README.md".source = assetsDir + "/autorandr/README.md";
}
