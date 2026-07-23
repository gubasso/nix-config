# Public GnuPG agent config. gpg owns the app-scoped pinentry-program option;
# the cache TTLs are shared. Generating avoids forking the file per host (ADR-0013).
{
  config,
  lib,
  pkgs,
  ...
}:
let
  pinentry = config.my.apps.gpg.pinentry;
in
{
  options.my.apps.gpg.pinentry = lib.mkOption {
    type = lib.types.str;
    default = "/usr/bin/pinentry-kwallet";
    description = "gpg-agent pinentry-program path (app-owned; ADR-0019).";
  };

  config = {
    xdg.configFile."gnupg/gpg-agent.conf".source = pkgs.writeText "gpg-agent.conf" ''
      pinentry-program ${pinentry}
      default-cache-ttl 86400
      max-cache-ttl 604800
    '';
  };
}
