# Cross-desktop GUI applications and their config. Loaded on every host with a
# graphical session, independent of the window manager / desktop environment.
# GL-accelerated apps are wrapped with nixGL (identity on NixOS, real wrapper on
# generic-Linux hosts via modules/home/generic-linux.nix). Asset files come from
# the consumer's tree via `publicAssetsDir`.
{
  pkgs,
  config,
  publicAssetsDir,
  ...
}:

{
  home.packages =
    # GL-accelerated apps: wrapped so they use the host GPU drivers on non-NixOS
    # hosts. `config.lib.nixGL.wrap` is a no-op where nixGL is unconfigured.
    map (p: config.lib.nixGL.wrap p) (
      with pkgs;
      [
        kitty
        brave
        librewolf
        thunderbird
      ]
    )
    ++ (with pkgs; [
      feh
      autorandr
      fontconfig
      liberation_ttf
      nerd-fonts.hack
      # devcontainer CLI (@devcontainers/cli): runtime dependency of the dctl
      # workflow whose assets are wired below.
      devcontainer
    ]);

  home.file = {
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

    # rofi's config.rasi includes `@theme "~/.local/state/rofi/active-theme.rasi"`.
    # Seed the active-theme state file pointing at a vendored theme so a fresh
    # activation has a working theme. Re-point it to another themes/*.rasi to switch.
    ".local/state/rofi/active-theme.rasi".source = publicAssetsDir + "/rofi/themes/everforest.rasi";

    # kitty.conf includes `~/.local/state/kitty/active-theme.conf`. Seed it (same
    # pattern as rofi above) so a fresh activation has a valid theme include and
    # kitty starts clean. Re-point to another kitty/theme-*.conf to switch.
    ".local/state/kitty/active-theme.conf".source =
      publicAssetsDir + "/kitty/theme-everforest-dark-hard.conf";
  };

  programs.autorandr.enable = true;
  # No profiles declared: autorandr matches by EDID fingerprint, which is
  # hardware-specific and only knowable on-metal. Capture with
  # `autorandr --fingerprint` per machine and add profiles in the consumer.

  xdg.configFile = {
    "rofi/config.rasi".source = publicAssetsDir + "/rofi/config.rasi";
    "rofi/rofimoji.rc".source = publicAssetsDir + "/rofi/rofimoji.rc";
    "rofi/themes/everforest.rasi".source = publicAssetsDir + "/rofi/themes/everforest.rasi";
    "rofi/themes/catppuccin-mocha.rasi".source = publicAssetsDir + "/rofi/themes/catppuccin-mocha.rasi";
    "rofi/themes/dracula.rasi".source = publicAssetsDir + "/rofi/themes/dracula.rasi";
    "rofi/themes/purple-city.rasi".source = publicAssetsDir + "/rofi/themes/purple-city.rasi";
    "rofi/themes/tokyonight.rasi".source = publicAssetsDir + "/rofi/themes/tokyonight.rasi";
    "kitty".source = publicAssetsDir + "/kitty";

    # PipeWire / WirePlumber user drop-ins (generic audio-quality tuning: 48 kHz
    # clock with dynamic rates, no ALSA suspend, higher-quality Bluetooth
    # codecs). Read from ~/.config by native and NixOS PipeWire alike.
    "pipewire/pipewire.conf.d/10-clock-rates.conf".source =
      publicAssetsDir + "/pipewire/pipewire.conf.d/10-clock-rates.conf";
    "wireplumber/wireplumber.conf.d/50-bluez.conf".source =
      publicAssetsDir + "/pipewire/wireplumber.conf.d/50-bluez.conf";
    "wireplumber/wireplumber.conf.d/50-no-suspend.conf".source =
      publicAssetsDir + "/pipewire/wireplumber.conf.d/50-no-suspend.conf";
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
    "dctl/devcontainer/editor/devcontainer.json".source =
      publicAssetsDir + "/dctl/devcontainer/editor/devcontainer.json";
    "dctl/devcontainer/gcloud/devcontainer.json".source =
      publicAssetsDir + "/dctl/devcontainer/gcloud/devcontainer.json";
    "dctl/devcontainer/kitty/devcontainer.json".source =
      publicAssetsDir + "/dctl/devcontainer/kitty/devcontainer.json";
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
    # NB: riptask/config.yaml is deliberately NOT managed here. It is the User
    # layer of riptask's config hierarchy, and `tsk config set`/`edit` rewrite it
    # at runtime (serde_yaml_ng serialize → tempfile → atomic rename), which would
    # clobber a read-only /nix/store symlink and lose comments/ordering — the same
    # runtime-state anti-pattern as dctl/projects.yaml. riptask owns the live file.
    "rclone/.rcloneignore".source = publicAssetsDir + "/rclone/rcloneignore";
    "browser/env.sh".source = publicAssetsDir + "/browser/env.sh";
    "browser/flags.d/defaults.conf".source = publicAssetsDir + "/browser/flags.d/defaults.conf";
    "browser/vulkan/disabled-icd.d/disabled.json".source =
      publicAssetsDir + "/browser/vulkan/disabled-icd.d/disabled.json";
    "browser/vulkan/disabled-icd.d/README.md".source =
      publicAssetsDir + "/browser/vulkan/disabled-icd.d/README.md";
    "autorandr/README.md".source = publicAssetsDir + "/autorandr/README.md";
  };
}
