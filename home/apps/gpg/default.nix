# Public GnuPG agent config. The pinentry program is the only per-host value
# (single SoT hostSettings.gpgPinentry, mirroring hostSettings.rofiFont); the
# cache TTLs are shared. Generating avoids forking the file per host (ADR-0013).
{ pkgs, hostSettings, ... }:
let
  pinentry = hostSettings.gpgPinentry or "/usr/bin/pinentry-kwallet";
in
{
  xdg.configFile."gnupg/gpg-agent.conf".source = pkgs.writeText "gpg-agent.conf" ''
    pinentry-program ${pinentry}
    default-cache-ttl 86400
    max-cache-ttl 604800
  '';
}
