{
  pkgs,
  lib,
  publicAssetsDir,
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
in
{
  services.xserver = {
    enable = true;

    xkb = {
      layout = "us";
      variant = "altgr-intl";
    };

    displayManager.startx.enable = true;
  };

  environment.etc."vconsole.conf".source = publicAssetsDir + "/system/console-keymap/vconsole.conf";
  environment.etc."X11/xorg.conf.d/00-keyboard.conf".source =
    publicAssetsDir + "/system/console-keymap/X11/xorg.conf.d/00-keyboard.conf";
  environment.etc."X11/xorg.conf.d/30-libinput-pointer.conf".source =
    publicAssetsDir + "/system/xorg-input/X11/xorg.conf.d/30-libinput-pointer.conf";
  environment.etc."X11/xorg.conf.d/35-libinput-trackpoint.conf".source =
    publicAssetsDir + "/system/xorg-input/X11/xorg.conf.d/35-libinput-trackpoint.conf";
  environment.etc."X11/xorg.conf.d/40-libinput-touchpad.conf".source =
    publicAssetsDir + "/system/xorg-input/X11/xorg.conf.d/40-libinput-touchpad.conf";
  environment.etc."udev/rules.d/99-libinput-ignore-touchscreen.rules".source =
    publicAssetsDir + "/system/xorg-input/udev/rules.d/99-libinput-ignore-touchscreen.rules";
  environment.etc."greetd/dotfiles-source-config.toml".source =
    publicAssetsDir + "/system/greetd/config.toml";
  environment.etc."pam.d/greetd.dotfiles-source".source = publicAssetsDir + "/system/greetd/pam-greetd";

  console.keyMap = lib.mkDefault "us";

  services.greetd = {
    enable = true;
    # (greetd is now fixed to VT1 upstream; the old `vt` option was removed.)

    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet -g 'Access is restricted to authorized personnel only.' --time --remember --asterisks --theme 'text=magenta;border=magenta;prompt=magenta;title=magenta;greet=magenta;time=magenta;action=magenta;button=magenta;container=black;input=magenta' --cmd startx";
      user = "greeter";
    };
  };

  security.polkit.enable = true;

  # greetd + kwallet is known-fragile on NixOS because greetd does not
  # substack login. Keep the structured option, but verify the rendered PAM
  # service on a Nix-capable host and fall back to explicit rules if needed.
  security.pam.services.greetd.kwallet = {
    enable = true;
    forceRun = true;
    package = kwalletPam;
  };

  services.dbus.packages = [ kwalletPackage ];

  environment.systemPackages = [
    pkgs.dwm
    # dwm-session carries the X-session scripts (startdwm, dwm-*, dock-audio,
    # autostart.sh). Install system-wide so startdwm and the helpers are on
    # /run/current-system/sw/bin -- i.e. on EVERY session PATH, including the
    # greetd `--cmd startx` session, which does not reliably pick up the
    # per-user profile (/etc/profiles/per-user/<user>/bin). A per-user-only
    # install left `exec startdwm` as command-not-found, so X exited at once
    # and greetd looped.
    pkgs.dwm-session

    # Terminal: kitty. Launcher: rofi.
    pkgs.kitty
    pkgs.rofi

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
}
