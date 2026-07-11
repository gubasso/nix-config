# Desktop base: browsers, compositor/notifier, the dwm X session, and their
# config assets. Asset files come from the consumer's tree via `publicAssetsDir`
# (threaded by lib/mk-host.nix). dwm-session comes from the overlay.
{ pkgs, publicAssetsDir, ... }:

{
  home = {
    packages = with pkgs; [
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

    file = {
      ".xinitrc".source = "${pkgs.dwm-session}/share/dwm-session/xinitrc";
      ".local/share/dwm/autostart.sh" = {
        source = "${pkgs.dwm-session}/share/dwm/autostart.sh";
        executable = true;
      };
      ".local/bin/browser-launcher" = {
        source = publicAssetsDir + "/bin/browser-launcher";
        executable = true;
      };
      ".local/bin/brave-launcher" = {
        source = publicAssetsDir + "/bin/brave-launcher";
        executable = true;
      };
      ".local/bin/kitty-dctl-pair" = {
        source = publicAssetsDir + "/bin/kitty-dctl-pair";
        executable = true;
      };
      ".local/bin/kitty-mode-help" = {
        source = publicAssetsDir + "/bin/kitty-mode-help";
        executable = true;
      };
      ".local/bin/dwm-status-updates" = {
        source = publicAssetsDir + "/dwm/bin/dwm-status-updates";
        executable = true;
      };
      ".local/share/applications/nvim-kitty.desktop".source =
        publicAssetsDir + "/applications/nvim-kitty.desktop";
      ".local/share/applications/brave-browser.desktop".source =
        publicAssetsDir + "/applications/brave/brave-browser.desktop";
      ".local/share/applications/webapp-ai.desktop".source =
        publicAssetsDir + "/applications/brave/webapp-ai.desktop";
      ".local/share/applications/webapp-google.desktop".source =
        publicAssetsDir + "/applications/brave/webapp-google.desktop";
      ".local/share/applications/webapp-social.desktop".source =
        publicAssetsDir + "/applications/brave/webapp-social.desktop";
      # Icons are wired per-file (not as a whole-directory source) so a private
      # consumer can add its own host-specific icons into the same hicolor
      # theme dir — a directory source would be all-or-nothing and block that.
      ".local/share/icons/hicolor/scalable/apps/brave-browser.svg".source =
        publicAssetsDir + "/icons/hicolor/scalable/apps/brave-browser.svg";
      ".local/share/icons/hicolor/scalable/apps/webapp-ai.svg".source =
        publicAssetsDir + "/icons/hicolor/scalable/apps/webapp-ai.svg";
      ".local/share/icons/hicolor/scalable/apps/webapp-google.svg".source =
        publicAssetsDir + "/icons/hicolor/scalable/apps/webapp-google.svg";
      ".local/share/icons/hicolor/scalable/apps/webapp-social.svg".source =
        publicAssetsDir + "/icons/hicolor/scalable/apps/webapp-social.svg";
      ".local/share/brave-unpacked-extensions".source = publicAssetsDir + "/brave-unpacked-extensions";
      ".local/state/rofi/active-theme.rasi".source = publicAssetsDir + "/rofi/themes/everforest.rasi";
      ".npmrc".source = publicAssetsDir + "/npm/npmrc";
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

  programs.autorandr.enable = true;
  # No profiles declared: autorandr matches by EDID fingerprint, which is
  # hardware-specific and only knowable on-metal. Capture with
  # `autorandr --fingerprint` per machine and add profiles in the consumer.

  xdg.configFile = {
    "rofi/config.rasi".source = publicAssetsDir + "/rofi/config.rasi";
    "rofi/rofimoji.rc".source = publicAssetsDir + "/rofi/rofimoji.rc";
    # config.rasi includes `@theme "~/.local/state/rofi/active-theme.rasi"`. Vendor
    # the theme and seed the active-theme state file pointing at it, so a fresh
    # activation has a working theme. Re-point active-theme.rasi to another
    # themes/*.rasi to switch.
    "rofi/themes/everforest.rasi".source = publicAssetsDir + "/rofi/themes/everforest.rasi";
    "rofi/themes/catppuccin-mocha.rasi".source = publicAssetsDir + "/rofi/themes/catppuccin-mocha.rasi";
    "rofi/themes/dracula.rasi".source = publicAssetsDir + "/rofi/themes/dracula.rasi";
    "rofi/themes/purple-city.rasi".source = publicAssetsDir + "/rofi/themes/purple-city.rasi";
    "rofi/themes/tokyonight.rasi".source = publicAssetsDir + "/rofi/themes/tokyonight.rasi";
    "kitty".source = publicAssetsDir + "/kitty";
    "dunst/dunstrc".source = publicAssetsDir + "/dunst/dunstrc";
    "picom/picom.conf".source = publicAssetsDir + "/picom/picom.conf";
    "gammastep/config.ini".source = publicAssetsDir + "/gammastep/config.ini";

    # PipeWire / WirePlumber user drop-ins (generic audio-quality tuning: 48 kHz
    # clock with dynamic rates, no ALSA suspend, higher-quality Bluetooth
    # codecs). Read from ~/.config by native and NixOS PipeWire alike.
    "pipewire/pipewire.conf.d/10-clock-rates.conf".source =
      publicAssetsDir + "/pipewire/pipewire.conf.d/10-clock-rates.conf";
    "wireplumber/wireplumber.conf.d/50-bluez.conf".source =
      publicAssetsDir + "/pipewire/wireplumber.conf.d/50-bluez.conf";
    "wireplumber/wireplumber.conf.d/50-no-suspend.conf".source =
      publicAssetsDir + "/pipewire/wireplumber.conf.d/50-no-suspend.conf";
    "sxhkd/sxhkdrc".source = publicAssetsDir + "/sxhkd/sxhkdrc";
    "dctl/default/devcontainer.json".source = publicAssetsDir + "/dctl/default/devcontainer.json";
    "dctl/devcontainer/agents/devcontainer.json".source =
      publicAssetsDir + "/dctl/devcontainer/agents/devcontainer.json";
    "dctl/devcontainer/agents/seccomp-bwrap.json".source =
      publicAssetsDir + "/dctl/devcontainer/agents/seccomp-bwrap.json";
    "dctl/devcontainer/base/devcontainer.json".source =
      publicAssetsDir + "/dctl/devcontainer/base/devcontainer.json";
    "dctl/devcontainer/bebash.yaml".source = publicAssetsDir + "/dctl/devcontainer/bebash.yaml";
    "dctl/devcontainer/bebash/devcontainer.json".source =
      publicAssetsDir + "/dctl/devcontainer/bebash/devcontainer.json";
    "dctl/devcontainer/claude/devcontainer.json".source =
      publicAssetsDir + "/dctl/devcontainer/claude/devcontainer.json";
    "dctl/devcontainer/codex/devcontainer.json".source =
      publicAssetsDir + "/dctl/devcontainer/codex/devcontainer.json";
    "dctl/devcontainer/cog/devcontainer.json".source =
      publicAssetsDir + "/dctl/devcontainer/cog/devcontainer.json";
    "dctl/devcontainer/dotfiles/devcontainer.json".source =
      publicAssetsDir + "/dctl/devcontainer/dotfiles/devcontainer.json";
    "dctl/devcontainer/gemini/devcontainer.json".source =
      publicAssetsDir + "/dctl/devcontainer/gemini/devcontainer.json";
    "dctl/devcontainer/general.yaml".source = publicAssetsDir + "/dctl/devcontainer/general.yaml";
    "dctl/devcontainer/nix/devcontainer.json".source =
      publicAssetsDir + "/dctl/devcontainer/nix/devcontainer.json";
    "dctl/devcontainer/node-dev.yaml".source = publicAssetsDir + "/dctl/devcontainer/node-dev.yaml";
    "dctl/devcontainer/node-dev/devcontainer.json".source =
      publicAssetsDir + "/dctl/devcontainer/node-dev/devcontainer.json";
    "dctl/devcontainer/opencode/devcontainer.json".source =
      publicAssetsDir + "/dctl/devcontainer/opencode/devcontainer.json";
    "dctl/devcontainer/pre-commit/devcontainer.json".source =
      publicAssetsDir + "/dctl/devcontainer/pre-commit/devcontainer.json";
    "dctl/devcontainer/projects/devcontainer.json".source =
      publicAssetsDir + "/dctl/devcontainer/projects/devcontainer.json";
    "dctl/devcontainer/python-minimal/devcontainer.json".source =
      publicAssetsDir + "/dctl/devcontainer/python-minimal/devcontainer.json";
    "dctl/devcontainer/python.yaml".source = publicAssetsDir + "/dctl/devcontainer/python.yaml";
    "dctl/devcontainer/python/devcontainer.json".source =
      publicAssetsDir + "/dctl/devcontainer/python/devcontainer.json";
    "dctl/devcontainer/riptask.yaml".source = publicAssetsDir + "/dctl/devcontainer/riptask.yaml";
    "dctl/devcontainer/riptask/devcontainer.json".source =
      publicAssetsDir + "/dctl/devcontainer/riptask/devcontainer.json";
    "dctl/devcontainer/rust.yaml".source = publicAssetsDir + "/dctl/devcontainer/rust.yaml";
    "dctl/devcontainer/rust/devcontainer.json".source =
      publicAssetsDir + "/dctl/devcontainer/rust/devcontainer.json";
    "dctl/devcontainer/shell/devcontainer.json".source =
      publicAssetsDir + "/dctl/devcontainer/shell/devcontainer.json";
    "dctl/devcontainer/zig.yaml".source = publicAssetsDir + "/dctl/devcontainer/zig.yaml";
    "dctl/devcontainer/zig/devcontainer.json".source =
      publicAssetsDir + "/dctl/devcontainer/zig/devcontainer.json";
    "dctl/images/agents".source = publicAssetsDir + "/dctl/images/agents";
    "riptask/config.yaml".source = publicAssetsDir + "/riptask/config.yaml";
    "rclone/.rcloneignore".source = publicAssetsDir + "/rclone/rcloneignore";
    "dwm/Xresources".source = publicAssetsDir + "/dwm/Xresources";
    # xsettingsd config is generated per-context by modules/home/graphics.nix,
    # not a static asset.
    # Sourced by ~/.xinitrc before xss-lock. Must exist: if this file is absent,
    # the dash `.`-on-missing-file abort in .xinitrc kills the whole X session.
    "xsecurelock/env.conf".source = publicAssetsDir + "/xsecurelock/env.conf";
    "browser/env.sh".source = publicAssetsDir + "/browser/env.sh";
    "browser/flags.d/defaults.conf".source = publicAssetsDir + "/browser/flags.d/defaults.conf";
    "browser/vulkan/disabled-icd.d/disabled.json".source =
      publicAssetsDir + "/browser/vulkan/disabled-icd.d/disabled.json";
    "browser/vulkan/disabled-icd.d/README.md".source =
      publicAssetsDir + "/browser/vulkan/disabled-icd.d/README.md";
    "autorandr/README.md".source = publicAssetsDir + "/autorandr/README.md";
  };
}
