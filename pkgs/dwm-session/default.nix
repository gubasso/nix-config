{ pkgs }:

let
  inherit (pkgs) lib;
  kwalletPam = lib.attrByPath [ "kdePackages" "kwallet-pam" ] (lib.attrByPath [
    "libsForQt5"
    "kwallet-pam"
  ] (throw "No kwallet-pam package found in nixpkgs") pkgs) pkgs;

  pamKwalletInit = "${kwalletPam}/libexec/pam_kwallet_init";
  xsecurelockDimmer = "${pkgs.xsecurelock}/libexec/xsecurelock/dimmer";
  polkitAgent = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "dwm-session";
  version = "0";
  # Host-neutral dwm X-session scripts, shared by every host that runs the dwm
  # desktop.
  src = ../../session;

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -d "$out/share/dwm-session"
    install -d "$out/share/dwm"
    install -Dm0755 startdwm "$out/bin/startdwm"
    install -Dm0755 autostart.sh "$out/bin/autostart.sh"
    install -m0755 autostart.sh "$out/share/dwm/autostart.sh"
    install -Dm0755 dwm-center-clock "$out/bin/dwm-center-clock"
    install -Dm0755 dock-audio "$out/bin/dock-audio"
    install -Dm0755 dwm-status-lib "$out/lib/dwm-status-lib"

    for script in dwm-status-right dwm-status-wifi dwm-status-battery; do
      substitute "$script" "$out/bin/$script" \
        --replace-fail "@dwmStatusLib@" "$out/lib/dwm-status-lib"
      chmod 0755 "$out/bin/$script"
    done

    substitute xinitrc "$out/share/dwm-session/xinitrc" \
      --replace-fail "@pamKwalletInit@" "${pamKwalletInit}" \
      --replace-fail "@xsecurelockDimmer@" "${xsecurelockDimmer}" \
      --replace-fail "@polkitAgent@" "${polkitAgent}"
    chmod 0755 "$out/share/dwm-session/xinitrc"

    patchShebangs "$out/bin" "$out/share/dwm-session/xinitrc" "$out/share/dwm/autostart.sh"

    runHook postInstall
  '';
}
