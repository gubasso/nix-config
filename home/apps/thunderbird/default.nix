# thunderbird: Mozilla email/calendar client. Package only — accounts/config TBD.
{ pkgs, config, ... }:

{
  home.packages = [ (config.lib.nixGL.wrap pkgs.thunderbird) ];
}
