# Public claude-session base config tree.
{ lib, pkgs, ... }:

{
  xdg.configFile."claude-session".source = lib.mkDefault (
    pkgs.mkRealConfigDir "claude-session" ./config null
  );
}
