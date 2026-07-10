# Desktop base: browsers, compositor/notifier, the dwm X session, and their
# config assets. Asset files come from the consumer's tree via `publicAssetsDir`
# (threaded by lib/mk-host.nix). dwm-session comes from the overlay.
{ pkgs, publicAssetsDir, ... }:

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
    source = publicAssetsDir + "/bin/browser-launcher";
    executable = true;
  };
  home.file.".local/bin/brave-launcher" = {
    source = publicAssetsDir + "/bin/brave-launcher";
    executable = true;
  };
  home.file.".local/bin/kitty-dctl-pair" = {
    source = publicAssetsDir + "/bin/kitty-dctl-pair";
    executable = true;
  };
  home.file.".local/bin/kitty-mode-help" = {
    source = publicAssetsDir + "/bin/kitty-mode-help";
    executable = true;
  };
  home.file.".local/bin/dwm-status-updates" = {
    source = publicAssetsDir + "/dwm/bin/dwm-status-updates";
    executable = true;
  };
  home.file.".local/share/applications/nvim-kitty.desktop".source =
    publicAssetsDir + "/applications/nvim-kitty.desktop";
  home.file.".local/share/applications/brave-browser.desktop".source =
    publicAssetsDir + "/applications/brave/brave-browser.desktop";
  home.file.".local/share/applications/webapp-ai.desktop".source =
    publicAssetsDir + "/applications/brave/webapp-ai.desktop";
  home.file.".local/share/applications/webapp-google.desktop".source =
    publicAssetsDir + "/applications/brave/webapp-google.desktop";
  home.file.".local/share/applications/webapp-social.desktop".source =
    publicAssetsDir + "/applications/brave/webapp-social.desktop";
  home.file.".local/share/icons/hicolor/scalable/apps".source =
    publicAssetsDir + "/icons/hicolor/scalable/apps";
  home.file.".local/share/brave-unpacked-extensions".source =
    publicAssetsDir + "/brave-unpacked-extensions";

  xdg.configFile."rofi/config.rasi".source = publicAssetsDir + "/rofi/config.rasi";
  xdg.configFile."rofi/rofimoji.rc".source = publicAssetsDir + "/rofi/rofimoji.rc";
  # config.rasi includes `@theme "~/.local/state/rofi/active-theme.rasi"`. Vendor
  # the theme and seed the active-theme state file pointing at it, so a fresh
  # activation has a working theme. Re-point active-theme.rasi to another
  # themes/*.rasi to switch.
  xdg.configFile."rofi/themes/everforest.rasi".source = publicAssetsDir + "/rofi/themes/everforest.rasi";
  xdg.configFile."rofi/themes/catppuccin-mocha.rasi".source =
    publicAssetsDir + "/rofi/themes/catppuccin-mocha.rasi";
  xdg.configFile."rofi/themes/dracula.rasi".source = publicAssetsDir + "/rofi/themes/dracula.rasi";
  xdg.configFile."rofi/themes/purple-city.rasi".source = publicAssetsDir + "/rofi/themes/purple-city.rasi";
  xdg.configFile."rofi/themes/tokyonight.rasi".source = publicAssetsDir + "/rofi/themes/tokyonight.rasi";
  home.file.".local/state/rofi/active-theme.rasi".source = publicAssetsDir + "/rofi/themes/everforest.rasi";
  xdg.configFile."kitty".source = publicAssetsDir + "/kitty";
  xdg.configFile."dunst/dunstrc".source = publicAssetsDir + "/dunst/dunstrc";
  xdg.configFile."picom/picom.conf".source = publicAssetsDir + "/picom/picom.conf";
  xdg.configFile."gammastep/config.ini".source = publicAssetsDir + "/gammastep/config.ini";
  xdg.configFile."sxhkd/sxhkdrc".source = publicAssetsDir + "/sxhkd/sxhkdrc";
  xdg.configFile."dctl/default/devcontainer.json".source =
    publicAssetsDir + "/dctl/default/devcontainer.json";
  xdg.configFile."dctl/devcontainer/agents/devcontainer.json".source =
    publicAssetsDir + "/dctl/devcontainer/agents/devcontainer.json";
  xdg.configFile."dctl/devcontainer/agents/seccomp-bwrap.json".source =
    publicAssetsDir + "/dctl/devcontainer/agents/seccomp-bwrap.json";
  xdg.configFile."dctl/devcontainer/base/devcontainer.json".source =
    publicAssetsDir + "/dctl/devcontainer/base/devcontainer.json";
  xdg.configFile."dctl/devcontainer/bebash.yaml".source =
    publicAssetsDir + "/dctl/devcontainer/bebash.yaml";
  xdg.configFile."dctl/devcontainer/bebash/devcontainer.json".source =
    publicAssetsDir + "/dctl/devcontainer/bebash/devcontainer.json";
  xdg.configFile."dctl/devcontainer/claude/devcontainer.json".source =
    publicAssetsDir + "/dctl/devcontainer/claude/devcontainer.json";
  xdg.configFile."dctl/devcontainer/codex/devcontainer.json".source =
    publicAssetsDir + "/dctl/devcontainer/codex/devcontainer.json";
  xdg.configFile."dctl/devcontainer/cog/devcontainer.json".source =
    publicAssetsDir + "/dctl/devcontainer/cog/devcontainer.json";
  xdg.configFile."dctl/devcontainer/dotfiles/devcontainer.json".source =
    publicAssetsDir + "/dctl/devcontainer/dotfiles/devcontainer.json";
  xdg.configFile."dctl/devcontainer/gemini/devcontainer.json".source =
    publicAssetsDir + "/dctl/devcontainer/gemini/devcontainer.json";
  xdg.configFile."dctl/devcontainer/general.yaml".source =
    publicAssetsDir + "/dctl/devcontainer/general.yaml";
  xdg.configFile."dctl/devcontainer/nix/devcontainer.json".source =
    publicAssetsDir + "/dctl/devcontainer/nix/devcontainer.json";
  xdg.configFile."dctl/devcontainer/node-dev.yaml".source =
    publicAssetsDir + "/dctl/devcontainer/node-dev.yaml";
  xdg.configFile."dctl/devcontainer/node-dev/devcontainer.json".source =
    publicAssetsDir + "/dctl/devcontainer/node-dev/devcontainer.json";
  xdg.configFile."dctl/devcontainer/opencode/devcontainer.json".source =
    publicAssetsDir + "/dctl/devcontainer/opencode/devcontainer.json";
  xdg.configFile."dctl/devcontainer/pre-commit/devcontainer.json".source =
    publicAssetsDir + "/dctl/devcontainer/pre-commit/devcontainer.json";
  xdg.configFile."dctl/devcontainer/projects/devcontainer.json".source =
    publicAssetsDir + "/dctl/devcontainer/projects/devcontainer.json";
  xdg.configFile."dctl/devcontainer/python-minimal/devcontainer.json".source =
    publicAssetsDir + "/dctl/devcontainer/python-minimal/devcontainer.json";
  xdg.configFile."dctl/devcontainer/python.yaml".source =
    publicAssetsDir + "/dctl/devcontainer/python.yaml";
  xdg.configFile."dctl/devcontainer/python/devcontainer.json".source =
    publicAssetsDir + "/dctl/devcontainer/python/devcontainer.json";
  xdg.configFile."dctl/devcontainer/riptask.yaml".source =
    publicAssetsDir + "/dctl/devcontainer/riptask.yaml";
  xdg.configFile."dctl/devcontainer/riptask/devcontainer.json".source =
    publicAssetsDir + "/dctl/devcontainer/riptask/devcontainer.json";
  xdg.configFile."dctl/devcontainer/rust.yaml".source =
    publicAssetsDir + "/dctl/devcontainer/rust.yaml";
  xdg.configFile."dctl/devcontainer/rust/devcontainer.json".source =
    publicAssetsDir + "/dctl/devcontainer/rust/devcontainer.json";
  xdg.configFile."dctl/devcontainer/shell/devcontainer.json".source =
    publicAssetsDir + "/dctl/devcontainer/shell/devcontainer.json";
  xdg.configFile."dctl/devcontainer/zig.yaml".source =
    publicAssetsDir + "/dctl/devcontainer/zig.yaml";
  xdg.configFile."dctl/devcontainer/zig/devcontainer.json".source =
    publicAssetsDir + "/dctl/devcontainer/zig/devcontainer.json";
  xdg.configFile."dctl/images/agents".source =
    publicAssetsDir + "/dctl/images/agents";
  xdg.configFile."riptask/config.yaml".source = publicAssetsDir + "/riptask/config.yaml";
  home.file.".npmrc".source = publicAssetsDir + "/npm/npmrc";
  xdg.configFile."rclone/.rcloneignore".source = publicAssetsDir + "/rclone/rcloneignore";
  xdg.configFile."dwm/Xresources".source = publicAssetsDir + "/dwm/Xresources";
  home.file.".Xresources".source = publicAssetsDir + "/dwm/Xresources";
  home.file.".local/share/dwm/autostart_blocking.sh" = {
    source = publicAssetsDir + "/dwm/share/autostart_blocking.sh";
    executable = true;
  };
  home.file.".local/bin/dwm-center-clock" = {
    source = publicAssetsDir + "/dwm/bin/dwm-center-clock";
    executable = true;
  };
  home.file.".local/bin/dwm-status-battery" = {
    source = publicAssetsDir + "/dwm/bin/dwm-status-battery";
    executable = true;
  };
  home.file.".local/bin/dwm-status-right" = {
    source = publicAssetsDir + "/dwm/bin/dwm-status-right";
    executable = true;
  };
  home.file.".local/bin/dwm-status-wifi" = {
    source = publicAssetsDir + "/dwm/bin/dwm-status-wifi";
    executable = true;
  };
  home.file.".local/lib/dwm-status-lib".source = publicAssetsDir + "/dwm/lib/dwm-status-lib";
  # xsettingsd config is generated per-context by modules/home/graphics.nix,
  # not a static asset.
  # Sourced by ~/.xinitrc before xss-lock. Must exist: if this file is absent,
  # the dash `.`-on-missing-file abort in .xinitrc kills the whole X session.
  xdg.configFile."xsecurelock/env.conf".source = publicAssetsDir + "/xsecurelock/env.conf";
  xdg.configFile."browser/env.sh".source = publicAssetsDir + "/browser/env.sh";
  xdg.configFile."browser/flags.d/defaults.conf".source =
    publicAssetsDir + "/browser/flags.d/defaults.conf";
  xdg.configFile."browser/vulkan/disabled-icd.d/disabled.json".source =
    publicAssetsDir + "/browser/vulkan/disabled-icd.d/disabled.json";
  xdg.configFile."browser/vulkan/disabled-icd.d/README.md".source =
    publicAssetsDir + "/browser/vulkan/disabled-icd.d/README.md";
  xdg.configFile."autorandr/README.md".source = publicAssetsDir + "/autorandr/README.md";
}
