{
  pkgs,
  lib,
  ...
}:

let
  kwalletPackage = lib.attrByPath [ "kdePackages" "kwallet" ] (lib.attrByPath [
    "libsForQt5"
    "kwallet"
  ] (throw "No kwallet package found in nixpkgs") pkgs) pkgs;
  kwalletPam = lib.attrByPath [ "kdePackages" "kwallet-pam" ] (lib.attrByPath [
    "libsForQt5"
    "kwallet-pam"
  ] (throw "No kwallet-pam package found in nixpkgs") pkgs) pkgs;

  # Re-arm xsecurelock and wake the display immediately after resume. Ported
  # from the old ~/.dotfiles system-sleep hook (Arch /usr/lib/systemd/
  # system-sleep). systemd runs system-sleep scripts as root with a minimal
  # PATH, so the tools are pinned here; `su` needs the setuid wrapper, hence
  # /run/wrappers/bin. USR2 alone doesn't reset DPMS, so we also force dpms on.
  # NB: verify on-host (orion/lyra) -- cannot be activated from a non-NixOS host.
  xsecurelockSleepHook = pkgs.writeShellScript "xsecurelock-sleep" ''
    export PATH=${
      lib.makeBinPath [
        pkgs.procps
        pkgs.xset
        pkgs.coreutils
        pkgs.gnused
        pkgs.shadow
      ]
    }:/run/wrappers/bin:$PATH
    if [ "$1" = "post" ]; then
      pid=$(pgrep -x xsecurelock | head -1)
      if [ -n "$pid" ]; then
        user=$(stat -c %U "/proc/$pid")
        display=$(tr '\0' '\n' <"/proc/$pid/environ" 2>/dev/null | sed -n 's/^DISPLAY=//p')
        xauth=$(tr '\0' '\n' <"/proc/$pid/environ" 2>/dev/null | sed -n 's/^XAUTHORITY=//p')

        kill -USR2 "$pid"

        # Wake display from DPMS (USR2 doesn't reset DPMS).
        if [ -n "$display" ]; then
          xset_env="DISPLAY=$display"
          [ -n "$xauth" ] && xset_env="$xset_env XAUTHORITY=$xauth"
          su "$user" -c "$xset_env xset dpms force on" 2>/dev/null || true
        fi
      fi
    fi
    exit 0
  '';
in
{
  services = {
    xserver = {
      enable = true;

      xkb = {
        layout = "us";
        variant = "altgr-intl";
        # Keyboard config is declared here as the single source of truth; nixpkgs
        # renders /etc/X11/xorg.conf.d/00-keyboard.conf from these xkb settings
        # (services/misc/graphical-desktop.nix). caps:swapescape was previously
        # shipped as a static 00-keyboard.conf, which now collides with that
        # generated file — hence the move to the declarative option.
        options = "caps:swapescape";
      };

      displayManager.startx.enable = true;
    };

    greetd = {
      enable = true;
      # (greetd is now fixed to VT1 upstream; the old `vt` option was removed.)

      settings.default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet -g 'Access is restricted to authorized personnel only.' --time --remember --asterisks --theme 'text=magenta;border=magenta;prompt=magenta;title=magenta;greet=magenta;time=magenta;action=magenta;button=magenta;container=black;input=magenta' --cmd startx";
        user = "greeter";
      };
    };

    dbus.packages = [ kwalletPackage ];
  };

  console.keyMap = lib.mkDefault "us";

  security = {
    polkit.enable = true;

    # greetd + kwallet is known-fragile on NixOS because greetd does not
    # substack login. Keep the structured option, but verify the rendered PAM
    # service on a Nix-capable host and fall back to explicit rules if needed.
    pam.services.greetd.kwallet = {
      enable = true;
      forceRun = true;
      package = kwalletPam;
    };
  };

  environment = {
    etc = {
      # Ship a curated vconsole.conf (KEYMAP=us-altgr-intl-nodeadkeys, FONT=ter-v32b).
      # nixpkgs' console module now also renders /etc/vconsole.conf from
      # console.keyMap/console.font (config/console.nix), so force ours to win.
      # We keep the static file rather than going through console.keyMap because
      # `us-altgr-intl-nodeadkeys` is an X-layout variant, not a kbd console keymap,
      # and console.keyMap is validated by `loadkeys` at build time.
      "vconsole.conf".source = lib.mkForce ./console-keymap/vconsole.conf;
      "X11/xorg.conf.d/30-libinput-pointer.conf".source =
        ./xorg-input/X11/xorg.conf.d/30-libinput-pointer.conf;
      "X11/xorg.conf.d/35-libinput-trackpoint.conf".source =
        ./xorg-input/X11/xorg.conf.d/35-libinput-trackpoint.conf;
      "X11/xorg.conf.d/40-libinput-touchpad.conf".source =
        ./xorg-input/X11/xorg.conf.d/40-libinput-touchpad.conf;
      "udev/rules.d/99-libinput-ignore-touchscreen.rules".source =
        ./xorg-input/udev/rules.d/99-libinput-ignore-touchscreen.rules;
      "greetd/dotfiles-source-config.toml".source = ./greetd/config.toml;
      "pam.d/greetd.dotfiles-source".source = ./greetd/pam-greetd;

      # Lock/resume hook: re-arm xsecurelock + wake DPMS on resume (see the
      # xsecurelockSleepHook binding above). Mode forces an executable copy so
      # systemd-sleep can run it.
      "systemd/system-sleep/xsecurelock" = {
        source = xsecurelockSleepHook;
        mode = "0755";
      };
    };

    systemPackages = [
      pkgs.dwm
      # dwm-session carries the X-session scripts (startdwm, dwm-*, dock-audio,
      # autostart.sh). Install system-wide so startdwm and the helpers are on
      # /run/current-system/sw/bin -- i.e. on EVERY session PATH, including the
      # greetd `--cmd startx` session, which does not reliably pick up the
      # per-user profile (/etc/profiles/per-user/<user>/bin). A per-user-only
      # install left `exec startdwm` as command-not-found, so X exited at once
      # and greetd looped.
      pkgs.dwm-session

      # Terminal: kitty. (Launcher rofi is owned by Home Manager's programs.rofi.)
      pkgs.kitty

      pkgs.xinit
      pkgs.xsetroot
      pkgs.xset
      pkgs.xprop
      pkgs.xrdb
      pkgs.xmodmap
      pkgs.xsecurelock
      pkgs.xss-lock
      pkgs.xsettingsd
      pkgs.gammastep
      pkgs.xbanish
      pkgs.nextcloud-client
      pkgs.keepassxc
      pkgs.polkit_gnome
      pkgs.sxhkd
      pkgs.iw
      pkgs.pulseaudio
      pkgs.dbus
      pkgs.procps
      pkgs.coreutils
      pkgs.systemd
      kwalletPackage
      kwalletPam
    ];
  };
}
